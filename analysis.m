%script for analyzing the optimal values for the summer job program
%compares the calculated angle values with the true angles found in
%Heikki's artificial test data
%
%saves the plots automatically
%takes a VERY long time to run when processing HR test data
files = dir(fullfile('testi_FAC*.mat'));
Nfiles = length(files);

for j = 1 : Nfiles
	%load test data
	load(files(j).name)
	disp(files(j).name)
	bx = Bx;
	by = By;
	testang = kulma;
	nn = length(bx);
	dn = [1:nn];

	limval = 1;
	overlap = 1;

	testang = kulma;

	%these loop values are for HR data
	for num = 20 : 150 : 6500
		step = num;
		div = (step - 1) / 2;

		%run calculations with each of the 3 methods
		calc_sel = 1;
		jep1 = calc_field_rot_1step(bx, by, lat, lon, r, dn, limval, div, calc_sel);

		calc_sel = 2;
		jep2 = calc_field_rot_1step(bx, by, lat, lon, r, dn, limval, div, calc_sel);

		calc_sel = 3;
		jep3 = calc_field_rot_1step(bx, by, lat, lon, r, dn, limval, div, calc_sel);

		%limit the angles of comparison when the satellite latitude is between 63-77
		N = length(jep1.theta);
		for num2 = 1 : N
			if lat(num2) > 63 && lat(num2) < 77
				%absolute value of the test data's true angle minus the calculated angle
				ang_diff1(num2, 1) = abs(testang(num2) - jep1.theta(num2));
			end
			if lat(num2) > 63 && lat(num2) < 77
				ang_diff2(num2, 1) = abs(testang(num2) - jep2.theta(num2));
			end
			if lat(num2) > 63 && lat(num2) < 77
				ang_diff3(num2, 1) = abs(testang(num2) - jep3.theta(num2));
			end
		end
	
		%save the sums of absolute values in arrays
		angsum1(num, 1) = sum(ang_diff1);
		angsum2(num, 1) = sum(ang_diff2);
		angsum3(num, 1) = sum(ang_diff3);

		%save the used window size to an array
		num_arr(num, 1) = step;
		clearvars jep1 jep2 jep3 ang_diff1 ang_diff2 ang_diff3
	end

	zeroind = find(angsum1 == 0);

	%remove empty values
	angsum1(zeroind) = [];
	angsum2(zeroind) = [];
	angsum3(zeroind) = [];
	num_arr(zeroind) = [];

	%find min and max values
	[min1, ind1] = min(angsum1);
	[min2, ind2] = min(angsum2);
	[min3, ind3] = min(angsum3);
	[max1, maxind1] = max(angsum1);
	[max2, maxind2] = max(angsum2);
	[max3, maxind3] = max(angsum3);
	%find the window size corresponding to the minimum value
	bestwindow1 = num_arr(ind1);
	bestwindow2 = num_arr(ind2);
	bestwindow3 = num_arr(ind3);
	%also for max value
	maxval1 = num_arr(maxind1);
	maxval2 = num_arr(maxind2);
	maxval3 = num_arr(maxind3);

	%display the found values to the user
	disp(' ')
	disp(sprintf('Best value for B_x minimized calculation method is %u.', min1))
	disp(sprintf('Found with a window size of %u.', bestwindow1))
	disp(sprintf('Max value is %u found with window of %u.', max1, maxind1))
	disp(' ')
	disp(sprintf('Best value for B_x minimized and <B_x> removed calculation method is %u.', min2))
	disp(sprintf('Found with a window size of %u.', bestwindow2))
	disp(sprintf('Max value is %u found with window of %u.', max2, maxind2))
	disp(' ')
	disp(sprintf('Best value for derivative calculation method is %u.', min3))
	disp(sprintf('Found with a window size of %u.', bestwindow3))
	disp(sprintf('Max value is %u found with window of %u.', max3, maxind3))

	leg1 = 'B_x minimized';

	leg2 = 'B_x min, average removed';

	leg3 = 'Derivative';

	%plot the results
	%sum of absolute values as a function of window size
	%minval marked with a star symbol for each calculation method
	figure
	plot(num_arr, angsum1, '-p', 'MarkerIndices', [ind1], 'MarkerFaceColor', 'yellow', 'MarkerSize', 15)
	hold on
	plot(num_arr, angsum2, '-p', 'MarkerIndices', [ind2], 'MarkerFaceColor', 'green', 'MarkerSize', 15)
	plot(num_arr, angsum3, '-p', 'MarkerIndices', [ind3], 'MarkerFaceColor', 'red', 'MarkerSize', 15)
	hold off
	grid on
	title('Best values for angles by window size') ; xlabel('Window size') ; ylabel('Sum of angle differences') ;
	legend({leg1, leg2, leg3}, 'Location', 'northwest')

	%save the .fig file
	nm = strsplit(files(j).name, '.');
	nm = nm{1};
	savefig(nm)

	clearvars -except j files Nfiles

end








