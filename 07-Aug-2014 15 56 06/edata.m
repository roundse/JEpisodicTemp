num_trials = 30;
data_name = 'after final trial_variables.mat';

all_pref_data = {};

for ii=1:3
   stri = num2str(ii);
   group = horzcat(stri,'-',stri);
   tdat = zeros(num_trials,2);
   worms = zeros(num_trials,2);
  
   for t=1:num_trials
      
      strt = num2str(t);
      data_loc = horzcat(group,';',strt,'/',data_name);
      
      load(data_loc);
      
      tdat(t,1) = pean_trial.side_pref;
      tdat(t,2) = worm_trial.side_pref;
       
   end

   all_pref_data{ii} = tdat;
   
end

save('correct_prefs', 'all_pref_data');