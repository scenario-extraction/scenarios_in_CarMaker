
# Signal Selection for multivariate DTW  

The goal of the project is the selection of appropriate signals for the detecting lane changes of object vehicles on the road, using the multivariate DTW.


## Method

The ego vehicle records many signals. The idea is to break down the amount of signals to a few relevant signals which are capable of describing the lane change of the object best.\
The signals were clustered according to their linear similarity (Pearson-Correlation). To achieve linear independency, out of each cluster one signal is selected.\
To select the signal containing the most information out of one cluster, a score was developed. The score filters signals with repetitive patterns. These signals are assumed to contain the most information about lane changes of the object vehicle.\
The score is the ration of the variance of the signal and the natural logarithm of the approximate entropy of the signal.
The signals with the minimal score within one cluster are chosen for the multivariate DTW.

## Process

1. Load in data
2. Calculation of the approximate entropy and variance
3. Calculation of the score
4. Data cleansing
5. Cluster analysis
6. Selection of signals with the minimal score within one cluster
7. Extraction of reference signals
8. Application of multivariate DTW


## Running the code

The used data is given in the repository: **Data**\
All the needed scripts can be found in the repository: **Scripts**\
The file **main.py** will run and import all the necessary scripts and modules.
Stick closely to the advice given in **main.py**.\
The evaluation of the DTW results is not a unified, self-contained process and should be adapt to the users needs.\
The results of the DTW are stored in 4 lists for each scenario. Each containing 20 dataframes with the DTW costs of each signal. \
These cost can latter be individually accumulated (simple sum, weighted sum, linear model) to achieve the final DTW cost series.
The results are broken down to every single signal so that no information is lost due to cumulation of DTW results. 

Please do not change the order of the repository!
