function [line_count, samples_per_line, sample_size] = read_idx_file(idx_filepath, gbo_filepath)
    % Размер заголовка в байтах
    HEADER_SIZE_BYTES = 224;
    % Размер строки индекса в байтах
    IDX_LINE_SIZE_BYTES = 200;
    % Размер одного семпла в байтах (4 байта = uint32)
    SAMPLE_SIZE = 4;

    % Получаем размер файла .idx
    idx_file_size = dir(idx_filepath).bytes;
    % Вычисляем количество строк
    line_count = floor((idx_file_size - HEADER_SIZE_BYTES) / IDX_LINE_SIZE_BYTES);

    % Получаем размер файла .gbo
    gbo_file_size = dir(gbo_filepath).bytes;
    % Вычисляем количество семплов на строку
    samples_per_line = floor((gbo_file_size - HEADER_SIZE_BYTES) / line_count / SAMPLE_SIZE);

    % Возвращаем размер семпла (всегда 4 байта)
    sample_size = SAMPLE_SIZE;
end