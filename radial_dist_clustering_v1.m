function index_clust_final = radial_dist_clustering_v1(Home_LatLong_mat)

% remove non-unique home locations
Home_LatLong_mat = unique(Home_LatLong_mat,'rows','stable') ;

%% parameters
nc = size(Home_LatLong_mat,1) ;
min_size = 10 ;
radial_dist = 2 ;

%% Calculations
Mdl = createns(Home_LatLong_mat,'Distance',@distfun);
[IdxNN, idx_d] = knnsearch(Mdl,Home_LatLong_mat,'K',min_size, 'IncludeTies',true);

distance_vect = zeros(size(IdxNN,1),1);
for it = 1:size(IdxNN,1)
    distance_vect(it,1) = idx_d{it,1}(end);
end
[~,sort_i] = sort(distance_vect);

inx = zeros(nc,1);
clust_cnt = 1 ;
for it_com = sort_i'
    D = pdist(Home_LatLong_mat(IdxNN{it_com,:},:),@distfun);
    if max(D) <= radial_dist && ~any(inx(IdxNN{it_com,:},:))
        inx(IdxNN{it_com,:},1) = clust_cnt ;
        clust_cnt = clust_cnt + 1 ;
    end
end


cluster_density = zeros(max(inx),2);
for it_clust = 1:max(inx)
    D = pdist(Home_LatLong_mat(inx==it_clust,:),@distfun);
    cluster_density(it_clust,:) = [it_clust , sum(D)] ;
end
[~,sort_index] = sort(cluster_density(:,2));


index_clust_final = zeros(nc,1);
for it_clust = sort_index'
    index_clust_final(inx == it_clust,1) = it_clust ;
    for it_point = setdiff(1:nc,find(inx == it_clust))
        D = pdist(Home_LatLong_mat([find(inx == it_clust);it_point],:),@distfun);
        if max(D) <= radial_dist && index_clust_final(it_point) == 0
            index_clust_final(it_point,1) = it_clust ;
        end
    end
    
end



scatter(Home_LatLong_mat(:,1),Home_LatLong_mat(:,2),40,index_clust_final,'filled')
hold on
log_ind = index_clust_final == 1 ;
scatter(Home_LatLong_mat(log_ind,1),Home_LatLong_mat(log_ind,2),100)


wmmarker(Home_LatLong_mat(:,1),Home_LatLong_mat(:,2),'color','red')
hold on
wmmarker(Home_LatLong_mat(log_ind,1),Home_LatLong_mat(log_ind,2),'color','yellow')

