% Objective function
%   x(1) = alpha; parameter of circle involute of pinion A
%   x(2) = gamma; pinion B rotation angle
%   varargin{1} = params
% 
% params = struct(
%   "phi", i * pinion.cp,
%   "r", pinion.r,
%   "m", m,
%   "b", pinion.b,
%   "alpha", rack.alpha,
%   "p", rack.p,
%   "t", rack.t,
%   "phiR", phiR,
%   "v", v,
%   "dp", pressure_dist,
%   "wp", pressure_width
% )
% 
function [F] = rack_pos(x, varargin)
  params = varargin{1};
  % cosa = cos(params.phi);
  % sina = sin(params.phi);
  cosa = cos(params.phi - params.phiR);
  sina = sin(params.phi - params.phiR);
  % cosb = cos(params.phiR);
  % sinb = sin(params.phiR);
  A = [cosa, -sina; sina, cosa];
  % B = [cosb, -sinb; sinb, cosb];
  I = circle_involute(params.alpha, params.r);
  % L = [
  %   (params.p + params.wp) / 2 + x(1);
  %   % params.dp + params.t + params.b + x(2)
  %   params.t + params.b + x(2)
  % ];
  L = [
    (params.p + params.wp) / 2 + x(1);
    params.t + params.b + x(2)
  ];
  % F = A * I - B * L;
  F = A * I - L;
end
