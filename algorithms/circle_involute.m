function [P] = circle_involute(theta, r)
  c = cos(theta);
  s = sin(theta);
  P = r * [c + theta .* s; s - theta .* c];
end
