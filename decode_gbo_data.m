function image = decode_gbo_data(data, line_count, samples_per_line)
    try
        % Преобразование линейного массива в матрицу
        data_matrix = reshape(data, [samples_per_line, line_count]);
        image = data_matrix';
    catch
        error('Ошибка при декодировании данных. Проверьте входные параметры.');
    end
end
