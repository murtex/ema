function wavtrim( wavalldir, trimdir, thresh )
% trim wave files
% 
% WAVTRIM( wavalldir, trimdir, thresh=6 )
%
% INPUT
% wavalldir : input directory (row char)
% trimdir : output directory (row char)
% thresh : mahalanobis threshold (scalar numeric)

		% safeguard
	if nargin < 1 || ~isrow( wavalldir ) || ~ischar( wavalldir ) || exist( wavalldir, 'dir' ) ~= 7
		error( 'invalid argument: wavalldir' );
	end

	if nargin < 2 || ~isrow( trimdir ) || ~ischar( trimdir )
		error( 'invalid argument: trimdir' );
	end

	if nargin < 3
		thresh = 6; % default to six sigmas (TODO: significance!)
	end
	if ~isscalar( thresh ) || ~isnumeric( thresh )
		error( 'invalid argument: thresh' );
	end

		% prepare for output
	if exist( trimdir, 'dir' ) == 7
		pause( 'on' );
		fprintf( 'THE <strong>OUTPUT DIRECTORY</strong> ALREADY EXISTS AND <strong>WILL BE DELETED</strong> BY FURTHER PROGRESSION!\n' );
		fprintf( 'press <strong>CTRL+C</strong> to stop now, any other key will continue...\n' );
		pause();

		rmdir( trimdir, 's' );
	end

	mkdir( trimdir );

		% proceed input files
	inlist = dir( fullfile( wavalldir, '*.all.wav' ) );
	inlist = {inlist.name};

	ninfiles = numel( inlist );
	nfixes = 0;
	nm1misses = 0;
	nm2misses = 0;
	noutfiles = 0;

	for i = 1:ninfiles
		fprintf( '\tfile: %d/%d, ', i, ninfiles );

			% read input file
		infile = fullfile( wavalldir, inlist{i} );
		fprintf( 'input: ''%s'', ', infile );

		try
			[data, rate] = wavread( infile );
		catch me
			if ~isempty( strfind( me.message, getString( message( 'MATLAB:audiovideo:wavread:IncorrectChunkSizeInfo' ) ) ) )
				fprintf( 'FIXED!, ' );
				[data, rate] = wavread( wavfix( infile ) ); % fix wave chunk size (input file remains unchanged)
				nfixes = nfixes + 1;
			else
				rethrow( me );
			end
		end

			% compute mahalanobis distance (assuming first channel holds markers and is mainly noise)
		mu = mean( data(:, 1) );
		sigma = std( data(:, 1), 1 );

		md = abs( data(:, 1) - mu ) / sigma;
		mdlen = numel( md );

			% find split points (assuming start marker sits in the left half and stop marker in the right)
		lh = 1:ceil( mdlen / 2 );
		rh = lh(end)+1:mdlen;

		m1 = find( md(lh) >= thresh, 1 );
		m2 = lh(end) + find( md(rh) >= thresh, 1 );

		if isempty( m1 )
			fprintf( 'MISSING M1!\n' );
			nm1misses = nm1misses + 1;
			continue; % missing start marker is crucial
		end
		if isempty( m2 )
			fprintf( 'MISSING M2!, ' );
			nm2misses = nm2misses + 2;
			m2 = mdlen - 1; % missing stop marker is not crucial
		end

			% trim data (leave only second channel)
		data = data(m1:m2-1, 2);

			% write output file
		outfile = fullfile( trimdir, strrep( inlist{i}, '.all', '' ) );
		fprintf( 'output: ''%s''\n', outfile );

		wavwrite( data, rate, outfile );
		noutfiles = noutfiles + 1;

	end

		% log summary
	fprintf( '%d files had incorrect wave chunk size (fixed)\n', nfixes );
	fprintf( '%d start markers were missing (crucial)\n', nm1misses );
	fprintf( '%d stop markers were missing (non-crucial)\n', nm2misses );
	fprintf( '%d files have been trimmed successfully\n', noutfiles );

end

