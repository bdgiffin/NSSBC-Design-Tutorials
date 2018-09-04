function [ time ] = construct( Nrunners, Nbargers, Nmembers, Nbolts, varargin )
%Runs a simulation of a construction run using the input params
% [ time ] = construct( Nrunners, Nbargers, Nmembers, Nbolts, [Timers] )
% time is measured in minutes
% Timers is an optional array input used to change the default task timers
% By default, the task timers are (in seconds):
% Trunner_bolts_all = 16 --- time taken for a runner to retrieve all bolts
% Trunner_there = 5 -------- time taken for a runner to run to the bridge
% Trunner_back = 4 --------- time taken for a runner to run back
% Tbarger_bolts_all = 0 ---- time taken for a barger to pouch their bolts
% Tbarger_member = 8 ------- time taken for a barger to install a member
% Tbarger_bolt = 10 -------- time taken for a barger to install a bolt
    
%initialize all builders
for i = 1:Nrunners
    Runner{i} = struct('name',i,'isfree',1,'timer',0,'part','nothing','ishere',1);
end
for i = 1:Nbargers
    Barger{i} = struct('name',i,'isfree',1,'timer',0,'part','nothing');
end

%set the processing times of bridge parts for individual builders
if ~isempty(varargin)
    Trunner_bolts_all = varargin{1}(1);
    Trunner_there = varargin{1}(2);
    Trunner_back = varargin{1}(3);
    Tbarger_bolts_all = varargin{1}(4);
    Tbarger_member = varargin{1}(5);
    Tbarger_bolt = varargin{1}(6);
else %use defulat Timers
    Trunner_bolts_all = 16;
    Trunner_there = 5;
    Trunner_back = 4;
    Tbarger_bolts_all = 0;
    Tbarger_member = 8;
    Tbarger_bolt = 10;
end

%set the ratio of bolts to members
Rbolts_members = Nbolts/Nmembers;

%initialize bridge part pools
Pool_runner_members = Nmembers;
Pool_runner_bolts_all = 1;
Pool_barger_members = 0;
Pool_barger_bolts_all = 0;
Pool_barger_bolts = 0;

%initialize finished bridge part pools
Finished_members = 0;
Finished_bolts = 0;

%begin main build loop!
ISbuilt = 0;
time = 0; %in seconds
while (ISbuilt == 0)
    time = time + 1; %increment the total time
    %do the main runner loop
    for i = 1:Nrunners
        if Runner{i}.isfree %if runner is free
            if Pool_runner_bolts_all %check if the bolts need to be brought out
                Pool_runner_bolts_all = Pool_runner_bolts_all - 1; %remove all bolts from the runner pool
                Runner{i}.isfree = 0; %runner is no longer free
                Runner{i}.timer = Trunner_bolts_all - 1; %start busy timer
                Runner{i}.part = 'bolts_all'; %runner is holding a member
            elseif Pool_runner_members %check if there are available members
                Pool_runner_members = Pool_runner_members - 1; %remove a member from the runner pool
                Runner{i}.isfree = 0; %runner is no longer free
                Runner{i}.timer = Trunner_there - 1; %start busy timer
                Runner{i}.part = 'member'; %runner is holding a member
            end
        else %if runner is busy
            Runner{i}.timer = Runner{i}.timer - 1; %count down timer
            if Runner{i}.timer < 1
                if Runner{i}.ishere %if runner is handing off a member
                    Runner{i}.timer = Trunner_back; %ensure timer is set to 0
                    Runner{i}.ishere = 0;
                    if strcmp(Runner{i}.part,'bolts_all')
                        Pool_barger_bolts_all = Pool_barger_bolts_all + Nbargers; %add bolts_all to the barger pool
                    elseif strcmp(Runner{i}.part,'member')
                        Pool_barger_members = Pool_barger_members + 1; %add a member to the barger pool
                    end
                    Runner{i}.part = 'nothing'; %runner is holding nothing
                else %if runner has returned
                    Runner{i}.timer = 0; %ensure timer is set to 0
                    Runner{i}.isfree = 1; %runner is now free
                    Runner{i}.ishere = 1;
                end
            end
        end
    end %end of main runner loop
    
    %do the main barger loop
    for i = 1:Nbargers
        if Barger{i}.isfree %if barger is free
            if Pool_barger_bolts_all %check if there are bolts to be placed in pouch
                Pool_barger_bolts_all = Pool_barger_bolts_all - 1; %remove to place in pouch form barger pool
                Barger{i}.isfree = 0; %barger is no longer free
                Barger{i}.timer = Tbarger_bolts_all - 1; %start busy timer
                Barger{i}.part = 'bolts_all'; %barger is placing bolts in their pouch
            elseif Pool_barger_members %check if there are available members
                Pool_barger_members = Pool_barger_members - 1; %remove a member from the barger pool
                Barger{i}.isfree = 0; %barger is no longer free
                Barger{i}.timer = Tbarger_member-1; %start busy timer
                Barger{i}.part = 'member'; %barger is holding a member
            elseif Pool_barger_bolts %check if bolts can be placed in pouch
                Pool_barger_bolts = Pool_barger_bolts - 1; %remove a bolt from the barger pool
                Barger{i}.isfree = 0; %barger is no longer free
                Barger{i}.timer = Tbarger_bolt-1; %start busy timer
                Barger{i}.part = 'bolt'; %barger is holding a bolt
            end
        else %if barger is busy
            Barger{i}.timer = Barger{i}.timer - 1; %count down timer
            if Barger{i}.timer < 1
                Barger{i}.timer = 0; %ensure timer is set to 0
                Barger{i}.isfree = 1; %barger is now free
                if strcmp(Barger{i}.part,'member')
                    Finished_members = Finished_members + 1; %finished a member
                    Pool_barger_bolts = Pool_barger_bolts + ceil(Rbolts_members); %add bolts to the barger pool
                elseif strcmp(Barger{i}.part,'bolt')
                    Finished_bolts = Finished_bolts + 1; %finished a bolt
                end
                Barger{i}.part = 'nothing'; %runner is holding nothing
            end
        end
    end %end of main barger loop
    
    %stopping criteria, if all bridge parts have been processed
    if(Finished_members >= Nmembers && Finished_bolts >= Nbolts)
        ISbuilt = 1;
    end
end %end of main build loop
time = time/60; %output time in minutes

end