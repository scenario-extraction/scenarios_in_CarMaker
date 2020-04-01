# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 16:03:46 2020

@author: uwdkg
Furhter Evaluation


"""

ground_truth = label_list


#Simple sum

dtw_windowed = list()
dtw_weighted_sum = list()
dtw_result_list = list([right_right_Results,right_left_Results,left_right_Results, left_left_Results])
simple_sum_list = list()
binary_list = list()

#Binary classification hit the Window or not 
for k in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[k])):
        binary = np.zeros(dtw_result_list[k][i].shape[1])
        for j in range(0,dtw_result_list[k][i].shape[1]):
            
            start = dtw_result_list[k][i].iloc[:,j].idxmin()
            interval_dtw = np.array(range(start*10,(start*10)+280))
            interval_gt = np.array(range(ground_truth[i+20*k][0],ground_truth[i+20*k][1]))
            
            min_s = min(min(interval_gt),min(interval_dtw))
            max_e = max(max(interval_gt),max(interval_dtw))
            overall = np.array(range(min_s,max_e))
            overlap1 = np.isin(overall,interval_dtw).astype(int)
            overlap2 = np.isin(overall,interval_gt).astype(int)
            res = np.add(overlap1,overlap2)
                
            #print(sum(overlap)> len(overlap)*threshold)
            if np.isin(res,2).any():
                binary[j] = 1
                
            bin_output = pd.DataFrame(binary, index=dtw_result_list[k][i].columns.values)
        binary_list.append(binary)


threshold = 0.4

#Simple addition of DTW Results 
for j in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[j])):
        simple_sum = dtw_result_list[j][i].sum(axis=1)
        #plt.plot(simple_sum)
        dtw_windowed.append(simple_sum)
        
#Binary classification of the simple sum 
results_bin_sim_sum = np.zeros(len(dtw_windowed))
for k in range(0,len(dtw_windowed)):
    start = np.argmin(np.array(dtw_windowed[k]))
    interval_dtw = np.array(range(start*10,(start*10)+280))
    interval_gt = np.array(range(ground_truth[k][0],ground_truth[k][1]))
            
    min_s = min(min(interval_gt),min(interval_dtw))
    max_e = max(max(interval_gt),max(interval_dtw))
    overall = np.array(range(min_s,max_e))
    
    overlap1 = np.isin(overall,interval_dtw).astype(int)
    overlap2 = np.isin(overall,interval_gt).astype(int)
    res = np.add(overlap1,overlap2)
    if np.isin(res,2).any():
        results_bin_sim_sum[k] = 1


        
#Overlapping results
results_sum = np.zeros(len(dtw_windowed))
for k in range(0,len(dtw_windowed)):
    start = np.argmin(np.array(dtw_windowed[k]))
    interval_dtw = np.array(range(start*10,(start*10)+280))
    interval_gt = np.array(range(ground_truth[k][0],ground_truth[k][1]))
            
    min_s = min(min(interval_gt),min(interval_dtw))
    max_e = max(max(interval_gt),max(interval_dtw))
    overall = np.array(range(min_s,max_e))
    
    overlap1 = np.isin(overall,interval_dtw).astype(int)
    overlap2 = np.isin(overall,interval_gt).astype(int)
    res = np.add(overlap1,overlap2)
    if sum(res-1)> len(res)*threshold:
        results_sum[k] = 1



#Weighted addition of the DTW Results 
k = 0
for j in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[j])):
        signals = Allocation[k].groupby('Cluster')['A-Score'].idxmin().array
        sorted_signals = Allocation[k]['A-Score'].loc[signals].sort_values()
        weighted_sum = 0.5*dtw_result_list[j][i][sorted_signals.index.values[0]]+0.3*dtw_result_list[j][i][sorted_signals.index.values[1]]+0.2*dtw_result_list[j][i][sorted_signals.index.values[2]]
        dtw_weighted_sum.append(weighted_sum)
        k += 1
        #dtw_windowed.append(simple_sum)
      
results_weighted_sum = np.zeros(len(dtw_windowed))
for k in range(0,len(dtw_windowed)):
    start = np.argmin(np.array(dtw_windowed[k]))
    interval_dtw = np.array(range(start*10,(start*10)+280))
    interval_gt = np.array(range(ground_truth[k][0],ground_truth[k][1]))
            
    min_s = min(min(interval_gt),min(interval_dtw))
    max_e = max(max(interval_gt),max(interval_dtw))
    overall = np.array(range(min_s,max_e))
    
    overlap1 = np.isin(overall,interval_dtw).astype(int)
    overlap2 = np.isin(overall,interval_gt).astype(int)
    res = np.add(overlap1,overlap2)
    if sum(res-1)> len(res)*threshold:
        results_weighted_sum[k] = 1
        




run_output_list = list()

for k in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[k])):
        results_sum = np.zeros(dtw_result_list[k][i].shape[1])
        for j in range(0,dtw_result_list[k][i].shape[1]):
            
            start = dtw_result_list[k][i].iloc[:,j].idxmin()
            interval_dtw = np.array(range(start*10,(start*10)+280))
            interval_gt = np.array(range(ground_truth[i+20*k][0],ground_truth[i+20*k][1]))
            
            min_s = min(min(interval_gt),min(interval_dtw))
            max_e = max(max(interval_gt),max(interval_dtw))
            overall = np.array(range(min_s,max_e))
            overlap1 = np.isin(overall,interval_dtw).astype(int)
            overlap2 = np.isin(overall,interval_gt).astype(int)
            res = np.add(overlap1,overlap2)
                
            
            #print(sum(overlap)> len(overlap)*threshold)
            if sum(res-1)> len(res)*threshold:
                results_sum[j] = 1
                
            run_output = pd.DataFrame(results_sum, index=dtw_result_list[k][i].columns.values)
        run_output_list.append(run_output)




#Detect which signales were used 
selected_signals = pd.Series()
for j in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[j])):
        signals = pd.Series(dtw_result_list[j][i].columns.values)
        selected_signals = pd.concat([selected_signals, signals], axis = 1)

selected_signals = selected_signals.iloc[:,1:]


titles = ['Ego Right, Object Right', 'Ego Right, Object Left','Ego Left, Object Right','Ego Left, Object Left',]
from collections import Counter
j=0
for i in range(0,80, 20):
    flat = selected_signals.iloc[:,i:i+20].values.flatten()
    word_count = Counter(flat)
    df = pd.DataFrame.from_dict(word_count, orient='index')
    fig = df.plot(kind='bar', title =titles[j]).get_figure()
    j += 1
    fig.savefig('Selected_Signals_run'+str(j)+'.pdf')

flat = selected_signals.values.flatten()
word_count = Counter(flat)
df = pd.DataFrame.from_dict(word_count, orient='index')
fig = df.plot(kind='bar', title ='All Scenarios').get_figure()
fig.savefig('Selected_Signals_all_runs.pdf')


#Dependency of A-Score and Classification
k = 0
corr_list = list()
for j in range(0,len(dtw_result_list)):
    for i in range(0,len(dtw_result_list[j])):
        bins = binary_list[k]
        aa = ApEn_Result_list[k]['A-Score'].loc[dtw_result_list[j][i].columns.values]
        bins = pd.DataFrame(bins, index= dtw_result_list[j][i].columns.values)
        bins = bins.merge(ApEn_Result_list[79]['A-Score'].loc[dtw_result_list[j][i].columns.values], on = bins.index)
        corr_list.append(bins)
        k+= 1
        
        
a = corr_list[0]       
for i in range(1,80):
    a = a.append(corr_list[i])
plot_df = a.iloc[:,1:]
plot_df.columns = ['Class','A-Score' ]
plot_df['A-Score'] = np.abs(plot_df['A-Score'])
plot_df.plot.scatter(y='Class', x='A-Score')
plot_df.groupby('Class')['A-Score'].plot.density()

