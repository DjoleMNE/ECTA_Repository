function ind = indMakeValid(ind,p)
%VALIDATEINDIVIDUAL Validate individuals
% by fixing the leading edge's (implicit) control point to 
% y = 0 and restricting range of other points.
%
% Example:
%  topLine = [0.5  0.49 -0.5 -0.49]
%  botLine = [0.49 0.5 -0.49 -0.5]

    % Center the individuals' leading edges vertically on zero
    ind = bsxfun(@minus,ind,( (ind(end,:)+ind(1,:)) /2 ) ); 
    
    % Binding to ranges
    ind(ind>p.grange(2)) = p.grange(2);
    ind(ind<p.grange(1)) = p.grange(1);
   
    % Move invalid control points to appropriate distance
    topLine = ind(1:end/2,:);
    botLine = ind(end:-1:1+end/2,:);
    
    oldBotline = botLine;
    invalidPts = botLine > (topLine - p.minCtlPtDist);
    high = botLine >= 0;
    low = topLine < 0;
        
    botLine(logical(high.*invalidPts)) = topLine(logical(high.*invalidPts));
    botLine = botLine - p.minCtlPtDist* (high.*invalidPts);
    
    topLine(logical(low.*invalidPts)) = oldBotline(logical(low.*invalidPts));
    topLine = topLine + p.minCtlPtDist* (low.*invalidPts);

    ind(1:end/2,:) = topLine;
    ind(end:-1:1+end/2,:) = botLine;
end

