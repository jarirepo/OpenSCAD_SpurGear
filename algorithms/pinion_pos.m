% Objective function
%   x(1) = alpha; parameter of circle involute of pinion A
%   x(2) = gamma; pinion B rotation angle
%   varargin{1} = params
function [F] = pinion_pos(x, varargin)
  params = varargin{1};
  cosa = cos(params.phiA);
  sina = sin(params.phiA);
  cosb = cos(params.phiB + x(2));
  sinb = sin(params.phiB + x(2));
  A = [cosa, -sina; sina, cosa];
  B = [cosb, -sinb; sinb, cosb];
  beta = params.phiA + x(1) + pi - params.phiB - x(2);
  Ia = circle_involute(x(1), params.ra);
  Ib = circle_involute(beta, params.rb);
  F = A * Ia - B * Ib - (params.Cb - params.Ca);
end
