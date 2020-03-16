# -*- coding: utf-8 -*-
"""
Created on Tue Jan 14 11:02:57 2020

@author: matthiasboeker
Import parameters for approximate entropy:
    U: time series 
    m: size of blocks in which the time series get sliced
    r: threshold of the distance measure to match two blocks 
    Return: the approximate Entropy of the time series

"""

import numpy as np

def ApEn(U, m, r):

    def _maxdist(x_i, x_j):
        return max([abs(ua - va) for ua, va in zip(x_i, x_j)])
    #Chebychef distance metrics
    
    def _phi(m):
        #Slicing up the time series in N-m+1 blocks of the same length
        x = [[U[j] for j in range(i, i + m - 1 + 1)] for i in range(N - m + 1)]
        
        #Calculate the enumerator C, match if distance of (x_i, x_j) <= r 
        C = [len([1 for x_j in x if _maxdist(x_i, x_j) <= r]) / (N - m + 1.0)  for x_i in x]
        
        #return phi
        return (N - m + 1.0)**(-1) * sum(np.log(C))
    
    #length of the time series 
    N = len(U)
    
    #return the approximate entropy 
    return abs(_phi(m + 1) - _phi(m))