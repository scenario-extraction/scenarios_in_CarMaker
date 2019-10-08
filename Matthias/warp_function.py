#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jul  1 14:01:34 2019

@author: matthiasboeker
Warping Function 
Finds the cost optimal Warping Path through the cost matrix with Backtracking 
"""

class DTW():

    
    def warp_function(self, tseries1,tseries2,accumulated_cost, dist):
        path = [[len(tseries1)-1, len(tseries2)-1]]
        i = len(tseries1)-1
        j = len(tseries2)-1
        while i>0 and j>0:
            if i==0:
                j = j - 1
            elif j==0:
                i = i - 1
            else:
                if accumulated_cost[i-1, j] == min(accumulated_cost[i-1, j-1], accumulated_cost[i-1, j], accumulated_cost[i, j-1]):
                    i = i - 1
                elif accumulated_cost[i, j-1] == min(accumulated_cost[i-1, j-1], accumulated_cost[i-1, j], accumulated_cost[i, j-1]):
                    j = j-1
                else:
                    i = i - 1
                    j= j- 1
            path.append([j, i])
        path.append([0,0])
        cost = 0
        for [k, m] in path:
            cost = cost + dist[m, k]
        
        return cost, path
    
    def simple_DTW(self,tseries1,tseries2):
    
    #Setting up the Distance Metrics 
        dist = np.zeros((len(tseries1), len(tseries2)))
        derv1 = np.zeros(len(tseries1))
        derv2 = np.zeros(len(tseries2))
    
    
        #Normalise the two sequenzes
        
        #std_t1 = np.std(tseries1)
        #std_t2 = np.std(tseries2)
        #mean_t1 = np.mean(tseries1)
        #mean_t2 = np.mean(tseries2)
        #if ((std_t1 and mean_t1) and (std_t1 and std_t2)) != 0:
         #   tseries1 = (tseries1-mean_t1)/std_t1
          #  tseries2 = (tseries2-mean_t2)/std_t2
        #else:
         #   tseries1 = tseries1
          #  tseries2 = tseries1
    
    
    #Euclidean distance between the pairs of points
        for i in range(1,len(tseries1)-1):
            derv1[i] = 1/2*(tseries1[i]-tseries1[i-1])+ 1/4*(tseries1[i+1]-tseries1[i-1])
        for j in range(1,len(tseries2)-1):
            derv2[j] = 1/2*(tseries2[j]-tseries2[j-1])+ 1/4*(tseries2[j+1]-tseries2[j-1])
        #print(len(derv1))
        #print(len(derv2))
        #print(np.shape(dist))
        for i in range(0,len(tseries1)):
            for j in range(0,len(tseries2)):
                dist[i,j] = (tseries2[j]-tseries1[i])**2    
        
    #Warping Path 
    #Creation of the Accumulation Cost Matrix
    
        accumulated_cost = np.zeros((len(tseries1), len(tseries2)))
        accumulated_cost[0,0] = dist[0,0]
        for i in range(len(tseries1)):
            accumulated_cost[i,0] = dist[i, 0] + accumulated_cost[i-1, 0]
        for i in range(len(tseries2)):
            accumulated_cost[0,i] = dist[0, i] + accumulated_cost[0, i-1]
        for i in range(1,len(tseries1)):
            for j in range(1,len(tseries2)):
                accumulated_cost[i, j] = min(accumulated_cost[i-1, j-1], accumulated_cost[i-1, j], accumulated_cost[i, j-1]) + dist[i, j]
    
    
        #Usage of Backtracking in order to find Warping Path 
        cost, path = self.warp_function(tseries1,tseries2,accumulated_cost, dist)
        return cost, path
    
    
    
    
 
