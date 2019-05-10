#!/usr/bin/env python
# coding: utf-8

# # A Traffic Scenario meta description
# 

# In[1]:


import glob
scenarios = glob.glob('../Masterarbeit/pic/carmaker/2lane1*.png')
scenarios[1]


# ## First case: Two lanes on the highway, one object car

# In[3]:


import matplotlib.pyplot as plt
import matplotlib.image as mpimg

plt.figure(figsize= (22,20))

for i,image in enumerate(scenarios):
    plt.subplot(2,5,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('2lane1car'+str(i+1))
    plt.axis("off")
plt.show()


# ## Second case: two lane on the highway, two object cars

# In[3]:


scenarios1 = glob.glob('../Masterarbeit/pic/carmaker/2lane2*.png')
scenarios1[1]


# In[4]:


plt.figure(figsize= (22,20))

for i,image in enumerate(scenarios1[0:10]):
    plt.subplot(2,5,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('2lane2car'+str(i+1))
    plt.axis("off")
plt.show()


# In[5]:


plt.figure(figsize= (22,20))

for i,image in enumerate(scenarios1[10:20]):
    plt.subplot(2,5,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('2lane2car'+str(i+11))
    plt.axis("off")
plt.show()


# In[6]:


plt.figure(figsize= (22,20))

for i,image in enumerate(scenarios1[20:30]):
    plt.subplot(2,5,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('2lane2car'+str(i+21))
    plt.axis("off")
plt.show()


# In[7]:


plt.figure(figsize= (22,20))

for i,image in enumerate(scenarios1[30:40]):
    plt.subplot(2,5,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('2lane2car'+str(i+31))
    plt.axis("off")
plt.show()


# # 2 lane 3 cars ...
# # 2 lane 4 cars ...
# # 2 lane 5 cars ...
# # 3 lane 3 cars ...

# ## Calculate the Number of Scenario
# 
# * we have two parameter: the number of the lanes and the number of the cars
# ### Z is the number of the scenario states
# 
# ![formel](../Masterarbeit/pic/formel1.png)
# ![formel](../Masterarbeit/pic/formel2.png)
# 

# ## Combine with the single decription
# 
# 
# 
# 
#  |  Value  |   st_Long                          |   st_Lat               |  long                       |  lat           |
#  |:------: |  :-------------: |:-------------:|:-------------:|:-------------:|
#  |  1     |  Car is in front of the ego         |   right of the ego     |    accelerate               |      turn right|
#  |   -1   |  Car is behind the ego              |   left of the ego      |     decelerate              |  turn left     |
#  |   0    |  Car is in the same level of the ego|    same lane           |    constant speed           |  keep lane     |

# ## klassification for the traffic scenario
# 
# ![heatmap](../Masterarbeit/pic/heatmapplot.png)

# In[8]:


import pandas as pd
import numpy as np 
import glob
import sklearn as sk

header = ['Time','ego_long','ego_lat']
#object_num = int((data[1].shape[1]-3)/4)
object_num = 130
for i in range(object_num):
    header.append(str(i)+'_long')
    header.append(str(i)+'_lat')
    header.append(str(i)+'st_long')
    header.append(str(i)+'st_lat')
    
#datasize = 45*20 = 900 m
data = {}
daten = glob.glob('../Masterarbeit/Testrun_data/trymingap1smax4dist10max150/*.csv')
for i in range(len(daten)):
    data[i] = pd.read_csv(daten[i],sep = ',',skiprows= 1,names = header, encoding = 'utf-8')
    
for i in range(len(data)):
    data[i].replace(-9,-99,inplace = True)


# In[9]:


daten2 = glob.glob('../Masterarbeit/Testrun_data/mingap1.8sdist15twosensor/*.csv')
for i in range(len(daten2)):
    data[45+i] = pd.read_csv(daten2[i],sep = ',',skiprows= 1,names = header, encoding = 'utf-8')
print(len(data))
for i in range(len(data)):
    data[i].replace(-9,-99,inplace = True)


# In[10]:


daten3 = glob.glob('../Masterarbeit/Testrun_data/trymingap2smax6dist5max150e0.5/*.csv')
for i in range(len(daten3)):
    data[90+i] = pd.read_csv(daten3[i],sep = ',',skiprows= 1,names = header, encoding = 'utf-8')
print(len(data))
for i in range(len(data)):
    data[i].replace(-9,-99,inplace = True)


# In[11]:


data[93].head()


# In[12]:


# case: 2 lane, and the number of the car unknown
def transform(data):
    data1 = {}
    out = {}
    for i in range(len(data)):
        data1[i] = data[i].replace([-9,-99],[100,100])
        data1[i] = np.sum(data1[i].iloc[:,3::].astype(int),axis = 1)
        data1[i] = ((520 - (data1[i]/100).astype(int))/4).astype(int)
        
    data2 = {}
    for i in range(len(data)):
        data2[i] = data[i].iloc[:,range(5,520,4)]
        data2[i] = data2[i][(data2[i]==0)|(data2[i]==-1)|(data2[i]==1)]
        data2[i] = data2[i].dropna(axis= 1, how = 'all')
        
    data3 = {}
    for i in range(len(data)):
        data3[i] = data[i].iloc[:,range(6,520,4)]
        data3[i] = data3[i][(data3[i]==0)|(data3[i]==-1)|(data3[i]==1)]
        data3[i] = data3[i].dropna(axis= 1, how = 'all')
    
    for i in range(len(data)):
        out[i] = pd.concat([data1[i],data2[i],data3[i]],axis = 1)
        
    return out
    


# In[13]:


pd.set_option('display.width', 100, 'display.max_rows', 100)
data3 = transform(data)
data3[1]


# In[14]:


#Klassification for the scenario
predict = []
predict = pd.unique(data3[2].iloc[:,0])
predict


# In[15]:


plt.figure(figsize= (12,9))
scenarios2 = [scenarios[1],scenarios1[1]]
for i,image in enumerate(scenarios2):
    plt.subplot(1,2,i+1)
    plt.imshow(mpimg.imread(image))
    plt.title('scenario No.'+str(i+1))
    plt.axis("off")
plt.show()


# ## Clustering for the States series

# In[16]:


n = np.sum(data3[4][data3[1].iloc[:,0]==0],axis= 1)


# In[17]:


#df = data3[2].groupby([0,'0st_long','1st_long','2st_long','3st_long','4st_long','5st_long','6st_long','7st_long','8st_long','9st_lat','10st_lat','11st_lat','12st_lat','13st_lat','14st_lat','15st_lat','16st_lat','17st_lat'])
df = data3[2][data3[2].iloc[:,0]==4].drop_duplicates(keep = 'first').index
df
#[data3[2].iloc[:,0]==2]


# In[18]:


#2 Folgers clustering
def segmentierung(data):
    folge = {}
    index = {}
    sum_index = 0
    imax = 0
    sum_index = 0
    for i in range(len(data)):
        imax = data[i].iloc[:,0].max()
        index[i] = []
        for j in range(imax):
            indexj = data[i][data[i].iloc[:,0]==j].drop_duplicates(keep = 'first').index.tolist()
            index[i] = index[i] + indexj
            index[i].sort()
        
        for n in range(len(index[i]) - 2):
            folge[sum_index + n] = data[i].iloc[index[i][n]:index[i][n+2],:]
#             print(sum_index+n)
        sum_index = sum_index + len(index[i]) - 2
                        
    return folge, index


# ## State Meta description
# 
# 
# ![relation](../Masterarbeit/pic/relation.PNG)

# ## Description the Change of the States
# 
# a Example of 2 states scenario
# 
# 
# ![scenario](../Masterarbeit/pic/scenario1.PNG)
# 
# 
# ## then combine the Matrix and we get a Meta description for a scenario

# In[19]:


reihe, index = segmentierung(data3)
len(reihe)
reihe[3]


# In[20]:


print('the number of 2 state folge in segment 21 is:',len(index[20]))
print('the number of the 2 state folge is:',len(reihe))
reihe[3000].drop_duplicates(keep = 'last').index.tolist()
#reihe[3].drop_duplicates(keep = 'first').iloc[:,1::]
df = reihe[3].drop_duplicates(keep = 'last')
reihe[3].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==1


# In[21]:


import numpy as np
from sklearn.datasets import make_friedman1
from sklearn.decomposition import SparsePCA

transformer = SparsePCA(n_components=2, random_state=0)


# ## Describe feature extraction from data
# 
# ![data](../Masterarbeit/pic/preprocessing.PNG)

# In[22]:


import numpy as np

matrix = np.zeros(shape = (len(reihe), 14))
for i in range(len(reihe)):
    matrix[i,0] = reihe[i].iloc[0,0]
    matrix[i,1] = reihe[i].iloc[-1,0]
    df = reihe[i].drop_duplicates(keep = 'last')
    matrix[i,2] = np.sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==1)
    matrix[i,3] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==0)
    matrix[i,4] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==-1)
    matrix[i,5] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix[i,6] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix[i,7] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix[i,8] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==1)
    matrix[i,9] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==0)
    matrix[i,10] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==-1)
    matrix[i,11] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix[i,12] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix[i,13] = sum(reihe[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==-1)
matrix


# In[23]:


np.savetxt("matrix.txt",matrix)


# In[24]:


from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
from matplotlib import pyplot as plt

Z = linkage(matrix, 'ward')
f = fcluster(Z,10,'distance')
fig = plt.figure(figsize=(14, 10))
dn = dendrogram(Z)
plt.show()
print(Z.shape)


# In[25]:


def fancy_dendrogram(*args, **kwargs):
    max_d = kwargs.pop('max_d', None)
    if max_d and 'color_threshold' not in kwargs:
        kwargs['color_threshold'] = max_d
    annotate_above = kwargs.pop('annotate_above', 0)

    ddata = dendrogram(*args, **kwargs)

    if not kwargs.get('no_plot', False):
        plt.title('Hierarchical Clustering Dendrogram (truncated)')
        plt.xlabel('sample index or (cluster size)')
        plt.ylabel('distance')
        for i, d, c in zip(ddata['icoord'], ddata['dcoord'], ddata['color_list']):
            x = 0.5 * sum(i[1:3])
            y = d[1]
            if y > annotate_above:
                plt.plot(x, y, 'o', c=c)
                plt.annotate("%.3g" % y, (x, y), xytext=(0, -5),
                             textcoords='offset points',
                             va='top', ha='center')
        if max_d:
            plt.axhline(y=max_d, c='k')
    return ddata


# In[26]:


plt.figure(figsize=(10,10))
fancy_dendrogram(
    Z,
    truncate_mode='lastp',
    p=30,
    leaf_rotation=90.,
    leaf_font_size=12.,
    show_contracted=True,
    annotate_above=13,
    max_d=13,
)
plt.show()


# ## Clustering using DBSCAN Clustering
# 
# Because we can't differ which datatuple hat the same feature so we choose to use the DBSCAN to clustering the data.

# In[27]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(matrix)
print('the dimention after PCA operate is:',newData.shape)
print(newData)


# In[28]:


x2 = [] 
y2 = []


for i in range(len(newData[:,0])):
    x2.append(newData[i,0])
    y2.append(newData[i,1])
fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)

