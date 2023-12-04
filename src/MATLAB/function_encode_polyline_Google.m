% Encodes polyline from Google Maps
% (Quick and possibly dirty, don't complain... it works)
% ------------------------------------------------------------------------------------------------------------
% Input: matrix with 2 columns containing (lat,lon) values
% Output: polyline
% ------------------------------------------------------------------------------------------------------------
% Reno Filla, NEPP, Scania R&D, created 2021-11-12, last updated 2021-11-13
% ------------------------------------------------------------------------------------------------------------


function poly = function_encode_polyline_Google (LatLon)       
% Documentation of how to encode a Google polyline: https://developers.google.com/maps/documentation/utilities/polylinealgorithm

    [num_rows, num_cols] = size(LatLon);
    if num_cols~= 2
        error ('paramter must be a matrix with 2 columns for (lat,lon) values')
    end

    for i=1:num_rows
        for j=1:2
            if i==1
                values(2*(i-1)+j) = int32(round(LatLon(i,j)*1e5));    
            else
                values(2*(i-1)+j) = int32(round(LatLon(i,j)*1e5))-int32(round(LatLon(i-1,j)*1e5));
            end
        end
    end
    
    poly = '';
    num_values = numel(values);
    for l=1:num_values
        value_bit = bitshift(values(l),1);
        if values(l)<0
            value_bit = bitcmp(value_bit);
        end
        value_str = dec2bin(value_bit);
        value_len = numel(value_str);
        chunk = [];
        for k=1:5:value_len
            chunk(1+(k-1)/5) = bitand(bitshift(value_bit,-(k-1)),int32(0x1F));
        end
        for k=1:numel(chunk)
            if k<numel(chunk)
                chunk(k) = bitor(chunk(k),int32(0x20));
            end
            chunk(k) = chunk(k) + 63;
        end
        poly_chunk = char(chunk);
        poly = [poly, poly_chunk];
    end
end
