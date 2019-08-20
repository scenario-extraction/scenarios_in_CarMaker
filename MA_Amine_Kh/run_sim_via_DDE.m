% This function enables matlab to run the CM Testrun via Dynamic Data
% Exchange. This function is used essentially by the process of autommationg the running of Testseries
function   run_sim_via_DDE( path2ergfile)

%preallocate
new_path_str = path2ergfile;

% preprocess the path string to avoid error while parsing the path
new_path_str = strrep(path2ergfile,'\','/');

%Initilize communication channel and create the instance
DDE_CH = ddeinit ('TclEval','CarMaker');

%%
%Load TestRun, Start simulation and wait until it is running (but not more then 60s)

% disp message
disp('starting the resimulation ...');

% load the testrun
ddeexec(DDE_CH,strcat('LoadTestRun',32,'"',new_path_str,'"'), '',120000);
ddeexec(DDE_CH,'WaitForStatus idle', '',60000);
ddeexec(DDE_CH,'StartSim');
ddeexec(DDE_CH, 'WaitForStatus running', '',60000);

%Check simulation status
ddeexec(DDE_CH,'set DDE_SimStatus [SimStatus]');
SimStatus = ddereq(DDE_CH,'DDE_SimStatus');
while (SimStatus>=0)
    pause(1);
    ddeexec(DDE_CH,'set DDE_SimStatus [SimStatus]');
    SimStatus = ddereq(DDE_CH,'DDE_SimStatus');
end
ddeexec(DDE_CH,'WaitForStatus idle', '',60000);

%disp message
disp('end of resimulation ');

%Close communication channel
ddeterm(DDE_CH);

end
