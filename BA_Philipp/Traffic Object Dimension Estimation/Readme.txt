Scripts "main_application_model_3_4" and "main_application_model_2" are for running traffic object dimension estimation using respective model.
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



Paths in scripts may have to be adjusted before running

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