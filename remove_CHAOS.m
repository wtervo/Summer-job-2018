%Read Swarm magnetic data in CDF format, extract variables,calculate Main
%B-field(CHAOS-6 model)and save file in matlab format for further analysis 
clear
% -------------------------------------Edit the CDF data directory -----------------------------------
addpath('CHAOS_6/')
addpath('aacgm_v2/')
addpath('cdfData/')
% Call files from the data folder
allskip = 0;
disp(' ')
while 1
	h_or_l = upper(strtrim(input('Please select High (H) or Low (L) resolution data: ', 's')));

	if h_or_l == 'H'
		files = dir(fullfile('./cdfData','SW_OPER_MAG*_HR.cdf'));
		break
	elseif h_or_l == 'L'
		files = dir(fullfile('./cdfData','SW_OPER_MAG*_LR.cdf'));
		break
	else
		disp('Please select H for High resolution data, L for Low resolution data.')
	end
end

%LOOP through all the data files in the directory
Nfiles = length(files);

for j = 1 : Nfiles
   	% Define current file in the Folder 
	file = files(j).name;
	split = strsplit(file, 'MAG');
	a_or_c = regexp(split{2}, '[AC]', 'match', 'once');
	NameStr = file(20:34);
	if a_or_c == 'A'
		whichsat = 'SatA';
	elseif a_or_c == 'C'
		whichsat = 'SatC';
	end
	
	disp(' ')
	disp(sprintf('Current file: %s %s.', whichsat, NameStr))
	disp('If you wish to select the whole file, leave the field empty.')
	disp('If you wish to skip this file, type "skip".')
	while 1
		% Ask user to select a time interval of observation and check for input errors
		year = str2num(NameStr(1:4));
		month = str2num(NameStr(5:6));
		day = str2num(NameStr(7:8));
		obs_begin = lower(strtrim(input('Please select beginning hour and minutes (hh mm): ', 's')));
		if obs_begin == "skip"
			break
		elseif isempty(obs_begin) == 1
			t_begin = -Inf;
			t_end = Inf;
			break
		else
			obs_begin = strsplit(obs_begin);

			if length(obs_begin) ~= 2
				disp('Invalid value: Please give exactly 2 numeric values separated by space (hh mm).')
				continue
			end

			begin_hour = str2num(obs_begin{1});
			begin_minute = str2num(obs_begin{2});
			if isempty(begin_hour) == 1 || isempty(begin_minute) == 1
				disp('Invalid value: Please give numeric values.')
				continue
			elseif begin_hour < 0 || begin_hour >= 24
				disp('Invalid value: 0 =< hours < 24 must be true.')
				continue
			elseif begin_minute < 0 || begin_minute >= 60
				disp('Invalid value: 0 =< minutes < 60 must be true.')
				continue
			end

			obs_end = strtrim(input('Please select ending hour and minutes (hh mm): ', 's'));
			obs_end = strsplit(obs_end);

			if length(obs_end) ~= 2
				disp('Invalid value: Please give exactly 2 numeric values separated by space (hh mm).')
				continue
			end

			end_hour = str2num(obs_end{1});
			end_minute = str2num(obs_end{2});

			if isempty(end_hour) == 1 || isempty(end_hour) == 1
				disp('Invalid value: Please give numeric values.')
				continue
			elseif end_hour < 0 || end_hour >= 24
				disp('Invalid value: 0 =< hours < 24 must be true.')
				continue
			elseif end_minute < 0 || end_minute >= 60
				disp('Invalid value: 0 =< minutes < 60 must be true.')
				continue
			elseif end_hour < begin_hour
				disp('Invalid value: Begin time cannot be greater than or equal to End time.')
				continue
			elseif end_hour == begin_hour && end_minute <= begin_minute
				disp('Invalid value: Begin time cannot be greater than or equal to End time.')
				continue
			else
				seconds = 0;
				t_begin = datenum([year, month, day, begin_hour, begin_minute, seconds]);
				t_end = datenum([year, month, day, end_hour, end_minute, seconds]);
				break
			end
		end
	end

	if obs_begin == "skip"
		continue
	end
	% Load High-resolution magnetic data
	if h_or_l == 'H'
		mag = sub_ReadMagData_HResolution(file, t_begin, t_end);
	end
	% Load Low-resolution magnetic data
	if h_or_l == 'L'
		mag = sub_ReadMagData_LResolution(file, t_begin, t_end);
	end

	% Save the variables for further analysis
	filename = [whichsat, NameStr];
	if h_or_l == 'L'
		varName = ['swarmMag_LR' filename '.mat'];
		save(varName,'mag');
		allskip = 1;
	else
		varName = ['swarmMag_HR' filename '.mat'];
		save(varName,'mag');
		allskip = 1;
	end
	clearvars -except files j h_or_l skiptest allskip
end

if allskip == 0
	disp(' ')
	disp('All files skipped.')
end

clearvars








