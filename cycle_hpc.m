function returnable = cycle_hpc(hpc_in, input_weights, input, value)
global w_hpc_to_hpc;
global hpc_eye;

global hpc_in_queue;
global hpc_weight_queue;

global HVAL;
global HPC_SIZE;

hpc_eye = eye(HPC_SIZE);

queue_pos = length(hpc_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    for i = 1:(queue_pos-1)
        temp_input = total_inputs + hpc_in_queue{i} * hpc_weight_queue{i};
        
        total_inputs = total_inputs + temp_input;
    end
    
    food_hpc_out = activity(hpc_in, hpc_eye, total_inputs, ...
        w_hpc_to_hpc);
    
    returnable = food_hpc_out;

    for l = 1:length(w_hpc_to_hpc)
        w_hpc_to_hpc(l,l) = 0;
    end

    hpc_weight_queue{queue_pos} = [];
    hpc_in_queue{queue_pos} = [];    
    hpc_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(hpc_weight_queue) )
        returnable = input_weights;
    else
        returnable = hpc_weight_queue{queue_pos};
    end

    HVAL = value;
    
    hpc_in_queue{queue_pos} = input;
    hpc_weight_queue{queue_pos} = input_weights;
end
end