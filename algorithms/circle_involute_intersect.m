%CIRCLE_INVOLUTE_INTERSECT
% Returns the parameter theta (in degrees) for the intersection between the involute 
% of a circle with radius (or diameter) r and another circle with radius (or diameter) R.
% 
%   r - Involute circle radius
%   R - Radius of "the other circle" or just a distance from the origin
% 
function [theta] = circle_involute_intersect(r, R)
  theta = sqrt((R / r)^2 - 1);
end
