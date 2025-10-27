# PosidoniaPatternFormation
This repository contains all the code used in the development of my Master's Thesis: ["Monitoring the Resilience of Seagrass Meadows from Satellite Meadows from Satellite Imagery Using Machine Learning"](https://ifisc.uib-csic.es/es/publications/monitoring-the-resilience-of-seagrass-meadows-from/). 

## Introduction
Seagrass meadows, found in coastal marine ecosystems worldwide, play a vital role in enhancing coastal biodiversity. They act as carbon sinks, protect coastlines from erosion, and improve water clarity through particle sedimentation. Unfortunately, the global seagrass extent has suffered significant losses, with approximately one third already vanished, primarily due to eutrophication, water quality deterioration, habitat destruction, overfishing, and climate change. 

In the thesis, we proposed to evaluate the health status of *Posidonia oceanica* habitats in the Balearic Islands from their spatial patterns. We used deep learning models based on Convolutional Neural Networks (CNNs) to separate the different classes of *P. oceanica* patterns and predict their mortality. For this purpose, a code has been developed from scratch to generate patterns according to a mathematical model capable of reproducing the behaviour of the species. This repository gathers the full code used for every step of the thesis from the pattern generation, its analysis, and, finally, the application to empirical data of the coasts of the Balearic Islands.

The general model used for generating the images is extracted from the original paper by D. Ruiz-Reynés, F. Schönsberg, E. Hernández-García, and D. Gomila [1]. For more information about the theoretical and practical knowledge necessary for the creation and analysis of said patterns such as the method of solving the problem and the initial conditions used the thesis is available on the [following link](https://ifisc.uib-csic.es/en/publications/monitoring-the-resilience-of-seagrass-meadows-from/).  


[1] D. Ruiz-Reynés, F. Schönsberg, E. Hernández-García, and D. Gomila, “General model
for vegetation patterns including rhizome growth”, [Physical Review Research 2, 023402
(2020)](https://link.aps.org/doi/10.1103/PhysRevResearch.2.023402)

## Contents
+ **pattern_generation**: A first folder containing the code for the pattern generation
  - **generating_funcs.jl**: Julia utility file with the basic functions where the model is included.
  - **generating_example_notebook.ipynb**: Julia notebook with an example of a pattern generation, plus some images of our own.
  - **requirements_and_recommendations.md**: Some written requirements and recommendations useful when using the code.
  - **pattern_generator.jl**: an example on how to run a big pattern generation of striped patterns.
  
+ **pattern_analysis**
  - **data_preprocess.ipynb**: Python notebook with examples on the data augmentation and thresholding went.
  - **X_model_training.py**: Python codes on how the best models were trained for the different problems.
+ **pattern_predictions**
  - **pollenca_predict.ipynb**: Python notebook of the example of the predictions of Pollença.
