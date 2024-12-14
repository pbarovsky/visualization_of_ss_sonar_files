% метод сегментации активных контуров "методом Чана-Везе (Chan-Vese)".

clc;
clear;
close all;

% Шаг 1: Загрузка изображения
img = imread('../data/images/ship_33.jpg');
if size(img, 3) == 3
    img = rgb2gray(img); % Преобразование в оттенки серого, если изображение цветное
end
imshow(img);
title('Original Image');

% Шаг 2: Вычисление текстурных признаков Харелика
offsets = [0 1; -1 1; -1 0; -1 -1]; % Направления смещений для GLCM
glcm = graycomatrix(img, 'Offset', offsets, 'Symmetric', true);
stats = graycoprops(glcm, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});

% Создание изображений признаков
featureImages = zeros(size(img, 1), size(img, 2), 4);
[rows, cols] = size(img);
windowSize = 15; % Размер окна для расчёта признаков
halfWin = floor(windowSize / 2);

for i = 1 + halfWin:rows - halfWin
    for j = 1 + halfWin:cols - halfWin
        patch = img(i-halfWin:i+halfWin, j-halfWin:j+halfWin);
        localGLCM = graycomatrix(patch, 'Offset', offsets, 'Symmetric', true);
        localStats = graycoprops(localGLCM, {'Contrast', 'Correlation', 'Energy', 'Homogeneity'});
        featureImages(i, j, 1) = mean(localStats.Contrast(:));
        featureImages(i, j, 2) = mean(localStats.Correlation(:));
        featureImages(i, j, 3) = mean(localStats.Energy(:));
        featureImages(i, j, 4) = mean(localStats.Homogeneity(:));
    end
end

% Нормализация изображений признаков
for k = 1:4
    featureImages(:, :, k) = mat2gray(featureImages(:, :, k));
end

% Шаг 3: Сегментация методом Чана-Везе
% Использование среднего значения текстурных признаков
combinedFeature = mean(featureImages, 3);

% Инициализация активных контуров
mask = false(size(img));
mask(50:end-50, 50:end-50) = true; % Пример начальной маски

segmentedImg = activecontour(combinedFeature, mask, 300, 'Chan-Vese');

% Шаг 4: Визуализация
figure;
subplot(1, 2, 1);
imshow(combinedFeature);
title('Combined Feature Image');

subplot(1, 2, 2);
imshow(segmentedImg);
title('Segmented Image');


extracted_object = double(img) .* segmentedImg; % Применение маски к исходному изображению

% Нахождение рамки объекта
stats = regionprops(segmentedImg, 'BoundingBox');
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
