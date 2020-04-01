#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec  6 11:25:02 2019

@author: matthiasboeker
Create Correlation Matrices and Dendrograms for test runs
"""



#Pre selected correlation analysis 
#Try to cut the dendograms at a level so that 6 - 8 clusters are left 

store_alloc = list()

for i in range(0,len(data_list)):
    data = data_list[i]
    
    #data.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/Data_Left_2.csv'
               # ,sep=";", index = False)
    #Check which columns do not vary
    #proc_data = data.loc[:, (data != data.iloc[0]).any()] 
    #proc_data.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/p_Data_Left_1.csv'
               # ,sep=";", index = False)
    
    
    
    #Select signals from preselect
    proc_data = data[pre_select[i].index.values]
    
    
    
    #Create Correlation Matrix
    corr = proc_data.corr()
    corr = 1- corr.abs()
    
    #corr.to_csv('/Users/matthiasboeker/Documents/Uni/ITIV/TS_Classification_DTW/Multivariate_Data/Corr_Right_2.csv'
                #,sep=";", index = False)
    
    #Prepare Heatmap
   # mask = np.zeros_like(corr, dtype=np.bool)
    #mask[np.triu_indices_from(mask)] = True
    #f, ax = plt.subplots(figsize=(12, 10))
    #sns.heatmap(corr, mask=mask, cmap="coolwarm", vmax=1, center=0,xticklabels=corr.columns,
      #          yticklabels=corr.columns,square=True)
    "Only uncomment if the plot should be safed"
    #os.chdir('C:/Users/uwdkg/DTW_Scripts/Correlation_Matrices')
    #f.savefig('Corr_Left_2_Absolute.pdf',bbox_inches = "tight")
    
    
    #g, dendrogram = plt.subplots(figsize=(12, 10))
    #dendrogram = sch.dendrogram(sch.linkage(corr, method='ward'), labels=corr.columns, leaf_font_size=10,leaf_rotation=60)
    
    
    #Save clusters of 6
    sig_in_clusters = sch.fcluster(sch.linkage(corr, method='ward'),6,'maxclust')
    
    #Allocate signals and cluster 
    alloc = pd.DataFrame(np.transpose([corr.index,sig_in_clusters]),columns=['Signal', 'ClusterNr'])

    store_alloc.append(alloc)
    #plt.xlabel('Signals')
    #plt.ylabel('Euc. Distance of R2')
    #os.chdir('C:/Users/uwdkg/DTW_Scripts/Correlation_Matrices')
    
    #if i < 20:
        #g.savefig('Dendo_Ego_Left_Object_Left'+str(i)+'.pdf',bbox_inches = "tight")
    #if (i>19)and(i<40):
        #g.savefig('Dendo_Ego_Left_Object_Right_'+str(i-20)+'.pdf',bbox_inches = "tight")
    #if (i>39)and(i<60):
        #g.savefig('Dendo_Ego_Right_Object_Left_'+str(i-40)+'.pdf',bbox_inches = "tight")
    #if (i>59)and(i<80):
        #g.savefig('Dendo_Ego_Right_Object_Right_'+str(i-60)+'.pdf',bbox_inches = "tight")

del sig_in_clusters 
del alloc 
del corr    
        
        

