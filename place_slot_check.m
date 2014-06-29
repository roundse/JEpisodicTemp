function [checked_places side_pref avg_checks first_checked] = place_slot_check()
global PLACE_SLOTS;
    global PLACE_CELLS;
    global cycles;
    
    global FOODED_SLOTS;
    FOODED_SLOTS = PLACE_SLOTS;

    % make variable place input with all inputs
    % inject into net for a cycle
    % collect place response
    % determine chosen palce
    % remove that input from all inputs
    % continue trial until no inputs left
    % the "Battle Royale" of inputs! 14 INPUTS ENTER. ONE ME LEAVES.

    testing_trials = 6;

    ranked_slots = zeros(PLACE_CELLS, 1);

    % food is retrieved from store
    neutral_input = sum(PLACE_SLOTS);
    %injection_current = rand(1,14); % <-- used for forgetting
    for p = 1:PLACE_CELLS
        injection_current = neutral_input/(15-p) +(rand(1,14) - 0.5 ); % <-- used for the eleminating input model

        final_place_activity = cycle_net(injection_current, [0 0], cycles, 0);

        avg = final_place_activity;
        [slot_signal ranked_slots(p)] = find_place(avg); % <-- used for the eleminating input model
        neutral_input = neutral_input - slot_signal; % <-- used for the eleminating input model
        % cycle_net(slot_signal, [0 0], cycles, -1); % <-- used forgetting
        %model
    end

%     disp(ranked_slots);
    checked_places = ranked_slots;
    side_pref = side_pref_calc(ranked_slots);
    avg_checks = ranked_slots';
    
    first_checked = avg_checks(1)<8;

% figure;
% title('Place dist');
% plot(avg_checks);
% drawnow;
end

function [slot_signal slot] = find_place(place_response)
    global FOODED_SLOTS;
    global PLACE_CELLS;
    
    vars = zeros(PLACE_CELLS,1);

    for i = 1:length(FOODED_SLOTS);
        vars(i) = sum(var([FOODED_SLOTS(i,:); ...
            place_response]));
    end
       
    slot = find(vars==min(vars));
    slot = slot(1); % in the unlikely (but still occuring) event there are multiple minimums, just take the first
    slot_signal = FOODED_SLOTS(slot, :);
    a = -2*ones(1,14);
    fs = FOODED_SLOTS(slot,:);
    FOODED_SLOTS(slot,:) = FOODED_SLOTS(slot,:)*0 - 35;
end

function side_pref = side_pref_calc (ranked_slots)
    global PLACE_CELLS;
    
    first_side = zeros(PLACE_CELLS,1);
    first_side(ranked_slots<8) = 1;
 
    side_pref = sum(first_side(1:7));
    disp('Worms in first seven checks: ');
    disp(side_pref);
end