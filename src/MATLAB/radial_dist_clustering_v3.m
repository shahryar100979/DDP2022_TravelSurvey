function [inx, cluster_centroid, cluster_size] = radial_dist_clustering_v3(HomeLatLong_mat,radial_dist, min_size)

% remove non-unique home locations
HomeLatLong_mat = unique(HomeLatLong_mat,'rows','stable') ;

%% parameters
nc = size(HomeLatLong_mat,1) ;

%% Calculations

% implement a range search for every point
Mdl = createns(HomeLatLong_mat,'Distance',@distfun);
[idx_clust, ~] = rangesearch(Mdl,HomeLatLong_mat,radial_dist);

% Calculate clusters centroid
cluster_centroid = zeros(size(idx_clust,1),2);
for it_clust = 1:size(idx_clust,1)
    cluster_centroid(it_clust,:) = mean(HomeLatLong_mat(idx_clust{it_clust,1},:),1);
end


% implement a range search for every point
Mdl = createns(HomeLatLong_mat,'Distance',@distfun);
[idx_clust, ~] = rangesearch(Mdl,cluster_centroid,radial_dist);

% sort the clusters based on size of nearest points and calculate clusters centroid
cluster_size = zeros(size(idx_clust,1),2);
cluster_centroid = zeros(size(idx_clust,1),2);
for it_clust = 1:size(idx_clust,1)
    cluster_size(it_clust,:) = [it_clust , numel(idx_clust{it_clust})] ;
    cluster_centroid(it_clust,:) = mean(HomeLatLong_mat(idx_clust{it_clust,1},:),1);
end
[~, sort_index] = sort(cluster_size(:,2), 'descend');


inx = zeros(nc,1);
clust_cnt = 1 ;
for it_com = sort_index'
    if length(idx_clust{it_com,:}) >= min_size && ~any(inx(idx_clust{it_com,:},:))
        inx(idx_clust{it_com,:},1) = clust_cnt ;
        clust_cnt = clust_cnt + 1 ;
    end
end
