function generate_png_vanpool_3(Home_LatLong_mat, worklatlongunique, index_clust_final)


colors = {'CCFFFF','FFCCFF','E6FFCC','FFE6CC', ...
    'CCE6FF', 'E6CCFF', 'CCCCFF', 'FFFFCC', 'CCCCA3',...
    'A3A382','424235', '22221B','FF9900','FF00FF','00FF00',...
    'CC0000','AEE233','F82229','F8AE3F','465B9E','41BECA'};

str_array = cell(max(index_clust_final),1);
for i = 1:max(index_clust_final)
    
    points = Home_LatLong_mat(index_clust_final == i,:) ;
    str = "";
    
    for j = 1:size(points,1)
        if j ==1
            str = sprintf("%.4f,%.4f",points(j,1),points(j,2));
        else
            str = sprintf("%s|%.4f,%.4f",str,points(j,1),points(j,2));
        end
    end
    str_array{i,1} = str;
end



str = "https://maps.googleapis.com/maps/api/staticmap?" + ...
    "center=" + worklatlongunique(1,1) + "," + worklatlongunique(1,2) + ...
    "&zoom=10&size=640x640&scale=2" ;
for i = 1:max(index_clust_final)
    
    ind_color = mod(i,numel(colors));
    if ind_color == 0
        ind_color = randsample(1:numel(colors),1); 
    end
    
    str = str + ...
    "&markers=size:tiny|color:0x" + colors{ind_color} + "|" +  str_array{i,1} ;

end

str  = str + "&markers=color:red|label:B|" + worklatlongunique(1,1) + "," + worklatlongunique(1,2) + ...
    "&key=AIzaSyDP1vj_KRkccTdk1nrngsuU45wPRto02fc" ;
[png_data,colormap,~] = webread(str);


imwrite(png_data,colormap,'vanpool_5miles_v100.png')

