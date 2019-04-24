% model prediction for Lat. maneuver 
function lat_pred_total= lat_offset_pred(lat_M)

lat_pred_total=[];
value_lat_temp = 0;

for i=1:size(lat_M,2)
    if i==1
        t_arr=0:0.02:lat_M(2,i);
    else 
        t_arr=0.02:0.02:lat_M(2,i);
    end
    t_arr=round(t_arr,2);
    t_lc=lat_M(2,i);
        
    %% 
    if i==1
        H=abs(lat_M(3,i));
    else
        H=abs((lat_M(3,i)-lat_M(3,i-1)));
    end
    %%
    if lat_M(end,i)==0
        if i==1
            lat_pred=arrayfun(@(x) x*0+lat_M(3,i),t_arr);
        else
            value_lat_temp = (lat_M(3,i)+lat_M(3,i-1))*0.5; % create mean btween two values of lat. pos
            lat_pred=arrayfun(@(x) x*0+value_lat_temp,t_arr);
        end

    elseif lat_M(end,i)==-9  || (lat_M(2,i)<3)% fit with a line
        if i==1
            a=lat_M(3,i)/lat_M(2,i);
            b=0;
        else
            a=(lat_M(3,i)-lat_M(3,i-1))/(lat_M(2,i));
            b=lat_M(3,i)-a*t_lc;
        end
        lat_pred=arrayfun(@(x) a*x+b,t_arr);

        % fit with sinus func
    elseif lat_M(end,i)==-1 % fit LCL
    
        %---------------------
        x1= (pi/t_lc);
        x2=-x1*t_lc*0.5;
        %----------------------
        lat_pred=arrayfun(@(t) H*0.5*sin(x1*(t)+x2)+H*0.5, t_arr);
    
    elseif lat_M(end,i)==1 % fit LCR 
        x1= -(pi/t_lc);
        x2=(pi*0.5);
        lat_pred=arrayfun(@(t) H*0.5*sin(x1*(t)+x2)+H*0.5, t_arr);
    
    else %
        
    end
     
    lat_pred_total=[lat_pred_total,lat_pred];
end
end
