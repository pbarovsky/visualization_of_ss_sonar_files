% метод Criminisi Inpainting для удаления теней

clc; clear all; close all;

% Загрузка изображения
originalImage = imread('../data/images/scan-2200s-5.jpg'); 

% Предварительная обработка изображения
% Изменение размера изображения (если требуется)
% resizedImage = originalImage;
resizedImage = imresize(originalImage, [512, 512]);

% Преобразование изображения в оттенки серого
if size(resizedImage, 3) == 3 
    % Преобразование изображения в оттенки серого 
    grayImage = rgb2gray(resizedImage); 
else 
    % Изображение уже чёрно-белое 
    grayImage = resizedImage; 
end

% Устранение шума с использованием медианного фильтра 
% denoisedImage = medfilt2(grayImage);

% Повышение качества изображения (гистограммное выравнивание)
% enhancedImage = histeq(grayImage);
enhancedImage = grayImage;

% Применение алгоритма k-means для сегментации теней
% Установка количества кластеров (например, 3: фон, объект, тень)
numClusters = 3;

% Преобразуем изображение в вектор для k-means
imageVector = double(enhancedImage(:)); % Одномерный вектор из изображения

% Применяем k-means
clusterIdx = kmeans(imageVector, numClusters, 'MaxIter', 1000);

% Проверка размера clusterIdx
disp(['Размер clusterIdx: ', num2str(size(clusterIdx))]); % Ожидается [numPixels x 1]

% Преобразуем вектор кластеров обратно в размер изображения
clusteredImage = reshape(clusterIdx, size(enhancedImage)); % Преобразование в двумерную матрицу

% Идентификация теневого сегмента (выбор кластера с низкой интенсивностью)
% Находим минимальный центр кластера (теневые области)
clusterCenters = accumarray(clusterIdx, imageVector, [], @mean);
[~, shadowCluster] = min(clusterCenters);

% Создаем бинарную маску для теней
shadowMask = clusteredImage == shadowCluster;

% Заполнение теневых областей с помощью Criminisi Inpainting
% Определяем область для заполнения
inpaintRegion = shadowMask;

% Преобразуем изображение в цветное для восстановления
rgbImage = resizedImage;

% Заполнение теней алгоритмом Criminisi Inpainting
% Если inpaintExemplar отсутствует, это нужно заменить на доступную функцию восстановления
try
    filledImage = inpaintExemplar(rgbImage, inpaintRegion);
catch
    warning('Функция inpaintExemplar отсутствует! Пропускаем этап восстановления.');
    filledImage = rgbImage; % Просто используем исходное изображение
end

% Постобработка: морфологические операции для сглаживания границ
se = strel('square', 5); % Структурирующий элемент (диск радиусом 5)
smoothedMask = imdilate(inpaintRegion, se);
finalImage = imerode(filledImage, se);

% Отображение результатов
figure;
imshow(originalImage);
title('Оригинальное изображение');

figure;
imshow(shadowMask);
title('Маска теневых областей');

figure;
imshow(filledImage);
title('После Criminisi Inpainting');