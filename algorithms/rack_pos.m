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

  % Pinion origin relative to the gear rack
  Porg = [0; params.dp + params.t + params.b];

  % Tangent point on pinion base circle involute (local coords.)
  Pinvol = circle_involute(params.alpha, params.r);
  c = cos(params.phi);
  s = sin(params.phi);
  Rz = [c, -s; s, c];
  Plcs = Rz * Pinvol;

  % Transform P to the rack base coordinate system (WCS)
  % Pwcs = T * Plcs <=> Plcs = T^-1 * Pwcs
  ex = params.v;
  ey = [-ex(2); ex(1)];
  T = [ex'; ey'];
  Pwcs = T * Plcs + Porg;

  Prack = [(params.p + params.wp) / 2; params.t + params.b] + x;
  F = Pwcs - Prack;
end
