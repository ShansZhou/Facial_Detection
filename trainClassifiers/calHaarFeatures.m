function feature = calHaarFeatures(ii_img,haarTemplate,col,row,haar_scaledCol,haar_scaledRow )

offsetCol = haar_scaledCol -1;
offsetRow = haar_scaledRow -1;
% haarTemplate = 1: top white / bottom black
% haarTemplate = 2: left white / right black
% haarTemplate = 3: top white / mid black / bottom white
% haarTemplate = 4: left white / mid black / right white
% haarTemplate = 5: topleft white / topright black / bottomleft black / bottomlight white

if haarTemplate ==1
    whiteRegion = evaluateIntegralImage(ii_img, col, row, col + offsetCol, row + floor(offsetRow/2));
    blackRegion = evaluateIntegralImage(ii_img, col, row + ceil(offsetRow/2), col + offsetCol, row + offsetRow);
    feature = whiteRegion - blackRegion;
    
elseif haarTemplate ==2
    whiteRegion = evaluateIntegralImage(ii_img, col, row, col + floor(offsetCol/2), row + offsetRow);
    blackRegion = evaluateIntegralImage(ii_img, col + ceil(offsetCol/2), row, col + offsetCol, row + offsetRow);
    feature = whiteRegion - blackRegion;
    
elseif haarTemplate ==3
    whiteRegion1 = evaluateIntegralImage(ii_img, col, row, col+offsetCol, row+ floor(offsetRow/3));
    blackRegion = evaluateIntegralImage(ii_img, col, row + ceil(offsetRow/3), col + offsetCol, row + floor(offsetRow*(2 /3)));
    whiteRegion2 = evaluateIntegralImage(ii_img,col, row + ceil(offsetRow*(2/3)),col + offsetCol, row + offsetRow);
    feature = whiteRegion1+whiteRegion2 - blackRegion; 
elseif haarTemplate ==4
    whiteRegion1 = evaluateIntegralImage(ii_img, col, row, col + floor(offsetCol/3), row + offsetRow);
    blackRegion = evaluateIntegralImage(ii_img, col + ceil(offsetCol/3), row, col + floor(offsetCol*(2/3)), row + offsetRow);
    whiteRegion2 = evaluateIntegralImage(ii_img, col + ceil(offsetCol*(2/3)), row, col + offsetCol, row + offsetRow);
    feature = whiteRegion1 + whiteRegion2 - blackRegion;
    
elseif haarTemplate ==5
    whiteRegion1 = evaluateIntegralImage(ii_img, col, row, col + floor(offsetCol/2), row + floor(offsetRow/2));
    blackRegion1 = evaluateIntegralImage(ii_img, col + ceil(offsetCol/2), row, col + offsetCol, row + floor(offsetRow/2));
    blackRegion2 = evaluateIntegralImage(ii_img, col, row + ceil(offsetRow/2), col + floor(offsetCol/2), row + offsetRow);
    whiteRegion2 = evaluateIntegralImage(ii_img, col + ceil(offsetCol/2), row + ceil(offsetRow/2), col + offsetCol,row + offsetRow);
    feature = whiteRegion1 + whiteRegion2 - (blackRegion1 + blackRegion2);    

end