ax.scatter(x2, y2)
plt.title("PCA results")
ax.set_xlabel('PCA 1')
ax.set_ylabel('PCA 2')


plt.show()


# ## This is because almost all the state Parameter is 1
# 
# ## Because of so many outier we cant make meaningful results

# ## Clustering der Scenario of 3 state folge
# 
# ![data](../Masterarbeit/pic/3state.PNG)

# In[29]:


def segmentierung_3st(data):
    folge = {}
    index = {}
    sum_index = 0
    imax = 0
    sum_index = 0
    for i in range(len(data)):
        imax = data[i].iloc[:,0].max()
        index[i] = []
        for j in range(imax):
            indexj = data[i][data[i].iloc[:,0]==j].drop_duplicates(keep = 'first').index.tolist()
            index[i] = index[i] + indexj
            index[i].sort()
        
        for n in range(len(index[i]) - 3):
            folge[sum_index + n] = data[i].iloc[index[i][n]:index[i][n+3],:]
#             print(sum_index+n)
        sum_index = sum_index + len(index[i]) - 3
                        
    return folge, index


# In[1]:


reihe_3st, index_3st = segmentierung_3st(data3)
print("the length of the 3 state scene is:",len(reihe_3st))
reihe_3st[3]


# In[33]:



matrix_3st = np.zeros(shape = (len(reihe_3st), 21))
for i in range(len(reihe_3st)):
    
    df = reihe_3st[i].drop_duplicates(keep = 'last')

    matrix_3st[i,0] = df.iloc[0,0]
    matrix_3st[i,1] = df.iloc[1,0]
    matrix_3st[i,2] = df.iloc[2,0]
    matrix_3st[i,3] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==1)
    matrix_3st[i,4] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==0)
    matrix_3st[i,5] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==-1)
    matrix_3st[i,6] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_3st[i,7] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_3st[i,8] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix_3st[i,9] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==1)
    matrix_3st[i,10] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==0)
    matrix_3st[i,11] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==-1)
    matrix_3st[i,12] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_3st[i,13] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_3st[i,14] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix_3st[i,15] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==1)
    matrix_3st[i,16] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==0)
    matrix_3st[i,17] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==-1)
    matrix_3st[i,18] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_3st[i,19] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_3st[i,20] = sum(reihe_3st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==-1)
