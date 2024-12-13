% обработка изображений с улучшением контраста и повышением резкости методом Лапласа

clc; clear all; close all;


path = '../data/images';
filename = './scan-2200s-5'; % Исходное имя файла (без расширения)
file_ext = '.jpg'; % Расширение файла
postfix = '_norm'; % Постфикс
postfix_lap = '_laplas'; % Постфикс

file_path = strcat(path, filename, file_ext);
originalImage = imread(file_path); 

x = linspace(0, 1, 256);

% Преобразование изображения в оттенки серого
grayImage = convertToGray(originalImage);

imag_stretch = intrans(grayImage, 'stretch', mean2(im2double(originalImage)), 0.9);
imag_normalized = adapthisteq(grayImage); % Нормализация
imag_stretch_normalized = adapthisteq(imag_stretch);

y_orig = intrans(x, 'stretch', mean2(im2double(originalImage)), 0.9);
y_stretch = intrans(x, 'stretch', mean2(im2double(imag_stretch)), 0.9);

figure('units', 'normalized', 'position', [0.25 0.25 0.5 0.5]);
subplot(2, 3, 1); imshow(originalImage); title('Исходное изображение');
subplot(2, 3, 2); plot(x, y_orig); grid on;
title('Функция преобразования (исходное)'); xlabel('Вход'); ylabel('Выход');
subplot(2, 3, 3); imhist(imag_normalized); title('Нормализованная гистограмма (исходное)');
subplot(2, 3, 4); imshow(imag_stretch); title('Улучшенное изображение');
subplot(2, 3, 5); plot(x, y_stretch); grid on; 
title('Функция преобразования (улучшенное)'); xlabel('Вход'); ylabel('Выход');
subplot(2, 3, 6); imhist(imag_stretch_normalized);
title('Нормализованная гистограмма (улучшенное)');


% Новое имя имя файла
% Сохранение изображения
% norm_filename = strcat(filename, postfix, file_ext);
% imwrite(imag_stretch, norm_filename);

% __________________________________ %

alpha = 0.4; % Значение параметра alpha
sharpened_image = applyLaplacian(imag_stretch, alpha);

figure;
imshow(sharpened_image);
title('Повышение резкости Лаплассом');

% Новое имя имя файла
% Сохранение изображения
% norm_filename = strcat(filename, postfix_lap, file_ext);
% imwrite(sharpened_image, norm_filename);

function grayImage = convertToGray(originalImage) 
    if size(originalImage, 3) == 3 
        grayImage = rgb2gray(originalImage); 
    else 
        grayImage = originalImage; 
    end
end

function sharpened_image = applyLaplacian(image, alpha)
    laplacian_filter = fspecial('laplacian', 0.2); % Фильтр Лапласа с фиксированным параметром
    sharpened_image = image + alpha * (image - imfilter(image, laplacian_filter));
end