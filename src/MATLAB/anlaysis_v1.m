%% Percentgae change
percentage_change = evaluatePercentageChange_exc_telecommute(Obj_Emission_Sol, ...
    Obj_Emission_Val, commuters_who_need_telecommuting, ...
    number_of_days_travel_attributes, UserIDs, Obj_Emission_Factors);

%% generate employees layout
generate_png_employees_layout_v2(HomeLatLong_mat, Work_LatLong, 10)
generate_png_employees_layout_v2(HomeLatLong_mat, Work_LatLong, 15)

%% Existing commute behavior

 if ~isempty(commuters_who_need_telecommuting)
        tmp_ind = ~cellfun(@isempty,commuters_who_need_telecommuting(:,1+3));
        [~,ind_tele] = ismember(commuters_who_need_telecommuting(tmp_ind,3),UserIDs(2:end,1)) ;

        tmp = zeros(size(UserIDs(2:end,1),1),1);
        tmp(ind_tele,1) = 1 ;
        tmp = logical(tmp);

        tmp_ind_2 = commuters_who_need_commute_week{1, 1} == 0;

        temp_ind = ~any([tmp, tmp_ind_2],2);
 end

% original_commute_mode_unique = OriginalCommuteModeUnique_V4(concat_data(temp_ind,:) , TimeMatrix_Week, 1);
% existing_mode_share = [sum(original_commute_mode_unique) , sum(tmp), sum(tmp_ind_2)];

original_commute_mode_unique = Obj_Emission_Sol{1, 1}{1, 1}{1, 2}.mor(temp_ind,:);
existing_mode_share = [sum(original_commute_mode_unique(:,1:6)) , sum(original_commute_mode_unique(:,7:end),'all') , sum(tmp), sum(tmp_ind_2)];

%% recommendations
if ~isempty(commuters_who_need_telecommuting)
        tmp_ind = ~cellfun(@isempty,commuters_who_need_telecommuting(:,1+3));
        [~,ind_tele] = ismember(commuters_who_need_telecommuting(tmp_ind,3),UserIDs(2:end,1)) ;

        tmp = zeros(size(UserIDs(2:end,1),1),1);
        tmp(ind_tele,1) = 1 ;
        tmp = logical(tmp);

        tmp_ind_2 = commuters_who_need_commute_week{1, 1} == 0;

        temp_ind = ~any([tmp, tmp_ind_2],2);
 end

recom_commute_mode_unique = Obj_Emission_Sol{1, 1}{1, 1}{1, 1}.x_mor(temp_ind,:);
recom_mode_share = [sum(recom_commute_mode_unique(:,1:6)) , sum(recom_commute_mode_unique(:,7:end),'all') , sum(tmp), sum(tmp_ind_2)];

%% commute change preference of those who recommended to drive alone
drive_ind = all([Obj_Emission_Sol{1, 1}{1, 1}{1, 1}.x_mor(:,1) == 1 ,  temp_ind], 2);
commute_change_pref = sum(commute_change_type(drive_ind,:));




time_factor_obj_mor = Obj_Emission_Factors{1, 1}{1, 1}.mor.time  ;
ex_behi = time_factor_obj_mor - time_factor_obj_mor(:,1) ;
log_ind = time_factor_obj_mor == 99999;
ex_behi(log_ind) = 99999;
for it = 1:size(time_factor_obj_mor,1)
    ind = find(time_factor_obj_mor(it,7:end) == 0);
    if ~isempty(ind)
        ex_behi(it,ind(1)+6:end) = 0;
    end
end

FeasCarpoolTotal = Obj_Emission_Sol{1,1}{1,1}{1,4};

cnt = 1 ;
min_extended_time = zeros(sum(drive_ind),1);
for it = 1:size(drive_ind,1)
    if drive_ind(it)
        min_tmp = [];
        for it_mod = [2:5,7:size(ex_behi,2)]
            if ex_behi(it,it_mod) > 0
                min_tmp = [min_tmp , ex_behi(it,it_mod)];
            end
        end
        min_extended_time(cnt,1) = min(min_tmp);
            cnt = cnt + 1 ;
    end
end



generate_png_employees_recom_drivers(HomeLatLong_mat, HomeLatLong_mat(drive_ind,:), Work_LatLong, 11)

generate_png_employees_recom_drivers_alaki(HomeLatLong_mat, HomeLatLong_mat(drive_ind,:), Work_LatLong, 11)


