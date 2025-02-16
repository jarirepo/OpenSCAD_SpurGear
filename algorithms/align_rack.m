% Algorithm (for Octave/Matlab) to calculate the translation and rotation
% for a gear rack to mesh with a pinion along a given direction vector (v)
clear all, close all, format long
D2R = pi / 180;
R2D = 180 / pi;
TWO_PI = 2 * pi;

% Define pinion
z = 32;
m = 1.0;
alpha = 20 * D2R;
pinion = new_pinion(z, m, alpha)

% Define gear rack
rack = new_gear_rack(5, m, alpha, 2.0)

% Direction for pinion B, v = [vx; vy]
% v = [1; -.1];
v = [1; 0];

% Find the intersection between the involute and the pitch circle
theta_p = circle_involute_intersect(pinion.r, pinion.Dp / 2);

% Generate the "construction points"
% Rotate the intersection point to get intermediate points along the pitch circle
%   1/4: defines the vector used when mirroring, i.e. the tooth center line
%   3/4: used to construct the gear rack
Rz = [
  cos(pinion.cp / 4), -sin(pinion.cp / 4);
  sin(pinion.cp / 4), cos(pinion.cp / 4)
];
P = zeros(2, 5);
P(:, 1) = circle_involute(theta_p, pinion.r);
for k=(2:5)
  P(:, k) = Rz * P(:, k-1);
end

disp(R2D * theta_p)
disp(P)

% Tangent points for the "pressure vector"
T = circle_involute(alpha, pinion.r);
Tm = mirror2(T, normalize(P(:,2)));
Tm2 = mirror2(Tm, normalize(P(:,4)));

% Needed for positioning of the gear rack, targeting a meshing pinion
pressure_dist = norm(Tm)        % distance from center of the pinion to the "pressure line"
pressure_width = norm(Tm2 - Tm) % width of the "pressure line"

% Gear rack initial direction
v1 = [0; 1;];
v2 = -normalize(v);
% v2 = normalize(v);
dir = sign(cross([v1;0], [v2;0]))(3);
phiR = dir * acos(dot(v1, v2));

% Find index of a nearby tooth in the direction v
phi = mod(atan2(v(2), v(1)) + TWO_PI, TWO_PI);
i = floor(phi / pinion.cp);

params = struct(
  "phi", i * pinion.cp,
  "r", pinion.r,
  "m", m,
  "b", pinion.b,
  "alpha", rack.alpha,
  "p", rack.p,
  "t", rack.t,
  "phiR", phiR,
  "v", -v2,
  "dp", pressure_dist,
  "wp", pressure_width
)

[x, f, niter, cnv] = nr_solver(
  "rack_pos",
  params,
  [0; 0],
  ftol = 1e-9
);

TT = [
  cos(phiR), -sin(phiR);
  sin(phiR), cos(phiR)
];
TT * x

figure
set(gca,'fontsize',12)
semilogy(cnv)
grid on
title('Convergence')
xlabel('Iteration')
ylabel('|F|')
