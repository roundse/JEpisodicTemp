function returnable = cycle_food(food_in, input_weights, input, value)
    global w_food_to_food;
    global VAL;

    global food_in_queue;
    global food_weight_queue;
    
    global FOOD_CELLS;
    
    % HPC recurrency stuff
    global w_food_to_hpc;
    global w_hpc_to_food;
    global hpc_learning;
  
    % PFC recurrency stuff
    global w_food_to_pfc;
    global w_pfc_to_food;
    global pfc_learning;
    
    food_eye = eye(FOOD_CELLS);
      
    queue_pos = length(food_in_queue)+1;
    
    if nargin < 3
    	total_inputs = 0;
        pfc_in = food_in{3};
        hpc_in = food_in{2};
        food_in = food_in{1};
        
    	for i = 1:(queue_pos-1)
    		total_inputs = total_inputs + food_in_queue{i} * food_weight_queue{i};
        end

        food_out = activity(food_in, food_eye, total_inputs, ...
            w_food_to_food);
        
        
        returnable = food_out;

        if hpc_learning
            [w_hpc_to_food w_food_to_hpc] = recurrent_oja(food_out, ...
                food_in, hpc_in, w_hpc_to_food, w_food_to_hpc, VAL);
        end
        
        if pfc_learning
            [w_pfc_to_food w_food_to_pfc] = recurrent_oja(food_out, ...
                food_in, pfc_in, w_pfc_to_food, w_food_to_pfc, VAL);
        end

        food_in_queue = {};
    else
        % return the weights given if no weight in queue
        if ( queue_pos > length(food_weight_queue) )
            returnable = input_weights;
        else
            returnable = food_weight_queue{queue_pos};
        end
        
        if nargin > 3
            VAL = value;
        end
        
        food_in_queue{queue_pos} = input;
        food_weight_queue{queue_pos} = input_weights;
    end 
end
