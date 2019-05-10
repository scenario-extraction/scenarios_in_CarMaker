#!/usr/bin/env python
# coding: utf-8

# In[12]:


import pandas as pd
import numpy as np 
import glob
import sklearn as sk

header = ['Time','ego_long','ego_lat']
#object_num = int((data[1].shape[1]-3)/4)
object_num = 128
for i in range(object_num):
    header.append(str(i)+'_long')
    header.append(str(i)+'_lat')
    header.append(str(i)+'st_long')
    header.append(str(i)+'st_lat')
    
#datasize = 45*20 = 900 m
data = {}
daten = glob.glob('../Masterarbeit/Testrun_data/newhighway/*.csv')
print(len(daten))
for i in range(len(daten)):
    data[i] = pd.read_csv(daten[i],sep = ',', skiprows = 1, names = header, encoding = 'utf-8')
    
# for i in range(len(data)):
#     data[i].replace(-9,-99,inplace = True)


# In[21]:


print(len(data))
data[0]
data[1][(data[1]<8)&(data[1]>-8)]


# In[24]:


def transform(data):
    data1 = {}
    out = {}
    for i in range(len(data)):
        data1[i] = data[i].iloc[:,range(5,515,4)]
        data1[i] = data1[i][(data1[i]<8)&(data1[i]>-8)]
        data1[i] = np.sum((data1[i]==1)|(data1[i]==-1)|(data1[i]==0),axis = 1)
#         data1[i] = data[i].replace([-9,-99],[1000,1000])
#         data1[i] = np.sum(data1[i].iloc[:,3::].astype(int),axis = 1)
#         data1[i] = ((512 - (data1[i]/1000)).astype(int)/4).astype(int)
         
        
        
    data2 = {}
    for i in range(len(data)):
        data2[i] = data[i].iloc[:,range(5,515,4)]
        data2[i] = data2[i][(data2[i]<8)&(data2[i]>-8)]
        data2[i] = data2[i].dropna(axis= 1, how = 'all')
        
    data3 = {}
    for i in range(len(data)):
        data3[i] = data[i].iloc[:,range(6,515,4)]
        data3[i] = data3[i][(data3[i]<8)&(data3[i]>-8)]
        data3[i] = data3[i].dropna(axis= 1, how = 'all')
    
    for i in range(len(data)):
        out[i] = pd.concat([data1[i],data2[i],data3[i]],axis = 1)
        
    return out


# In[26]:


pd.set_option('display.width', 100, 'display.max_rows', 100)
data3 = transform(data)
data3[1]


# In[27]:


def segmentierung_2st(data):
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


# In[28]:


pd.options.display.max_columns = None
reihe, index = segmentierung_2st(data3)
print(len(reihe))
reihe[3]


# In[ ]:


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


# In[ ]:


np.savetxt("matrix62.txt",matrix)


# In[ ]:


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

reihe_3st, index_3st = segmentierung_3st(data3)
print("the length of the 3 state scene is:",len(reihe_3st))
reihe_3st[4][100:200]


# In[ ]:



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


# In[ ]:


np.savetxt("matrix63.txt",matrix_3st)


# In[ ]:


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
#         print(sum_index+n)
        sum_index = sum_index + len(index[i]) - 4
                        
    return folge, index


# In[ ]:


reihe_4st, index_4st = segmentierung_4st(data3)
print("the length of the 4 state scene is:",len(reihe_4st))
reihe_3st[4]


# In[ ]:


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


# In[ ]:


np.savetxt("matrix64.txt",matrix_4st)

