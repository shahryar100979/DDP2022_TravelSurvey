function generate_png_employees_layout_v2(HomeLatLong, Work_LatLong, zoom_lvl)

str_emp_home_locs = "";
for it_com = 1:size(HomeLatLong,1)
    if it_com ==1
        str_emp_home_locs = sprintf("%.4f,%.4f",HomeLatLong(it_com,1),HomeLatLong(it_com,2));
    else
        str_emp_home_locs = sprintf("%s|%.4f,%.4f",str_emp_home_locs,HomeLatLong(it_com,1),HomeLatLong(it_com,2));
    end
end


str_emp_work_locs = "";
for it_com = 1:size(Work_LatLong,1)
    if it_com ==1
        str_emp_work_locs = sprintf("%.4f,%.4f",Work_LatLong(it_com,1),Work_LatLong(it_com,2));
    else
        str_emp_work_locs = sprintf("%s|%.4f,%.4f",str_emp_work_locs,Work_LatLong(it_com,1),Work_LatLong(it_com,2));
    end
end


str = "https://maps.googleapis.com/maps/api/staticmap?" + ...
    "center=" + mean(Work_LatLong(:,1)) + "," + mean(Work_LatLong(:,2)) + ...
    "&zoom=" + zoom_lvl + "&size=640x640&scale=2" + ...
    "&markers=size:tiny|color:green|" +  str_emp_home_locs + ...
    "&markers=color:red|label:B|" + str_emp_work_locs + ...
    "&key=AIzaSyDP1vj_KRkccTdk1nrngsuU45wPRto02fc" ;
[png_data,colormap,~] = webread(str);


imwrite(png_data,colormap,"employees_layout_v2_zoomlvl_" + num2str(zoom_lvl) + ".png")
