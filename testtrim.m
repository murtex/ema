function testtrim( wavalldir, trim1dir, trim2dir )
% test wave file trimming
%
% TESTTRIM( wavdir, trim1dir, trim2dir )
%
% INPUT
% wavalldir : raw input directory (row char)
% trim1dir : first trimming input directory (row char)
% trim2dir : second trimming input directory (row char)

		% safeguard
	if nargin < 1 || ~isrow( wavalldir ) || ~ischar( wavalldir ) || exist( wavalldir, 'dir' ) ~= 7
		error( 'invalid argument: wavalldir' );
	end

	if nargin < 2 || ~isrow( trim1dir ) || ~ischar( trim1dir ) || exist( trim1dir, 'dir' ) ~= 7
		error( 'invalid argument: trim1dir' );
	end

	if nargin < 3 || ~isrow( trim2dir ) || ~ischar( trim2dir ) || exist( trim2dir, 'dir' ) ~= 7
		error( 'invalid argument: trim2dir' );
	end

		% prepare file lists
	fl0 = dir( fullfile( wavalldir, '*.all.wav' ) );
	fl0 = strrep( {fl0.name}, '.all', '' );

	fl1 = dir( fullfile( trim1dir, '*.wav' ) );
	fl1 = {fl1.name};

	fl2 = dir( fullfile( trim2dir, '*.wav' ) );
	fl2 = {fl2.name};

		% set comparable file indices
	i1comp = [];
	i2comp = [];

	for i = 1:numel( fl0 )
		if any( strcmp( fl1, fl0{i} ) ) % trim #1
			i1comp(end+1) = i;
		end
		if any( strcmp( fl2, fl0{i} ) ) % trim #2
			i2comp(end+1) = i;
		end
	end

		% filter by minimum wave lengths
	nminsamples = 100;

	i1filt = [];
	l1 = [];
	for i = 1:numel( i1comp )
		tmp = wavread( fullfile( trim1dir, fl0{i1comp(i)} ), 'size' );
		if tmp(1) >= nminsamples
			i1filt(end+1) = i1comp(i);
			l1(i1comp(i)) = tmp(1);
		end
	end

	i2filt = [];
	l2 = [];
	for i = 1:numel( i2comp )
		tmp = wavread( fullfile( trim2dir, fl0{i2comp(i)} ), 'size' );
		if tmp(1) >= nminsamples
			i2filt(end+1) = i2comp(i);
			l2(i2comp(i)) = tmp(1);
		end
	end

		% gather delta length statistics
	icomp = intersect( i1filt, i2filt );

	deltas = abs( l1(icomp) - l2(icomp) );

	d1 = deltas(deltas <= 1);
	d10 = deltas(deltas <= 10);
	d100 = deltas(deltas <= 100);
	d1k = deltas(deltas <= 1000);
	d10k = deltas(deltas <= 10000);
	d100k = deltas(deltas <= 100000);

		% log summary
	fprintf( '%d files exist in ''%s''\n', numel( fl0 ), wavalldir );

	fprintf( '%d files exist in ''%s'', ', numel( fl1 ), trim1dir );
	fprintf( '%d files are valid\n', numel( i1filt ) );
	for i = setdiff( 1:numel( fl0 ), i1comp )
		fprintf( '\tmissing: ''%s''\n', fl0{i} );
	end

	fprintf( '%d files exist in ''%s'', ', numel( fl2 ), trim2dir );
	fprintf( '%d files are valid\n', numel( i2filt ) );
	for i = setdiff( 1:numel( fl0 ), i2comp )
		fprintf( '\tmissing: ''%s''\n', fl0{i} );
	end

	fprintf( '%d files are comparable\n', numel( icomp ) );
	fprintf( '\t%d have wave length delta <= 1 samples\n', numel( d1 ) );
	if numel( d1 ) < numel( icomp )
		fprintf( '\t%d have wave length delta <= 10 samples\n', numel( d10 ) );
		if numel( d10 ) < numel( icomp )
			fprintf( '\t%d have wave length delta <= 100 samples\n', numel( d100 ) );
			if numel( d100 ) < numel( icomp )
				fprintf( '\t%d have wave length delta <= 1000 samples\n', numel( d1k ) );
				if numel( d1k ) < numel( icomp )
					fprintf( '\t%d have wave length delta <= 10000 samples\n', numel( d10k ) );
					if numel( d10k ) < numel( icomp )
						fprintf( '\t%d have wave length delta <= 100000 samples\n', numel( d100k ) );
					end
				end
			end
		end
	end

end

