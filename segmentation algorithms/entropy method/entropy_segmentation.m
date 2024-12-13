function ENTROPY_IMAGE = entropy_segmentation(EXPANDED_IMAGE)
    Input_Image = EXPANDED_IMAGE;  %ES Input Image 
    Double_Image = double(Input_Image);  
    [rows, cols] = size(Input_Image);  
    half_window = 1;  
    Smoothed_Image = zeros(rows, cols);  
    
    for i = 1:rows
        for j = 1:cols 
            index = 0;
            for k = -half_window:half_window  
                for w = -half_window:half_window
                    index = index + 1;   
                    row_index = i + k;  
                    col_index = j + w;  
                    if (row_index <= 0) || (row_index > rows)  
                        row_index = i;  
                    end  
                    if (col_index <= 0) || (col_index > cols)  
                        col_index = j;  
                    end  
                    Smoothed_Image(i, j) = Double_Image(row_index, col_index) + Smoothed_Image(i, j); 
                    Neighborhood(index) = Double_Image(row_index, col_index);
                end
            end
    
           Local_Avg_Image(i, j) = uint8(1/9 * Smoothed_Image(i, j));  
           % Local_Avg_Image(i, j) = mode(Neighborhood);
        end  
    end  
    
    Joint_Histogram = zeros(256, 256);  
    
    for i = 1:rows  
        for j = 1:cols  
            gray_value = Double_Image(i, j);  
            avg_value = double(Local_Avg_Image(i, j));  
            Joint_Histogram(gray_value + 1, avg_value + 1) = Joint_Histogram(gray_value + 1, avg_value + 1) + 1;  
        end  
    end  
    
    Joint_Prob = Joint_Histogram / (rows * cols);      
    Padded_Prob = padarray(Joint_Prob, [1 1], 0, 'both');
    [padded_rows, padded_cols] = size(Padded_Prob); 
    
    for i = 2:padded_rows - 1
        for j = 2:padded_cols - 1
            Sum_Prob(i - 1, j - 1) = Padded_Prob(i - 1, j - 1) + Padded_Prob(i - 1, j) + Padded_Prob(i - 1, j + 1) + Padded_Prob(i, j - 1) + Padded_Prob(i, j) + Padded_Prob(i, j + 1) + Padded_Prob(i + 1, j - 1) + Padded_Prob(i + 1, j) + Padded_Prob(i + 1, j + 1);
            Weight(i - 1, j - 1) = 1 - Sum_Prob(i - 1, j - 1) - abs(i - 1 - j - 1) / 100;
        end
    end
    
    alpha = 0.5;
    Cumulative_Prob = 0;
    Cumulative_Prob_Complement = 0;
    Cumulative_Entropy1 = 0;
    Cumulative_Entropy2 = 0;
    Prob = zeros(234, 216);
    Prob_Complement = zeros(234, 216);
    Entropy1 = zeros(234, 216);
    Entropy2 = zeros(234, 216);
    
    for i = 4:237
        for j = 4:219
            Cumulative_Prob = Cumulative_Prob + Joint_Prob(i, j);
            Prob(i, j) = Cumulative_Prob;           
        end
    end
    
    for i = 4:237
        for j = 4:219
            Prob_Complement(i, j) = 1 - Prob(i, j);  
        end
    end
    
    for i = 5:237
        for j = 5:219
            Cumulative_Entropy1 = Cumulative_Entropy1 + (Joint_Prob(i, j)^alpha);
            Entropy1(i, j) = Cumulative_Entropy1;
        end
    end
    
    for i = 5:230
        for j = 5:210
            Entropy2(i, j) = Entropy1(230, 210) - Entropy1(i, j);
        end
    end
    
    max_entropy = 0;
    best_s = 0;
    best_t = 0;
    best_s1 = 0;
    best_t1 = 0;
    
    for s = 70:100
        for t = 70:100
            for s1 = 100:150
                for t1 = 100:150   
                    term1 = 1/(alpha - 1) * (1 - Entropy1(s, t) / (Prob(s, t)^alpha));
                    term2 = 1/(alpha - 1) * (1 - (Entropy1(s1, t1) - Entropy1(s, t)) / ((Prob(s1, t1) - Prob(s, t))^alpha));
                    term3 = 1/(alpha - 1) * (1 - Entropy2(s1, t1) / (Prob_Complement(s1, t1)^alpha));
                    Entropy = (term1 + term2 + term3) + Weight(s, t) + Weight(s1, t1);
    
                    if Entropy > max_entropy
                        max_entropy = Entropy;
                        best_s = s;
                        best_t = t;  
                        best_s1 = s1;
                        best_t1 = t1;
                    end
                end
            end
        end
    end
    
    if best_s < best_t
        threshold1 = best_s;
    else
        threshold1 = best_t;
    end
    
    best_s = threshold1;
    best_t = threshold1;
    
    if best_s1 > best_t1
        threshold2 = best_s1;
    else
        threshold2 = best_t1;
    end
    
    best_s1 = threshold2;   
    best_t1 = threshold2; 
    
    Segmented_Image = zeros(rows, cols);
    for i = 1:rows  
        for j = 1:cols  
            if Double_Image(i, j) >= best_s1 + 50 && Local_Avg_Image(i, j) >= best_t1 + 50
                Segmented_Image(i, j) = 255; 
            elseif Double_Image(i, j) <= best_s - 50 && Local_Avg_Image(i, j) <= best_t - 50  
                Segmented_Image(i, j) = 0; 
            else
                Segmented_Image(i, j) = 100;
            end
        end
    end
    
    ss = best_s;
    tt = best_t;
    ss1 = best_s1;
    tt1 = best_t1;
    ENTROPY_IMAGE = uint8(Segmented_Image);
end