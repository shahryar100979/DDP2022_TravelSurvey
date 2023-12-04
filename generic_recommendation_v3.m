generic_recommendations = strings(size(HomeLatLong_mat,1),1);

cnt_walk          = 0 ;
cnt_bike          = 0 ;
cnt_transit_walk  = 0 ;
cnt_transit_drive = 0 ;
cnt_carpool       = 0 ;

social_hrs        = 0 ;
carpool_emissions = 0 ;
drive_emissions   = 0 ;
drive_and_carpool_cost = 0 ;


for it_com = 1:size(HomeLatLong_mat,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % walk: Employees within 0.5 miles
    if DistanceMatrix_Week{1,1}(it_com,4) ~= 99999 && ...
            DistanceMatrix_Week{1,1}(it_com,4) <= 0.5
        generic_recommendations(it_com,1) = 'walk';
    end

    % walk: 50% of employees between 0.5 to 0.75 miles
    tmp = sum(all( [DistanceMatrix_Week{1,1}(:,4) ~= 99999 , ...
        DistanceMatrix_Week{1,1}(:,4) > 0.5 , DistanceMatrix_Week{1,1}(:,4) <= 0.75] , 2) );
    if DistanceMatrix_Week{1,1}(it_com,4) ~= 99999 && ...
            DistanceMatrix_Week{1,1}(it_com,4) > 0.5 && ...
            DistanceMatrix_Week{1,1}(it_com,4) <= 0.75 && cnt_walk < 0.5*tmp
        generic_recommendations(it_com,1) = 'walk';
        cnt_walk = cnt_walk + 1 ;
    end
end

for it_com = 1:size(HomeLatLong_mat,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % bike:Employees within 1 mile
    if DistanceMatrix_Week{1,1}(it_com,5) ~= 99999 && ...
            DistanceMatrix_Week{1,1}(it_com,5) <= 1 && isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'bike';
    end

    % bike: 50% of employees between 1 to 1.5 miles
    tmp = sum(all( [DistanceMatrix_Week{1,1}(:,5) ~= 99999 , ...
        DistanceMatrix_Week{1,1}(:,5) > 1 , DistanceMatrix_Week{1,1}(:,5) <= 1.5] , 2) );
    if DistanceMatrix_Week{1,1}(it_com,5) ~= 99999 && ...
            DistanceMatrix_Week{1,1}(it_com,5) > 1 && ...
            DistanceMatrix_Week{1,1}(it_com,5) <= 1.5 && ...
            cnt_bike < 0.5*tmp && isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'bike';
        cnt_bike = cnt_bike + 1 ;
    end


end


for it_com = 1:size(HomeLatLong_mat,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public transit and walk: 15 minute added time
    if TimeMatrix_Week{1,1}(it_com,2) ~= 99999 && ...
            TimeMatrix_Week{1,1}(it_com,2) - TimeMatrix_Week{1,1}(it_com,1) <= 15 && ...
            isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'transit + walk';
    end

    % public transit and walk: between 15 minute added time up to 20 minutes added time
    tmp = sum(all( [TimeMatrix_Week{1,1}(:,2) ~= 99999 , ...
        TimeMatrix_Week{1,1}(:,2) - TimeMatrix_Week{1,1}(:,1) > 15 , TimeMatrix_Week{1,1}(:,2) - TimeMatrix_Week{1,1}(:,1) <= 20] , 2) );
    if TimeMatrix_Week{1,1}(it_com,2) ~= 99999 && ...
            TimeMatrix_Week{1,1}(it_com,2) - TimeMatrix_Week{1,1}(it_com,1) > 15 && ...
            TimeMatrix_Week{1,1}(it_com,2) - TimeMatrix_Week{1,1}(it_com,1) <= 20 && ...
            cnt_transit_walk < 0.5*tmp && isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'transit + walk';
        cnt_transit_walk = cnt_transit_walk + 1 ;
    end
end


for it_com = 1:size(HomeLatLong_mat,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public transit and drive: 15 minute added time
    if p_time(it_com,1) ~= 99999 && ...
            p_time(it_com,1) - TimeMatrix_Week{1,1}(it_com,1) <= 15 && ...
            isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'transit + drive';
    end

    % public transit and drive: between 15 minute added time up to 20 minutes added time
    tmp = sum(all( [p_time(:,1) ~= 99999 , ...
        p_time(:,1) - TimeMatrix_Week{1,1}(:,1) > 15 , p_time(:,1) - TimeMatrix_Week{1,1}(:,1) <= 20] , 2) );
    if p_time(it_com,1) ~= 99999 && ...
            p_time(it_com,1) - TimeMatrix_Week{1,1}(it_com,1) > 15 && ...
            p_time(it_com,1) - TimeMatrix_Week{1,1}(it_com,1) <= 20 && ...
            cnt_transit_drive < 0.5*tmp && isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'transit + drive';
        cnt_transit_drive = cnt_transit_drive + 1 ;
    end


end




for it_com = 1:size(HomeLatLong_mat,1)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % carpool
    counter = 0 ;
    if isempty(generic_recommendations{it_com,1}) && cnt_carpool/size(HomeLatLong_mat,1) < 16/100
        for it_car = 1:size(FeasCarpoolTotal{it_com, 1},1)
            for it_rider = 1:size(FeasCarpoolTotal{it_com, 1}{it_car,1},1)
                riders = FeasCarpoolTotal{it_com, 1}{it_car,1}(it_rider,:);
                avail = true;
                counter = counter + 1 ;
                for it_rid = riders
                    if ~isempty(generic_recommendations{it_rid,1})
                        avail = false;
                    end
                end
                if avail
                    generic_recommendations(it_com,1) = 'carpool';
                    social_hrs = social_hrs + 2*time_factor_obj_mor_commuters_time(it_com, 6+counter)/60;
                    carpool_emissions = carpool_emissions + 2*emit_factor_obj_mor(it_com, 6+counter)/CO2_Cost*1000;
                    drive_and_carpool_cost = drive_and_carpool_cost + 2*cost_factor_obj_mor(it_com, 6+counter);
                    for it_rid = riders
                        generic_recommendations(it_rid,1) = 'carpool';
                    end
                    cnt_carpool = cnt_carpool + 1 + length(riders);
                end
            end
        end
    end

end


for it_com = 1:size(generic_recommendations,1)
    if isempty(generic_recommendations{it_com,1})
        generic_recommendations(it_com,1) = 'drive alone';
        drive_emissions = drive_emissions + 2*emit_factor_obj_mor(it_com, 1)/CO2_Cost*1000;
        drive_and_carpool_cost = drive_and_carpool_cost + 2*cost_factor_obj_mor(it_com, 1);
    end
end


calories = sum(calory_factor_obj_mor(generic_recommendations(:,1) == 'transit + walk', 2)) + ...
    sum(calory_factor_obj_mor(generic_recommendations(:,1) == 'walk', 4)) + ...
    sum(calory_factor_obj_mor(generic_recommendations(:,1) == 'bike', 5));

reduced_sov_trips_recom = sum(generic_recommendations(:,1) ~= 'drive alone');


