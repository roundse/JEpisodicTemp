function [avg_checks side_pref checked_places first_checked] = bg_experiment(cycles, ... 
    learning_rate, gain_oja, is_disp_weights, VALUE)


global GAIN;
GAIN = 5;

global HPC_SIZE;
HPC_SIZE = 250;                 % 2 x 14 possible combinations multipled
                                % by 10 for random connectivity of 10%
global FOOD_CELLS;
global PLACE_CELLS;
FOOD_CELLS = 2;
PLACE_CELLS = 14;

EXT_CONNECT = .2;                   % Chance of connection = 10%
INT_CONNECT = .2;

global worm;
global peanut;
worm = 1;
peanut = 2;

global PEANUT;
global WORM;
WORM =  [-1,  1];
PEANUT =[ 1, -1];

global place;
place = zeros(length(PEANUT), PLACE_CELLS);

% Weight initialization
global w_food_to_hpc;
global w_place_to_hpc;
global w_hpc_to_food;
global w_hpc_to_place;
global w_hpc_to_hpc;

global w_food_to_food;
global w_food_in;

global hpc_in_queue;
global hpc_weight_queue;
global food_in_queue;
global food_weight_queue;

global place_in_queue;
global place_weight_queue;

global hpc_responses_to_place;

global hpc_cumul_activity;
hpc_cumul_activity = 0;

global is_learning;
is_learning = 1;

place_in_queue = {};
place_weight_queue = {};

hpc_in_queue = {};
hpc_weight_queue = {};

food_in_queue = {};
food_weight_queue = {};

w_food_in = eye(FOOD_CELLS);
w_food_to_food = zeros(FOOD_CELLS);

w_food_to_hpc = 0.5 .* (rand(FOOD_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_food = - w_food_to_hpc';
w_place_to_hpc = 0.5 .* (rand(PLACE_CELLS, HPC_SIZE) < EXT_CONNECT);
w_hpc_to_place =  - w_place_to_hpc';


global w_hpc_to_place_init;
global w_place_to_hpc_init;

w_hpc_to_hpc = -1 .* (rand(HPC_SIZE, HPC_SIZE) < INT_CONNECT);
w_hpc_to_place_init = w_hpc_to_place;
w_place_to_hpc_init = w_place_to_hpc;

global hpc;
global place_region;
global food;

hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);
hpc_responses_to_place = zeros(PLACE_CELLS, HPC_SIZE);

global PLACE_SLOTS;

PLACE_SLOTS = zeros(PLACE_CELLS);

PLACE_STR = 0.4;

side1 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

side2 = 1*(rand(1, PLACE_CELLS) < PLACE_STR/2);

% Food is pre-stored.
for i = 1:PLACE_CELLS
    if i <= 7
        place(:,i) = WORM;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) + side1 - side2;
    else
        place(:,i) = PEANUT;
        PLACE_SLOTS(i,:) = 1*(rand(1, PLACE_CELLS) < PLACE_STR) - side1 + side2;
    end
end

place = place';

