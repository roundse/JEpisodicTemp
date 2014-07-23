function final_place_activity = cycle_net( place_stim, food_stim, cycles, value)

global pfc;
global hpc;
global place_region;
global food;

global PLACE_CELLS;
global FOOD_CELLS;
global HPC_SIZE;

global w_hpc_to_place;
global w_hpc_to_food;
global w_place_to_hpc;
global w_food_to_hpc;

global is_learning;

global w_pfc_to_food;
global w_food_to_pfc;
global w_pfc_to_place;
global w_place_to_pfc;

global hpc_cumul_activity;
global pfc_cumul_activity;

global is_place_stim;
global is_food_stim;

hpc = zeros(cycles, HPC_SIZE);
food = zeros(cycles, FOOD_CELLS);
place_region = zeros(cycles, PLACE_CELLS);

for j = 2:cycles
    hpc_out = hpc(j-1,:);
    place_out = place_region(j-1,:);
    food_out = food(j-1, :);
    pfc_out = pfc(j-1,:);

    if is_place_stim
        cycle_place(place_out, eye(PLACE_CELLS), place_stim);
    end
    
    cycle_place(place_out, w_hpc_to_place, hpc_out);
    cycle_place(place_out, w_pfc_to_place, pfc_out);

    if is_food_stim
        cycle_food(food_out, eye(FOOD_CELLS), food_stim);
    end
    
    cycle_food(food_out, w_hpc_to_food, hpc_out);
    cycle_food(food_out, w_pfc_to_food, pfc_out);

    cycle_hpc(hpc_out, w_place_to_hpc, place_out, value);
    cycle_hpc(hpc_out, w_food_to_hpc, food_out, value);
    
    if is_place_stim
        cycle_hpc(hpc_out, w_food_to_hpc,  food_stim, value);
    end
    
    cycle_pfc(pfc_out, w_place_to_pfc, place_out, value);
    cycle_pfc(pfc_out, w_food_to_pfc, food_out, value);
    
    if is_place_stim
        cycle_pfc(pfc_out, w_food_to_pfc, food_stim, value);
    end
  
    pfc(j,:) = cycle_pfc(pfc_out, is_learning);         
    hpc(j,:) = cycle_hpc(hpc_out, is_learning);
    place_region(j,:) = cycle_place({place_region(j-1,:), hpc(j,:), ...
                        pfc(j,:)}, is_learning);
    food(j,:) = cycle_food({food(j-1,:), hpc(j,:), ...
                pfc(j,:)}, is_learning);
end

final_place_activity = mean(place_region(6:cycles,:));
hpc_cumul_activity = hpc_cumul_activity + mean(mean(hpc));
pfc_cumul_activity = pfc_cumul_activity + mean(mean(pfc));

end