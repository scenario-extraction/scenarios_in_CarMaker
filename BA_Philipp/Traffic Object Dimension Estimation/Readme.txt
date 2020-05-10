Structure of this Readme file:
1. General Information
2. Information specific to "Traffic Object Dimension Estimation":


====================


General information:


Version: 8th May 2020

Dear user,

instead of creating one large "Readme" file I decided to use a decentralised approach where I document each folder's, script's or function's purpose at their own
location.
For this purpose I created multiple text files called "Readme" or "Remark" which explain how to use the respective elements. 
Furthermore I added detailed documentations and comments in the respective Matlab scripts and functions.

If questions arrise, please feel free to contact me via email: Philippmetzger2@gmail.com

I used as little absolute paths as possible and used relative paths instead, so most scripts and functions will still run properly, if this folder structure is kept 
intact, even when it is moved to a new location.
Yet, some paths in some scripts or functions may have to be adjusted before running.

"Traffic Object Dimension Estimation" and "Traffic Sign Recognition" can be regarded as independent packages. They do not reference to each other in any way and can
be moved to different locations independently.

For creating and running this code I had the following installed:
MATLAB                                                Version 9.7         (R2019b)
Simulink                                              Version 10.0        (R2019b)
Automated Driving Toolbox                             Version 3.0         (R2019b)
Computer Vision Toolbox                               Version 9.1         (R2019b)
Deep Learning Toolbox                                 Version 13.0        (R2019b)
Image Processing Toolbox                              Version 11.0        (R2019b)
Optimization Toolbox                                  Version 8.4         (R2019b)
Parallel Computing Toolbox                            Version 7.1         (R2019b)
Statistics and Machine Learning Toolbox               Version 11.6        (R2019b)
Symbolic Math Toolbox                                 Version 8.4         (R2019b)


====================


Information specific to "Traffic Object Dimension Estimation":

General remark:
In the scripts and functions of this implementation, the parameters that I call f, f_width and f_height in my thesis are called "c", "c_width" and "c_height".

Scripts "main_application_model_3_4" and "main_application_model_2" are for running traffic object dimension estimation using respective model.
Model 3 and 4 are equivalent and refer to the model with one parameter f (called "c" in the script). 
Model 2 refers to the model with two parameters f_width and f_height (called "c_width" and "c_height" in the script).
All data needed for running these two scripts is located in "Data Application".
Dimension estimation results are stored in "Resuslts Application".

"main_training" is for training the models.
"Data Training" contains all data needed for training.
Training results are stored in "Results Training". "main_application_model_3_4" and "main_application_model_2" load these results automatically.

"create_training_dataset" is for creating the dataset used for training the models.
"Data Training Set Generation" contains all data needed for training set generation.
The main purpose of "create_training_dataset_rcnn" was to see if a CNN provided by matlab would be a better choice than our ACF detector (which it isn't).

"appl_model_3_4_as_function" and "run_appl_fct" are for searching for good parameters that are used in "main_application_model_3_4" and "main_application_model_2".

"read_DAT_file" is used by some scripts to read ground truth data.