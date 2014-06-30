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
cycles = 11;
% cycles = 8;

global REPL;  
global PILF;
global DEGR;

%      Worm   Peanut
REPL = [ 6.0   2 ]; 
PILF = [ 2.0   2 ];
DEGR = [-6   2 ]; % O X
%hpc: peanut crazy if training ends on degrade, perfect if it ends on worm.
%pfc: prefers flip of what was last presented...

gain_oja = 0.7;
learning_rate = 0.48;
pfc_learning_rate = 0.04;


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

        p_avg_side_preference(v) = mean(p_place_stats);
        p_avg_pref_error(v) = mean(p_pref_error);

        w_avg_side_preference(v) = mean(w_place_stats);
        w_avg_pref_error(v) = mean(w_pref_error);
        
        value_groups{v} = [VALUE worm_trials pean_trials]; 
%         avg_first_checks(v) = sum(first_checkeds) / runs;
%         avg_side_preference(v) = mean(place_stats(:,1));
% 
%         expirments{v} = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
%             place_responses, place_stats, checked_places, ...
%             avg_first_checks, avg_side_preference};

        v = v+1;
    end

    
    figure;
    bar(w_avg_pref_error);
    drawnow;
    title('Worm error margin');


    figure;
    bar(p_avg_pref_error);
    drawnow;
    title('Peanut error margin');
    
    % Some how reordering trials changed the order...
    showTrials(p_avg_side_preference, p_avg_first_checks, ... 
       e, 'P then W');
    showTrials(w_avg_side_preference, w_avg_first_checks, ...
       e, 'W then P');
    
    multi_groups{e} = value_groups;
end

save(filename, 'multi_groups');
% profile viewer
% profile off
end

function showTrials(avg_side_preference, avg_first_checks, e, type)
    ffc = 'fig_first_check';
    fsp = 'fig_side_prefs';
    
    global DIR;
    
    figure;
    bar(avg_first_checks);
    drawnow;
    title_message = horzcat(type, ' First Check %');
    title(title_message);
    % strrep(ffc, '%d', num2str(e))

    saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(e), type), 'fig');
    
    temp = zeros(6,1);
    
    for k=1:3
        l = 2*k;
        temp(l-1) = avg_side_preference(k);

        temp(l) = 7 - avg_side_preference(k);
    end

    avg_side_preference = temp;

    figure;
    for i = 1:3
        k = i*2;
        bar(k-1, avg_side_preference(k-1),'b');
        hold on
        bar(k, avg_side_preference(k),'r');
        hold on
    end
    drawnow;
    title_message = horzcat(type, ' Side Preferences %');
    title(title_message);
   
    saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(e), type), 'fig');
end