matrix_3st


# In[34]:


np.savetxt("matrix_3st.txt",matrix_3st)


# In[35]:


from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
from matplotlib import pyplot as plt

Z = linkage(matrix_3st, 'ward')
f = fcluster(Z,10,'distance')
fig = plt.figure(figsize=(14, 10))
dn = dendrogram(Z)
plt.show()
print(Z.shape)


# In[36]:


def fancy_dendrogram(*args, **kwargs):
    max_d = kwargs.pop('max_d', None)
    if max_d and 'color_threshold' not in kwargs:
        kwargs['color_threshold'] = max_d
    annotate_above = kwargs.pop('annotate_above', 0)

    ddata = dendrogram(*args, **kwargs)

    if not kwargs.get('no_plot', False):
        plt.title('Hierarchical Clustering Dendrogram (truncated)')
        plt.xlabel('sample index or (cluster size)')
        plt.ylabel('distance')
        for i, d, c in zip(ddata['icoord'], ddata['dcoord'], ddata['color_list']):
            x = 0.5 * sum(i[1:3])
            y = d[1]
            if y > annotate_above:
                plt.plot(x, y, 'o', c=c)
                plt.annotate("%.3g" % y, (x, y), xytext=(0, -5),
                             textcoords='offset points',
                             va='top', ha='center')
        if max_d:
            plt.axhline(y=max_d, c='k')
    return ddata


