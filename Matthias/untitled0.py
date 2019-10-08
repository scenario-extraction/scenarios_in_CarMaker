#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 25 14:57:07 2019

@author: matthiasboeker
"""


std_t1 = np.std(ref_left)
std_t2 = np.std(signal[len(ref_left):2*len(ref_left)])
mean_t1 = np.mean(ref_left)
mean_t2 = np.mean(signal[len(ref_left):2*len(ref_left)])
if ((std_t1 and mean_t1) and (std_t1 and std_t2)) != 0:
    tseries1 = (ref_left-mean_t1)/std_t1
    tseries2 = (signal[len(ref_left):2*len(ref_left)]-mean_t2)/std_t2


    
dist = np.zeros((len(ref_left), len(signal[0:len(ref_left)])))

for i in range(0,len(ref_left)):
    for j in range(0,len(signal[0:len(ref_left)])):
        dist[i,j] = (signal[0:len(ref_left)][j]-ref_left[i])**2
        
accumulated_cost = np.zeros((len(ref_left), len(signal[0:len(ref_left)])))
accumulated_cost[0,0] = dist[0,0]
print(accumulated_cost)
for i in range(len(ref_left)):
    accumulated_cost[i,0] = dist[i, 0] + accumulated_cost[i-1, 0]
for i in range(len(signal[0:len(ref_left)])):
    accumulated_cost[0,i] = dist[0, i] + accumulated_cost[0, i-1]
for i in range(1,len(ref_left)):
    for j in range(1,len(signal[0:len(ref_left)])):
        accumulated_cost[i, j] = min(accumulated_cost[i-1, j-1], accumulated_cost[i-1, j], accumulated_cost[i, j-1]) + dist[i, j]


test = DTW()

cost_l = list()
for i in range(0,int(len(signal))-len(ref_left), 10):
    tsignal = signal[i:i+len(ref_left)]
    cost, path = test.simple_DTW(ref_left,tsignal)
    cost_l.append(cost) 



plt.plot(pf)
plt.ylabel('Raw Signal')
plt.show
