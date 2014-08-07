% IMPORTANTE NOTE ~~~READ!~~
% - only replenish is being checked now, needs be turned on at line 75 &
% 129 & 170 & 161
% - also I changed line 405 in experiment to check for worm instead of time
%   during testing, because testing is set up differently, so it was wrong



%Adding comment for commit: This version seems to do best on pilfer.

function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global INP_STR;
global gain_oja;
global cycles;

global pfc_learning_rate;

global pfc_max;
global hpc_max;
global max_max_weight;

pfc_max = 8;
hpc_max = 8;
max_max_weight = 20;

INP_STR = 5;
gain_step = .04;
gain_max = 0.7;

%started at 7:31!

runs = 30;
cycles = 9;

global REPL;
global PILF;
global DEGR;

%      Worm   Peanut
REPL = [ 6.0   1.0];
PILF = [ 0.0   1.0];
DEGR = [-6.0   1.0];

gain_oja = 0.7;
pfc_learning_rate = 0.25;
learning_rate = 0.5;

global pos
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
mkdir(DIR);

pos = 0;
w_place_responses = zeros(runs, 14);
w_place_stats = zeros(runs, 1);
p_place_responses = zeros(runs, 14);
p_place_stats = zeros(runs, 1);
filename = horzcat(DIR, '\trial_data', '.mat');
trial_file_name = horzcat(DIR, '\check_orders', '.mat');
pref_file_name = horzcat(DIR, '\side_prefs', '.mat');
worm_trials = {};
pean_trials = {};

value_groups = {};

multi_groups = {};

is_disp_weights = 0;
for e=1:1
    v = 1;
    while v  <= 3
        VALUE = v;
        
        for i = 1:runs
            TRIAL_DIR = horzcat(DIR, '\', num2str(VALUE), '-', ...
                num2str(VALUE), ';', num2str(i), '\');
            mkdir(TRIAL_DIR);
            init_val = VALUE;
                       
            [worm_trial, pean_trial] = ...
                experiment(cycles, learning_rate, gain_oja, is_disp_weights, VALUE);

            worm_trials{i} = worm_trial;
            pean_trials{i} = pean_trial;
            
            w_place_stats(i) = mean(worm_trial.('side_pref'));
            w_checked_places{i} = worm_trial.('check_order');
            w_first_checkeds(i) = worm_trial.('first_check');
            w_pref_error(i) = worm_trial.('error_pref');
            
            p_place_stats(i) = mean(pean_trial.('side_pref'));
            p_checked_places{i} = pean_trial.('check_order');
            p_first_checkeds(i) = pean_trial.('first_check');
            p_pref_error(i) = pean_trial.('error_pref');
            
            message = horzcat('trial ', num2str(i), ' complete');
            disp(message);
            
            all_side_pref = [w_place_stats p_place_stats];
            all_checks = [w_place_stats p_place_stats];
            
           save(trial_file_name, 'all_checks');
           save(pref_file_name, 'all_side_pref');
            
        end
        
        if sum(p_first_checkeds) == 0
            p_avg_first_checks(v) = 0;
        else
            p_avg_first_checks(v) = sum(p_first_checkeds) / runs;
        end
        
        if sum(w_first_checkeds) == 0
            w_avg_first_checks(v) = 0;
        else
            w_avg_first_checks(v) = sum(w_first_checkeds) /  runs;
        end
        
        p_place_stats
        p_avg_side_preference(v) = mean(p_place_stats)
        p_avg_pref_error(v) = std(p_place_stats)/ sqrt(length(p_place_stats));
        
        w_place_stats
        w_avg_side_preference(v) = mean(w_place_stats)
        w_avg_pref_error(v) = std(w_place_stats)/ sqrt(length(w_place_stats));
        
        value_groups{v} = [VALUE worm_trials pean_trials];

        v = v+1;
    end
    is_disp_weights = false;

    showTrials(p_avg_pref_error, p_avg_side_preference, p_avg_first_checks, ...
        e, '124 HR Trial');
    showTrials(w_avg_pref_error, w_avg_side_preference, w_avg_first_checks, ...
        e, '4 HR Trial');
    
    multi_groups{e} = value_groups;
end

save(filename, 'multi_groups');
end

function showTrials(error, avg_side_preference, avg_first_checks, epp, type)
ffc = 'fig_first_check';
fsp = 'fig_side_prefs';

global DIR;

figure;
bar(avg_first_checks);
drawnow;
title_message = horzcat(type, ' First Check %');
title(title_message);

saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(epp), type), 'fig');

temp = zeros(2,2);

for cond=1:3
    temp(cond, 1) = 7 - avg_side_preference(cond);
    temp(cond, 2) = avg_side_preference(cond);
    e(cond, 1) = error(cond);
    e(cond, 2) = error(cond);
end

avg_side_preference = temp;
error = e;

figure;
barwitherr(error, avg_side_preference);
set(gca,'XTickLabel',{'Degrade','Replenish','Pilfer'});
legend('peanut','worm');
ylabel('Avg Number of Checks');
title_message = horzcat(type, ' Side Preference');
title(title_message);

saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(epp), type), 'fig');

end