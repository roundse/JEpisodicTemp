function [net_in] = activity(net_in, stim_weights, stimulus, ...
    net_to_netweights)
    global INP_STR;
    global GAIN;
    persist = 0.1;

    len = length(net_in);
    noise = 0.0001*rand(1,len)-0.00005;
    
    stim_in = INP_STR*(stimulus*stim_weights');
    intranet_in = 1*(net_in*net_to_netweights');

    I = stim_in + intranet_in + noise;
    
    net_in = persist.*net_in + (1-persist).*(1./(1+exp(-GAIN.*I))); 
end