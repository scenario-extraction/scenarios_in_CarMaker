#!/usr/bin/env python
# coding: utf-8

# # Reduced Daten
# 
# 

# In[1]:


from sklearn.manifold import TSNE
import numpy as np
import matplotlib.pyplot as plt


# In[2]:


#load the data matrics
matrix_2st=np.loadtxt('matrix.txt')
print('2 state scenario matrics has the shape:',matrix_2st.shape)
matrix_3st=np.loadtxt('matrix_3st.txt')
print('3 state scenario matrics has the shape:',matrix_3st.shape)
matrix_4st=np.loadtxt('matrix_4st.txt')
print('4 state scenario matrics has the shape:',matrix_4st.shape)


# In[3]:


tsne = TSNE(n_components = 2)
print(len(matrix_2st))
unique2 = np.unique(matrix_2st,axis =0)
print(unique2.shape)


# In[4]:


print(len(matrix_3st))
unique3 = np.unique(matrix_3st,axis =0)
print(unique3.shape)


# In[5]:


print(len(matrix_4st))
unique4 = np.unique(matrix_4st,axis =0)
print(unique4.shape)


# In[6]:


X2 = tsne.fit_transform(unique2)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X2[:, 0], X2[:, 1])
plt.show()


# In[7]:


X3 = tsne.fit_transform(unique3)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1])
plt.show()


# In[8]:


X4 = tsne.fit_transform(unique4)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X4[:, 0], X4[:, 1])
plt.show()


# In[9]:


import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
import tensorflow as tf
from tensorflow.contrib.layers import fully_connected
get_ipython().run_line_magic('matplotlib', 'inline')


# In[10]:


num_inputs = 14  # 3 dimensional input
num_hidden = 2  # 2 dimensional representation 
num_outputs = num_inputs # Must be true for an autoencoder!

learning_rate = 0.01


# In[11]:


#Placeholder
X = tf.placeholder(tf.float32, shape=(None, num_inputs))
#Layers
hidden = fully_connected(X, num_hidden, activation_fn=None)
outputs = fully_connected(hidden, num_outputs, activation_fn=None)
#Loss Function
loss = tf.reduce_mean(tf.square(outputs - X))  # MSE
#Optimizer
optimizer = tf.train.AdamOptimizer(learning_rate)
train  = optimizer.minimize(loss)
#Init
init = tf.global_variables_initializer()


# In[12]:


num_steps = 1000

with tf.Session() as sess:
    sess.run(init)
    
    for iteration in range(num_steps):
        sess.run(train,feed_dict={X: unique2})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_2d = hidden.eval(feed_dict={X: unique2})
output_2d


# In[14]:


x2 = [] 
y2 = []

