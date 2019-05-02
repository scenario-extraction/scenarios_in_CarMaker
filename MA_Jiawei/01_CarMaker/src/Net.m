clc
clear
All_error=[];%storage all errors 
load('DataforTrain.mat');
%---------------------------------------------------
%Load Data
%---------------------------------------------------

load('DataforTrain.mat');

%---------------------------------------------------
%���ݹ�һ������,��һ�����ݵ�[-1,1]��mapminmax����������ʽ
%[y,ps] =%mapminmax(x,ymin,ymax)��x��黯���������룬
%ymin��ymaxΪ��黯���ķ�Χ������Ĭ��Ϊ�黯��[-1,1]
%���ع黯���ֵy���Լ�����ps��ps�ڽ������һ���У���Ҫ����
%---------------------------------------------------


[normInputLong,ps] = mapminmax(Long);
 
[normInputLongLabel,ts] = mapminmax(LongLabel);
 
%ȷ��ѵ�����ݣ���������,һ��������Ĵ�������ѡȡ70%��������Ϊѵ������
 
%15%��������Ϊ�������ݣ�һ����ʹ�ú���dividerand����һ���ʹ�÷������£�
 
%[trainInd,valInd,testInd] = dividerand(Q,trainRatio,valRatio,testRatio)
 
[trainsample.p,valsample.p,testsample.p] =dividerand(Long,0.7,0.15,0.15);
 
[trainsample.t,valsample.t,testsample.t] =dividerand(LongLabel,0.7,0.15,0.15);


%---------------------------------------------------
% �����������
%---------------------------------------------------   
NodeNum1 = 5; % �����һ��ڵ���
NodeNum2=2;   % ����ڶ���ڵ���
TypeNum = 1;   % ���ά��

TF1 = 'tansig';TF2 = 'tansig'; TF3 = 'tansig';%���㴫�亯����TF3Ϊ����㴫�亯��
%���ѵ����������룬���Գ��Ը��Ĵ��亯����������Щ�Ǹ��ഫ�亯��
%TF1 = 'tansig';TF2 = 'logsig';
%TF1 = 'logsig';TF2 = 'purelin';
%TF1 = 'tansig';TF2 = 'tansig';
%TF1 = 'logsig';TF2 = 'logsig';
%TF1 = 'purelin';TF2 = 'purelin';
 
%�������򴫲��㷨��BP�����磬ʹ��newff��������һ���ʹ�÷�������
 
