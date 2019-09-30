Thema:Implementation and Evaluation of Methods for Time Series Analysis and Scenar-io Classification from Vehicle data


Abstract
In order to be able to ensure the functional safety of functions of automated driving, tremendous efforts are made in development and testing in order to achieve the required test coverage. The identification of the relevant test cases represents a major challenge. Efficient approaches com-bine simulation methods with records from real data in order to identify and classify the required test cases on the basis of real data and then transfer them to the simulation for utilization.

Within the scope of this thesis, a classification procedure for the driving maneuvers on the high-way is to be developed, which has the goal to reduce the test effort for functions of the automated driving.

To achieve this goal, the following sub-steps are planned:
-	familiarization with the topic by researching the state of the art and knowledge,
-	Identification of suitable classification methods
-	Development, implementation, and evaluation of different approaches to the analysis of time series from simulation (CarMaker) and possibly real data to derive scenes or scenari-os
-	Development of a framework for the categorization of the data (for example by means of machine learning methods, decision trees, etc.)

In this work, a concept for the classification algorithms of scenarios was developed and imple-mented. For this purpose, six atomic driving maneuvers in the transverse direction and longitudi-nal direction were defined as an example in the first step. Based on the definitions, time series variables were derived, which can annotate the respective scenario. As a basic methodology, four time series classification algorithms were introduced. Using these methods, the variables were compared and classified via the driving maneuvers.

In the second step, the simulation software CarMaker simulated 100 kilometers and thus 331,700 scenes (100 Hz). For each scene, the previously derived variables, so-called signal data, and a Label, defined as Ground Truth Label, were generated.

In the final step, the implementation of the similarity comparison between signal data and refer-ence signal was made using the four classification algorithms. The classification result was evalu-ated by means of ground truth label from quantity quality and quality grade.