for i in range(len(output_2d[:,0])):
    x2.append(output_2d[i,0])
    y2.append(output_2d[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x2, y2)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')

plt.show()


# In[15]:


num_inputs = 21  # 3 dimensional input
num_hidden = 2  # 2 dimensional representation 
num_outputs = num_inputs # Must be true for an autoencoder!

learning_rate = 0.01

#Placeholder
X = tf.placeholder(tf.float32, shape=(None, num_inputs))
#Layers
hidden = fully_connected(X, num_hidden, activation_fn=None)
outputs = fully_connected(hidden, num_outputs, activation_fn=None)
#Loss Function
loss = tf.reduce_mean(tf.square(outputs - X))  # MSE
#Optimizer
optimizer = tf.train.AdamOptimizer(learning_rate)
train  = optimizer.minimize(loss)
#Init
init = tf.global_variables_initializer()

num_steps = 1000

with tf.Session() as sess:
    sess.run(init)
    
    for iteration in range(num_steps):
        sess.run(train,feed_dict={X: unique3})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_3d = hidden.eval(feed_dict={X: unique3})
output_3d


# In[16]:


x3 = [] 
y3 = []

for i in range(len(output_3d[:,0])):
    x3.append(output_3d[i,0])
    y3.append(output_3d[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x3, y3)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')

plt.show()


# In[17]:


num_inputs = 28  # 3 dimensional input
num_hidden = 2  # 2 dimensional representation 
num_outputs = num_inputs # Must be true for an autoencoder!

learning_rate = 0.01

#Placeholder
X = tf.placeholder(tf.float32, shape=(None, num_inputs))
#Layers
hidden = fully_connected(X, num_hidden, activation_fn=None)
outputs = fully_connected(hidden, num_outputs, activation_fn=None)
#Loss Function
loss = tf.reduce_mean(tf.square(outputs - X))  # MSE
#Optimizer
optimizer = tf.train.AdamOptimizer(learning_rate)
train  = optimizer.minimize(loss)
#Init
init = tf.global_variables_initializer()

num_steps = 1000

with tf.Session() as sess:
    sess.run(init)
    
    for iteration in range(num_steps):
        sess.run(train,feed_dict={X: unique4})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_4d = hidden.eval(feed_dict={X: unique4})
output_4d


# In[18]:


x4 = [] 
y4 = []

for i in range(len(output_4d[:,0])):
    x4.append(output_4d[i,0])
    y4.append(output_4d[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x4, y4)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')


plt.show()


# In[19]:


get_ipython().run_line_magic('matplotlib', 'inline')
import time
import hashlib
import scipy
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.datasets.samples_generator import make_blobs

plt.rcParams['figure.figsize'] = 10, 10
def optimalK(data, nrefs=3, maxClusters=15):
    """
    Calculates KMeans optimal K using Gap Statistic from Tibshirani, Walther, Hastie
    Params:
        data: ndarry of shape (n_samples, n_features)
        nrefs: number of sample reference datasets to create
        maxClusters: Maximum number of clusters to test for
    Returns: (gaps, optimalK)
    """
    gaps = np.zeros((len(range(1, maxClusters)),))
    resultsdf = pd.DataFrame({'clusterCount':[], 'gap':[]})
    for gap_index, k in enumerate(range(1, maxClusters)):

        # Holder for reference dispersion results
        refDisps = np.zeros(nrefs)

        # For n references, generate random sample and perform kmeans getting resulting dispersion of each loop
        for i in range(nrefs):
            
            # Create new random reference set
            randomReference = np.random.random_sample(size=data.shape)
            
            # Fit to it
            km = KMeans(k)
            km.fit(randomReference)
            
            refDisp = km.inertia_
            refDisps[i] = refDisp

        # Fit cluster to original data and create dispersion
        km = KMeans(k)
        km.fit(data)
        
        origDisp = km.inertia_

        # Calculate gap statistic
        gap = np.log(np.mean(refDisps)) - np.log(origDisp)

        # Assign this loop's gap statistic to gaps
        gaps[gap_index] = gap
        
        resultsdf = resultsdf.append({'clusterCount':k, 'gap':gap}, ignore_index=True)

    return (gaps.argmax() + 1, resultsdf)  # Plus 1 because index of 0 means 1 cluster is optimal, index 2 = 3 clusters are optimal


# In[20]:


k2, gapdf2 = optimalK(X2, nrefs=10, maxClusters=50)
print('Optimal k is: ', k2)


# In[21]:


plt.plot(gapdf2.clusterCount, gapdf2.gap, linewidth=3)
plt.scatter(gapdf2[gapdf2.clusterCount == k2].clusterCount, gapdf2[gapdf2.clusterCount == k2].gap, s=250, c='r')
plt.grid(True)
plt.xlabel('Cluster Count')
plt.ylabel('Gap Value')
plt.title('Gap Values by Cluster Count')
plt.show()


# In[22]:


k3, gapdf3 = optimalK(X3, nrefs=10, maxClusters=50)
print('Optimal k is: ', k3)


# In[23]:


plt.plot(gapdf3.clusterCount, gapdf3.gap, linewidth=3)
plt.scatter(gapdf3[gapdf3.clusterCount == k3].clusterCount, gapdf3[gapdf3.clusterCount == k3].gap, s=250, c='r')
plt.grid(True)
plt.xlabel('Cluster Count')
plt.ylabel('Gap Value')
plt.title('Gap Values by Cluster Count')
plt.show()


# In[24]:


k4,gapdf4 = optimalK(X4, nrefs=10, maxClusters=50)
print('Optimal k is: ', k4)


# In[25]:


plt.plot(gapdf4.clusterCount, gapdf4.gap, linewidth=3)
plt.scatter(gapdf4[gapdf4.clusterCount == k4].clusterCount, gapdf4[gapdf4.clusterCount == k4].gap, s=250, c='r')
plt.grid(True)
plt.xlabel('Cluster Count')
plt.ylabel('Gap Value')
plt.title('Gap Values by Cluster Count')
plt.show()


# In[26]:


from sklearn.cluster import MeanShift
import numpy as np
MeanShift2 = MeanShift(bandwidth=22).fit(X2)
print(len(np.unique(MeanShift2.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X2[:, 0], X2[:, 1],c=MeanShift2.labels_)
plt.show()


# In[27]:


from sklearn import metrics
from sklearn.metrics import pairwise_distances

ch2_meanshift={}
for k in range(3, 22):
    meanshift2 = MeanShift(bandwidth = k).fit(X2)
    labels = meanshift2.labels_
    ch2_meanshift[k] = metrics.calinski_harabaz_score(X2, labels)
    print(k, ch2_meanshift[k])


# In[28]:


lists = sorted(ch2_meanshift.items()) # sorted by key, return a list of tuples

x, y = zip(*lists) # unpack a list of pairs into two tuples

plt.plot(x, y)

plt.xlabel('Bandwidth')
plt.ylabel('CH Value')
plt.title('CH Values by Bandwidth')
plt.show()


# In[29]:


from sklearn import metrics
from sklearn.metrics import pairwise_distances

ch3_meanshift={}
for k in range(3, 22):
    meanshift3 = MeanShift(bandwidth = k).fit(X3)
    labels = meanshift3.labels_
    ch3_meanshift[k] = metrics.calinski_harabaz_score(X3, labels)
    print(k, ch3_meanshift[k])


# In[30]:


lists = sorted(ch3_meanshift.items()) # sorted by key, return a list of tuples

x, y = zip(*lists) # unpack a list of pairs into two tuples

plt.plot(x, y)

plt.xlabel('Bandwidth')
plt.ylabel('CH Value')
plt.title('CH Values by Bandwidth')
plt.show()


# In[31]:


from sklearn import metrics
from sklearn.metrics import pairwise_distances

ch4_meanshift={}
for k in range(3, 22):
    meanshift4 = MeanShift(bandwidth = k).fit(X4)
    labels = meanshift4.labels_
    ch4_meanshift[k] = metrics.calinski_harabaz_score(X4, labels)
    print(k, ch4_meanshift[k])


# In[32]:


lists = sorted(ch4_meanshift.items()) # sorted by key, return a list of tuples

x, y = zip(*lists) # unpack a list of pairs into two tuples

plt.plot(x, y)

plt.xlabel('Bandwidth')
plt.ylabel('CH Value')
plt.title('CH Values by Bandwidth')
plt.show()


# In[33]:


from sklearn.cluster import MeanShift
import numpy as np
MeanShift3 = MeanShift(bandwidth=13).fit(X3)
print(len(np.unique(MeanShift3.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1],c=MeanShift3.labels_)
plt.show()


# In[34]:


from sklearn.cluster import MeanShift
import numpy as np
MeanShift3 = MeanShift(bandwidth=8).fit(X3)
print(len(np.unique(MeanShift3.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1],c=MeanShift3.labels_)
plt.show()


# In[35]:


from sklearn.cluster import MeanShift
import numpy as np
MeanShift4 = MeanShift(bandwidth=8).fit(X4)
print(len(np.unique(MeanShift4.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X4[:, 0], X4[:, 1],c=MeanShift4.labels_)
plt.show()


# In[36]:


from sklearn.cluster import DBSCAN
import numpy as np

DBSCAN2 = DBSCAN(6,20).fit(X2)
print(len(np.unique(DBSCAN2.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X2[:, 0], X2[:, 1],c=DBSCAN2.labels_)
plt.show()


# In[37]:


from sklearn.cluster import DBSCAN
import numpy as np

DBSCAN3 = DBSCAN(6,20).fit(X3)
print(len(np.unique(DBSCAN3.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1],c=DBSCAN3.labels_)
plt.show()


# In[38]:


from sklearn.cluster import DBSCAN
import numpy as np

DBSCAN4 = DBSCAN(6,20).fit(X4)
print(len(np.unique(DBSCAN4.labels_)))
plt.figure(figsize=(20, 20))
plt.scatter(X4[:, 0], X4[:, 1],c=DBSCAN4.labels_)
plt.show()


# In[39]:


from sklearn.cluster import AgglomerativeClustering
import numpy as np
Agglomerative2 = AgglomerativeClustering(n_clusters=4).fit(X2)
print(Agglomerative2.linkage)
plt.figure(figsize=(20, 20))
plt.scatter(X2[:, 0], X2[:, 1],c=Agglomerative2.labels_)
plt.show()


# In[40]:


from sklearn.cluster import AgglomerativeClustering
import numpy as np
Agglomerative3 = AgglomerativeClustering(n_clusters=5).fit(X3)
print(Agglomerative3.linkage)
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1],c=Agglomerative3.labels_)
plt.show()


# In[41]:


from sklearn.cluster import AgglomerativeClustering
import numpy as np
Agglomerative4 = AgglomerativeClustering(n_clusters=6).fit(X4)
print(Agglomerative4.linkage)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:, 0], X4[:, 1],c=Agglomerative4.labels_)
plt.show()


# In[46]:


from sklearn.cluster import AffinityPropagation
from sklearn import metrics
from sklearn.datasets.samples_generator import make_blobs

af2 = AffinityPropagation(preference=-50).fit(X2)
cluster_centers_indices2 = af2.cluster_centers_indices_
labels2 = af2.labels_
print(len(np.unique(af2.labels_)))
n_clusters_ = len(cluster_centers_indices2)
plt.figure(figsize=(20, 20))
plt.scatter(X2[:, 0], X2[:, 1],c=af2.labels_)
plt.show()


# In[47]:


from sklearn.cluster import AffinityPropagation
from sklearn import metrics
from sklearn.datasets.samples_generator import make_blobs

af3 = AffinityPropagation(preference=-50).fit(X3)
cluster_centers_indices3 = af3.cluster_centers_indices_
labels3 = af3.labels_
print(len(np.unique(af3.labels_)))
n_clusters_ = len(cluster_centers_indices3)
plt.figure(figsize=(20, 20))
plt.scatter(X3[:, 0], X3[:, 1],c=af3.labels_)
plt.show()


# In[49]:


from sklearn.cluster import AffinityPropagation
from sklearn import metrics
from sklearn.datasets.samples_generator import make_blobs

af4 = AffinityPropagation(preference=-50).fit(X4)
cluster_centers_indices4 = af4.cluster_centers_indices_
labels4 = af4.labels_
print(len(np.unique(af4.labels_)))
n_clusters_ = len(cluster_centers_indices4)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:, 0], X4[:, 1],c=af4.labels_)
plt.show()

