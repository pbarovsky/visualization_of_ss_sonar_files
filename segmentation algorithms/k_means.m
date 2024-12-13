% сегментация методом k-means

clc; clear all; close all;

k_means("../data/images/others_286.jpg")

function k_means(image_path)
    % Чтение изображения
    img = imread(image_path);
    if size(img, 3) == 3
        img = rgb2gray(img); % Преобразование в оттенки серого, если RGB
    end
    img = double(img);

    % Исходное изображение
    figure; imshow(img, []); title('Исходное изображение');

    % Этап 1: Фильтрация шумов с использованием NLMSF
    fprintf('Применение NLMSF фильтрации...\n');
    filtered_img = nlmsf_filter(img);
    figure; imshow(filtered_img, []); title('После фильтрации (NLMSF)');

    % Этап 2: Грубая сегментация (например, k-means)
    fprintf('Выполнение грубой сегментации...\n');

    num_clusters = 3; % Три класса: объект, тень, фон

    [cluster_idx, cluster_centers] = kmeans(filtered_img(:), num_clusters, ...
        'MaxIter', 100, 'Replicates', 3);
    clustered_img = reshape(cluster_idx, size(filtered_img));
    figure; imagesc(clustered_img); colormap('jet'); colorbar; title('Грубая сегментация (k-means)');

    % Этап 3: Бинаризация на основе k-means
    [~, object_class] = max(cluster_centers);
    binary_mask = clustered_img == object_class;

    % Улучшение маски (морфологическая обработка)
    fprintf('Улучшение маски...\n');
    binary_mask = imclose(binary_mask, strel('square', 2)); % Закрытие пробелов

    % Параметры для удаления мелких объектов
    min_sizes = [20, 50, 100, 200, 500, 800, 1200, 2000, 5000];

    % Цикл для удаления мелких объектов
    for i = 1:length(min_sizes)
        current_size = min_sizes(i);
        binary_mask = bwareaopen(binary_mask, current_size); % Удаление мелких объектов
        fprintf('Удаление объектов размером менее %d пикселей...\n', current_size);
    end

    figure; imshow(binary_mask, []); title('Улучшенная маска объекта');

    % Этап 4: Нахождение объекта на основе маски
    fprintf('Выделение объекта...\n');
    extracted_object = img .* binary_mask; % Применение маски к исходному изображению

    % Нахождение рамки объекта
    stats = regionprops(binary_mask, 'BoundingBox');
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
end

function filtered_img = nlmsf_filter(img)
    % % Примерная реализация NLMSF (может быть улучшена)
    % h = fspecial('gaussian', [7, 7], 2.5); % Гауссово размытие
    % filtered_img = imfilter(img, h, 'symmetric');


    % Применяем медианный фильтр
    filtered_img = medfilt2(img, [5, 5]); % Размер ядра можно изменить
end