%% Business provided data
telecommuting_ratio = 1/5 ;
working_days_per_month = 4*(5*(1-telecommuting_ratio)) ;

business_name = 'Auraria Higher Education Center';
business_address = '1098 9th Street, Denver, CO 80204, USA';
business_size = '272';
employees_arrival_range   = '8am - 9am';
employees_departure_range = '4pm - 5pm';
number_of_employees_commuting = '217';
commuting_days = 'Monday, Tuesday, Wednesday, Thursday, Friday';
parking_daily_cost = '10'; % daily
transit_pass_cost = '105' ; % per employee per year

denver_county_drive_alone_share = 66.1/100;
denver_county_carpool_share = 7.3/100 ;
denver_county_transit_share = 6.2/100 ;
denver_county_walk_share = 4.7/100 ;

%% Parameters
report_template_filename = 'report_template_v0.docx';
figure_template_filename = 'figures_template_v0.xlsx';

%% Configurations
current_date = datestr(now,'yyyy_mm_dd_HH_MM_SS');
APIKeys_Here360 = {'E9XDV4mFu35b-1cd5IW4_IptSXZhSD2ZqIEm_AqZ8Go'};

%% Copy the template files
report_destination_path = sprintf("%s\\report_%s_%s.docx",pwd,business_name,current_date);
copyfile(report_template_filename,report_destination_path,'f')

figure_destination_path = sprintf("%s\\figures_%s_%s.xlsx",pwd,business_name,current_date);
copyfile(figure_template_filename,figure_destination_path,'f')

figure_destination_path = figure_template_filename;

%% Open the report
word         = actxserver('Word.Application');        % start Word
word.Visible = 1;                                     % make Word Visible
document     = word.Documents.Open(report_destination_path); % create new Document
selection    = word.Selection;
%% Section: Overview
selection.Find.Execute('field_businessName',0,1,0,0,0,1,1,1,business_name,2,0,0,1,1); 
selection.Find.Execute('field_businessAddress',0,1,0,0,0,1,1,1,business_address,2,0,0,1,1); 
selection.Find.Execute('field_businessSize',0,1,0,0,0,1,1,1,business_size,2,0,0,1,1); 
selection.Find.Execute('field_employeesArrivalRange',0,1,0,0,0,1,1,1,employees_arrival_range,2,0,0,1,1); 
selection.Find.Execute('field_employeesDepartureRange',0,1,0,0,0,1,1,1,employees_departure_range,2,0,0,1,1); 
selection.Find.Execute('field_numberOfEmployeesCommuting',0,1,0,0,0,1,1,1,number_of_employees_commuting,2,0,0,1,1); 
selection.Find.Execute('field_commuting_days',0,1,0,0,0,1,1,1,commuting_days,2,0,0,1,1); 
selection.Find.Execute('field_parkingDailyCost',0,1,0,0,0,1,1,1,parking_daily_cost,2,0,0,1,1);
selection.Find.Execute('field_transitPassCost',0,1,0,0,0,1,1,1,transit_pass_cost,2,0,0,1,1);

%% Section: Employees Map
generate_png_employees_layout_v2(HomeLatLong_mat, Work_LatLong, 10);
selection.Find.Execute('Field_employees_map',1,1,0,0,0,1,1,1," %",2,0,0,1,1);
selection.InlineShapes.AddPicture(pwd + "\employees_layout_v2_zoomlvl_9.png");  % absolute path to the image

%% Section: Commute Estimates
inc_ind_mor = TimeMatrix_Week{1,1}(:,1) ~= 99999 ;
inc_ind_aft = TimeMatrix_Week{2,1}(:,1) ~= 99999 ;

% Emission
total_commuting_emission_per_month = (  ...
    sum(EmissionMatrix_Week{1,1}(inc_ind_mor,1)) + ...
    sum(EmissionMatrix_Week{2,1}(inc_ind_aft,1))  ...
    ) ...
    / CO2_Cost*1000*working_days_per_month;

% Time
average_commuting_time_per_two_trips = mean(TimeMatrix_Week{1,1}(inc_ind_mor,1)) + mean(TimeMatrix_Week{2,1}(inc_ind_aft,1));
average_commuting_time_per_day = average_commuting_time_per_two_trips*(1-telecommuting_ratio);