# In[37]:


plt.figure(figsize=(10,10))
fancy_dendrogram(
    Z,
    truncate_mode='lastp',
    p=30,
    leaf_rotation=90.,
    leaf_font_size=12.,
    show_contracted=True,
    annotate_above=13,
    max_d=13,
)
plt.show()


# In[38]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(matrix_3st)
print('the dimention after PCA operate is:',newData.shape)
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


# ## 4 State Scenario Clustering
# 
# ![data](../Masterarbeit/pic/4state.PNG)

# In[39]:


def segmentierung_4st(data):
    folge = {}
    index = {}
    sum_index = 0
    imax = 0
    sum_index = 0
    for i in range(len(data)):
        imax = data[i].iloc[:,0].max()
        index[i] = []
        for j in range(imax):
            indexj = data[i][data[i].iloc[:,0]==j].drop_duplicates(keep = 'first').index.tolist()
            index[i] = index[i] + indexj
            index[i].sort()
        
        for n in range(len(index[i]) - 4):
            folge[sum_index + n] = data[i].iloc[index[i][n]:index[i][n+4],:]
#             print(sum_index+n)
        sum_index = sum_index + len(index[i]) - 4
                        
    return folge, index


# In[40]:


reihe_4st, index_4st = segmentierung_4st(data3)
print("the length of the 4 state scene is:",len(reihe_4st))
reihe_3st[4]


# In[41]:


