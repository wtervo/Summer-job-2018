%this is a separate function for a case where the "step" is a single datapoint
%see calc_field_rot.m for rest of the cases
%
%creates arrays for the calculation of angle theta based on user inputs
%subfunction find_theta.m calculates the angle of rotation theta
%theta is used in this function to find B'_x, B'_y
%B'_x, B'_y are used in subfunction calc_FAC.m for finding FAC in non-rotated and rotated frames
%
%outputs structure s, which has all the relevant results from calculations as N-dimensional vectors
function s = calc_field_rot(bx, by, lat, lon, r, dn, limval, div, calc_sel)

N = length(bx);
	
%finding the best common angle, calculating FAC
for num = 1 : N
	%determining array bounds for each bin
	rng_beg = floor(div);
	rng_end = ceil(div);

	%when bin's beginning is smaller than array's first index
	if (num - rng_beg) < 1 
		rng_beg = 1;
		rng_end = num + rng_end;

		ind = num;
	%when bin's end is larger than array's last index
	elseif (num + rng_end) > N
		rng_beg = num - rng_beg + 1;
		rng_end = N;
		
		ind = num;
	%rest of the cases
	else
		rng_beg = num - rng_beg;
		rng_end = num + rng_end;

		ind = num;
	end

	bxavg = mean(bx(rng_beg : rng_end));
	byavg = mean(by(rng_beg : rng_end));		

	bxsumm = bx(rng_beg : rng_end) - bxavg;
	bysumm = by(rng_beg : rng_end) - byavg;

	%create arrays for magnetic fields
	bxsum = bx(rng_beg : rng_end);
	bysum = by(rng_beg : rng_end);

	%calculate angle theta
	the = find_theta(bxsum, bysum, bxsumm, bysumm, calc_sel);

	s.theta(ind, 1) = the;

	%calculate magnetic xy-components in the rotated coordinate frame
	runnum = 1;
	for num2 = rng_beg : rng_end
		%B_x and B_y rotations
		bxd_tmp(runnum) = bx(num2) * cosd(the) + by(num2) * sind(the);
		byd_tmp(runnum) = -bx(num2) * sind(the) + by(num2) * cosd(the);

		%"skip" first value to avoid problems
		if num2 == 1
			s.FAC(1) = NaN;
			s.FAC_rot(1) = NaN;
			lastval = 0;
			continue
		end

		%time difference between two points in seconds
		ts = (dn(num2) - dn(num2 - 1)) * 24 * 3600;
		%angle difference between two points in North-South (x) direction
		latdiff = lat(num2) - lat(num2 - 1);
		%angle difference between two points in East-West (y) direction
		%special treatment for longitude to avoid problems when jumping from 180 to -180
		if lon(num2) < 0 && lon(num2 - 1) > 0
			londiff = 180 - lon(num2 - 1) + 180 + lon(num2);
		elseif lon(num2) > 0 && lon(num2 - 1) < 0
			londiff = 180 - lon(num2) + 180 + lon(num2 - 1);
		else
			londiff = lon(num2) - lon(num2 - 1);
		end

		%length of the NS arc in meters
		xarc = 2 * pi * r(num2) * (latdiff / 360) * 1e3;
		%length of the EW arc in meters
		%multiplication by cosine of latitude because longitude change is dependant on the latitude
		yarc = 2 * pi * r(num2) * (londiff / 360) * 1e3 * cosd(lat(num2));
		%difference of magnetic disturbance between points
		Bdiff = (by(num2) - by(num2 - 1)) * 1e-9; %from nT to T

		%difference of rotated values
		if num2 == rng_beg || num2 == 2
			Bdotdiff = (byd_tmp(runnum) - lastval) * 1e-9;
		else
			Bdotdiff = (byd_tmp(runnum) - byd_tmp(runnum - 1)) * 1e-9;
		end

		%FAC in both coordinate systems
		[fac, fac_rot] = calc_FAC(xarc, yarc, ts, Bdiff, Bdotdiff, the);
		
		%save values to structure when num2 is between predetermined array ends
		if num2 == ind
			s.bx_dot(num2, 1) = bxd_tmp(runnum);
			s.by_dot(num2, 1) = byd_tmp(runnum);

			s.FAC(num2, 1) = fac * 1e6; %1e6 is a correction term to get the unit to
			s.FAC_rot(num2, 1) = fac_rot * 1e6; %a scale of microA / m^2
		end
		
		%save the last value of B_y components for the next loop of calculations
		if num2 == rng_end
			lastval1 = byd_tmp(end);
		end

		runnum = runnum + 1;
	end
	
	bxdotsum = sum(bxd_tmp.^2);
	bydotsum = sum(byd_tmp.^2);

	%array for checking if the B_x / B_y limit is too high
	s.limcheck(ind, 1) = bxdotsum / bydotsum;

	clearvars rng_beg rng_end arr_begin arr_end bxd_tmp1 byd_tmp1 runnum

end

%remove FAC values where B_x' / B_y' ratio is over the chosen limit
for num3 = 1 : N
	if s.limcheck(num3) > limval
		s.FAC(num3) = NaN;
		s.FAC_rot(num3) = NaN;
	end
end

s.lat = lat;
s.lon = lon;
s.r = r;
s.time = dn;

