%NEW_GEAR_RACK
% 
%   z - No. of teeth
%   m - Module (addendum) [mm]
%   alpha - Pressue angle [rad]
%   t - Thickness [mm]
% 
function [s] = new_gear_rack(z, m, alpha, t)
  s = struct(
    "z", z,
    "m", m,
    "alpha", alpha,
    "b", 1.25 * m, % dendendum
    "p", m * pi, % pitch
    "t", t
  );
end
