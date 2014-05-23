function jay_episodic()
clear;
close all;
clc;

global learning_rate;
global gain_oja;
global INP_STR;
global cycles;

global pfc_learning_rate;

INP_STR = 2;
gain_step = .04;
gain_max = 0.7;

runs = 10;
cycles = 14;

global REPL;
global PILF;
global DEGR;

%       Worm   Peanut
REPL = [ 5.0   2 ];
PILF = [ 1.0   2 ];
DEGR = [-1.5   2 ];

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
place_responses = zeros(runs, 14);
place_stats = zeros(runs, 2);
filename = horzcat(DIR, '\trial_data', '.mat');

is_disp_weights = 1;
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

            [place_responses(i,:) side_pref checked_place first_checked] = ...
            experiment(cycles, learning_rate, gain_oja, is_disp_weights, VALUE);

            place_stats(i,:) = mean(side_pref);
            checked_places{i} = checked_place;
            first_checkeds(i) = first_checked;
            is_disp_weights = false;
            message = horzcat('trial ', num2str(i), ' complete');
            disp(message);
        end

        avg_first_checks(v) = sum(first_checkeds) / runs;
        avg_side_preference(v) = mean(place_stats(:,1));

        trials{v} = {INP_STR, VALUE, mean(place_stats(:,2)), avg_side_preference, ...
            place_responses, place_stats, checked_places, ...
            avg_first_checks, avg_side_preference};

        v = v+1;
    end
    
    all_trials{e} = trials;
    
    ffc = 'fig_first_check';
    fsp = 'fig_side_prefs';
    
    figure;
    title('First Check %');
    bar(avg_first_checks);
    drawnow;
    % strrep(ffc, '%d', num2str(e))
    saveas(gcf, horzcat(DIR, '\', ffc, '_', num2str(e)), 'fig');
    
    temp = zeros(6,1);
    
    for k=1:3
        l = 2*k;
        temp(l-1) = avg_side_preference(k);
        temp(l) = 6- avg_side_preference(k);
    end

    avg_side_preference = temp;

    figure;
    title('Side Preferences %');
    for i = 1:3
        k = i*2;
        bar(k-1, avg_side_preference(k-1),'b');
        hold on
        bar(k, avg_side_preference(k),'r');
        hold on
    end
    drawnow;
    
    saveas(gcf, horzcat(DIR, '\', fsp, '_', num2str(e)), 'fig');
end

save(filename,'trials', 'avg_first_checks', 'avg_side_preference');
% profile viewer
% profile off
end