function EDGE_IMAGE = edge_detection(DENOISE_IMAGE)
    % Обнаружение краев: Оператор Робертса
    % Операторы: roberts, sobel, log, canny, prewitt
    EDGE_IMAGE = edge(DENOISE_IMAGE, 'roberts');
end
