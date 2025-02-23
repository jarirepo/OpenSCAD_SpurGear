function [x, fx, niter, conv] = nr_solver(fn, params, x0, ftol = 1e-9)
  niter = 0;
  maxiter = 20;
  h = 1e-10;
  f = @(x) feval(fn, x, params);
  x = x0;
  fx = f(x);
  conv = [norm(fx)];
  while niter < maxiter && norm(fx) > ftol
    % J = [
    %   (f(x + [h; 0] ) - f(x - [h; 0])) / (2 * h), ...
    %   (f(x + [0; h] ) - f(x - [0; h])) / (2 * h)
    % ];
    J = [
      (f(x + [h; 0]) - fx) / h, ...
      (f(x + [0; h]) - fx) / h
    ];
    % dx = -inv(J) * fx;
    dx = -J \ fx;
    x += dx;
    fx = f(x);
    niter += 1;
    disp([x', fx'])
    conv = [conv, norm(fx)];
 end
end
