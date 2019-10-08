#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 28 15:44:08 2019

@author: matthiasboeker
"""

#KNN classifier
synthlab = df_dl[df_dl['label'] == 1]
synth = df_dl.append(synthlab)
for i in range(0,2):
    synth = synth.append(synthlab)

X = synth['signal']
y = synth['label']

X = X.values.reshape(-1, 1)
y = y.values.reshape(-1, 1)

#Split up train and test dataset 
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X,y, test_size = 0.5, shuffle = True)



#Fitting classifier to training dataset 
#Create classifier
from sklearn.neighbors import KNeighborsClassifier
classifier = KNeighborsClassifier(n_neighbors = 2, metric = 'minkowski', p = 2)
classifier.fit(X_train,y_train)

#Predict results
1y_pred = classifier.predict(X_test)


from sklearn.metrics import accuracy_score
accuracy_score(y_test, y_pred)

from sklearn.metrics import confusion_matrix
cn = confusion_matrix(y_test,y_pred)
