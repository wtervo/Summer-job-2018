%a script for finding the best common angle of rotation theta
%based on theta, magnetic field components B_x, B_y are calculated in the rotated coordinate frame
%these values in turn are used for calculating FAC in the rotated frame
%
%requires a datafile, which contains arrays of B_x, B_y, B_xModel, B_yModel, lat, lon, radius, time
%creates a datafile swarm_bdot_*.mat with B'_x, B'_y, theta, B'_x/B'_y ratio, FAC, FAC_rot, lat, lon, radius, time
%plots relevant data as a function of latitude if the user wishes so
%
%for output values/plots:
%	B_x: positive values to the north, negative to the south
%	B_y: positive values to the east, negetive to the west
%	angle theta from north. positive values to east, negatives to west
files = dir(fullfile('swarmMag_*.mat'));
Nfiles = length(files);
allskip = 0;
for j = 1 : Nfiles
	%load values from the file
	load(files(j).name)
	bx = mag.Bx - mag.BxModel;
	by = mag.By - mag.ByModel;
	lat = mag.lat;
	lon = mag.lon;
	r = mag.r;
	dn = mag.dn;
	
	skipfile = 0;
	N = length(bx);

	%identify satellite as A or C
	a_or_c = regexp(files(j).name, 'Sat[AC]', 'match', 'once');

	%choosing a value for the number points to use for finding the best common angle
	disp(' ')
	disp('How many datapoints to use for finding the best common angle?')
	disp(sprintf('Current file: %s.', files(j).name))
	disp('To skip this file, type "skip".')
	disp(sprintf('Number of datapoints in the file is %u.', N))	
	while 1
		step = lower(strtrim(input('Please enter a value for binsize: ', 's')));

		if step == "skip"
			skipfile = 1;
			break
		end

		step = str2num(step);

		if isempty(step) == 1 || length(step) > 1
			disp('Please enter a single numeric value.')
			continue
		elseif step < 3 || mod(step, 1) ~= 0
			disp('Binsize must be an integer greater than or equal to 3.')
			continue
		elseif step > N
			disp('Binsize cannot be greater than the number of datapoints.')
			continue
		else
			break
		end
	end

	if skipfile == 1
		continue
	end

	%choosing how much bins overlap one another when calculating the rotation angle
	maxoverlap = step - 1;
	disp(' ')
	disp('Choose how much the bins will overlap while calculating the angle of rotation.')
	disp(sprintf('For no overlap, select 0. Maximum overlap is %u.', maxoverlap))
	while 1
		overlap = str2num(strtrim(input('Enter a value for bin overlap: ', 's')));

		if isempty(overlap) == 1 || length(overlap) > 1
			disp('Please enter a single numeric value.')
			continue
		elseif mod(overlap, 1) ~= 0
			disp('Overlap value must be an integer.')
			continue
		elseif overlap < 0 || overlap >= step
			disp(sprintf('Overlap must be between the range of 0 - %u.', maxoverlap))
			continue
		else
			%value div needed to determine window beginning and end
			div = (step - 1) / 2;
			break
		end
	end

	%choosing a limit for |B_x| / |B_y| ratio
	disp(' ')
	disp("Choose a limit for the ratio |B_x'| / |B_y'| in the rotated coordinate")
	disp('system. If the ratio value is below the chosen limit, Field Aligned')
	disp('Current will be calculated for the corresponding rotated coordinates.')
	while 1
		limval = str2num(strtrim(input('Please enter a limit: ', 's')));

		if isempty(limval) == 1 || length(limval) > 1
			disp('Please enter a single numeric value.')
			continue
		elseif limval <= 0 || limval >= 20
			disp('The value must be greater than zero and less than 20.')
			continue
		else
			break
		end	
	end

	%choosing a method of calculating the angle of rotation
	%the results may vary wildly depending on the method and data
	disp(' ')
	disp('Choose how the angle of rotation is calculated.')
	disp('	1) Minimizing B_x component')
	disp('	2) Minimizing B_x, average value removed')
	disp('	3) Derivative')
	while 1
		calc_sel = str2num(strtrim(input('Choose calculation method: ', 's')));
		if calc_sel == 1
			break
		elseif calc_sel == 2
			break
		elseif calc_sel == 3
			break
		else
			disp('Please select a number from 1-3.')
			continue
		end
	end

	%ask if the calculated data should be plotted
	disp(' ')
	disp('Do you wish to plot the data?')
	while 1
		plotq = lower(strtrim(input('Plot data [y/n]? ', 's')));

		if length(plotq) > 1
			disp('Please type a single value.')
			continue
		elseif plotq == 'n'
			break
		elseif plotq == 'y'
			break
		else
			disp('Please select [y]es or [n]o.')
			continue
		end
	end		
	
	if (step - overlap) == 1
		%calculate rotation angle, FAC when window moves by 1 datapoint
		bdot = calc_field_rot_1step(bx, by, lat, lon, r, dn, limval, div, calc_sel);
		allskip = 1;
	else
		%calculate rotation angle, FAC
		bdot = calc_field_rot(bx, by, lat, lon, r, dn, step, overlap, limval, div, calc_sel);
		allskip = 1;
	end
	
	%plot the data with swarmplot script if the user chose to do so
	if plotq == 'y'
		swarmplot
	end

	nm = strsplit(files(j).name, '.');
	nm = strsplit(nm{1}, '_');
	nm = strsplit(nm{2}, 'T');
	nm = nm{1};

	%save bdot structure into a file
	filename = ['swarm_bdot_' nm '.mat'];
	save(filename, 'bdot');
	
	clearvars -except j files Nfiles limval allskip
end

if allskip == 0
	disp(' ')
	disp('All files skipped.')
end

clearvars



