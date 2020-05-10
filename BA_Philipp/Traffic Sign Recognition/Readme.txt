Structure of this Readme file:
1. General Information
2. Information specific to "Traffic Sign Recognition":


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


Information specific to "Traffic Sign Recognition":


For running traffic sign detection and recognition, run "main_ts_detection_and_recognition"

"001 Data" contains all data needed for running any script or function in this project

When running "main_ts_detection_and_recognition" four files with intermediate results will be created and saved here. 
Their names begin with "tsdr_..."

The purpose of "run_main_ts_detection_and_recognition_as_fct" and "main_ts_detection_and_recognition_as_fct" is to find a good value for "delay" which is a variable
used in "main_ts_detection_and_recognition"