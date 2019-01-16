%finds a magnetic footpoint location for a desired height
%found through coordinate conversions: geocent. --> aacgm --> geocent.
%
%creates a file "swarmAC_footpoint.mat", which includes the data
%
addpath('aacgm_v2/')
%load necessary coefficients
load('aacgmv2coefs.mat')
files = dir(fullfile('swarmACmag_*.mat'));
Nfiles = length(files);

for j = 1 : Nfiles
	%value for footpoint height with input error checks
	if j == 1
		useall = 0;
		fp_h = fp_height(files(j).name);
	else
		if useall == 0
			fp_h = fp_height(files(j).name);
		end
	end

	if fp_h == 'skip'
		continue
	end
	
	%ask user if they wish to keep using the same fp height value for other files
	if useall == 0 && Nfiles > 1
		disp('Use this value for subsequent files as well?')
		while 1
			yn = lower(strtrim(input('[y/n]: ', 's')));
			if yn == 'y'
				useall = 1;
				break
			elseif yn == 'n'
				useall = 0;
				break
			else
				disp('Please select yes (y) or no (n).')
				continue
			end
		end
	end

	disp(sprintf('Calculating magnetic footpoint location for data in file %s...', files(j).name))
	load(files(j).name)
	Alat = magAC.A.lat;
	Clat = magAC.C.lat;
	Alon = magAC.A.lon;
	Clon = magAC.C.lon;
	Arad = magAC.A.r - RE; %RE = Earth's radius
	Crad = magAC.C.r - RE;
	Adn = datetime(datestr(magAC.A.dn));
	Cdn = datetime(datestr(magAC.C.dn));
	N = length(Alat);
	%determine footpoint for the chosen height
	for num = 1 : N
		%skip latitudes less than 40 to avoid problems with aacgm (non)definition at low latitudes
		if Alat(num) < 40
			continue
		end
		%geocent. to aacgm
		[A_aacgm_lat, A_aacgm_lon, A_aacgm_r] = geocentric2aacgm(Alat(num), Alon(num), Arad(num), Adn(num));
		[C_aacgm_lat, C_aacgm_lon, C_aacgm_r] = geocentric2aacgm(Clat(num), Clon(num), Crad(num), Cdn(num));
		%aacgm to geocent.
		[A_fp_lat, A_fp_lon, A_fp_r] = aacgm2geocentric(A_aacgm_lat, A_aacgm_lon, fp_h, Adn(num));
		[C_fp_lat, C_fp_lon, C_fp_r] = aacgm2geocentric(C_aacgm_lat, C_aacgm_lon, fp_h, Cdn(num));
		Alatfp(num, 1) = A_fp_lat;
		Alonfp(num, 1) = A_fp_lon;
		Aradfp(num, 1) = A_fp_r;
		Atimfp(num, 1) = Adn(num);
		Clatfp(num, 1) = C_fp_lat;
		Clonfp(num, 1) = C_fp_lon;
		Cradfp(num, 1) = C_fp_r;
		Ctimfp(num, 1) = Cdn(num);
	end
	
	%remove empty values left over from low latitude condition
	ind = find(Alatfp == 0);
	Alatfp(ind) = [];
	Alonfp(ind) = [];
	Aradfp(ind) = [];
	Atimfp(ind) = [];
	ind = find(Clatfp == 0);
	Clatfp(ind) = [];
	Clonfp(ind) = [];
	Cradfp(ind) = [];
	Ctimfp(ind) = [];

	%create a single structure to save the data from all files in
	fpA = struct('fp_lat', Alatfp, 'fp_lon', Alonfp, 'fp_rad', Aradfp, 'fp_time', Atimfp);
	fpC = struct('fp_lat', Clatfp, 'fp_lon', Clonfp, 'fp_rad', Cradfp, 'fp_time', Ctimfp);
	fpfile = struct('A', fpA, 'C', fpC);
	nm = strsplit(files(j).name, '.');
	nm = strsplit(nm{1}, '_');
	nm = strsplit(nm{2}, 'T');
	nm = ['fp_', nm{1}];

	if j == 1
		footpoint = struct(nm, fpfile);
	else
		[footpoint(:).(nm)] = fpfile;
	end
	
	%plot(Alat, Alon, 'r-', Alatfp, Alonfp, 'b.-');
	clearvars -except j footpoint files Nfiles RE useall fp_h

end

allskip = exist('footpoint', 'var');

if allskip == 0
	disp('All files skipped.')
else
	filename = ['swarmAC_footpoint' '.mat'];
	save(filename, 'footpoint');
end

clearvars -except RE



