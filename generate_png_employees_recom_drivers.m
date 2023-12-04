function generate_png_employees_recom_drivers(HomeLatLong_mat, HomeLatLong_mat_drivers, Work_LatLong, zoom_lvl)

Work_LatLong_mat = cell2mat(Work_LatLong);
Work_LatLong_mat = unique(Work_LatLong_mat,'rows','stable');


str_emp_home_locs = "";
for it_com = 1:size(HomeLatLong_mat,1)
    if it_com ==1
        str_emp_home_locs = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
    else
        str_emp_home_locs = sprintf("%s|%.4f,%.4f",str_emp_home_locs,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
    end
end

str_emp_home_locs_drivers = "";
for it_com = 1:size(HomeLatLong_mat_drivers,1)
    if it_com ==1
        str_emp_home_locs_drivers = sprintf("%.4f,%.4f",HomeLatLong_mat_drivers(it_com,1),HomeLatLong_mat_drivers(it_com,2));
    else
        str_emp_home_locs_drivers = sprintf("%s|%.4f,%.4f",str_emp_home_locs_drivers,HomeLatLong_mat_drivers(it_com,1),HomeLatLong_mat_drivers(it_com,2));
    end
end


str_emp_work_locs = "";
for it_com = 1:size(Work_LatLong_mat,1)
    if it_com ==1
        str_emp_work_locs = sprintf("%.4f,%.4f",Work_LatLong_mat(it_com,1),Work_LatLong_mat(it_com,2));
    else
        str_emp_work_locs = sprintf("%s|%.4f,%.4f",str_emp_work_locs,Work_LatLong_mat(it_com,1),Work_LatLong_mat(it_com,2));
    end
end


str = "https://maps.googleapis.com/maps/api/staticmap?" + ...
    "center=" + mean(Work_LatLong_mat(:,1)) + "," + mean(Work_LatLong_mat(:,2)) + ...
    "&zoom=" + zoom_lvl + "&size=640x640&scale=2" + ...
    "&markers=size:tiny|color:red|" +  str_emp_home_locs_drivers + ...
    "&markers=size:tiny|color:green|" +  str_emp_home_locs + ...
    "&markers=color:red|label:B|" + str_emp_work_locs + ...
    "&key=AIzaSyDP1vj_KRkccTdk1nrngsuU45wPRto02fc" ;
[png_data,colormap,~] = webread(str);


imwrite(png_data,colormap,"recom_drivers_zoomlvl_" + num2str(zoom_lvl) + ".png")
