function REMOVING_SHADOW_BOUNDARIES = remove_shadow_boundary(EDGE_IMAGE, DENOISE_IMAGE)
    % Удаление границ теней
    [rows, cols] = size(EDGE_IMAGE);
    Extended_Image = ones(rows, cols+16);
    Extended_Image_2 = ones(rows, cols+16);
    
    % Заполнение дополнительных колонок значениями 150
    for i = 1:rows
        for j = 1:7
            Extended_Image(i, j) = 150;
            Extended_Image_2(i, j) = 150;
        end
    end
    for i = 1:rows
        for j = cols+8:cols+16
            Extended_Image(i, j) = 150;
            Extended_Image_2(i, j) = 150;
        end
    end
    
    % Заполнение центральной части изображениями
    for i = 1:rows
        for j = 1:cols
            Extended_Image(i, j+7) = DENOISE_IMAGE(i, j);
            Extended_Image_2(i, j+7) = EDGE_IMAGE(i, j);
        end
    end
    
    Processed_Image = Extended_Image_2;
    Processed_Image_2 = Extended_Image_2;
    
    % Обработка изображений
    for i = 1:rows
        for j = 8:cols+8
            if Extended_Image_2(i, j) == 1
                Processed_Image(i, j) = floor((Extended_Image(i, j-7) + Extended_Image(i, j-6) + Extended_Image(i, j-5) + ...
                                              Extended_Image(i, j-4) + Extended_Image(i, j-3) + Extended_Image(i, j-2) + Extended_Image(i, j-1)) / 9);
                Processed_Image_2(i, j) = floor((Extended_Image(i, j+7) + Extended_Image(i, j+6) + Extended_Image(i, j+5) + ...
                                                 Extended_Image(i, j+4) + Extended_Image(i, j+3) + Extended_Image(i, j+2) + Extended_Image(i, j+1)) / 7);
            end
        end
    end
    Processed_Image = uint8(Processed_Image);
    Processed_Image_2 = uint8(Processed_Image_2);
    
    % Удаление границ теней
    Shadow_Removed_Image = Processed_Image;
    for i = 1:rows  
        for j = 1:cols+8
            if Processed_Image(i, j) <= 80 && Processed_Image_2(i, j) > 50 && Processed_Image_2(i, j) < 150
                Shadow_Removed_Image(i, j) = 0;
            end
        end
    end
    
    % Обрезка изображения до исходного размера
    REMOVING_SHADOW_BOUNDARIES = Shadow_Removed_Image(: ,8:cols+7);
    
    % Бинаризация изображения
    threshold = graythresh(REMOVING_SHADOW_BOUNDARIES);
    REMOVING_SHADOW_BOUNDARIES = im2bw(REMOVING_SHADOW_BOUNDARIES, threshold);
end
