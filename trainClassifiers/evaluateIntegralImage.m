function regionSum = evaluateIntegralImage(ii_img, start_col, start_row, end_col, end_row)

l1 = ii_img(start_row,start_col);
l2 = ii_img(start_row,end_col);
l3 = ii_img(end_row,start_col);
l4 = ii_img(end_row,end_col);

regionSum = l4 - l3 - l2 + l1;

end


