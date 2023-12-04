function geo_spatial_radial_distance_clustering(HomeLatLong_mat, radial_dist)

[x,y] = grn2eqa(HomeLatLong_mat(:,1),HomeLatLong_mat(:,2));

radial_dist = 

for k = 2:size(HomeLatLong_mat,1)

    [idx,C,sumd,D] = kmeans(HomeLatLong_mat,k)

end

