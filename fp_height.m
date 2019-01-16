function fp_h = fp_height(filename)
%value for footpoint height with input error checks
	disp(sprintf('Please select magnetic footpoint location height for file %s.', filename))
	disp('To skip this file, type "skip".')
	while 1
		fp_h = lower(strtrim(input('Enter a height in [km]: ', 's')));

		if fp_h == "skip"
			break
		else
			fp_h = str2num(fp_h);
		
			if isempty(fp_h) == 1
				disp('Please enter a numeric value.')
				continue
			elseif length(fp_h) > 1
				disp('Please enter a single value.')
				continue
			elseif fp_h > 2000 || fp_h < 0
				disp('Please choose a value between the range of 0 - 2000km.')
				continue
			else
				break
			end
		end
	end
end