% Cost
CostMatrix_Week{1,1}(:,1) = CostMatrix_Week{1,1}(:,1) - 5.8;
tmp_ind = CostMatrix_Week{1,1}(:,2:3)==1.25;
CostMatrix_Week{1,1}(tmp_ind,2:3) = 0;
CostMatrix_Week{2,1}(tmp_ind,2:3) = 0;
average_commuting_cost_per_two_trips = mean(CostMatrix_Week{1,1}(inc_ind_mor,1)) + mean(CostMatrix_Week{2,1}(inc_ind_aft,1));
average_commuting_cost_per_day = average_commuting_cost_per_two_trips*(1-telecommuting_ratio);

% SOV trips
sov_trips_per_day = round(size(TimeMatrix_Week{1,1},1)*denver_county_drive_alone_share*(1-telecommuting_ratio));

% Parking Cost
employer_parking_cost = 0 ;
employee_parking_cost = str2double(parking_daily_cost);

% replace in report
selection.Find.Execute('field_existingEmissions',0,1,0,0,0,1,1,1,round(total_commuting_emission_per_month),2,0,0,1,1); 
selection.Find.Execute('field_existingTime',0,1,0,0,0,1,1,1,round(average_commuting_time_per_day),2,0,0,1,1); 
selection.Find.Execute('field_existingCost',0,1,0,0,0,1,1,1,round(average_commuting_cost_per_day),2,0,0,1,1); 
selection.Find.Execute('field_existingSOVtrips',0,1,0,0,0,1,1,1,round(sov_trips_per_day),2,0,0,1,1); 
selection.Find.Execute('field_employerParkingCost',0,1,0,0,0,1,1,1,round(employer_parking_cost),2,0,0,1,1); 
selection.Find.Execute('field_employeeParkingCost',0,1,0,0,0,1,1,1,round(employee_parking_cost),2,0,0,1,1); 
selection.Find.Execute('field_commutingdaysperweek',0,1,0,0,0,1,1,1,round(5 - telecommuting_ratio*5),2,0,0,1,1); 


%% Section: Commute Analysis

% walk
walking_speed          = 3 ; % mile per hour
dist_flexibility_range = 0.25:0.25:1.5 ;
feasibility_walk       = zeros(length(dist_flexibility_range),3);
cnt = 1 ;
for dist_flexibility = dist_flexibility_range
    feas_ind = all( [DistanceMatrix_Week{1,1}(:,4) ~= 99999 , ...
        DistanceMatrix_Week{1,1}(:,4) <= dist_flexibility] , 2) ;
    feasibility_walk(cnt,:) = [dist_flexibility, dist_flexibility/walking_speed*60, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_walk(:,2:3),figure_destination_path, 'Sheet','fig1','Range','B3')


% bike
biking_speed           = 10 ; % mile per hour
dist_flexibility_range = 0.5:0.5:3 ;
feasibility_bike       = zeros(length(dist_flexibility_range),3);
cnt = 1 ;
for dist_flexibility = dist_flexibility_range
    feas_ind = all( [DistanceMatrix_Week{1,1}(:,5) ~= 99999 , ...
        DistanceMatrix_Week{1,1}(:,5) <= dist_flexibility] , 2) ;
    feasibility_bike(cnt,:) = [dist_flexibility, dist_flexibility/biking_speed*60, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_bike(:,2:3),figure_destination_path, 'Sheet','fig2','Range','B3')


% e-bike
biking_speed           = 20 ; % mile per hour
dist_flexibility_range = 0.5:0.5:6 ;
feasibility_bike       = zeros(length(dist_flexibility_range),3);
cnt = 1 ;
for dist_flexibility = dist_flexibility_range
    feas_ind = all( [DistanceMatrix_Week{1,1}(:,5) ~= 99999 , ...
        DistanceMatrix_Week{1,1}(:,5) <= dist_flexibility] , 2) ;
    feasibility_bike(cnt,:) = [dist_flexibility, dist_flexibility/biking_speed*60, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_bike(:,2:3),figure_destination_path, 'Sheet','fig2 (2)','Range','B3')


