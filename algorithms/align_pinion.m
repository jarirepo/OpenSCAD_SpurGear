% Algorithm (for Octave/Matlab) to estimate the rotation angle required to mesh pinion B with pinion
% along the given direction vector (v)
clear all, close all, format short
D2R = pi / 180;
% Define pinions A and B
m = 1.0;
alpha = 20 * D2R;
A = new_pinion(16, m, alpha);
B = new_pinion(32, m, alpha);
% Direction for pinion B, v = [vx; vy]
% v = [1.8; .4];
% v = [1.8; 1.3];
% v = [0; -1];
v = [-1; -.6];
% v = [-1; 0];
% v = [0; 1];

% Center points
Ca = [0; 0];
Cb = Ca + (A.Dp + B.Dp) / 2 * v / norm(v);

% Max. theta on circle involute
theta_max_A = sqrt((A.D/2/A.r)^2-1)
theta_max_B = sqrt((B.D/2/B.r)^2-1)
Ia = circle_involute(linspace(0, theta_max_A, 21), A.r);
Ib = circle_involute(linspace(0, theta_max_B, 21), B.r);

% Circles
N = 101;
u = linspace(0, 1, N);
P = [cos(u*2*pi); sin(u*2*pi)];

Pa = Ca * ones(1,N) + A.Dp / 2 * P;
Pb = Cb * ones(1,N) + B.Dp / 2 * P;

Pba = Ca * ones(1,N) + A.Db / 2 * P;
Pbb = Cb * ones(1,N) + B.Db / 2 * P;

Pra = Ca * ones(1,N) + A.Dr / 2 * P;
Prb = Cb * ones(1,N) + B.Dr / 2 * P;

figure
set(gca, 'linewidth', 1, 'fontsize', 12)
hold on
plot([Ca(1), Cb(1)], [Ca(2), Cb(2)], 'x', 'markersize', 6, 'color', 'k');
plot(
  [Pa(1,:); Pb(1,:); Pba(1,:); Pbb(1,:); Pra(1,:); Prb(1,:)]',
  [Pa(2,:); Pb(2,:); Pba(2,:); Pbb(2,:); Pra(2,:); Prb(2,:)]',
  ':', 'linewidth', .5, 'color', .5*[1 1 1]
);
line([Ca(1), Cb(1)], [Ca(2), Cb(2)], 'linestyle', '-.', 'linewidth', .5, 'color', 'k');

ang_A = (0:A.z-1) * A.cp +  A.cp / 4;
Va = A.r * [cos(ang_A); sin(ang_A)];  % base circle pts.

% Vector v angle 0<=phi<=2*pi
phi = mod(atan2(v(2), v(1)) + 2 * pi, 2 * pi);

x = ang_A - phi;
phiA = max(x(find(x < 0))) + phi;
% phiA = min(x(find(x > 0))) + phi;
w = A.r * [cos(phiA); sin(phiA)];

plot([Ca(1), Ca(1) + w(1)], [Ca(2), Ca(2) + w(2)], '-');
Rz = [
  cos(phiA - A.cp/4), -sin(phiA - A.cp/4);
  sin(phiA - A.cp/4), cos(phiA - A.cp/4)
];
Ainvolute = Ca * ones(1,size(Ia,2)) + Rz * Ia;
plot(Ainvolute(1,:), Ainvolute(2,:),'-','color','r');  

% phiA = ang_A(1);

ang_B = (0:B.z-1) * B.cp +  B.cp / 4;
Vb = B.r * [cos(ang_B); sin(ang_B)];  % base circle pts.
gamma = mod(phi + pi, 2 * pi);
x = ang_B - gamma;
% phiB = max(x(find(x < 0))) + gamma;
phiB = min(x(find(x > 0))) + gamma;
w = B.r * [cos(phiB); sin(phiB)];
plot([Cb(1), Cb(1) + w(1)], [Cb(2), Cb(2) + w(2)], '-');
Rz = [
  cos(phiB - B.cp/4), -sin(phiB - B.cp/4);
  sin(phiB - B.cp/4), cos(phiB - B.cp/4)
];
Binvolute = Cb * ones(1,size(Ib,2)) + Rz * Ib;
plot(Binvolute(1,:), Binvolute(2,:),'-','color','b');  

