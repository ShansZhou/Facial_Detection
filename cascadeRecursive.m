function [ output ] = cascadeRecursive( ii_img, selectedClassifier, threshold, depth ,a,b,const)

if depth <= 0
    output = 1;
else
    classifier = selectedClassifier(a:b,:);
    result = cascadeClassifier(ii_img, classifier,threshold);
    depth = depth-1; 
    const = const + 10;
    a = b + 1;
    b = b + const;
    
    if result ==1
        cascadeRecursive(ii_img,selectedClassifier,threshold,depth, a, b, const);
        output = 1;
    else
        output = 0;
    end

end

end

