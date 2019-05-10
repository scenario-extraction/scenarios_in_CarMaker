#!/usr/bin/env python
# coding: utf-8

# # TSN-E

# In[1]:


from sklearn.manifold import TSNE
import numpy as np
import matplotlib.pyplot as plt


# In[2]:


#load the data matrics
matrix_2st=np.loadtxt('matrix62.txt')
print('2 state scenario matrics has the shape:',matrix_2st.shape)
matrix_3st=np.loadtxt('matrix63.txt')
print('3 state scenario matrics has the shape:',matrix_3st.shape)
matrix_4st=np.loadtxt('matrix64.txt')
print('4 state scenario matrics has the shape:',matrix_4st.shape)


# In[3]:


tsne = TSNE(n_components = 2)
print(len(matrix_2st))
unique = np.unique(matrix_2st,axis =0)
print(unique.shape)
unique3 = np.unique(matrix_3st,axis =0)
print(unique3.shape)
unique4 = np.unique(matrix_4st,axis =0)
print(unique4.shape)


# In[4]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X2 = tsne.fit_transform(matrix_2st)
X_embedded = np.unique(X2,axis=0)
# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[5]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X_embedded = tsne.fit_transform(unique)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[6]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(unique)

print(newData)

x3 = [] 
y3 = []

for i in range(len(newData[:,0])):
    x3.append(newData[i,0])
    y3.append(newData[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x3, y3)
plt.title("PCA results")
ax.set_xlabel('PCA 1')
ax.set_ylabel('PCA 2')


plt.show()


# In[7]:


from pyod.models.knn import KNN
knn4 = KNN()
knn4.fit(unique)


# In[8]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X4 = tsne.fit_transform(unique)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:,0], X4[:,1], c = knn4.labels_)
plt.show()


# In[9]:


from pyod.models.iforest import IForest
iforest2 = IForest()
iforest2.fit(unique)


# In[10]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X22 = tsne.fit_transform(unique)
plt.figure(figsize=(20, 20))
plt.scatter(X22[:,0], X22[:,1], c = iforest2.labels_)
plt.show()


# In[11]:


len(X_embedded)


# In[12]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X3 = tsne.fit_transform(matrix_3st)
X_embedded = np.unique(X3,axis=0)
# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[13]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X_embedded = tsne.fit_transform(unique3)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[14]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(unique3)

print(newData)

x3 = [] 
y3 = []

for i in range(len(newData[:,0])):
    x3.append(newData[i,0])
    y3.append(newData[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x3, y3)
plt.title("PCA results")
ax.set_xlabel('PCA 1')
ax.set_ylabel('PCA 2')


plt.show()


# In[17]:


from pyod.models.knn import KNN
knn3 = KNN()
knn3.fit(unique3)


# In[19]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X3 = tsne.fit_transform(unique3)
plt.figure(figsize=(20, 20))
plt.scatter(X3[:,0], X3[:,1], c = knn3.labels_)
plt.show()


# In[20]:


from pyod.models.iforest import IForest
iforest3 = IForest()
iforest3.fit(unique3)


# In[21]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X3 = tsne.fit_transform(unique3)
plt.figure(figsize=(20, 20))
plt.scatter(X3[:,0], X3[:,1], c = iforest3.labels_)
plt.show()


# In[22]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X4 = tsne.fit_transform(matrix_4st)
X_embedded = np.unique(X4,axis=0)
# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[23]:


tsne = TSNE(n_components = 2)
#reduce the redunant data
X_embedded = tsne.fit_transform(unique4)

# plot
plt.figure(figsize=(20, 20))
plt.scatter(X_embedded[:, 0], X_embedded[:, 1])
plt.show()


# In[24]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(unique4)

print(newData)

x3 = [] 
y3 = []

for i in range(len(newData[:,0])):
    x3.append(newData[i,0])
    y3.append(newData[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x3, y3)
plt.title("PCA results")
ax.set_xlabel('PCA 1')
ax.set_ylabel('PCA 2')


plt.show()


# In[25]:


from pyod.models.knn import KNN
knn4 = KNN()
knn4.fit(unique)


# In[26]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X4 = tsne.fit_transform(unique)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:,0], X4[:,1], c = knn4.labels_)
plt.show()


# In[27]:


from pyod.models.iforest import IForest
iforest4 = IForest()
iforest4.fit(unique4)


# In[28]:


from sklearn.manifold import TSNE
tsne = TSNE(n_components = 2)

# Reduce the redunant data
X4 = tsne.fit_transform(unique4)
plt.figure(figsize=(20, 20))
plt.scatter(X4[:,0], X4[:,1], c = iforest4.labels_)
plt.show()

