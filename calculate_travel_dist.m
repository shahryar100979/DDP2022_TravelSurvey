function travel_dist = calculate_travel_dist(latlongcord)

travel_dist = 0 ;
for i = 1:size(latlongcord,1)-1
    travel_dist = travel_dist + lldistkm(latlongcord(i,:), ...
        latlongcord(i+1,:))*0.621371;
end