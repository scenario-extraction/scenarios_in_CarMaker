% This function enables matlab to run the CM Testrun via Dynamic Data Exchange
function   run_sim_via_ch_com( path2ergfile)

new_path_str = path2ergfile;

% preprocess the path string to avoid error while path reading
new_path_str = strrep(path2ergfile,'\','/');

%Initilize communication channel and create the instance
DDE_CH = ddeinit ('TclEval','CarMaker');
% ddeterm(DDE_CH);
% DDE_CH = ddeinit ('TclEval','CarMaker');

%%
%Load TestRun, Start simulation and wait until it is running (but not more then 60s)

ddeexec(DDE_CH,strcat('LoadTestRun',32,'"',new_path_str,'"'), '',60000);

% connect the application
ddeexec(DDE_CH,'Application connect',3000);

ddeexec(DDE_CH,'WaitForStatus idle', '',60000);

ddeexec(DDE_CH,'StartSim');
ddeexec(DDE_CH, 'WaitForStatus running', '',60000);

%Check simulation status
ddeexec(DDE_CH,'set DDE_SimStatus [SimStatus]');
SimStatus = ddereq(DDE_CH,'DDE_SimStatus');
while (SimStatus>=0)
    %<Add the code that you want to execute during simulation>
    pause(1);
    ddeexec(DDE_CH,'set DDE_SimStatus [SimStatus]');
    SimStatus = ddereq(DDE_CH,'DDE_SimStatus');
end

disp('end of resimulation ');

%Close communication DDE_CH
ddeterm(DDE_CH);

end


%% draft!!
% function CarMakerChannel = get_CarMaker_channel()
% persistent CarMaker_channel_persistent
% if isempty(CarMaker_channel_persistent)
%     CarMaker_channel_persistent = ddeinit('TclEval', 'CarMaker');
% end
% CarMakerChannel = CarMaker_channel_persistent;
% end


%----- draft
% ddeexec(ch,'LoadTestRun "Examples/VehicleDynamics/Braking/Braking"', '', 60000);
% ddeexec(ch,'LoadTestRun "F:/Highway_scenarios_overwrite/Data/TestRun/Ground_Truth_label_Highwat_01_ov"', '',60000);
% ddeexec(ch,'Application connect', '',60000);
%After simulation: access last value of subscribed UAQ
% BrakingDist = ddereq(ch,'Qu(DM.ManDist)');
% disp(['Braking distance ', num2str(BrakingDist), ' m']);