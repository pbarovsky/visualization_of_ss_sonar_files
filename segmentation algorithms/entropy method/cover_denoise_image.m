function EXPANDED_IMAGE = cover_denoise_image(DILATE_IMAGE, DENOISE_IMAGE, REMOVING_SHADOW_BOUNDARIES)
    [LOCALIZATION, ROW_THRESHOLD_1, ROW_THRESHOLD_2, COL_THRESHOLD_1, COL_THRESHOLD_2] = localization_object(REMOVING_SHADOW_BOUNDARIES);
    EXPANDing_IMAGE = DILATE_IMAGE;
    EXPANDED_IMAGE = DENOISE_IMAGE;
    [height, width] = size(EXPANDED_IMAGE);
    
    for expanded_row = 1:height
        for expanded_col = 1:width
            for row_expanding = (ROW_THRESHOLD_1 + expanded_row):ROW_THRESHOLD_2
                for col_expanding = (COL_THRESHOLD_1 + expanded_col):COL_THRESHOLD_2     
                    if EXPANDing_IMAGE(expanded_row, expanded_col) == 1
                        EXPANDED_IMAGE(ROW_THRESHOLD_1 + expanded_row, COL_THRESHOLD_1 + expanded_col) = 255;
                    end
                end
            end
        end
    end
end