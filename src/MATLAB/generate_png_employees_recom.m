function generate_png_employees_recom(HomeLatLong_mat, worklatlongunique, generic_recommendations )

str_drive_alone = "";
str_telecommute = "";
str_transit_walk = "";
str_transit_drive = "";
str_walk = "";
str_bike = "";
str_carpool = "";

max_cnt_drive_alone = Inf;
cnt = 0  ;

for it_com = 1:size(HomeLatLong_mat,1)

    % drive alone
    if strcmp(generic_recommendations{it_com,1} , "drive alone")
        cnt = cnt + 1;
        if cnt <= max_cnt_drive_alone
            if strcmp(str_drive_alone, "")
                str_drive_alone = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
            else
                str_drive_alone = sprintf("%s|%.4f,%.4f",str_drive_alone,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
            end
        else
            if strcmp(str_telecommute, "")
                str_telecommute = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
            else
                str_telecommute = sprintf("%s|%.4f,%.4f",str_telecommute,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
            end

        end
    end

  

    % transit + walk
    if strcmp(generic_recommendations{it_com,1} , "transit + walk")
        if strcmp(str_transit_walk, "")
            str_transit_walk = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        else
            str_transit_walk = sprintf("%s|%.4f,%.4f",str_transit_walk,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        end
    end

    % transit + drive
    if strcmp(generic_recommendations{it_com,1} , "transit + drive")
        if strcmp(str_transit_drive, "")
            str_transit_drive = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        else
            str_transit_drive = sprintf("%s|%.4f,%.4f",str_transit_drive,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        end
    end

    % walk
    if strcmp(generic_recommendations{it_com,1} , "walk")
        if strcmp(str_walk, "")
            str_walk = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        else
            str_walk = sprintf("%s|%.4f,%.4f",str_walk,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        end
    end

    % bike
    if strcmp(generic_recommendations{it_com,1} , "bike")
        if strcmp(str_bike, "")
            str_bike = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        else
            str_bike = sprintf("%s|%.4f,%.4f",str_bike,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        end
    end

     % carpool
    if strcmp(generic_recommendations{it_com,1} , "carpool")
        if strcmp(str_carpool, "")
            str_carpool = sprintf("%.4f,%.4f",HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        else
            str_carpool = sprintf("%s|%.4f,%.4f",str_carpool,HomeLatLong_mat(it_com,1),HomeLatLong_mat(it_com,2));
        end
    end


end


str = "https://maps.googleapis.com/maps/api/staticmap?" + ...
    "center=" + worklatlongunique(1,1) + "," + worklatlongunique(1,2) + ...
    "&zoom=10&size=640x640&scale=2" + ...
    "&markers=size:tiny|color:red|" +  str_drive_alone + ...
    "&markers=size:tiny|color:gray|" +  str_telecommute + ...
    "&markers=size:tiny|color:black|" +  str_transit_walk + ...
    "&markers=size:tiny|color:purple|" +  str_transit_drive + ...
    "&markers=size:tiny|color:blue|" +  str_walk + ...
    "&markers=size:tiny|color:green|" +  str_bike + ...
    "&markers=size:tiny|color:yellow|" +  str_carpool + ...
    "&markers=color:red|label:B|" + worklatlongunique(1,1) + "," + worklatlongunique(1,2) + ...
    "&key=AIzaSyDP1vj_KRkccTdk1nrngsuU45wPRto02fc" ;
[png_data,colormap,~] = webread(str);


imwrite(png_data,colormap,'generic_recommendations.png')
