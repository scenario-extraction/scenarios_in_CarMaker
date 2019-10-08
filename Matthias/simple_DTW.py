#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jul  1 10:59:54 2019

@author: matthiasboeker
"""

#DTW Function 

class SWindow(DTW):
    
    def __init__(self, ref_signal,  signal, labels, step_size=10, testing_p = 1 ):
        
        self.labels = labels
        self.signal = signal
        self.ref_signal = ref_signal
        self.win_size = len(self.ref_signal)
        self.ss_l = int(self.win_size/step_size)
        self.cost_l = list()
        self.label_ref = list()
        self.testing_p = testing_p
        


    def sliding_window_label(self,window_labelling = 1/2,direction = 1):
        
        if direction not in [1,-1,0]:
            print('Please only enter direction 1, -1, 0')
    
    #First sliding window approach - overtaking right 
        
        for i in range(0,int(len(self.labels)*self.testing_p)-self.win_size, self.ss_l):
            t = self.labels[i:i+self.win_size]
            if np.count_nonzero(~np.isnan(t[t == direction]))>int(self.win_size*window_labelling):
                self.label_ref.append(1)
            else:
                self.label_ref.append(0)
    
        return self.label_ref
    
    def sliding_window(self):

        #First sliding window approach - overtaking right 
        for i in range(0,int(len(self.signal)*self.testing_p)-self.win_size, self.ss_l):
            tsignal = self.signal[i:i+self.win_size]
            cost, path = super().simple_DTW(self.ref_signal,tsignal)
            self.cost_l.append(cost) 
        return self.cost_l
    #Labelling the data 
    #df_dl = pd.DataFrame(dist) 
    #df_dl.columns = ['signal']
   # df_dl['label'] = labels

    