global default_val;
default_val = [5 2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE: Agent stores both foods. Consolidates 124 hours and is allowed to
% retrieve the foods. Learns worms decay.
% Then agent stores both foods. Consolidates 4 hours and then is
% allowed to retrieve the foods. Learns worms are still good.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

run_protocol('training', cycles, is_disp_weights, VALUE);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TESTING: Agent stores one food, consolidates either 4 or 124 hours, then
% stores the second food, and consolidates the leftover time.
% Then gets to recover its caches.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[checked_places, side_pref, avg_checks, first_checked] = ...
                        run_protocol('testing', cycles, is_disp_weights, VALUE);

                    
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVING VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global TRIAL_DIR;

filename = horzcat(TRIAL_DIR, 'after final trial ', '_variables');

save(filename);

varlist = {'hpc','place_region','food', 'place_in_queue', ...
    'place_weight_queue', 'hpc_in_queue', 'hpc_weight_queue', ...
    'food_in_queue', 'food_weight_queue'};
clear(varlist{:})

end

function places = spot_shuffler (start, finish)
    if (nargin == 1)
        places = randperm(start);
    else
        range = finish - start+1;
        numsets = (start : finish);
        perm = randperm(range);

        for i=1:range
            p = perm(i);
            places(i) = numsets(p);
        end
    end
end

function [checked_places, side_pref, avg_checks, first_checked] = ...
          run_protocol (prot_type, cycles, is_disp_weights, VALUE)
    global PLACE_SLOTS;
    
    global worm;   global WORM;
    global peanut; global PEANUT;
    
    global REPL; global PILF; global DEGR;
    
    if VALUE == 1
        value = REPL;
    elseif VALUE ==2
        value = PILF;
    else
        value = DEGR;
    end
    
    global place;
    global hpc_cumul_activity;
    global default_val;
    
    food_types = [peanut worm];
    rev_food = [worm peanut];
    time_lengths = [4, 120];

    type_order = randperm(2);
    time_order = randperm(2);
    
    is_testing = strcmp(prot_type, 'testing');

    global is_learning;
        
    if is_testing
        % !~CHANGE~! 
        duration = 1;
    else
        duration = 4;
    end
        
    for j=1:duration
        for l=1:2
            is_learning = 0;
            
            % if testing time is always 4 then 120
            if is_testing
                current_time = time_lengths(l);
                % Should change back to random
                % !~CHANGE~! 
                % just want trials to work
                current_type =rev_food(l);
            
             % otherwise time is randomly one way or the other
            else
                current_time = time_lengths(time_order(l));
                current_type = food_types(type_order(l));
                
            end
            
            disp([prot_type, ' ', num2str(j)]);

            if current_time == 4
                value1 = default_val;
            else
                value1 = VALUE;
            end

            if current_type == peanut
                disp('First food to be stored is peanut');
            else
                disp('First food to be stored is worm');  
            end

            disp(['First consolidation period is: ', num2str(current_time)]);

            if is_testing
                if current_type == worm
                    spots = spot_shuffler(7);
                else
                    spots = spot_shuffler(8,14);
                end        
            else
                spots = spot_shuffler(7);
                spots = horzcat(spots,spot_shuffler(8,14));
            end
            
            val = 1;

            for i = spots
                while place(i,:) == 0
                    place(i,:) = current_type;
                end

                cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, val);
            end
            
            % m1 = mean(hpc_cumul_activity) / (current_time*14);
            
            % conso lidate
            spots = spot_shuffler(14);
            
            for q = 1:current_time
                for i = spots
                    cycle_net( PLACE_SLOTS(i,:), place(i,:), cycles, val);
                end
            end
            
            % after retrieving food it ponders the stimulus
            spots = spot_shuffler(14);
            hpc_cumul_activity = 0;
            
            if current_time == 120
                val = value;
            else
                val = REPL;
            end

            if ~is_testing
                is_learning = 1;
                for q = 1:12
                    for i = spots
                        if place(i,:) == WORM
                            v = val(worm);
                        else
                            v = val(peanut);
                        end

                        cycle_net(PLACE_SLOTS(i,:), place(i,:), cycles, v);
                    end
                end
            end
            
            show_weights([prot_type, ' ', num2str(current_time)], is_disp_weights);

            m1 = mean(hpc_cumul_activity) / (12*14);         
            activity1 = mean(m1);
            disp(['HPC Consolidate: ', num2str(activity1)]);  

            %m2 = mean(pfc_sum);
            %activity2 = mean(m2);
            %disp(['PFC Consolidate: ', num2str(activity2)]);
        end

         % only if it is testing is the judging protocol enacted
        if is_testing
            [checked_places, side_pref, avg_checks, first_checked] ...
                 = place_slot_check;
        end
        
        time_order = [time_order(2) time_order(1)];
    end

end
