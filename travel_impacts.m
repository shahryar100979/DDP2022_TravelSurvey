% initialization
% clc
% close all
% clear

% parameters
APIKeys_Here360 = {'E9XDV4mFu35b-1cd5IW4_IptSXZhSD2ZqIEm_AqZ8Go'} ;
timeout_val = 5 ;
AvgEmitCO2_Car = 368.4 ; % gram per mile of CO2 emissions for driving
Fuel_Price = 3.6 ; % $ per gallon
tire_cost = 0.025;
combined_MPG = 20 ;
depreciation_cost = 0.104;
mileage_cost = 0.15;

% load data
load geocode_address.mat

% impact_time = zeros(size(geo_coded_addresses,1),4);
% impact_distance = zeros(size(geo_coded_addresses,1),4);
% impact_cost = zeros(size(geo_coded_addresses,1),4);
% impact_co2emission = zeros(size(geo_coded_addresses,1),4);
% for every commuter
for it_com = 1050:size(geo_coded_addresses,1)


    origin = str2double([geo_coded_addresses(it_com,4),geo_coded_addresses(it_com,5)]);
    destination = str2double([geo_coded_addresses(it_com,9),geo_coded_addresses(it_com,10)]);

    %% driving alone
    % construct the here360 map api requests
    Here360_URL_1 = sprintf('https://router.hereapi.com/v8/routes?apiKey=%s',APIKeys_Here360{1}) ;
    Here360_URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&routingMode=fast&transportMode=car&return=summary,polyline',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url and set the option
    url = sprintf('%s%s',Here360_URL_1,Here360_URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;

    time = data_struct.routes.sections.summary.duration/60 ;
    distance = data_struct.routes.sections.summary.length*0.000621371;
    co2emission = distance * AvgEmitCO2_Car * 10^(-3);
    cost = distance * Fuel_Price / combined_MPG + (tire_cost + depreciation_cost + mileage_cost) * distance ;

    impact_time(it_com,1) = time;
    impact_distance(it_com,1) = distance;
    impact_co2emission(it_com,1) = co2emission;
    impact_cost(it_com,1) = cost;


    %% Transit
    % construct the here360 map api requests
    Here360_URL_1 = sprintf('https://transit.router.hereapi.com/v8/routes?apiKey=%s',APIKeys_Here360{1}) ;
    Here360_URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&alternative=0&return=polyline,fares',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url and set the option
    url = sprintf('%s%s',Here360_URL_1,Here360_URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;
    time = 0 ;
    distance = 0 ;
    cost = 0;
    co2emission = 0 ;
    if ~isempty(data_struct.routes)
        if ~isfield(data_struct,'notices')
            for it_sec = 1:numel(data_struct.routes(1).sections)
                arrival_time = datetime(data_struct.routes(1).sections{it_sec, 1}.arrival.time, 'InputFormat','yyyy-MM-dd''T''HH:mm:ssZ', 'TimeZone','UTC');
                departure_time = datetime(data_struct.routes(1).sections{it_sec, 1}.departure.time, 'InputFormat','yyyy-MM-dd''T''HH:mm:ssZ', 'TimeZone','UTC');
                time = time + (arrival_time - departure_time);

                route_shape = function_decode_flexpolyline_HERE(data_struct.routes(1).sections{it_sec, 1}.polyline) ;
                latlongcord = [route_shape.data.latitude' , route_shape.data.longitude'] ;
                distance = distance + calculate_travel_dist(latlongcord);
            end
            time = datenum(time)*60*24;
        end
    end


    impact_time(it_com,2) = time;
    impact_distance(it_com,2) = distance;
    impact_co2emission(it_com,2) = co2emission;
    impact_cost(it_com,2) = cost;


    %% walk only
    % construct the here360 api requests for walk only
    Here360_URL_1 = sprintf('https://router.hereapi.com/v8/routes?apiKey=%s',APIKeys_Here360{1}) ;
    Here360_URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&routingMode=fast&transportMode=pedestrian&return=summary,polyline',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url
    url = sprintf('%s%s',Here360_URL_1,Here360_URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;

    if numel(data_struct.routes.sections) > 1
        time = data_struct.routes.sections{1}.summary.duration/60 ;
        distance = data_struct.routes.sections{1}.summary.length*0.000621371;
    else
        time = data_struct.routes.sections.summary.duration/60 ;
        distance = data_struct.routes.sections.summary.length*0.000621371;
    end
    co2emission = 0;
    cost = 0;

    impact_time(it_com,3) = time;
    impact_distance(it_com,3) = distance;
    impact_co2emission(it_com,3) = co2emission;
    impact_cost(it_com,3) = cost;

    %% bike only
    % construct the here360 api requests for bike only
    Here360_URL_1 = sprintf('https://router.hereapi.com/v8/routes?apiKey=%s',APIKeys_Here360{1}) ;
    Here360_URL_2 = sprintf('&origin=%0.9f,%0.9f&destination=%0.9f,%0.9f&transportMode=bicycle&return=summary',...
        origin(1,1),...
        origin(1,2),...
        destination(1,1),...
        destination(1,2)) ;

    % create the url and set the web option
    url = sprintf('%s%s',Here360_URL_1,Here360_URL_2) ;
    options = weboptions('Timeout',timeout_val) ;
    data_struct = webread(url,options) ;
    time = 0 ;
    distance = 0 ;
    co2emission = 0;
    cost = 0;
    if ~isa(data_struct.routes.sections, 'struct')
        for i = 1:numel(data_struct.routes.sections)
            time = time + data_struct.routes.sections{i}.summary.duration/60 ;
            distance = distance + data_struct.routes.sections{i}.summary.length*0.000621371;
        end
    else
        for i = 1:numel(data_struct.routes.sections)
            time = time + data_struct.routes.sections(i).summary.duration/60 ;
            distance = distance + data_struct.routes.sections(i).summary.length*0.000621371;
        end
    end

    impact_time(it_com,4) = time;
    impact_distance(it_com,4) = distance;
    impact_co2emission(it_com,4) = co2emission;
    impact_cost(it_com,4) = cost;

end

final = [geo_coded_addresses, string([impact_time, impact_distance, impact_co2emission, impact_cost])]
