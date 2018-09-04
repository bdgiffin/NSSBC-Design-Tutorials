clear all
clc

%set the bridges
Nbridges = 3;
Bridge_names = {'Berkeley','Davis','Mit'};
Actual_times = [8.37, 8.95, 11.30];

%set the number of builders
Nrunners = [1, 1, 1];
Nbargers = [3, 3, 2];

%set the total number of bridge parts
Nmembers = [45, 55, 51];
Nbolts = [106, 78, 92];

%set the processing times of bridge parts for individual builders
Trunner_bolts_all = 16;
Trunner_there = 5;
Trunner_back = 4;
Tbarger_bolts_all = 0;
Tbarger_member = 8;
Tbarger_bolt = 10;

%store timers in in "Timers" array
Timers = [Trunner_bolts_all, Trunner_there, Trunner_back,...
          Tbarger_bolts_all, Tbarger_member, Tbarger_bolt];

%calculate construction times and economy scores
time = zeros(1,Nbridges);
cost = zeros(1,Nbridges);
for i = 1:Nbridges
    time(i) = construct( Nrunners(i), Nbargers(i), Nmembers(i), Nbolts(i), Timers );
    cost(i) = time(i)*(Nrunners(i)+Nbargers(i))*50000;
    fprintf('The total build time for %s was: %4.2f minutes\n',Bridge_names{i},time(i))
    fprintf('%s''s economy score was: $%10.2f \n\n',Bridge_names{i},cost(i))
end

%calibrate timers
old_Timers = Timers;
Timer_current_best = Timers;
maxIt = 10;
It = 0;
while (((~all(Timers == old_Timers))||(~It))&&(It<maxIt))
    It = It + 1;
    old_Timers = Timers;
    for t = 1:length(Timers)
        error = inf;
        for Timer_current = (Timers(t)-1):(Timers(t)+1)
            Timers = old_Timers;
            Timers(t) = Timer_current;
            for i = 1:Nbridges
                time(i) = construct( Nrunners(i), Nbargers(i), Nmembers(i), Nbolts(i), Timers );
            end
            if (sum((Actual_times - time).^2) < error)&&(Timer_current >= 0)
                error = sum((Actual_times - time).^2);
                Timer_current_best(t) = Timer_current;
            end
        end
    end
    Timers = Timer_current_best;
end
fprintf('Timers have been calibrated.\nThe new Timers are listed below:\n')
Timers
