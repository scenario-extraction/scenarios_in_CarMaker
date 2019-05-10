#!/usr/bin/env python
# coding: utf-8

# In[2]:


from sklearn.manifold import TSNE
import numpy as np
import matplotlib.pyplot as plt


# In[3]:


#load the data matrics
matrix_2st=np.loadtxt('matrix.txt')
print('2 state scenario matrics has the shape:',matrix_2st.shape)
matrix_3st=np.loadtxt('matrix_3st.txt')
print('3 state scenario matrics has the shape:',matrix_3st.shape)
matrix_4st=np.loadtxt('matrix_4st.txt')
print('4 state scenario matrics has the shape:',matrix_4st.shape)


# In[4]:


unique2 = np.unique(matrix_2st,axis = 0)
unique3 = np.unique(matrix_3st,axis = 0)
unique4 = np.unique(matrix_4st,axis = 0)


# In[5]:


print('2 state scenario matrics has the shape:',unique2.shape)
print('3 state scenario matrics has the shape:',unique3.shape)
print('4 state scenario matrics has the shape:',unique4.shape)


# In[6]:


#anomaly detection using PYod


# In[7]:


from pyod.models.knn import KNN
knn2 = KNN()
knn2.fit(unique2)


# In[8]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data

X2 = tsne.fit_transform(unique2)
plt.figure(figsize=(20, 20))
plt.scatter(X2[:,0], X2[:,1], c = knn2.labels_)
plt.show()


# In[9]:


from pyod.models.knn import KNN
knn3 = KNN()
knn3.fit(unique3) 


# In[10]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data

X3 = tsne.fit_transform(unique3)
plt.figure(figsize=(20, 20))
plt.scatter(X3[:,0], X3[:,1], c = knn3.labels_)
plt.show()


# In[11]:


from pyod.models.knn import KNN
knn4 = KNN()
knn4.fit(unique4)


# In[12]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X4 = tsne.fit_transform(unique4)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:,0], X4[:,1], c = knn4.labels_)
plt.show()


# In[13]:


from pyod.models.knn import KNN
knn4 = KNN()
knn4.fit(unique4) 


# In[14]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X4 = tsne.fit_transform(unique4)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:,0], X4[:,1], c = knn4.labels_)
plt.show()


# In[14]:


from pyod.models.pca import PCA
pca2 = PCA()
pca2.fit(unique2) 


# In[15]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X12 = tsne.fit_transform(unique2)
plt.figure(figsize=(20, 20))
plt.scatter(X12[:,0], X12[:,1], c = pca2.labels_)
plt.show()


# In[16]:


from pyod.models.pca import PCA
pca3 = PCA()
pca3.fit(unique3)


# In[17]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X13 = tsne.fit_transform(unique3)
plt.figure(figsize=(20, 20))
plt.scatter(X13[:,0], X13[:,1], c = pca3.labels_)
plt.show()


# In[18]:


from pyod.models.pca import PCA
pca4 = PCA()
pca4.fit(unique4)


# In[19]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X14 = tsne.fit_transform(unique4)
plt.figure(figsize=(20, 20))
plt.scatter(X14[:,0], X14[:,1], c = pca4.labels_)
plt.show()


# In[17]:


from pyod.models.iforest import IForest
iforest2 = IForest()
iforest2.fit(unique2)


# In[15]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X22 = tsne.fit_transform(unique2)
plt.figure(figsize=(20, 20))
plt.scatter(X22[:,0], X22[:,1], c = iforest2.labels_)
plt.show()


# In[22]:


iforest3 = IForest()
iforest3.fit(unique3)


# In[23]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X23 = tsne.fit_transform(unique3)
plt.figure(figsize=(20, 20))
plt.scatter(X23[:,0], X23[:,1], c = iforest3.labels_)
plt.show()


# In[24]:


iforest4 = IForest()
iforest4.fit(unique4)


# In[25]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X24 = tsne.fit_transform(unique4)
plt.figure(figsize=(20, 20))
plt.scatter(X24[:,0], X24[:,1], c = iforest4.labels_)
plt.show()


# In[29]:


from pyod.models.auto_encoder import AutoEncoder

autoencoder2 = AutoEncoder(hidden_neurons=[16,8,8,16])
autoencoder2.fit(unique2)


# In[30]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X42 = tsne.fit_transform(unique2)
plt.figure(figsize = (20, 20))
plt.scatter(X42[:,0], X42[:,1], c = autoencoder2.labels_)
plt.show()


# In[1]:


autoencoder2 = AutoEncoder(hidden_neurons=[16,8,8,16])
autoencoder2.fit(unique2)

from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X42 = tsne.fit_transform(unique2)
plt.figure(figsize = (20, 20))
plt.scatter(X42[:,0], X42[:,1], c = autoencoder2.labels_)
plt.show()

