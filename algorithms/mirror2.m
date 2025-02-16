%MIRROR2 Mirror 2-dimensional vector
% Mirrors the vector (t) about the axis (a)
function [tm] = mirror2(t,a)
  tm = t + 2 * (eye(2 ) -a * a') * (-t);
end
