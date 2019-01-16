%calculates FAC in non-rotated coordinate system and also in a system
%rotated by angle theta
function [FAC, FAC_rot] = calc_FAC(arc_x, arc_y, tme, by_diff, bydot_diff, theta)

mu_zero = 4 * pi * 1e-7;

FAC = (by_diff / arc_x) / mu_zero;

%velocity's components in m/s
vx = arc_x / tme;
vy = arc_y / tme;

%velocity's x-component in the rotated coordinate system
vx_dot = vx * cosd(theta) + vy * sind(theta);
xdot_diff = vx_dot * tme;
FAC_rot = (bydot_diff / xdot_diff) / mu_zero;

end



