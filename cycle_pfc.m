function returnable = cycle_pfc(pfc_in, input_weights, input, value)
global w_pfc_to_pfc;
global pfc_eye;

global pfc_in_queue;
global pfc_weight_queue;

global HVAL;
global PFC_SIZE;

pfc_eye = eye(PFC_SIZE);
w_pfc_to_pfc = zeros(PFC_SIZE);

queue_pos = length(pfc_in_queue)+1;

if nargin < 3
    total_inputs = 0;
    for i = 1:(queue_pos-1)
        temp_input = total_inputs + pfc_in_queue{i} * pfc_weight_queue{i};
        
        total_inputs = total_inputs + temp_input;
    end
    
    food_pfc_out = activity(pfc_in, pfc_eye, total_inputs, w_pfc_to_pfc);
    
    returnable = food_pfc_out;

    for l = 1:length(w_pfc_to_pfc)
        w_pfc_to_pfc(l,l) = 0;
    end

    pfc_weight_queue{queue_pos} = [];
    pfc_in_queue{queue_pos} = [];    
    pfc_in_queue = {};
else
    % return the weights given if no weight in queue
    if ( queue_pos > length(pfc_weight_queue) )
        returnable = input_weights;
    else
        returnable = pfc_weight_queue{queue_pos};
    end

    HVAL = value;
    
    pfc_in_queue{queue_pos} = input;
    pfc_weight_queue{queue_pos} = input_weights;
end
end