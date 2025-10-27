using FourierFlows, Random, Plots
using LinearAlgebra: mul!, ldiv!
using DelimitedFiles
using CUDA

include("generating_funcs.jl")

# This example corresponds to a striped pattern generator. For different patterns one would change the 
# range of w and the initial condition/folder (remember that more complex patterns such as hexagons require
# much more time, ideally one would start with an initial condition already formed and perform a sweep of omega)

# Setting the parameters
dev = GPU()

# Numerical parameters and time-stepping parameters
nx = 256                # grid resolution
ny = 256                # grid resolution
stepper = "ETDRK4"      # timestepper
dt = 1e-4               # timestep (s)
nsteps = 120            # total number of time-steps
nsub = 10000            # writing step

# Physical parameters
Lx = 40           # Domain length (m)
Ly = 40           # Domain length (m)
w  = 0.42         # Local net death rate in the linear regime
a = 1.39          # facilitative interaction
b = 1.0           # competitive interaction
epsilon = 1.15e-2 # diffusion constant
alpha = -1.78     # interaction parameters to ensure existence of bare soil solution and positive density
delta = 1.03e-2   # effect of clonal grwoth by rhizome elongation
beta = -1.0       # interaction parameters to ensure existence of bare soil solution and positive density

IC = stable_sol(w, a, b)
gamma = - beta * abs(IC)

# Loop

for i = 1:150
    grid = TwoDGrid(dev; nx=nx,ny=ny, Lx=Lx,Ly=Ly,aliased_fraction=0)

    params = Params(w, a, b, epsilon, alpha, delta, beta, gamma)
    vars = Vars(grid)
    equation = Equation(params, grid)

    prob = FourierFlows.Problem(equation, stepper, dt, grid, vars, params)

    n0 = ones((grid.nx, grid.ny)) * IC + randn((grid.nx, grid.ny))*0.1

    set_n!(prob, n0)

    last_result = 0

    @time for j = 0:nsteps 

        updatevars!(prob)
        stepforward!(prob, nsub)
        
        nmax = maximum(prob.vars.n)
        println(j, "\t", prob.clock.t, "\t", nmax)

        if isnan(nmax)
            print("Exception: NaN")
            break
        end

        last_result = Array(prob.vars.n)
    end

    # Saving results as a txt
    result_save = reduce(vcat, last_result)

    f = open("patterns/stripes/stripes_$i.txt", "w")

    write(f, "# shape=($nx, $ny)\n")
    writedlm(f, result_save)

    close(f)

end
