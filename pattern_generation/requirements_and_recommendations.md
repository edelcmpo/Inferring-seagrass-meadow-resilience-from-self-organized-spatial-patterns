The developed Julia code is fairly simple at first glance. However there are some aspects to take into consideration when using it at a long scale project such as the generation of a big number of patterns.

#### REQUIREMENTS:
+ Julia 1.9.3
+ One must have the necessary packages installed:
    - FourierFlows, Random, Plots and LinearAlgebra for the solving
    - DelimitedFiles in order to be able to save the resulting patterns
    - CUDA if you want to run on GPU

#### RECOMMENDATIONS:
+ The code takes a loong time to run. It is strongly recommended to use GPU to speed up the process.
+ In the notebook the example has a grid of nx=ny=128 points and Lx=Ly=20 m. When using GPU, you can increase the size considerably so you can find more stripes/dots of the pattern in your image (for me, it worked fine with a grid of nx=ny=256 and Lx=Ly=40m). You can have fun trying different configurations of the grid and time resolution by changing the settings of the notebook.
+ If you want to adapt the code for other equation, keep in mind how you have to work with each term in the Fourier space in the concerning function. In our case it was necessary to add (and substract) an additional term governed by gamma so that the code wouldnt collapse (more details on this on the written thesis).
+ When working with more complex patterns than the homogeneous meadow, a great way to also reduce the runing time in large generations is to use previous patterns as initial conditions when changing a parameter such as the mortality. This is a recommendation for striped patterns, but basically a requirement for hexagonal (filled or empty) ones as they tend to need much more computing time.
