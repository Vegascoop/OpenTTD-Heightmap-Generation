function X = noise(sz,sig)
% RANDS     Smooth random noise in N-dimensions
%
% SYNTAX
% =========================================================================
% X = RANDS
% X = RANDS(n)
% X = RANDS(sz)
% X = RANDS(sz,sig)
%
% INPUT ARGUMENTS
% =========================================================================
% n             Size of square matrix, specified as an integer value
% sz            Size of each dimension, specified as a row vector of
%               integer values
% sig           Width of the gaussian kernel (pixels). Defaults to 10% of
%               the maximum argument in "sz" 
%
% OUTPUT ARGUMENTS
% =========================================================================
% X             Array of smooth random noise with size "sz" or n-by-n
    % BASE CASE
    if nargin == 0
        X = rand;
        return
    end
    % PARSE SIZE OF ARRAY
    if any(sz ~= fix(sz))
        error('Size inputs must be integers');
    end
    if numel(sz) == 1
        sz = sz*[1 1];
    end
    % DEFAULT GAUSSIAN WIDTH (pixels)
    if nargin == 1
        sig = ceil(0.1*max(sz));
    end
    % GENERATE RANDOM NUMBERS
    X = rand(sz);
    % CALCULATE GAUSSIAN KERNEL 
    K = gkern(sz,sig);
    % SMOOTH RANDOM NUMBERS WITH FFT
    X = real(ifftn(fftn(X) .* fftn(K,sz)));
    % SCALE X
    X = X - min(X(:));
    X = X / max(X(:));
end
function K = gkern(sz,sigma)
    %% 

% GKERN     Calculates Gaussian kernel of size "sz" with width "sig"
    % CALCULATE NUMBER OF DIMENSIONS || will always be 2 in this case.
    N = numel(sz);
    % CALCULATE GRID CENTER
    cidx = ceil(sz / 2);
    
    % CALCULATE ND GRID
    inds = cell(1,N);
    for i = 1:N
        inds{i} = 1:sz(i);
    end
    [grid{1:N}] = ndgrid(inds{:});
    % CALCULATE RADIAL DISTANCE 
    % SQUARED FROM CENTER
    RSQ = 0;
    coder.varsize('RSQ');
    for i = 1 : N
        RSQ = RSQ + (grid{i} - cidx(i)).^2;
    end
    % CALCULATE GAUSSIAN KERNEL
    K = exp(- RSQ ./ (2.*sigma.^2)); 
    K = K ./ sum(K(:));
end