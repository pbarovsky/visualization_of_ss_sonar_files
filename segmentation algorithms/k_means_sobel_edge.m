% сегментация с использованием подчеркивания контуров оператором Собеля и k-means кластеризации

clc; clear all; close all;

k_means_sobel_edge_alg("../data/images/ship_33.jpg")


function k_means_sobel_edge_alg(image_path)
    % Чтение изображения
    img = imread(image_path);
    if size(img, 3) == 3
        img = rgb2gray(img); % Преобразование в оттенки серого, если RGB
    end
    img = double(img);

    % Исходное изображение
    figure; imshow(img, []); title('Исходное изображение');

    % Этап 1: Подчеркивание контуров
    fprintf('Подчеркивание контуров...\n');
    edges = edge(img, 'Sobel'); % Применяем оператор Собеля
    figure; imshow(edges, []); title('Контуры (Sobel)');

    % Этап 2: Фильтрация с использованием адаптивного размытия
    fprintf('Применение адаптивного размытия...\n');
    filtered_img = adaptive_blur(img, edges);
    figure; imshow(filtered_img, []); title('После фильтрации (адаптивное размытие)');

    % Этап 3: Грубая сегментация (например, k-means)
    fprintf('Выполнение грубой сегментации...\n');
    num_clusters = 3; % Три класса: объект, тень, фон
    [cluster_idx, cluster_centers] = kmeans(filtered_img(:), num_clusters, ...
        'MaxIter', 100, 'Replicates', 3);
    clustered_img = reshape(cluster_idx, size(filtered_img));
    figure; imagesc(clustered_img); colormap('jet'); colorbar; title('Грубая сегментация (k-means)');

    % Этап 4: Бинаризация на основе k-means
    [~, object_class] = max(cluster_centers);
    binary_mask = clustered_img == object_class;

    binary_mask = imclose(binary_mask, strel('square', 5)); % Закрытие пробелов
    binary_mask = bwareaopen(binary_mask, 100); % Удаление мелких объектов

    figure; imshow(binary_mask, []); title('Бинаризация (на основе k-means)');

    % Этап 5: Нахождение объекта на основе маски
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

function filtered_img = adaptive_blur(img, edges)
    % Примитивная реализация адаптивного размытия
    [rows, cols] = size(img);
    filtered_img = zeros(size(img));

    for r = 1:rows
        for c = 1:cols
            if edges(r, c) == 1
                filtered_img(r, c) = img(r, c); % Сохраняем детали, где есть контуры
            else
                % Размываем, если контур отсутствует
                % Используем окружающие пиксели для усреднения значения
                neighbors = img(max(r-1,1):min(r+1,rows), max(c-1,1):min(c+1,cols));
                filtered_img(r, c) = mean(neighbors(:)); % Среднее значение соседей
            end
        end
    end
end