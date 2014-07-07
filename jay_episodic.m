% IMPORTANTE NOTE ~~~READ!~~
% - only replenish is being checked now, needs be turned on at line 75 &
% 129 & 170 & 161
% - also I changed line 405 in experiment to check for worm instead of time
%   during testing, because testing is set up differently, so it was wrong

function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global gain_oja;
global INP_STR;
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

runs = 10;
cycles = 9;
% cycles = 8;

global REPL;
global PILF;
global DEGR;

%      Worm   Peanut
REPL = [ 6.4   2.0];
PILF = [ 3.25   2.0];
DEGR = [-9.0   2.0]; % O X
%hpc: peanut crazy if training ends on degrade, perfect if it ends on worm.
%pfc: prefers flip of what was last presented...

gain_oja = 0.7;
learning_rate = 0.45;
pfc_learning_rate = 0.01;


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
% profile on
for e=1:1
    v = 1;
    while v  <= 3
        VALUE = v;
        
        for i = 1:runs
            TRIAL_DIR = horzcat(DIR, '\', num2str(VALUE), '-', ...
                num2str(VALUE), ';', num2str(i), '\');
            mkdir(TRIAL_DIR);
            init_val = VALUE;
            
            %             [place_responses(i,:) side_pref checked_place first_checked] = ...
            %             experiment(cycles, learning_rate, gain_oja, is_disp_weights, VALUE);
            
            [worm_trial pean_trial] = ...
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
            
            is_disp_weights = false;
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
        %         avg_first_checks(v) = sum(first_checkeds) / runs;
        %         avg_side_preference(v) = mean(place_stats(:,1));
        %
        %         expirments{v} = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
        %             place_responses, place_stats, checked_places, ...
        %             avg_first_checks, avg_side_preference};
        
        v = v+1;
    end
    
    
    %     figure;
    %     bar(w_avg_pref_error);
    %     drawnow;
    %     title('Worm error margin');
    %
    %
    %     figure;
    %     bar(p_avg_pref_error);
    %     drawnow;
    %     title('Peanut error margin');
    
    % Some how reordering trials changed the order...
    showTrials(p_avg_pref_error, p_avg_side_preference, p_avg_first_checks, ...
        e, '124 HR Trial');
    showTrials(w_avg_pref_error, w_avg_side_preference, w_avg_first_checks, ...
        e, '4 HR Trial');
    
    multi_groups{e} = value_groups;
end

save(filename, 'multi_groups');
% profile viewer
% profile off
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
% strrep(ffc, '%d', num2str(e))

saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(epp), type), 'fig');

temp = zeros(2,2);

for cond=1:3
    %l = 2*k;
    %     temp(l-1) = avg_side_preference(k);
    %     e(l-1) = error(k);
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

%barwitherr(error, avg_side_preference);
% for cond = 1:3
%     k = cond*2;
%     barwitherr(error(cond,1), k-1, avg_side_preference(cond,1),'b');
%     hold on
%     barwitherr(error(cond,2), k, avg_side_preference(cond,2),'r');
%     hold on
% end
% set(gca,'XTick', [1.5 3.5 5.5], 'XTickLabel',{'Degrade','Replenish','Pilfer'});
% legend(['peanut','worm']);
% ylabel('Avg Number of Checks');
% drawnow;
% title_message = horzcat(type, ' Side Preference');
% title(title_message);
saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(epp), type), 'fig');

end