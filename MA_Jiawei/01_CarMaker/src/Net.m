clc
clear
All_error=[];%storage all errors 
load('DataforTrain.mat');
%---------------------------------------------------
%Load Data
%---------------------------------------------------

load('DataforTrain.mat');

%---------------------------------------------------
%数据归一化处理,归一化数据到[-1,1]，mapminmax函数调用形式
%[y,ps] =%mapminmax(x,ymin,ymax)，x需归化的数据输入，
%ymin，ymax为需归化到的范围，不填默认为归化到[-1,1]
%返回归化后的值y，以及参数ps，ps在结果反归一化中，需要调用
%---------------------------------------------------


[normInputLong,ps] = mapminmax(Long);
 
[normInputLongLabel,ts] = mapminmax(LongLabel);
 
%确定训练数据，测试数据,一般是随机的从样本中选取70%的数据作为训练数据
 
%15%的数据作为测试数据，一般是使用函数dividerand，其一般的使用方法如下：
 
%[trainInd,valInd,testInd] = dividerand(Q,trainRatio,valRatio,testRatio)
 
[trainsample.p,valsample.p,testsample.p] =dividerand(Long,0.7,0.15,0.15);
 
[trainsample.t,valsample.t,testsample.t] =dividerand(LongLabel,0.7,0.15,0.15);


%---------------------------------------------------
% 设置网络参数
%---------------------------------------------------   
NodeNum1 = 5; % 隐层第一层节点数
NodeNum2=2;   % 隐层第二层节点数
TypeNum = 1;   % 输出维数

TF1 = 'tansig';TF2 = 'tansig'; TF3 = 'tansig';%各层传输函数，TF3为输出层传输函数
%如果训练结果不理想，可以尝试更改传输函数，以下这些是各类传输函数
%TF1 = 'tansig';TF2 = 'logsig';
%TF1 = 'logsig';TF2 = 'purelin';
%TF1 = 'tansig';TF2 = 'tansig';
%TF1 = 'logsig';TF2 = 'logsig';
%TF1 = 'purelin';TF2 = 'purelin';
 
%建立反向传播算法的BP神经网络，使用newff函数，其一般的使用方法如下
 
%net = newff(minmax(p),[隐层的神经元的个数，输出层的神经元的个数],{隐层神经元的传输函数，输出层的传输函数｝,'反向传播的训练函数'),其中p为输入数据，t为输出数据
 
%tf为神经网络的传输函数，默认为'tansig'函数为隐层的传输函数，
 
%purelin函数为输出层的传输函数
 
%一般在这里还有其他的传输的函数一般的如下，如果预测出来的效果不是很好，可以调节
 
%TF1 = 'tansig';TF2 = 'logsig';
 
%TF1 = 'logsig';TF2 = 'purelin';
 
%TF1 = 'logsig';TF2 = 'logsig';
 
%TF1 = 'purelin';TF2 = 'purelin';
 
TF1 = 'tansig';TF2 = 'tansig'; TF3 = 'purelin';%各层传输函数，TF3为输出层传输函数

%net=newff(minmax(p),[10,1],{TF1 TF2},'traingdm');%网络创建
net=newff(minmax(normInput),[NodeNum1,NodeNum2,TypeNum],{TF1 TF2 TF3},'traingdx');%BP网络

 
%网络参数的设置
 
net.trainParam.epochs=5000;%训练次数设置
 
net.trainParam.goal=1e-7;%训练目标设置
 
net.trainParam.lr=0.01;%学习率设置,应设置为较少值，太大虽然会在开始加快收敛速度，但临近最佳点时，会产生动荡，而致使无法收敛
 
net.trainParam.mc=0.9;%动量因子的设置，默认为0.9
 
net.trainParam.show=25;%显示的间隔次数
 
% 指定训练参数
 
% net.trainFcn = 'traingd'; % 梯度下降算法
 
% net.trainFcn = 'traingdm'; % 动量梯度下降算法
 
% net.trainFcn = 'traingda'; % 变学习率梯度下降算法
 
% net.trainFcn = 'traingdx'; % 变学习率动量梯度下降算法
 
% (大型网络的首选算法)
 
% net.trainFcn = 'trainrp'; % RPROP(弹性BP)算法,内存需求最小
 
% 共轭梯度算法
 
% net.trainFcn = 'traincgf'; %Fletcher-Reeves修正算法
 
% net.trainFcn = 'traincgp'; %Polak-Ribiere修正算法,内存需求比Fletcher-Reeves修正算法略大
 
% net.trainFcn = 'traincgb'; % Powell-Beal复位算法,内存需求比Polak-Ribiere修正算法略大
 
% (大型网络的首选算法)
 
%net.trainFcn = 'trainscg'; % ScaledConjugate Gradient算法,内存需求与Fletcher-Reeves修正算法相同,计算量比上面三种算法都小很多
 
% net.trainFcn = 'trainbfg'; %Quasi-Newton Algorithms - BFGS Algorithm,计算量和内存需求均比共轭梯度算法大,但收敛比较快
 
% net.trainFcn = 'trainoss'; % OneStep Secant Algorithm,计算量和内存需求均比BFGS算法小,比共轭梯度算法略大
 
% (中型网络的首选算法)
 
%net.trainFcn = 'trainlm'; %Levenberg-Marquardt算法,内存需求最大,收敛速度最快
 
% net.trainFcn = 'trainbr'; % 贝叶斯正则化算法
 
% 有代表性的五种算法为:'traingdx','trainrp','trainscg','trainoss', 'trainlm'
 
%在这里一般是选取'trainlm'函数来训练，其算对对应的是Levenberg-Marquardt算法

 
net.trainFcn='trainlm';
 
[net,tr]=train(net,trainsample.p,trainsample.t);
 
%计算仿真，其一般用sim函数
 
[normtrainoutput,trainPerf]=sim(net,trainsample.p,[],[],trainsample.t);%训练的数据，根据BP得到的结果
 
[normvalidateoutput,validatePerf]=sim(net,valsample.p,[],[],valsample.t);%验证的数据，经BP得到的结果
 
[normtestoutput,testPerf]=sim(net,testsample.p,[],[],testsample.t);%测试数据，经BP得到的结果
 
%将所得的结果进行反归一化，得到其拟合的数据
 
trainoutput=mapminmax('reverse',normtrainoutput,ts);
 
validateoutput=mapminmax('reverse',normvalidateoutput,ts);
 
testoutput=mapminmax('reverse',normtestoutput,ts);
 
%正常输入的数据的反归一化的处理，得到其正式值
 
trainvalue=mapminmax('reverse',trainsample.t,ts);%正常的验证数据
 
validatevalue=mapminmax('reverse',valsample.t,ts);%正常的验证的数据
 
testvalue=mapminmax('reverse',testsample.t,ts);%正常的测试数据
 
%做预测，输入要预测的数据pnew
 
pnew=[313,256,239]';
pnewn=mapminmax(pnew);
anewn=sim(net,pnewn);
anew=mapminmax('reverse',anewn,ts);

%绝对误差的计算
errors=trainvalue-trainoutput;
%plotregression拟合图
figure,plotregression(trainvalue,trainoutput)
%误差图
figure,plot(1:length(errors),errors,'-b')
title('误差变化图')
%误差值的正态性的检验
figure,hist(errors);%频数直方图
figure,normplot(errors);%Q-Q图
[muhat,sigmahat,muci,sigmaci]=normfit(errors);%参数估计 均值,方差,均值的0.95置信区间,方差的0.95置信区间
[h1,sig,ci]= ttest(errors,muhat);%假设检验
figure, ploterrcorr(errors);%绘制误差的自相关图
