function SELECTED_CLUSTER = compare_masks(FINAL_IMAGE, BINARY_MASK)
    % Функция сравнения маски сложной сегментации и кластеров
    % Возвращает кластер с максимальным перекрытием
    
    % Вычислить свойства областей в FINAL_IMAGE и BINARY_MASK
    final_props = regionprops(FINAL_IMAGE, 'Area', 'BoundingBox', 'PixelIdxList');
    cluster_props = regionprops(BINARY_MASK, 'Area', 'BoundingBox', 'PixelIdxList');
    
    max_overlap = 0;
    SELECTED_CLUSTER = struct('BoundingBox', []);
    
    % Сравнить области
    for i = 1:numel(cluster_props)
        cluster_pixels = cluster_props(i).PixelIdxList;
        for j = 1:numel(final_props)
            final_pixels = final_props(j).PixelIdxList;
            
            % Вычисление перекрытия
            overlap = numel(intersect(cluster_pixels, final_pixels));
            if overlap > max_overlap
                max_overlap = overlap;
                SELECTED_CLUSTER = cluster_props(i);
            end
        end
    end
end
