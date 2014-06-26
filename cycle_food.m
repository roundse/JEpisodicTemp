function returnable = cycle_food(food_in, input_weights, input)
    global w_food_to_food;
    global PVAL;
    global HVAL;

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
    global is_pfc;
    decay = .004;
    
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
%             temp_w_h_f = w_hpc_to_food;
%             temp_w_f_h = w_food_to_hpc;

            [w_hpc_to_food w_food_to_hpc] = recurrent_oja(food_out, ...
                food_in, hpc_in, w_hpc_to_food, w_food_to_hpc, HVAL);

%             w_hpc_to_food = w_hpc_to_food - decay * (temp_w_h_f - w_hpc_to_food);
%             w_food_to_hpc = w_food_to_hpc - decay * (temp_w_f_h - w_food_to_hpc);
        end
        
        if pfc_learning
            is_pfc = 1;
            [w_pfc_to_food w_food_to_pfc] = recurrent_oja(food_out, ...
                food_in, pfc_in, w_pfc_to_food, w_food_to_pfc, PVAL);
            is_pfc = 0;
        end

        food_in_queue = {};
    else
        % return the weights given if no weight in queue
        if ( queue_pos > length(food_weight_queue) )
            returnable = input_weights;
        else
            returnable = food_weight_queue{queue_pos};
        end
        
        food_in_queue{queue_pos} = input;
        food_weight_queue{queue_pos} = input_weights;
    end 
end
