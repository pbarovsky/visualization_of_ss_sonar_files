function data = read_gbo_file(gbo_filepath)
    % Размер заголовка в байтах
    HEADER_SIZE_BYTES = 224;

    % Открываем файл для чтения
    fid = fopen(gbo_filepath, 'rb');
    if fid == -1
        error('Не удается открыть файл: %s', gbo_filepath);
    end

    % Пропускаем заголовок
    fseek(fid, HEADER_SIZE_BYTES, 'bof');
    % Читаем оставшиеся данные
    data = fread(fid, Inf, 'uint32');
    fclose(fid);
end