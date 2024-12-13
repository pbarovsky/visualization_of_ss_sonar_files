function DILATE_IMAGE = dilate_image(DILATE_NEW_IMAGE)
    tool = strel('disk',3);
    DILATE_IMAGE = imdilate(DILATE_NEW_IMAGE, tool);
end