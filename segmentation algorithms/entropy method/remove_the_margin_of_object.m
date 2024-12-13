function [DILATED_IMAGE, RECREATED_IMAGE] = remove_the_margin_of_object(LOCALIZATION)
    % Удаление границы корабля
    [num_rows, num_cols] = size(LOCALIZATION);
    white_pixel_value = 1;
    first_pixel_indices = [];
    last_pixel_indices = [];
    localized_image = LOCALIZATION;
    randomized_image = uint8(LOCALIZATION);
    
    % Нахождение первого и последнего белого пикселя и сохранение индекса
    for i = 1:num_rows
        for j = 1:num_cols
            if localized_image(i, j) == 0
                random_value = randi(224) + 1;   
                randomized_image(i, j) = random_value;
            end
            pixel_line = uint8(randomized_image(i, :));
            [white_pixel_value, first_index] = unique(pixel_line);  % Нахождение первого белого пикселя с использованием unique()
            [white_pixel_value, last_index] = unique(pixel_line, 'legacy'); % Нахождение последнего белого пикселя с использованием unique( ***,'legacy' )
            first_pixel_indices(i) = first_index(1);
            last_pixel_indices(i) = last_index(1);
        end
    end
    
    first_coordinates = [];
    last_coordinates = [];
    rows = 1:1:num_rows;
    first_coordinates = [rows', first_pixel_indices'];  % Сохранение первого индекса
    last_coordinates = [rows', last_pixel_indices'];  % Сохранение последнего индекса
                
    % Границы корабля
    RECREATED_IMAGE = localized_image;
    for i = 1:num_rows
        for j = 1:num_cols
            if RECREATED_IMAGE(i, j) ~= 0
                RECREATED_IMAGE(i, j) = 0;
            end
            RECREATED_IMAGE(first_coordinates(i, 1), first_coordinates(i, 2)) = 1;  % Подсветка первой (левой) белой границы
            RECREATED_IMAGE(last_coordinates(i, 1), last_coordinates(i, 2)) = 1;  % Подсветка последней (правой) белой границы
        end
    end
    
    % Удаление границы корабля ------> Изменение окружных 8 пикселей на черный (0)
    DILATED_IMAGE = localized_image;
    for i = 1:num_rows
        DILATED_IMAGE(first_coordinates(i, 1), first_coordinates(i, 2)) = 0;
        DILATED_IMAGE(first_coordinates(i, 1) + 1, first_coordinates(i, 2)) = 0;
        DILATED_IMAGE(first_coordinates(i, 1), first_coordinates(i, 2) + 1) = 0;
        DILATED_IMAGE(first_coordinates(i, 1) + 1, first_coordinates(i, 2) + 1) = 0;
        
        DILATED_IMAGE(last_coordinates(i, 1), last_coordinates(i, 2)) = 0;
        DILATED_IMAGE(last_coordinates(i, 1) + 1, last_coordinates(i, 2)) = 0;
        DILATED_IMAGE(last_coordinates(i, 1), last_coordinates(i, 2) + 1) = 0;
        DILATED_IMAGE(last_coordinates(i, 1) + 1, last_coordinates(i, 2) + 1) = 0;
        
        if i > 1
            DILATED_IMAGE(first_coordinates(i, 1) - 1, first_coordinates(i, 2)) = 0;
            DILATED_IMAGE(last_coordinates(i, 1) - 1, last_coordinates(i, 2)) = 0;
            
            if first_coordinates(i, 2) > 1
                DILATED_IMAGE(first_coordinates(i, 1), first_coordinates(i, 2) - 1) = 0;
                DILATED_IMAGE(first_coordinates(i, 1) - 1, first_coordinates(i, 2) - 1) = 0;
            end
            
            if last_coordinates(i, 2) > 1
                DILATED_IMAGE(last_coordinates(i, 1), last_coordinates(i, 2) - 1) = 0;
                DILATED_IMAGE(last_coordinates(i, 1) - 1, last_coordinates(i, 2) - 1) = 0;
            end
        end
    end
end
