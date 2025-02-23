function [s] = new_pinion(z, m, alpha)
  Dp = m * z;             % Pitch circle diam.
  Db = Dp * cos(alpha);   % Base circle diam.
  r = Db / 2;
  D = Dp + 2 * m;         % Addendum circle diam.
  Dc = Dp - 2 * m;        % Clearance circle diam.
  b = 1.25 * m;           % Dedendum
  Dr = Dp - 2 * b;        % Root circle diam.
  cp = 2*pi / z;          % Circular pitch angle, same as 2*PI*P/(PI*Dp)
  s = struct("z", z, "m", m, "alpha", alpha, "Dp", Dp, "Db", Db, "r", r, "D", D, "Dc", Dc, "b", b, "Dr", Dr, "cp", cp);
end
