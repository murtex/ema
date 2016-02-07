function outfile = wavfix( infile )
% fix wave file chunk size
%
% outfile = WAVFIX( infile )
%
% INPUT
% infile : input wave filename (row char)
%
% OUTPUT
% outfile : (temporary) output wave filename (row char)
%
% SEE
% https://www.mathworks.com/matlabcentral/answers/92303-why-do-i-receive-an-error-about-incorrect-chunk-size-when-using-wavread-in-matlab

		% safeguard
	if nargin < 1 || ~isrow( infile ) || ~ischar( infile ) || exist( infile, 'file' ) ~= 2
		error( 'invalid argument: infile' );
	end

		% create temporary wave file copy
	persistent tmpfile;

	if isempty( tmpfile )
		tmpfile = [tempname(), '.wav'];
	end

	outfile = tmpfile;

	copyfile( infile, outfile );

		% fix wave chunk size
	fi = dir( outfile );

	fid = fopen( outfile, 'r+', 'l' );

	fseek( fid, 4, 'bof' );
	fwrite( fid, fi.bytes - 8, 'uint32' );
	fseek( fid, 40, 'bof' );
	fwrite( fid, fi.bytes - 44, 'uint32' );

	fclose( fid );

end

