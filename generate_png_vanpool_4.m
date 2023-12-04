function generate_png_vanpool_4(HomeLatLong_mat, worklatlongunique, inx, add_label, radial_dist, zoom_lvl)

% remove non-unique home locations
HomeLatLong_mat = unique(HomeLatLong_mat,'rows','stable') ;

labels = 'A':'Z';

colors = {'CCFFFF','FFCCFF','E6FFCC','FFE6CC', ...
    'CCE6FF', 'E6CCFF', 'CCCCFF', 'FFFFCC', 'CCCCA3',...
    'A3A382','424235', '22221B','FF9900','FF00FF','00FF00',...
    'CC0000','AEE233','F82229','F8AE3F','465B9E','41BECA'};

str_array = cell(max(inx),1);
for i = 1:max(inx)
    
    points = HomeLatLong_mat(inx == i,:) ;
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
    "center=" + mean(HomeLatLong_mat(:,1)) + "," + mean(HomeLatLong_mat(:,2)) + ...
    "&zoom=" + num2str(zoom_lvl) + "&size=640x640&scale=2" ;
for i = 1:max(inx)
    ind_color = mod(i,numel(colors));
    if ind_color == 0
        ind_color = randsample(1:numel(colors),1); 
    end
    
    if add_label
        str = str + ...
            "&markers=size:med|color:0x" + colors{ind_color} + "|label:" + ...
            convertCharsToStrings(labels(i)) + "|" +  str_array{i,1} ;
    else
        str = str + ...
            "&markers=size:tiny|color:0x" + colors{ind_color} + "|label:" + ...
            convertCharsToStrings(labels(i)) + "|" +  str_array{i,1} ;
    end
end


for i = 1:max(inx)
    worldmap([25 55],[-130 -65])
    [~,circlelat,circlelon] = circlem(mean(HomeLatLong_mat(inx==i,1)),mean(HomeLatLong_mat(inx==i,2)), radial_dist*1.9);
    encoded_polyline = function_encode_polyline_Google([circlelat([1:5:100,1]),circlelon([1:5:100,1])]);
    str = str + ...
        "&path=color:0x00000000|geodesic:true|fillcolor:0x" + "AA000033|weight:5" + "|enc:" +   encoded_polyline ;
end


for i = 1:max(inx) 
    num_member = num2str(sum(inx == i));
    center = [mean(HomeLatLong_mat(inx==i,1)), mean(HomeLatLong_mat(inx==i,2))] ;
    str = str + ...
    "&markers=size:med|color:0xFFFFFF" + "|label:" + convertCharsToStrings(labels(i)) + ...
    "|" +  center(1,1) + "," + center(1,2) ;
end



str  = str + "&markers=color:red|label:Busines|" + worklatlongunique(1,1) + "," + worklatlongunique(1,2) + ...
    "&key=AIzaSyDP1vj_KRkccTdk1nrngsuU45wPRto02fc" ;
[png_data,colormap,~] = webread(str);

if add_label
    image_name = sprintf('vanpool_potential_%.1f_mile_label.png',radial_dist);
else
    image_name = sprintf('vanpool_potential_%.1f_mile_nolabel.png',radial_dist);
end

imwrite(png_data,colormap,image_name)

