function [ vars ] = find_place( hpc_activity )
global hpc_responses_to_place;

[len ~] = size(hpc_responses_to_place);
vars = ones(1,14);

for i = 1:len
    vars(1,i) = sum(var([hpc_responses_to_place(i,:); ...
        hpc_activity]));
end

end