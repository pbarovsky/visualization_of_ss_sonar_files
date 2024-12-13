% сегментация изображений с использованием текстурных признаков Харелика и метода активных контуров

clc; clear all; close all

% Загрузка изображения
img = imread('../data/images/scan-2200s-5.jpg'); % Замените на путь к вашему изображению

img_gray = Gray_Image(img); % Преобразование в градации серого


num_levels = 52;  % Количество уровней серого (32 - 128)
displacement = [0 1; -1 1; -1 0; -1 -1]; % Направления для матриц совместной встречаемости

% Вычисление текстурных признаков Haralick
[rows, cols] = size(img_gray);

% % Размер окна для извлечения текстурных признаков (от 15 до 30)
if rows > 512 || cols > 512
    window_size = 31;
else
    window_size = 25;
end

features = zeros(rows, cols, 6); % Для хранения 6 текстурных признаков

for i = 1:rows - window_size
    for j = 1:cols - window_size
        window = img_gray(i:i+window_size-1, j:j+window_size-1);
        glcm = graycomatrix(window, 'NumLevels', num_levels, 'Offset', displacement);
        stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        features(i, j, 1) = mean(stats.Contrast);
        features(i, j, 2) = mean(stats.Correlation);
        features(i, j, 3) = mean(stats.Energy);
        features(i, j, 4) = mean(stats.Homogeneity);
    end
end

% Нормализация признаков
% features = normalize(features, 'range');
for k = 1:6
    features(:, :, k) = normalize(features(:, :, k), 'range');
end


% Инициализация уровня активного контура
initial_mask = zeros(rows, cols);
initial_mask(rows/4:3*rows/4, cols/4:3*cols/4) = 1; % Центральный прямоугольник
phi = bwdist(~initial_mask) - bwdist(initial_mask);
phi = im2double(phi);

% Параметры активного контура
lambda1 = 1; 
lambda2 = 1;
mu = 0.2; 
iterations = 200; % от 200 до 500
threshold = 1e-3; % Порог сходимости
 
phi_prev = phi; % Инициализация предыдущего уровня

% Выполнение уровня активного контура
for iter = 1:iterations
    c1 = sum(features .* (phi >= 0), [1, 2]) ./ sum(phi(:) >= 0);
    c2 = sum(features .* (phi < 0), [1, 2]) ./ sum(phi(:) < 0);
    force = lambda1 * sum((features - c1).^2, 3) - lambda2 * sum((features - c2).^2, 3);
    force = force / max(abs(force(:)));
        phi = phi - mu * force;
    
    % Проверка сходимости
    if max(abs(phi(:) - phi_prev(:))) < threshold
        disp(['Алгоритм сошелся на итерации ', num2str(iter)]);
        break;
    end
    
    % Обновление phi_prev для следующей итерации
    phi_prev = phi;
end

% Итоговая сегментация
segmented = phi >= 0;

% Отображение результата
figure;
subplot(1, 2, 1); imshow(img_gray); title('Исходное изображение');
subplot(1, 2, 2); imshow(segmented); title('Сегментация');

extracted_object = double(img) .* segmented; % Применение маски к исходному изображению

% Нахождение рамки объекта
stats = regionprops(segmented, 'BoundingBox');
if ~isempty(stats)
    % Находим самый крупный объект (если их несколько)
    [~, largest_idx] = max(cellfun(@(x) x(3)*x(4), {stats.BoundingBox}));
    bounding_box = stats(largest_idx).BoundingBox; % Рамка самого большого объекта
else
    bounding_box = [];
end

% Визуализация выделенного объекта
figure; 
subplot(1, 2, 1);
imshow(extracted_object, []); title('Выделенный объект');

subplot(1, 2, 2);
imshow(img, []); title('Объект с рамкой');
hold on;
if ~isempty(bounding_box)
    rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 2);
end



function [Img_gray] = Gray_Image(Original_Image)
    % Проверка, является ли изображение уже оттенками серого
    if (size(Original_Image, 3) == 1)
        Img_gray = Original_Image;
        return
    end
    
    Img_gray = rgb2gray(Original_Image);
end