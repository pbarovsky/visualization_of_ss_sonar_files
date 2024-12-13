function process_gbo_file(gbo_filepath, idx_filepath)
    % Читаем информацию о строках и семплах
    [line_count, samples_per_line, sample_size] = read_idx_file(idx_filepath, gbo_filepath);

    % Читаем бинарные данные из файла .gbo
    gbo_data = read_gbo_file(gbo_filepath);

    % Расшифровываем данные в матрицу изображения
    image = decode_gbo_data(gbo_data, line_count, samples_per_line);

    % Визуализация изображения
    figure;
    imagesc(image);
    colormap('pink'); % Цветовая схема
    title(['Изображение морского дна: ', gbo_filepath], 'Interpreter', 'none');
    axis equal tight;
    set(gca, 'Position', [0 0 1 1]); % Удаляем рамки
end