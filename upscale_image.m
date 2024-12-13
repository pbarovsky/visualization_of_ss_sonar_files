function scaled_image = upscale_image(image, target_resolution)
    % Масштабируем изображение до заданного разрешения
    scaled_image = imresize(image, target_resolution, 'bicubic');
end