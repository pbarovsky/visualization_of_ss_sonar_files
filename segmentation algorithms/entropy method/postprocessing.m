function FINAL_IMAGE = postprocessing(ENTROPY_IMAGE)
    % Заполнение изображения сегментации энтропии: нахождение первого белого и первого черного пикселя, затем объединение белого цвета
    [rows, cols] = size(ENTROPY_IMAGE);
    First_White_Black = zeros(rows, cols);
    FINAL_IMAGE = ENTROPY_IMAGE;
    
    % Нахождение первого белого пикселя в каждом ряду
    for i = 1:rows
        for j = 1:cols
            if ENTROPY_IMAGE(i, j) == 255
                First_White_Black(i, j) = 1;
                break;
            end
        end
    end
    
    % Нахождение первого черного пикселя в каждом ряду
    for i = 1:rows
        for j = 1:cols
            if ENTROPY_IMAGE(i, j) == 0
                First_White_Black(i, j) = 1;
                break;
            end
        end
    end
    
    % Объединение белого цвета между первым белым и черным пикселями
    for i = 1:rows
        white_count = 0;
        black_count = 0;
        for j = 1:cols
            white_count = white_count + First_White_Black(i, j);
            if white_count == 2  % строка с белым и черным
                for h = 1:cols
                    black_count = black_count + First_White_Black(i, h);
                    if black_count == 1  % первый белый
                        FINAL_IMAGE(i, h) = 255;
                    elseif black_count == 2  % первый черный
                        break;
                    end
                end
            end
        end
    end
end