%net = newff(minmax(p),[�������Ԫ�ĸ�������������Ԫ�ĸ���],{������Ԫ�Ĵ��亯���������Ĵ��亯����,'���򴫲���ѵ������'),����pΪ�������ݣ�tΪ�������
 
%tfΪ������Ĵ��亯����Ĭ��Ϊ'tansig'����Ϊ����Ĵ��亯����
 
%purelin����Ϊ�����Ĵ��亯��
 
%һ�������ﻹ�������Ĵ���ĺ���һ������£����Ԥ�������Ч�����Ǻܺã����Ե���
 
%TF1 = 'tansig';TF2 = 'logsig';
 
%TF1 = 'logsig';TF2 = 'purelin';
 
%TF1 = 'logsig';TF2 = 'logsig';
 
%TF1 = 'purelin';TF2 = 'purelin';
 
TF1 = 'tansig';TF2 = 'tansig'; TF3 = 'purelin';%���㴫�亯����TF3Ϊ����㴫�亯��

%net=newff(minmax(p),[10,1],{TF1 TF2},'traingdm');%���紴��
net=newff(minmax(normInput),[NodeNum1,NodeNum2,TypeNum],{TF1 TF2 TF3},'traingdx');%BP����

 
%�������������
 
net.trainParam.epochs=5000;%ѵ����������
 
net.trainParam.goal=1e-7;%ѵ��Ŀ������
 
net.trainParam.lr=0.01;%ѧϰ������,Ӧ����Ϊ����ֵ��̫����Ȼ���ڿ�ʼ�ӿ������ٶȣ����ٽ���ѵ�ʱ�����������������ʹ�޷�����
 
net.trainParam.mc=0.9;%�������ӵ����ã�Ĭ��Ϊ0.9
 
net.trainParam.show=25;%��ʾ�ļ������
 
% ָ��ѵ������
 
% net.trainFcn = 'traingd'; % �ݶ��½��㷨
 
% net.trainFcn = 'traingdm'; % �����ݶ��½��㷨
 
% net.trainFcn = 'traingda'; % ��ѧϰ���ݶ��½��㷨
 
% net.trainFcn = 'traingdx'; % ��ѧϰ�ʶ����ݶ��½��㷨
 
% (�����������ѡ�㷨)
 
% net.trainFcn = 'trainrp'; % RPROP(����BP)�㷨,�ڴ�������С
 
% �����ݶ��㷨
 
% net.trainFcn = 'traincgf'; %Fletcher-Reeves�����㷨
 
% net.trainFcn = 'traincgp'; %Polak-Ribiere�����㷨,�ڴ������Fletcher-Reeves�����㷨�Դ�
 
% net.trainFcn = 'traincgb'; % Powell-Beal��λ�㷨,�ڴ������Polak-Ribiere�����㷨�Դ�
 
% (�����������ѡ�㷨)
 
%net.trainFcn = 'trainscg'; % ScaledConjugate Gradient�㷨,�ڴ�������Fletcher-Reeves�����㷨��ͬ,�����������������㷨��С�ܶ�
 
% net.trainFcn = 'trainbfg'; %Quasi-Newton Algorithms - BFGS Algorithm,���������ڴ�������ȹ����ݶ��㷨��,�������ȽϿ�
 
% net.trainFcn = 'trainoss'; % OneStep Secant Algorithm,���������ڴ��������BFGS�㷨С,�ȹ����ݶ��㷨�Դ�
 
% (�����������ѡ�㷨)
 
%net.trainFcn = 'trainlm'; %Levenberg-Marquardt�㷨,�ڴ��������,�����ٶ����
 
% net.trainFcn = 'trainbr'; % ��Ҷ˹�����㷨
 
% �д����Ե������㷨Ϊ:'traingdx','trainrp','trainscg','trainoss', 'trainlm'
 
%������һ����ѡȡ'trainlm'������ѵ��������Զ�Ӧ����Levenberg-Marquardt�㷨

 
net.trainFcn='trainlm';
 
[net,tr]=train(net,trainsample.p,trainsample.t);
 
%������棬��һ����sim����
 
[normtrainoutput,trainPerf]=sim(net,trainsample.p,[],[],trainsample.t);%ѵ�������ݣ�����BP�õ��Ľ��
 
[normvalidateoutput,validatePerf]=sim(net,valsample.p,[],[],valsample.t);%��֤�����ݣ���BP�õ��Ľ��
 
[normtestoutput,testPerf]=sim(net,testsample.p,[],[],testsample.t);%�������ݣ���BP�õ��Ľ��
 
%�����õĽ�����з���һ�����õ�����ϵ�����
 
trainoutput=mapminmax('reverse',normtrainoutput,ts);
 
validateoutput=mapminmax('reverse',normvalidateoutput,ts);
 
testoutput=mapminmax('reverse',normtestoutput,ts);
 
%������������ݵķ���һ���Ĵ����õ�����ʽֵ
 
trainvalue=mapminmax('reverse',trainsample.t,ts);%��������֤����
 
validatevalue=mapminmax('reverse',valsample.t,ts);%��������֤������
 
testvalue=mapminmax('reverse',testsample.t,ts);%�����Ĳ�������
 
%��Ԥ�⣬����ҪԤ�������pnew
 
pnew=[313,256,239]';
pnewn=mapminmax(pnew);
anewn=sim(net,pnewn);
anew=mapminmax('reverse',anewn,ts);

%�������ļ���
errors=trainvalue-trainoutput;
%plotregression���ͼ
figure,plotregression(trainvalue,trainoutput)
%���ͼ
figure,plot(1:length(errors),errors,'-b')
title('���仯ͼ')
%���ֵ����̬�Եļ���
figure,hist(errors);%Ƶ��ֱ��ͼ
figure,normplot(errors);%Q-Qͼ
[muhat,sigmahat,muci,sigmaci]=normfit(errors);%�������� ��ֵ,����,��ֵ��0.95��������,�����0.95��������
[h1,sig,ci]= ttest(errors,muhat);%�������
figure, ploterrcorr(errors);%�������������ͼ