% phiB = ang_B(1);

% Incremental rotations if the circle involute of pinion B such that it becomes tangential to the involute A
da = -.2 * D2R;
Rz = [cos(da), -sin(da); sin(da), cos(da)];
for k=1:19
  Binvolute = Rz * (Binvolute - Cb * ones(1,size(Ib,2))) + Cb * ones(1,size(Ib,2));
  plot(Binvolute(1,:), Binvolute(2,:),'-','color','b');  
end




% for k=1:A.z
%   if dot(Va(:,k), v) > 0
%     % Find the closest tooth on the right-hand-side of the vector (v)
%     % by evaluating the z-component of the cross-product between the vectors.
%     % a_z = b_x * c_y - b_y * c_x
%     w = cross([v(:);0], [Va(:,k);0]); 
%     if w(3) < 0
%       plot([Ca(1), Ca(1) + Va(1,k)], [Ca(2), Ca(2) + Va(2,k)], '-');
%       Rz = [
%         cos((k - 1) * A.cp), -sin((k - 1) * A.cp);
%         sin((k - 1) * A.cp), cos((k - 1) * A.cp)
%       ];
%       Ainvolute = Ca * ones(1,size(Ia,2)) + Rz * Ia;
%       plot(Ainvolute(1,:), Ainvolute(2,:),'-');  
%     end
%   end
% end

% for k=1:B.z
%   if dot(Vb(:,k), v) < 0
%     plot([Cb(1), Cb(1) + Vb(1,k)], [Cb(2), Cb(2) + Vb(2,k)], '-', 'color', .7*[1 1 1]);
%     Rz = [
%       cos((k - 1) * B.cp), -sin((k - 1) * B.cp);
%       sin((k - 1) * B.cp), cos((k - 1) * B.cp)
%     ];
%     Binvolute = Cb * ones(1,size(Ib,2)) + Rz * Ib;
%     plot(Binvolute(1,:), Binvolute(2,:),'-','color','b');
%   end
% end

hold off
axis equal
grid on
xlabel('x'), ylabel('y')


[ALPHA, GAMMA] = meshgrid(
  linspace(0, theta_max_A, 21),
  linspace(-1 * B.cp, 1 * B.cp, 21)
);

BETA = (phiA - A.cp/4) - (phiB - B.cp/4) + pi + ALPHA - GAMMA;

Iax = A.r * (cos(ALPHA) + ALPHA.*sin(ALPHA));
Iay = A.r * (sin(ALPHA) - ALPHA.*cos(ALPHA));
Ibx = B.r * (cos(BETA) + BETA.*sin(BETA));
Iby = B.r * (sin(BETA) - BETA.*cos(BETA));

AA = [
  cos(phiA - A.cp/4), -sin(phiA - A.cp/4);
  sin(phiA - A.cp/4), cos(phiA - A.cp/4)
];

F1 = AA(1,1) * Iax + ...
  AA(1,2) * Iay - ...
  cos(phiB - B.cp/4 + GAMMA) .* Ibx + ...
  sin(phiB - B.cp/4 + GAMMA) .* Iby - ...
  (Cb(1) - Ca(1));

F2 = AA(2,1) * Iax + ...
  AA(2,2) * Iay - ...
  sin(phiB - B.cp/4 + GAMMA) .* Ibx - ...
  cos(phiB - B.cp/4 + GAMMA) .* Iby - ...
  (Cb(2) - Ca(2));

figure
hold on
  surf(ALPHA, GAMMA, F1);
  surf(ALPHA, GAMMA, F2);
hold off
view(3);
grid on
xlabel('\alpha'), ylabel('\gamma')

params = struct(
  "ra", A.r,
  "rb", B.r,
  "Ca", Ca,
  "Cb", Cb,
  "phiA", phiA - A.cp / 4,
  "phiB", phiB - B.cp / 4
);

[x, f, niter, cnv] = nr_solver("pinion_pos", params, [1; 0], ftol = 1e-9)

figure
set(gca,'fontsize',12)
semilogy(cnv)
grid on
title('Convergence')
xlabel('Iteration')
ylabel('|F|')
