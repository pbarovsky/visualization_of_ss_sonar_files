% сегментация k-means кластеризации и активных контуров Чан Весе

clc; clear all; close all;

k_means_chan_vese_alg("../data/images/ship_33.jpg")

function k_means_chan_vese_alg(image_path)
    % Чтение изображения
    img = imread(image_path);
    if size(img, 3) == 3
        img = rgb2gray(img); % Преобразование в оттенки серого, если RGB
    end
    img = double(img);

    % Исходное изображение
    figure; imshow(img, []); title('Исходное изображение');

    %% Этап 1: Фильтрация шумов с использованием NLMSF
    fprintf('Применение NLMSF фильтрации...\n');
    filtered_img = nlmsf_filter(img);
    figure; imshow(filtered_img, []); title('После фильтрации (NLMSF)');

    %% Этап 2: Грубая сегментация с использованием k-means
    fprintf('Выполнение грубой сегментации...\n');
    num_clusters = 3; % Три класса: объект, тень, фон
    [cluster_idx, cluster_centers] = kmeans(filtered_img(:), num_clusters, ...
        'MaxIter', 100, 'Replicates', 3);
    clustered_img = reshape(cluster_idx, size(filtered_img));
    figure; imagesc(clustered_img); colormap('jet'); colorbar; title('Грубая сегментация (k-means)');

    %% Этап 3: Бинаризация на основе k-means
    % Выбираем класс объекта с максимальной яркостью
    [~, object_class] = max(cluster_centers);
    binary_mask = clustered_img == object_class;

    % Улучшение маски (морфологическая обработка)
    fprintf('Улучшение маски...\n');
    binary_mask = imclose(binary_mask, strel('square', 5)); % Закрытие пробелов
    binary_mask = bwareaopen(binary_mask, 20); % Удаление мелких объектов
    figure; imshow(binary_mask, []); title('Улучшенная маска объекта');

    %% Этап 4: Точная сегментация с использованием активного контура
    fprintf('Точная сегментация с активным контуром...\n');
    % Используем бинарную маску как начальную форму для активного контура
    fine_mask = activecontour(filtered_img / max(filtered_img(:)), binary_mask, ...
        300, 'Chan-Vese'); % Активный контур (метод Чана-Весе)

    figure; imshow(fine_mask, []); title('Результат активного контура');

    %% Этап 5: Выделение объекта
    fprintf('Выделение объекта...\n');
    % Применение маски к изображению
    extracted_object = img .* fine_mask;

    % Нахождение рамки объекта
    stats = regionprops(fine_mask, 'BoundingBox');
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
    % Реализация NLMSF фильтрации
    h = fspecial('gaussian', [3, 3], 2.5); % Гауссово размытие
    filtered_img = imfilter(img, h, 'symmetric');
end