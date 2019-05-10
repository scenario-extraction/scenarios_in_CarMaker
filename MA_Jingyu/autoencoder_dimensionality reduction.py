#!/usr/bin/env python
# coding: utf-8

# In[2]:


import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
import tensorflow as tf
from tensorflow.contrib.layers import fully_connected
get_ipython().run_line_magic('matplotlib', 'inline')


# In[3]:


#load the data matrics
matrix_2st=np.loadtxt('matrix.txt')
print('2 state scenario matrics has the shape:',matrix_2st.shape)
matrix_3st=np.loadtxt('matrix_3st.txt')
print('3 state scenario matrics has the shape:',matrix_3st.shape)
matrix_4st=np.loadtxt('matrix_4st.txt')
print('4 state scenario matrics has the shape:',matrix_4st.shape)


# In[4]:


num_inputs = 14  # 3 dimensional input
num_hidden = 2  # 2 dimensional representation 
num_outputs = num_inputs # Must be true for an autoencoder!

learning_rate = 0.01


# ![encoder](../Masterarbeit/pic/autoencoder.png)

# In[5]:


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


# In[6]:


num_steps = 1000

with tf.Session() as sess:
    sess.run(init)
    
    for iteration in range(num_steps):
        sess.run(train,feed_dict={X: matrix_2st})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_2d = hidden.eval(feed_dict={X: matrix_2st})
output_2d


# In[7]:


x3 = [] 
y3 = []

for i in range(len(output_2d[:,0])):
    x3.append(output_2d[i,0])
    y3.append(output_2d[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x3, y3)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')

plt.show()


# In[8]:


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
        sess.run(train,feed_dict={X: matrix_3st})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_2d_3st = hidden.eval(feed_dict={X: matrix_3st})
output_2d_3st


# In[9]:


x4 = [] 
y4 = []

for i in range(len(output_2d_3st[:,0])):
    x4.append(output_2d_3st[i,0])
    y4.append(output_2d_3st[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x4, y4)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')


plt.show()


# In[10]:


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
        sess.run(train,feed_dict={X: matrix_4st})

        
    # Now ask for the hidden layer output (the 2 dimensional output)
    output_2d_4st = hidden.eval(feed_dict={X: matrix_4st})
output_2d_4st


# In[11]:


x5 = [] 
y5 = []

for i in range(len(output_2d_4st[:,0])):
    x5.append(output_2d_4st[i,0])
    y5.append(output_2d_4st[i,1])

fig = plt.figure(figsize = (20,20))
ax = fig.add_subplot(111)
ax.scatter(x5, y5)
plt.title("autoencoder results")
ax.set_xlabel('axis 1')
ax.set_ylabel('axis 2')


plt.show()

