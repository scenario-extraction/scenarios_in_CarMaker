#!/usr/bin/env python
# coding: utf-8

# In[15]:


from sklearn.manifold import TSNE
import numpy as np
import matplotlib.pyplot as plt


# In[16]:


#load the data matrics
matrix_3st=np.loadtxt('matrix63.txt')
print('3 state scenario matrics has the shape:',matrix_3st.shape)


# In[17]:


unique3 = np.unique(matrix_3st,axis =0)
print(unique3.shape)


# ## Max-Min Normalization
# $$
# x^{\prime}=\frac{x-\min (x)}{\max (x)-\min (x)}
# $$

# In[18]:


from sklearn.preprocessing import MinMaxScaler

scaler3 = MinMaxScaler()
scaler3.fit(unique3)
normal3 = scaler3.transform(unique3)


# In[19]:


normal3


# ### two approach 
# #### handcraft labeling
# - visual observation through carmaker
# - choose the anomaly scenario 
# - label the anomaly scenario
# 
# #### clustering labeling

# ## Model training using Loop driving data
# 
# ![loop](..\Masterarbeit\pic\kreisfahrt.jpg)

# In[20]:


n_input_1 = 7
n_input_2 = 14
n_input_3 = 21
n_input_4 = 28


# In[21]:


# Labeling data
# from pyod.models.iforest import IForest
# from sklearn.manifold import TSNE
# iforest2 = IForest()
# iforest2.fit(unique2)

# tsne = TSNE(n_components = 2)

# #visualization the labeled data in 2D
# X2 = tsne.fit_transform(unique2)
# plt.figure(figsize=(20, 20))
# plt.scatter(X2[:,0], X2[:,1], c = iforest2.labels_)
# plt.show()


# In[22]:


import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

# Parameters
learning_rate = 0.008
training_epochs = 130
batch_size = 560    # the batch size can not exceed the size of the data.


# In[23]:


# Building the encoder
def encoder(x,weights,biases):
    # Encoder Hidden layer with sigmoid activation #1
    layer_1 = tf.nn.sigmoid(tf.add(tf.matmul(x, weights['encoder_h1']),
                                   biases['encoder_b1']))
    # Decoder Hidden layer with sigmoid activation #2
    layer_2 = tf.nn.sigmoid(tf.add(tf.matmul(layer_1, weights['encoder_h2']),
                                   biases['encoder_b2']))
    return layer_2


# In[24]:


# Building the decoder
def decoder(x,weights,biases):
    # Encoder Hidden layer with sigmoid activation #1
    layer_1 = tf.nn.sigmoid(tf.add(tf.matmul(x, weights['decoder_h1']),
                                   biases['decoder_b1']))
    # Decoder Hidden layer with sigmoid activation #2
    layer_2 = tf.nn.sigmoid(tf.add(tf.matmul(layer_1, weights['decoder_h2']),
                                   biases['decoder_b2']))
    return layer_2


# In[25]:


tf.reset_default_graph()


# In[26]:


from sklearn.utils import shuffle
def one_class_learning(dataset,testset):
    # Network Parameters
    n_input = 21
    n_hidden_1 = int(n_input/2)
    n_hidden_2 = int(n_input/2)
    # tf Graph input (only pictures)
    X = tf.placeholder("float", [None, n_input])

    weights = {
        'encoder_h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
        'encoder_h2': tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2])),
        'decoder_h1': tf.Variable(tf.random_normal([n_hidden_2, n_hidden_1])),
        'decoder_h2': tf.Variable(tf.random_normal([n_hidden_1, n_input])),
    }
    biases = {
        'encoder_b1': tf.Variable(tf.random_normal([n_hidden_1])),
        'encoder_b2': tf.Variable(tf.random_normal([n_hidden_2])),
        'decoder_b1': tf.Variable(tf.random_normal([n_hidden_1])),
        'decoder_b2': tf.Variable(tf.random_normal([n_input])),
    }
    # Construct model
    encoder_op = encoder(X,weights,biases)
    decoder_op = decoder(encoder_op,weights,biases)
    # Prediction
    y_pred = decoder_op
    # Targets (Labels) are the input data.
    y_true = X
    # Define loss and optimizer, minimize the squared error
    cost = tf.reduce_mean(tf.pow(y_true - y_pred, 2))
    optimizer = tf.train.RMSPropOptimizer(learning_rate).minimize(cost)

    # Initializing the variables
    init = tf.global_variables_initializer()
    lost = []
    
    # Launch the graph
    with tf.Session() as sess2:
        sess2.run(init)
        total_batch = int(len(dataset['data'])/batch_size)
        dataset = shuffle(dataset['data'])
        
        # Training cycle
        for epoch in range(training_epochs):
            
            # Loop over all batches
            for i in range(total_batch):
                batch_xs = dataset[i*batch_size:(i+1)*batch_size]
                #batch_ys = dataset['label'][i*batch_size:(i+1)*batch_size]
                
                # Run optimization op (backprop) and cost op (to get loss value)
                _, co = sess2.run([optimizer, cost], feed_dict={X: batch_xs})
                
            # Display logs per epoch step
            print("Epoch:", '%04d' % (epoch+1),"cost=", "{:.9f}".format(co))
            lost.append(co)

        encode_decode = sess2.run(y_pred, feed_dict={X: testset['data']})
        error = sess2.run(tf.reduce_mean(tf.pow(testset['data'] - encode_decode, 2)))
        f, a = plt.subplots(2,2, figsize=(14, 14))
        
        for i in range(2):

            print(testset['label'][i],sess2.run(tf.reduce_mean(tf.pow(testset['data'][i] - encode_decode[i], 2))))
            a[0][i].matshow(testset['data'][i:i+10])
            a[1][i].matshow(encode_decode[i:i+10])
            
        f.show()
        
        saver = tf.train.Saver()
        tf.add_to_collection('pred_network', y_pred)
        tf.add_to_collection('AE_input',X)
        saver.save(sess2,'../Masterarbeit/model_3st/model_3st')
        print("Model saved")
        
#             self supervised learning
#             for j in range(len(testset['data'])):
#             error.append(sess.run(tf.reduce_mean(tf.pow(testset['data'][j] - encode_decode[j], 2))))
            

    return lost, error
#     examples_to_show = 14
#     f, a = plt.subplots(2, examples_to_show, figsize=(examples_to_show, 2))
#     for i in range(examples_to_show):
#         print(testset['label'][i],sess.run(tf.reduce_mean(tf.pow(testset['data'][i] - encode_decode[i], 2))))
#         a[0][i].imshow(np.reshape(testset['data'][i], (28, 28)))
#         a[1][i].imshow(np.reshape(encode_decode[i], (28, 28)))
#     f.show()
#     plt.draw()
#     plt.waitforbuttonpress()
#         wf = open(filename,'a+')
#         for i in range(len(encode_decode)):
#             wf.write(str(one_class_label)+','+str(testset['label'][i])+','+str(sess.run(tf.reduce_mean(tf.pow(testset['data'][i] - encode_decode[i], 2))))+'\n')
#             if i % 500 == 0:
#                 print(i)
#         wf.close()


# In[27]:


def train(X_train,X_test):
    trainset = {'data':X_train,'label':np.zeros(len(X_train))}
    testset  = {'data':X_test,'label':np.zeros(len(X_test))}
    lost,error = one_class_learning(trainset,testset)
    return lost,error


# In[28]:


X_train3, X_test3 = train_test_split(normal3, test_size=0.1, random_state=920)
lost3,error3 = train(X_train3, X_test3)

