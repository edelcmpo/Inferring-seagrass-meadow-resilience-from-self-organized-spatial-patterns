The developed Julia code is fairly simple at first glance. However there are some aspects to take into consideration when using it at a long scale project such as the generation of a big number of patterns.

#### REQUIREMENTS:
+ Julia 1.9.3
+ One must have the necessary packages installed:
    - FourierFlows, Random, Plots and LinearAlgebra for the solving
    - DelimitedFiles in order to be able to save the resulting patterns
    - CUDA if you want to run on GPU

#### RECOMMENDATIONS:
+ The code takes a loong time to run. It is strongly recommended to use GPU to speed up the process.
+ In the notebook the example has a grid of nx=ny=128 points and Lx=Ly=20 m. When using GPU, you can increase the size considerably so you can find more stripes/dots of the pattern in your image (for me, it worked fine with a grid of nx=ny=256 and Lx=Ly=40m)
+ If you want to adapt the code for other equation, keep in mind how you have to adapt each term in the Fourier space in the concerning function. In our case it was necessary to add an additional term governed by gamma so that the code wouldnt collapse (more details on this on the written thesis).
