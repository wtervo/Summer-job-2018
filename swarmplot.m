%plots Swarm data from bdot structure by calc_field_rot(_1step) function
%3 different plots: one with B'_x, B_'y, angle, B'_x/B'_y ration
%separate plots for FAC in non-rotated and rotated frames

%get value arrays from bdot structure
lat = bdot.lat;
bxdot = bdot.bx_dot;
bydot = bdot.by_dot;
ang = bdot.theta;
relation = bdot.limcheck;
fac = bdot.FAC;
fac_rot = bdot.FAC_rot;

ostep = step - overlap;

%change legend depending on the method of calculation
if calc_sel == 1
	leg = 'B_x minimized';
elseif calc_sel == 2
	leg = 'B_x min, average removed';
elseif calc_sel == 3
	leg = 'Derivative';
end

%title and main window
tbegin = datestr(bdot.time(1));
tend = datestr(bdot.time(end));
ttl = sprintf('%s: %s - %s, Window = %u, Step = %u.', a_or_c, tbegin, tend, step, ostep);
f = figure;
p = uipanel('Parent', f, 'BorderType', 'none');
p.Title = ttl;
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold';
%B_x component
subplot(2, 2, 1, 'Parent', p), plot(lat, bxdot)
title('B_x component') ; xlabel('Latitude [deg.]') ; ylabel('Magnetic field [nT], pos. val. -> northward') ;
legend({leg}, 'Location', 'northwest')
grid on
%B_y component
subplot(2, 2, 2), plot(lat, bydot)
title('B_y component') ; xlabel('Latitude [deg.]') ; ylabel('Magnetic field [nT], pos. val. -> eastward') ;
legend({leg}, 'Location', 'northwest')
grid on
%angle
subplot(2, 2, 3), plot(lat, ang)
title("Coordinate system's angle of rotation \theta from North-axis.") ; xlabel('Latitude [deg.]') ; ylabel('Angle [degrees], pos. val. -> eastward') ;
legend({leg}, 'Location', 'northwest')
grid on
%B'_x/B'_y ratio
ratiottl = sprintf("Ratio of B'_x and B'_y components. Limit = %u.", limval);
subplot(2, 2, 4), plot(lat, relation)
title(ratiottl) ; xlabel('Latitude [deg.]') ; ylabel('Ratio') ;
legend({leg}, 'Location', 'northwest')
grid on

%FAC, non-rotated
figure
plot(lat, fac, '-', 'MarkerSize', 4)
grid on
title('Field Aligned Currents, non-rotated frame.') ; xlabel('Latitude [deg.]') ; ylabel('FAC [\muA / m²]') ;
legend({leg}, 'Location', 'northwest')

%FAC, rotated
figure
plot(lat, fac_rot, '-', 'MarkerSize', 4)
grid on
title('Field Aligned Currents, rotated frame.') ; xlabel('Latitude [deg.]') ; ylabel('FAC [\muA / m²]') ;
legend({leg}, 'Location', 'northwest')
