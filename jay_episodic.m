function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global gain_oja;
global INP_STR;
global cycles;

global hpc_decay;
global pfc_learning_rate;

global pfc_max;
global hpc_max;
global max_max;

pfc_max = 4;
hpc_max = 8;
max_max = 12;

INP_STR = 2;
gain_step = .04;
gain_max = 0.7;

runs = 2; 
cycles = 10;

global REPL;
global PILF;
global DEGR;

%      Worm   Peanut
REPL = [ 5.0   2 ];
PILF = [ 2.0   2 ];
DEGR = [ 0.0   2 ];

gain_oja = 0.7;
learning_rate = 0.4;
pfc_learning_rate = 0.04;


global pos
global DIR;
global TRIAL_DIR;
DIR = datestr(now);
DIR = strrep(DIR,':',' ');
mkdir(DIR);

pos = 0;
w_place_responses = zeros(runs, 14);
w_place_stats = zeros(runs, 2);
p_place_responses = zeros(runs, 14);
p_place_stats = zeros(runs, 2);
filename = horzcat(DIR, '\trial_data', '.mat');

worm_trials = {};
pean_trials = {};

value_groups = {};

multi_groups = {};

is_disp_weights = 0;
% profile on
for e=1:1
    v = 1;
    while v <= 3
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

            w_place_stats(i,:) = mean(worm_trial.('side_pref'));
            w_checked_places{i} = worm_trial.('check_order');
            w_first_checkeds(i) = worm_trial.('first_check');
            
            p_place_stats(i,:) = mean(pean_trial.('side_pref'));
            p_checked_places{i} = pean_trial.('check_order');
            p_first_checkeds(i) = pean_trial.('first_check');
            
            is_disp_weights = false;
            message = horzcat('trial ', num2str(i), ' complete');
            disp(message);
        end
        
        
        p_avg_first_checks(v) = sum(p_first_checkeds) / runs;
        p_avg_side_preference(v) = mean(p_place_stats(:,1));
 
        w_avg_first_checks(v) = sum(w_first_checkeds) /  runs;
        w_avg_side_preference(v) = mean(w_place_stats(:,1));
        
        value_groups{v} = [VALUE worm_trials pean_trials]; 
%         avg_first_checks(v) = sum(first_checkeds) / runs;
%         avg_side_preference(v) = mean(place_stats(:,1));
% 
%         expirments{v} = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
%             place_responses, place_stats, checked_places, ...
%             avg_first_checks, avg_side_preference};

        v = v+1;
    end
        
    showTrials(p_avg_side_preference, p_avg_first_checks, e, 'Peanut first');
    showTrials(w_avg_side_preference, w_avg_first_checks, e, 'Worm first');
    
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
        temp(l) = 6 - avg_side_preference(k);
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