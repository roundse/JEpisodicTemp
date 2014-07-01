function show_weights(section, is_disp_weights)

global w_place_to_hpc;
global w_hpc_to_place;
global w_food_to_hpc;
global w_hpc_to_food;
global w_place_to_pfc;
global w_pfc_to_place;
global w_food_to_pfc;
global w_pfc_to_food;
% global w_hpc_to_hpc;
global hpc;
global place_region;
global food;
global cycles
global learning_rate;
global TRIAL_DIR;
global PLACE_SLOTS;

global hpc_cur_decay;

filename = horzcat(TRIAL_DIR, section, '_variables');
%save(filename);

if is_disp_weights
    figure;
    subplot(1,2,1);
    wx_phpc_temp = w_place_to_hpc(w_place_to_hpc ~= 0);
    hist(wx_phpc_temp);
    title(horzcat(section, ' Place to HPC'));
    subplot(1,2,2);
    imagesc(w_place_to_hpc);
    colorbar();
    drawnow;

    figure;
    subplot(1,2,1);
    wx_hpcp_temp = w_hpc_to_place(w_hpc_to_place ~= 0);
    hist(wx_hpcp_temp);
    title(horzcat(section, ' HPC to Place'));
    subplot(1,2,2);
    imagesc(w_hpc_to_place);
    colorbar();
    drawnow;

%     figure;
%     title(horzcat(section, ' HPC to HPC'));
%     imagesc(w_hpc_to_hpc);
%     colorbar();
%     drawnow;

    figure;
    subplot(1,2,1);
    wx_fhpc_temp = w_food_to_hpc(w_food_to_hpc ~= 0);
    hist(wx_fhpc_temp);
    title(horzcat(section, ' Food to HPC'));
    subplot(1,2,2);
    imagesc(w_food_to_hpc);
    colorbar();
    drawnow;

    figure;
    subplot(1,2,1);
    wx_hpcf_temp = w_hpc_to_food(w_hpc_to_food ~= 0);
    hist(wx_hpcf_temp);
    title(horzcat(section, ' HPC to Food'));
    subplot(1,2,2);
    imagesc(w_hpc_to_food);
    colorbar();
    drawnow;

    figure;
    hist(hpc);
    title(horzcat(section, ' HPC cumulative inputs'));
    drawnow;

    figure;
    hist(place_region);
    title(horzcat(section, ' Place cumulative inputs'));
    drawnow;

    figure;
    hist(food);
    title(horzcat(section, ' Food cumulative inputs'));
    drawnow;

    global hpc_responses_to_place;

    if hpc_responses_to_place
        
        if (sum(var(hpc_responses_to_place)) < 4)
           variance = var(hpc_responses_to_place)
           error('bland outputs...'); 
        end
        figure;
        subplot(1,2,1);
        hist(hpc_responses_to_place);
        title(horzcat(section, ' HPC responses to place slots and food'));
        subplot(1,2,2);
        imagesc(hpc_responses_to_place);
        colorbar();
        drawnow;

        figure;
        title(horzcat(section, ' HPC responses above mean'));
        imagesc(hpc_responses_to_place>mean(mean(hpc_responses_to_place')));
        colorbar();
        drawnow;
    end
end

end