% public transit - Based on Trip Duration
trip_druation_range = 15:15:60 ;
feasibility_public_transit_v1 = zeros(length(trip_druation_range),2);
cnt = 1 ;
for trip_dur = trip_druation_range
    feas_ind = all( [TimeMatrix_Week{1,1}(:,2) ~= 99999 , ...
        TimeMatrix_Week{1,1}(:,2) <= trip_dur] , 2) ;
    feasibility_public_transit_v1(cnt,:) = [trip_dur, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_public_transit_v1,figure_destination_path, 'Sheet','fig3','Range','A3')

if ~exist('p_time', 'var')
    % load park and ride geo coordinates
    load park_n_ride_geo_code.mat
    % calculate travel attributes for park n ride
    park_n_ride_attributes
    [min_time, ind_min_time] = min(park_n_ride_time, [], 2) ;
    idx = sub2ind(size(park_n_ride_time), 1:size(park_n_ride_time,1), ind_min_time') ;
    p_time = park_n_ride_time(idx)'  ;
    p_dist = park_n_ride_distance(idx)';
end
time_flexibility_range = 15:15:60 ;
feasibility_park_and_ride_v1 = zeros(length(time_flexibility_range),2);
cnt = 1 ;
for time_flexibility = time_flexibility_range
    feas_ind = all( [p_time ~= 99999 , ...
        p_time <= time_flexibility] , 2) ;
    feasibility_park_and_ride_v1(cnt,:) = [time_flexibility, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_park_and_ride_v1,figure_destination_path, 'Sheet','fig3','Range','A11')



% public transit - Based on Time Flexibility
time_flexibility_range = 15:5:45 ;
feasibility_public_transit_v2 = zeros(length(time_flexibility_range),2);
cnt = 1 ;
for time_flexibility = time_flexibility_range
    feas_ind = all( [TimeMatrix_Week{1,1}(:,2) ~= 99999 , ...
        TimeMatrix_Week{1,1}(:,2) - TimeMatrix_Week{1,1}(:,1) <= time_flexibility] , 2) ;
    feasibility_public_transit_v2(cnt,:) = [time_flexibility, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_public_transit_v2(:,end),figure_destination_path, 'Sheet','fig4','Range','B3')

% park and ride - Based on Time Flexibility
time_flexibility_range = 15:5:45 ;
feasibility_park_and_ride_v2 = zeros(length(time_flexibility_range),2);
cnt = 1 ;
for time_flexibility = time_flexibility_range
    feas_ind = all( [p_time ~= 99999 , ...
        p_time - TimeMatrix_Week{1,1}(:,1) <= time_flexibility] , 2) ;
    feasibility_park_and_ride_v2(cnt,:) = [time_flexibility, sum(feas_ind)];
    cnt = cnt + 1 ;
end
writematrix(feasibility_park_and_ride_v2(:,end),figure_destination_path, 'Sheet','fig4','Range','B13')

%% Section: Recommendations
generic_recommendation_v3

recom_walk_cnt      = sum(generic_recommendations == 'walk');
recom_bike_cnt      = sum(generic_recommendations == 'bike');
recom_walk_bike_cnt = recom_walk_cnt + recom_bike_cnt;
recom_walk_bike_prc = recom_walk_bike_cnt/size(generic_recommendations,1)*100;

recom_transit_pot       = sum(TimeMatrix_Week{1,1}(:,2) ~= 99999);
recom_transit_hour      = sum(all([TimeMatrix_Week{1,1}(:,2) ~= 99999 , TimeMatrix_Week{1,1}(:,2) <= 60],2));
recom_transit_walk_cnt  = sum(generic_recommendations == 'transit + walk');
recom_transit_drive_cnt = sum(generic_recommendations == 'transit + drive');
recom_transit_total     = recom_transit_walk_cnt + recom_transit_drive_cnt ;
recom_transit_prc       = recom_transit_total/size(generic_recommendations,1)*100;
field_employer_transit_cost_option_1 = recom_transit_pot*str2double(transit_pass_cost);
field_employer_transit_cost_option_2 = recom_transit_total*50*4*(1-telecommuting_ratio)*5;

field_recom_carpool_total = sum(generic_recommendations == 'carpool');
field_recom_carpool_prc = sum(generic_recommendations == 'carpool')/size(generic_recommendations,1)*100;

carpoolers_driving_cost = CostMatrix_Week{1,1}(generic_recommendations == 'carpool',1);
field_recom_monetary_inc  = 0.5*mean(carpoolers_driving_cost);


selection.Find.Execute('field_walk',0,1,0,0,0,1,1,0,round(recom_walk_cnt),2,1,1,1,1); 
selection.Find.Execute('field_bike',0,1,0,0,0,1,1,1,round(recom_bike_cnt),2,0,0,1,1); 
selection.Find.Execute('field_walkbike',0,1,0,0,0,1,1,1,round(recom_walk_bike_cnt),2,0,0,1,1); 
selection.Find.Execute('field_walkbikeperc',0,1,0,0,0,1,1,1,round(recom_walk_bike_prc),2,1,0,0,0); 
selection.Find.Execute('field_transitpot',0,1,0,0,0,1,1,1,round(recom_transit_pot),2,0,0,1,1); 
selection.Find.Execute('field_transithour',0,1,0,0,0,1,1,1,round(recom_transit_hour),2,0,0,1,1); 
selection.Find.Execute('field_transitwalkcnt',0,1,0,0,0,1,1,1,round(recom_transit_walk_cnt),2,0,0,1,1); 
selection.Find.Execute('field_transitdrivecnt',0,1,0,0,0,1,1,1,round(recom_transit_drive_cnt),2,0,0,1,1); 
selection.Find.Execute('field_transittotal',0,1,0,0,0,1,1,1,round(recom_transit_total),2,0,0,1,1); 
selection.Find.Execute('field_transitprc',0,1,0,0,0,1,1,1,round(recom_transit_prc),2,0,0,1,1); 
selection.Find.Execute('field_employertransitcostoption1',0,1,0,0,0,1,1,1,round(field_employer_transit_cost_option_1),2,0,0,1,1); 
selection.Find.Execute('field_employertransitcostoption2',0,1,0,0,0,1,1,1,round(field_employer_transit_cost_option_2),2,0,0,1,1); 
selection.Find.Execute('field_recomcarpooltotal',0,1,0,0,0,1,1,1,round(field_recom_carpool_total),2,0,0,1,1); 
selection.Find.Execute('field_recomcarpoolprc',0,1,0,0,0,1,1,1,round(field_recom_carpool_prc),2,0,0,1,1); 
selection.Find.Execute('field_recommonetaryinc',0,1,0,0,0,1,1,1,round(field_recom_monetary_inc),2,0,0,1,1); 


%% Section: Modal Share
ex_sol_mor = Obj_Emission_Sol{1, 1}{1, 1}{1, 2}.mor;
ex_sol_aft = Obj_Emission_Sol{1, 1}{1, 1}{1, 2}.aft;
sol_mor = Obj_Emission_Sol{1, 1}{1, 1}{1, 1}.x_mor;
sol_aft = Obj_Emission_Sol{1, 1}{1, 1}{1, 1}.x_aft;

existing_mode_share    = zeros(1,6);

existing_mode_share(1,1) = round(size(sol_mor,1)*denver_county_drive_alone_share*(1-telecommuting_ratio));
existing_mode_share(1,2) = round(size(sol_mor,1)*denver_county_transit_share*(1-telecommuting_ratio));
existing_mode_share(1,3) = round(size(sol_mor,1)*denver_county_walk_share*(1-telecommuting_ratio));
existing_mode_share(1,5) = round(size(sol_mor,1)*denver_county_carpool_share*(1-telecommuting_ratio));
existing_mode_share(1,4) = size(sol_mor,1)*(1-telecommuting_ratio) - sum(existing_mode_share);
existing_mode_share(1,6) = size(sol_mor,1) - sum(existing_mode_share);


recommended_mode_share = round([ sum(sol_mor(:,1)) , sum(sum(sol_mor(:,2:3))) , sum(sol_mor(:,4:5)) , sum(sol_mor(:,6:end),"all") ]*(1-telecommuting_ratio)) ;
recommended_mode_share(1,6) =  size(sol_mor,1) - sum(recommended_mode_share);


modal_share = [existing_mode_share ; recommended_mode_share];

writematrix(transpose(modal_share(2,:)/size(sol_mor,1)) ,figure_destination_path, 'Sheet','fig6','Range','B2')

%% Section: Generic Recommendations Map
generate_png_employees_recom(HomeLatLong_mat, worklatlongunique, generic_recommendations )
selection.Find.Execute('Field_generic_recom_map',1,1,0,0,0,1,0,0,"",2,0,0,1,1);
selection.InlineShapes.AddPicture(pwd + "\generic_recommendations.png");  % absolute path to the image

%% Section: Community Benefits

field_co2 = (carpool_emissions + drive_emissions)*working_days_per_month ;
field_co2_reduction = round((total_commuting_emission_per_month - field_co2)/total_commuting_emission_per_month*100);
field_social_benefits = round(social_hrs) ;
field_calories = round(calories*working_days_per_month) ;
field_reduced_sov = round(reduced_sov_trips_recom*(1-telecommuting_ratio));
field_reduced_sov_monthly = round(field_reduced_sov*4*5);
field_reduced_sov_prc = round(field_reduced_sov/sov_trips_per_day*100);

field_employees_savings  = (average_commuting_cost_per_day*272 - drive_and_carpool_cost*(1-telecommuting_ratio))*4*5;
field_employees_monetary_inc_month = 4000;
field_employees_monetary_inc_year = 48000;
field_employees_program_cost_month = 8346;
field_employees_program_cost_year = 100156;

selection.Find.Execute('field_co2',1,1,0,0,0,1,0,1,round(field_co2),2,0,0,1,1); 
selection.Find.Execute('field_co2_reduction',1,1,0,0,0,1,0,1,round(field_co2_reduction),2,0,0,1,1); 
selection.Find.Execute('field_social_benefits',1,1,0,0,0,1,0,1,round(field_social_benefits),2,0,0,1,1); 
selection.Find.Execute('field_calories',1,1,0,0,0,1,0,1,round(field_calories),2,0,0,1,1); 
selection.Find.Execute('field_reduced_sov',1,1,0,0,0,1,0,1,round(field_reduced_sov),2,0,0,1,1); 
selection.Find.Execute('field_reduced_sov_monthly',1,1,0,0,0,1,0,1,round(field_reduced_sov_monthly),2,0,0,1,1); 
selection.Find.Execute('field_reduced_sov_prc',1,1,0,0,0,1,0,1,round(field_reduced_sov_prc),2,0,0,1,1); 
selection.Find.Execute('field_employees_savings',1,1,0,0,0,1,0,1,round(field_employees_savings),2,0,0,1,1); 

selection.Find.Execute('field_employees_monetary_inc_month',1,1,0,0,0,1,0,1,round(field_employees_monetary_inc_month),2,0,0,1,1); 
selection.Find.Execute('field_employees_monetary_inc_year',1,1,0,0,0,1,0,1,round(field_employees_monetary_inc_year),2,0,0,1,1); 
selection.Find.Execute('field_employees_program_cost_month',1,1,0,0,0,1,0,1,round(field_employees_program_cost_month),2,0,0,1,1); 
selection.Find.Execute('field_employees_program_cost_year',1,1,0,0,0,1,0,1,round(field_employees_program_cost_year),2,0,0,1,1); 

%% Clustering
dist_range = 0.5:0.5:5;
output = zeros(length(dist_range),3);

for it_dist = 1:length(dist_range)
    [clustersCentroids,clustersGeoMedians,clustersXY] = ...
        clusterXYpoints(HomeLatLong_mat,dist_range(it_dist),5,'centroid','merge');
    output(it_dist,1) = dist_range(it_dist);
    cnt_emp = 0 ;
    for i = 1:size(clustersXY,1)
        cnt_emp = cnt_emp + size(clustersXY{i,1},1);
    end
    output(it_dist,1) = dist_range(it_dist);
    output(it_dist,2) = cnt_emp;
    close all
    tmp = zeros(size(clustersCentroids,1),1);
    for i = 1:size(clustersCentroids,1)
        tmp(i,1) = lldistkm(clustersCentroids(i,:),worklatlongunique)*0.621371;
    end
    output(it_dist,3) = mean(tmp);
end


