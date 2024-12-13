function [LOCALIZATION, ROW_TRESHHOLD_1, ROW_TRESHHOLD_2, COL_TRESHHOLD_1, COL_TRESHHOLD_2] = localization_object(REMOVING_SHADOW_BOUNDARIES)
    % Поиск строки локализации
    [num_rows, num_cols] = size(REMOVING_SHADOW_BOUNDARIES);
    row_sums = zeros(1, num_rows);
    for i = 1:num_rows
        num_white_pixels = sum(REMOVING_SHADOW_BOUNDARIES(i, :));
        row_sums(i) = num_white_pixels;  
    end
    row_sums = row_sums ./ sum(row_sums);
    x_axis = 1:1:num_rows;
    y_axis = row_sums;
    filtered_row_sums = medfilt1(row_sums, 10);
    filtered_row_sums = medfilt1(filtered_row_sums, 10);
    y_axis_filtered = filtered_row_sums;
    extended_filtered_row_sums = zeros(1, num_rows + 4);
    extended_filtered_row_sums(3:num_rows + 2) = y_axis_filtered;
    extended_x_axis = 1:1:num_rows + 4;
    smoothed_row_sums = extended_filtered_row_sums;
    max_value = 0;
    for i = 3:num_rows + 2
        smoothed_row_sums(i) = (extended_filtered_row_sums(i - 2) + extended_filtered_row_sums(i - 1) + extended_filtered_row_sums(i) + extended_filtered_row_sums(i + 1) + extended_filtered_row_sums(i + 2)) / 5;
        if smoothed_row_sums(i) > max_value
            max_value = smoothed_row_sums(i);
            max_index = i;
        end
    end
    min_value_before_max = 10;
    min_value_after_max = 10;
    for i = 3:num_rows + 2
        if smoothed_row_sums(i) <= min_value_before_max && i < max_index
            min_value_before_max = smoothed_row_sums(i);  
            ROW_TRESHHOLD_1 = i;
        end
        if smoothed_row_sums(i) < min_value_after_max && i > max_index
            min_value_after_max = smoothed_row_sums(i); 
            ROW_TRESHHOLD_2 = i;
        end
    end

    % Поиск столбца локализации
    col_sums = zeros(1, num_cols);
    for i = 1:num_cols
        num_white_pixels = sum(REMOVING_SHADOW_BOUNDARIES(:, i));
        col_sums(i) = num_white_pixels;  
    end
    col_sums = col_sums ./ sum(col_sums);
    filtered_col_sums = medfilt1(col_sums, 10);
    filtered_col_sums = medfilt1(filtered_col_sums, 10);
    filtered_col_sums = medfilt1(filtered_col_sums, 10);
    filtered_col_sums = medfilt1(filtered_col_sums, 10);
    y_axis_filtered_cols = filtered_col_sums;
    extended_filtered_col_sums = zeros(1, num_cols + 4);
    extended_filtered_col_sums(3:num_cols + 2) = y_axis_filtered_cols;
    extended_x_axis_cols = 1:1:num_cols + 4;
    smoothed_col_sums = extended_filtered_col_sums;
    max_value_cols = 0;
    for i = 3:num_cols + 2
        smoothed_col_sums(i) = (extended_filtered_col_sums(i - 2) + extended_filtered_col_sums(i - 1) + extended_filtered_col_sums(i) + extended_filtered_col_sums(i + 1) + extended_filtered_col_sums(i + 2)) / 5;
        if smoothed_col_sums(i) > max_value_cols
            max_value_cols = smoothed_col_sums(i);
            max_index_cols = i;
        end
    end
    min_value_before_max_cols = 10;
    min_value_after_max_cols = 10;
    for i = 3:num_cols + 2
        if smoothed_col_sums(i) <= min_value_before_max_cols && i < max_index_cols
            min_value_before_max_cols = smoothed_col_sums(i);  
            COL_TRESHHOLD_1 = i;
        end
        if smoothed_col_sums(i) < min_value_after_max_cols && i > max_index_cols
            min_value_after_max_cols = smoothed_col_sums(i);  
            COL_TRESHHOLD_2 = i;
        end
    end

    % Проверить индексы на наличие ограничений
    if ROW_TRESHHOLD_1 < 1
        ROW_TRESHHOLD_1 = 1;
    end
    if ROW_TRESHHOLD_2 > num_rows
        ROW_TRESHHOLD_2 = num_rows;
    end
    if COL_TRESHHOLD_1 < 1
        COL_TRESHHOLD_1 = 1;
    end
    if COL_TRESHHOLD_2 > num_cols
        COL_TRESHHOLD_2 = num_cols;
    end

    % Локализация объекта
    LOCALIZATION = REMOVING_SHADOW_BOUNDARIES(ROW_TRESHHOLD_1:ROW_TRESHHOLD_2, COL_TRESHHOLD_1:COL_TRESHHOLD_2);
end
