% initialization
% clc
% close all
% clear

% parameters
APIKeys_Here360 = {'E9XDV4mFu35b-1cd5IW4_IptSXZhSD2ZqIEm_AqZ8Go'} ;
APIKeys_GoogleMaps = {'AIzaSyBHg6s8MLOAwdkpNlUfiWfSDOYzmNQ1RiA'};
APIKeys_GoogleMaps = {'AIzaSyBy1vCZDk_23Ytobq_udbTh_HGw8Klq5VI'};


timeout_val = 5 ;
AvgEmitCO2_Car = 368.4 ; % gram per mile of CO2 emissions for driving
Fuel_Price = 3.1 ; % $ per gallon
tire_cost = 0.025;
combined_MPG = 20 ;
depreciation_cost = 0.104;
mileage_cost = 0.15;

% load data
load geocode_address.mat

% impact_time = zeros(size(geo_coded_addresses,1),4) ;
% impact_distance = zeros(size(geo_coded_addresses,1),4) ;
% impact_co2emission = zeros(size(geo_coded_addresses,1),4) ;
% impact_cost = zeros(size(geo_coded_addresses,1),4) ;

% for every commuter
for it_com = 1627:size(geo_coded_addresses,1)

    if ismissing(geo_coded_addresses(it_com,4)) || ...
            strcmp(geo_coded_addresses(it_com,1),'NA') || ...
            ismissing(geo_coded_addresses(it_com,9))
        continue
    end

    % skip if the addresses are not in colorado
    if ~contains(geo_coded_addresses(it_com,8),'CO') || ...
            ~contains(geo_coded_addresses(it_com,3),'CO') 
        continue
    end

    origin = str2double([geo_coded_addresses(it_com,4),geo_coded_addresses(it_com,5)]);
    destination = str2double([geo_coded_addresses(it_com,9),geo_coded_addresses(it_com,10)]);
    departure_time = round(str2double(geo_coded_addresses(it_com,11)));

    %% driving alone
    % construct the here360 map api requests
    URL_1 = sprintf('https://maps.googleapis.com/maps/api/directions/json?key=%s',APIKeys_GoogleMaps{1}) ;
    URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&mode=driving&departure_time=%d&traffic_model=pessimistic',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2),...
        departure_time+4*7*24*3600+7*3600) ;

    % create the url and set the option
    url = sprintf('%s%s',URL_1,URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;

    if strcmp(data_struct.status,'OK')

        url_optimistic_traffic = strrep(url,'=pessimistic','=optimistic') ;
        data_struct_optimistic = webread(url_optimistic_traffic,options) ;

        if isfield(data_struct_optimistic.routes.legs, 'duration_in_traffic')
            impact_time(it_com,1) = (data_struct.routes.legs.duration_in_traffic.value/60 + data_struct_optimistic.routes.legs.duration_in_traffic.value/60)/2 ;
        else
            impact_time(it_com,1) = (data_struct.routes.legs.duration.value/60 + data_struct_optimistic.routes.legs.duration.value/60)/2 ;
        end
        impact_distance(it_com,1) = data_struct.routes.legs.distance.value*0.000621371;
        impact_co2emission(it_com,1) = data_struct.routes.legs.distance.value*0.000621371 * AvgEmitCO2_Car * 10^(-3);
        impact_cost(it_com,1) = impact_distance(it_com,1) * Fuel_Price / combined_MPG + (tire_cost + depreciation_cost + mileage_cost) * impact_distance(it_com,1) ;
    else
        impact_time(it_com,1) = 0;
        impact_distance(it_com,1) = 0;
        impact_co2emission(it_com,1) = 0;
        impact_cost(it_com,1) = 0;
    end


    %% Transit
    % construct the here360 map api requests
    URL_1 = sprintf('https://maps.googleapis.com/maps/api/directions/json?key=%s',APIKeys_GoogleMaps{1}) ;
    URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&mode=transit&departure_time=%d',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2),...
        departure_time+4*7*24*3600+7*3600) ;

    % create the url and set the option
    url = sprintf('%s%s',URL_1,URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;


    if strcmp(data_struct.status,'OK')
        impact_time(it_com,2) = data_struct.routes.legs.duration.value/60 ;
        impact_distance(it_com,2) = data_struct.routes.legs.distance.value*0.000621371;
        impact_co2emission(it_com,2) = 0;
        impact_cost(it_com,2) = 0;
    else
        impact_time(it_com,2) = 0;
        impact_distance(it_com,2) = 0;
        impact_co2emission(it_com,2) = 0;
        impact_cost(it_com,2) = 0;
    end


    %% walk only
    % construct the here360 api requests for walk only
    URL_1 = sprintf('https://maps.googleapis.com/maps/api/directions/json?key=%s',APIKeys_GoogleMaps{1}) ;
    URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&mode=walking',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url
    url = sprintf('%s%s',URL_1,URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;

    if strcmp(data_struct.status,'OK')
        impact_time(it_com,3) = data_struct.routes.legs.duration.value/60 ;
        impact_distance(it_com,3) = data_struct.routes.legs.distance.value*0.000621371;
        impact_co2emission(it_com,3) = 0;
        impact_cost(it_com,3) = 0;
    else
        impact_time(it_com,3) = 0 ;
        impact_distance(it_com,3) = 0;
        impact_co2emission(it_com,3) = 0;
        impact_cost(it_com,3) = 0;
    end

    %% bike only
    % construct the here360 api requests for bike only
    URL_1 = sprintf('https://maps.googleapis.com/maps/api/directions/json?key=%s',APIKeys_GoogleMaps{1}) ;
    URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&mode=bicycling',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url and set the web option
    url = sprintf('%s%s',URL_1,URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;

    if strcmp(data_struct.status,'OK')
        impact_time(it_com,4) = data_struct.routes.legs.duration.value/60 ;
        impact_distance(it_com,4) = data_struct.routes.legs.distance.value*0.000621371;
        impact_co2emission(it_com,4) = 0;
        impact_cost(it_com,4) = 0;
    else
        impact_time(it_com,4) = 0;
        impact_distance(it_com,4) = 0;
        impact_co2emission(it_com,4) = 0;
        impact_cost(it_com,4) = 0;
    end

end

final = [geo_coded_addresses, string([impact_time, impact_distance, impact_co2emission, impact_cost])];
save("travel_impacts.mat","final"); 
