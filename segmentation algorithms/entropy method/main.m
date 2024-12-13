% сегментация с помощью энтропии

clc; clear all; close all;

image_path = '../../data/images/others_286.jpg';
ORIGINAL_IMG = read_image(image_path);

GRAY_IMG = gray_image(ORIGINAL_IMG);
DENOISE_IMG = denoise(GRAY_IMG);
EDGE_IMG = edge_detection(DENOISE_IMG);
SHADOW_REMOVAL_IMG = remove_shadow_boundary(EDGE_IMG, DENOISE_IMG);
[LOCALIZATION, ~, ~, ~, ~] = localization_object(SHADOW_REMOVAL_IMG);

[DILATE_NEW_IMG, RECREATED_IMG] = remove_the_margin_of_object(LOCALIZATION);
DILATE_IMG = dilate_image(DILATE_NEW_IMG);
EXPANDED_IMG = cover_denoise_image(DILATE_IMG, DENOISE_IMG, SHADOW_REMOVAL_IMG);
ENTROPY_IMG = entropy_segmentation(EXPANDED_IMG);
FINAL_IMG = postprocessing(ENTROPY_IMG);

% Преобразование изображеия в двоичный формат
BINARY_IMG = imbinarize(FINAL_IMG);
figure;
imshow(BINARY_IMG, []);
title('Двоичное изображение');

figure;
subplot(3, 4, 1), imshow(ORIGINAL_IMG), title('Исходное изображение')
subplot(3, 4, 2), imshow(GRAY_IMG), title('Изображение в градациях серого')
subplot(3, 4, 3), imshow(DENOISE_IMG), title('Фильтрация изображения (Дискретное косинусное преобразование)')
subplot(3, 4, 4), imshow(EDGE_IMG), title('Изображение с краями (Робертс)')
subplot(3, 4, 5), imshow(SHADOW_REMOVAL_IMG), title('Удаление границ теней')
subplot(3, 4, 6), imshow(LOCALIZATION), title('Локализация объекта (Порог)')
subplot(3, 4, 7), imshow(RECREATED_IMG), title('Извлечение границ объекта (Левый и правый пиксель)')
subplot(3, 4, 8), imshow(DILATE_NEW_IMG), title('Удаление границ объекта')
subplot(3, 4, 9), imshow(DILATE_IMG), title('Расширение белого пикселя (Морфологическое расширение)')
subplot(3, 4, 10), imshow(EXPANDED_IMG), title('Объединение изображений после фильтрации и расширения')
subplot(3, 4, 11), imshow(ENTROPY_IMG), title('Сегментация по двумерной энтропии')
subplot(3, 4, 12), imshow(FINAL_IMG), title('Постобработка')


extracted_object = double(ORIGINAL_IMG) .* BINARY_IMG;

% Нахождение рамки объекта
stats = regionprops(BINARY_IMG, 'BoundingBox');
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
imshow(ORIGINAL_IMG, []); title('Объект с рамкой');
hold on;
if ~isempty(bounding_box)
    rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 2);
end


