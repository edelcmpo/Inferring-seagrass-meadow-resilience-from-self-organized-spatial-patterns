using FourierFlows, Random, Plots
using LinearAlgebra: mul!, ldiv!
using DelimitedFiles
using CUDA

# Define useful structures and functions
struct Params{T} <: AbstractParams
    w :: T         
    a :: T      
    b :: T         
    epsilon :: T         
    alpha :: T  
    delta :: T 
    beta :: T  
    gamma :: T      
 end

 struct Vars{Aphys, Atrans} <: AbstractVars
    n :: Aphys         # flow field in physical space
    gradx :: Aphys     # velocity in x in physical space (derivada de n en x)
    grady :: Aphys     # velocity in y in physical space (derivada de n en x)
    lapla :: Aphys     # laplacian of n in physical space (nabla cuadrado)
    nabla4 :: Aphys    # nabla^4(n)
    nh :: Atrans       # fourier transform of the field
    gradxh :: Atrans   # fourier transform of velocity in x
    gradyh :: Atrans   # fourier transform of velocity in x
    laplah :: Atrans   # fourier transform of the laplacian
    nabla4h :: Atrans  # fourier transform of nabla^4(n)
 end

function Vars(grid)
    """
    Construct the `Vars` for 2D linear dynamics based on the dimensions of the `grid` arrays.
    """
    Dev = typeof(grid.device)
    T = eltype(grid)
  
    @devzeros Dev T (grid.nx,grid.ny) n realNn gradx grady lapla nabla4
    @devzeros Dev Complex{T} (grid.nkr , grid.nl) nh gradxh gradyh laplah nabla4h
  
    return Vars(n, gradx, grady, lapla, nabla4, nh, gradxh, gradyh, laplah, nabla4h)
end

function calcN!(N, sol, t, clock, vars, params, grid)
    """
    Compute the nonlinear terms for 2D linear dynamics.
    """
    @. vars.nh = sol
    @. vars.gradxh = im * grid.kr * vars.nh
    @. vars.gradyh = im * grid.l * vars.nh
    @. vars.laplah = - (grid.kr^2 + grid.l^2) * vars.nh
    @. vars.nabla4h = (grid.kr^2 + grid.l^2)^2 * vars.nh

    ldiv!(vars.n, grid.rfftplan, vars.nh) #Deshacemos transformada de fourier nh
    ldiv!(vars.gradx, grid.rfftplan, vars.gradxh)
    ldiv!(vars.grady, grid.rfftplan, vars.gradyh)
    ldiv!(vars.lapla, grid.rfftplan, vars.laplah)
    ldiv!(vars.nabla4, grid.rfftplan, vars.nabla4h)
    
    @. vars.lapla *= vars.n                                          # lapla(n) * n
    mul!(vars.laplah, grid.rfftplan, vars.lapla)                        # \hat{lapla(n) * n}

    @. vars.gradx = vars.gradx^2 + vars.grady^2                             # ||grad||^2
    mul!(vars.gradxh, grid.rfftplan, vars.gradx )                              # \hat{||grad||^2}

    @. vars.nabla4 *= (vars.n + params.gamma/params.beta)            # nabla4(n) * n. We add the gamma correction
    mul!(vars.nabla4h, grid.rfftplan, vars.nabla4)                      # \hat{nabla4(n) * n}

    RealN = @. params.a * vars.n * vars.n - params.b * vars.n * vars.n * vars.n  # Local non-linear part

    N .= grid.rfftplan *RealN                               # Local non-linear part
    
    @. N += params.alpha * vars.laplah + params.delta * vars.gradxh + params.beta * vars.nabla4h 

    return nothing
end

function Equation(params::Params, grid::AbstractGrid)
    """
    Construct the equation: now including the linear part, 
    and the nonlinear part, which is computed by `calcN!` function.
    """
    T = eltype(grid)
    dev = grid.device

    L = zeros(dev, T, (grid.nkr, grid.nl))
    D = @. -grid.kr^2 - grid.l^2
    P = @. (grid.kr^2 + grid.l^2)^2

    L .= params.epsilon .* D .- params.w .- params.gamma .* P  # for n equation (linear part, we dont need to add the n)

    return FourierFlows.Equation(L, calcN!, grid)
end

function updatevars!(prob)
    """
    Update the variables in `prob.vars` using the solution in `prob.sol`.
    """
    #dealias!(sol, grid) # Soy un poco negacionista del dealiasing en general, si se quiere se puede descomentar

    vars, grid, sol = prob.vars, prob.grid, prob.sol # He puesto estoa qui xq es lo que yo suelo hacer

    ldiv!(vars.n, grid.rfftplan, deepcopy(sol)) # use deepcopy() because irfft destroys its input

    mul!(vars.nh, grid.rfftplan, deepcopy(vars.n))

    sol .= vars.nh

    return nothing
end

function set_n!(prob, n0)
    """
    Set the state variable `prob.sol` as the Fourier transforms of n0
    and update all variables in `prob.vars`.
    """
    sol, vars, params, grid = prob.sol, prob.vars, prob.params, prob.grid

    A = typeof(vars.n) # determine the type of vars.n

    # below, e.g., A(n0) converts n0 to the same type as vars expects
    # (useful when n0 is a CPU array but grid.device is GPU)
    mul!(vars.nh, grid.rfftplan, A(n0))

    @. sol = vars.nh

    updatevars!(prob)

    return nothing
end
