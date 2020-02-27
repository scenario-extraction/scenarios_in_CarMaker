function [prediction] = map_pred_to_orig_classes(prediction)
% Maps classes predicted by recognition network to original class numbers

    for i = (1:size(prediction, 1))
        if prediction(i) == 1
            prediction(i) = 0;
        elseif prediction(i) == 2
            prediction(i) = 1;
        elseif prediction(i) == 3
            prediction(i) = 10;
        elseif prediction(i) == 4
            prediction(i) = 11;
        elseif prediction(i) == 5
            prediction(i) = 12;
        elseif prediction(i) == 6
            prediction(i) = 13;
        elseif prediction(i) == 7
            prediction(i) = 14;
        elseif prediction(i) == 8
            prediction(i) = 15;
        elseif prediction(i) == 9
            prediction(i) = 16;
        elseif prediction(i) == 10
            prediction(i) = 17;
        elseif prediction(i) == 11
            prediction(i) = 18;
        elseif prediction(i) == 12
            prediction(i) = 19;
        elseif prediction(i) == 13
            prediction(i) = 2;
        elseif prediction(i) == 14
            prediction(i) = 20;
        elseif prediction(i) == 15
            prediction(i) = 21;
        elseif prediction(i) == 16
            prediction(i) = 22;
        elseif prediction(i) == 17
            prediction(i) = 23;
        elseif prediction(i) == 18
            prediction(i) = 24;
        elseif prediction(i) == 19
            prediction(i) = 25;
        elseif prediction(i) == 20
            prediction(i) = 26;
        elseif prediction(i) == 21
            prediction(i) = 27;
        elseif prediction(i) == 22
            prediction(i) = 28;
        elseif prediction(i) == 23
            prediction(i) = 29;
        elseif prediction(i) == 24
            prediction(i) = 3;
        elseif prediction(i) == 25
            prediction(i) = 30;
        elseif prediction(i) == 26
            prediction(i) = 31;
        elseif prediction(i) == 27
            prediction(i) = 32;
        elseif prediction(i) == 28
            prediction(i) = 33;
        elseif prediction(i) == 29
            prediction(i) = 34;
        elseif prediction(i) == 30
            prediction(i) = 35;
        elseif prediction(i) == 31
            prediction(i) = 36;
        elseif prediction(i) == 32
            prediction(i) = 37;
        elseif prediction(i) == 33
            prediction(i) = 38;
        elseif prediction(i) == 34
            prediction(i) = 39;
        elseif prediction(i) == 35
            prediction(i) = 4;
        elseif prediction(i) == 36
            prediction(i) = 40;
        elseif prediction(i) == 37
            prediction(i) = 41;
        elseif prediction(i) == 38
            prediction(i) = 42;
        elseif prediction(i) == 39
            prediction(i) = 5;
        elseif prediction(i) == 40
            prediction(i) = 6;
        elseif prediction(i) == 41
            prediction(i) = 7;
        elseif prediction(i) == 42
            prediction(i) = 8;
        elseif prediction(i) == 43
            prediction(i) = 9;
        else 
            disp("something isn't right");
            return
        end
    end

end

