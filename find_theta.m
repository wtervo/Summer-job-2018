%finds the angle of coordinate frame rotation with one of 3 different methods for a Swarm satellite
%see calc_field_rot(_1step).m function(s) for more info on input parameters
%outputs the best angle of rotation, theta
function the  = find_theta(bxsm, bysm, bxsumm, bysumm, calc_sel)
	
		if calc_sel == 1
			%minimizing B_x method
			bxby = dot(bxsm, bysm);
			bxsum = sum(bxsm.^2);
			bysum = sum(bysm.^2);
		elseif calc_sel == 2
			%minimizing but with B_x average removed
			bxby = dot(bxsumm, bysumm);

			bxsum = sum(bxsumm.^2);
			bysum = sum(bysumm.^2);
		elseif calc_sel == 3
			%angle theta through derivative
			bxsum = diff(bxsm);
			bysum = diff(bysm);

			bxby = dot(bxsum, bysum);
			bxsum = sum(bxsum.^2);
			bysum = sum(bysum.^2);
		end

		%equations for the xy-components of the tangent
		eq1 = sqrt(4 * bxby^2 + (bxsum - bysum)^2);
		eq2 = sqrt((-bxsum + eq1 + bysum) / eq1);
		tanx = 2 * eq2;
		tany = -4 * bxby / (eq1 * eq2);
		thet = atan2d(tany, tanx);
		
		%normalizing the angle between -90 and 90 degrees
		thet = mod(thet, 180);
		if thet > 90
			the = thet - 180;
		else
			the = thet;
		end
end