matrix_4st = np.zeros(shape = (len(reihe_4st), 28))
for i in range(len(reihe_4st)):
    
    df = reihe_4st[i].drop_duplicates(keep = 'last')
    
    matrix_4st[i,0] = df.iloc[0,0]
    matrix_4st[i,1] = df.iloc[1,0]
    matrix_4st[i,2] = df.iloc[2,0]
    matrix_4st[i,3] = df.iloc[3,0]
    matrix_4st[i,4] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==1)
    matrix_4st[i,5] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==0)
    matrix_4st[i,6] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,1:int(df.shape[1]/2)]==-1)
    matrix_4st[i,7] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_4st[i,8] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_4st[i,9] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[0,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix_4st[i,10] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==1)
    matrix_4st[i,11] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==0)
    matrix_4st[i,12] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,1:int(df.shape[1]/2)]==-1)
    matrix_4st[i,13] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_4st[i,14] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_4st[i,15] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[1,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix_4st[i,16] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==1)
    matrix_4st[i,17] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==0)
    matrix_4st[i,18] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,1:int(df.shape[1]/2)]==-1)
    matrix_4st[i,19] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_4st[i,20] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_4st[i,21] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[2,int(df.shape[1]/2):int(df.shape[1])]==-1)
    matrix_4st[i,22] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,1:int(df.shape[1]/2)]==1)
    matrix_4st[i,23] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,1:int(df.shape[1]/2)]==0)
    matrix_4st[i,24] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,1:int(df.shape[1]/2)]==-1)
    matrix_4st[i,25] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,int(df.shape[1]/2):int(df.shape[1])]==1)
    matrix_4st[i,26] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,int(df.shape[1]/2):int(df.shape[1])]==0)
    matrix_4st[i,27] = sum(reihe_4st[i].drop_duplicates(keep = 'last').iloc[3,int(df.shape[1]/2):int(df.shape[1])]==-1)
matrix_4st


# In[42]:


np.savetxt("matrix_4st.txt",matrix_4st)


# In[43]:


from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
from matplotlib import pyplot as plt

Z = linkage(matrix_4st, 'ward')
f = fcluster(Z,10,'distance')
fig = plt.figure(figsize=(14, 10))
dn = dendrogram(Z)
plt.show()
print(Z.shape)


# In[44]:


def fancy_dendrogram(*args, **kwargs):
    max_d = kwargs.pop('max_d', None)
    if max_d and 'color_threshold' not in kwargs:
        kwargs['color_threshold'] = max_d
    annotate_above = kwargs.pop('annotate_above', 0)
    ddata = dendrogram(*args, **kwargs)

    if not kwargs.get('no_plot', False):
        plt.title('Hierarchical Clustering Dendrogram (truncated)')
        plt.xlabel('sample index or (cluster size)')
        plt.ylabel('distance')
        for i, d, c in zip(ddata['icoord'], ddata['dcoord'], ddata['color_list']):
            x = 0.5 * sum(i[1:3])
            y = d[1]
            if y > annotate_above:
                plt.plot(x, y, 'o', c=c)
                plt.annotate("%.3g" % y, (x, y), xytext=(0, -5),
                             textcoords='offset points',
                             va='top', ha='center')
        if max_d:
            plt.axhline(y=max_d, c='k')
    return ddata


# In[45]:


plt.figure(figsize=(10,10))
fancy_dendrogram(
    Z,
    truncate_mode='lastp',
    p=30,
    leaf_rotation=90.,
    leaf_font_size=12.,
    show_contracted=True,
    annotate_above=13,
    max_d=13,
)
plt.show()


# In[46]:


from sklearn.decomposition import PCA 
pca=PCA(n_components=2)
newData=pca.fit_transform(matrix_4st)
print('the dimention after PCA operate is:',newData.shape)
print(newData)

x4 = [] 
y4 = []


for i in range(len(newData[:,0])):
    x4.append(newData[i,0])
    y4.append(newData[i,1])
fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)

ax.scatter(x4, y4)
plt.title("PCA results")
ax.set_xlabel('PCA 1')
ax.set_ylabel('PCA 2')
# plt.xlim((-125,75))
# plt.ylim((-100,100))

plt.show()


# ## a possible solution
# 
# ![encoder](../Masterarbeit/pic/grid.png)

# ## Autoencoder
# 






np.savetxt("matrix.txt",matrix)



