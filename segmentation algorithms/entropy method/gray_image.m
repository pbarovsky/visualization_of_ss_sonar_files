function [GRAY_IMAGE] = gray_image(ORIGINAL_IMAGE)
    % Проверка, является ли изображение уже оттенками серого
    if (size(ORIGINAL_IMAGE, 3) == 1)
        GRAY_IMAGE = ORIGINAL_IMAGE;
        return
    end
    
    GRAY_IMAGE = rgb2gray(ORIGINAL_IMAGE);
end