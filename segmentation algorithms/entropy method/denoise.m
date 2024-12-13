function DENOISE_IMAGE = denoise(GRAY_IMAGE)
    % Шумоподавление: Дискретное косинусное преобразование (DCT)
    % medfilt2, Lee, Kuan, Frost, вейвлеты
    [rows, cols] = size(GRAY_IMAGE); 
    dct_transformed = dct2(GRAY_IMAGE);  % Дискретное косинусное преобразование: Шум --> Высокие частоты --> Низкая амплитуда
    
    low_frequency_mask = zeros(round(rows), round(cols));
    
    low_frequency_mask(1:rows/3, 1:cols/3) = 1; % Сохранение низких частот, подавление высоких частот
    denoised_DCT = dct_transformed .* low_frequency_mask;  % Шумоподавление
    DENOISE_IMAGE = uint8(idct2(denoised_DCT)); % Обратное дискретное косинусное преобразование
end
