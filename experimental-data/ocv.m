function ocv = ocv(coeffs,SOC)
% this is a function for finding the OCV at any SOC using legandre
% polynomial with coefficents found in "legandre_polynomial.mat"
SOC=SOC(:); 
SOC = max(0, min(1, SOC));        % <— clamp to [0,1]

% Degree of polynomial
    n = length(coeffs)-1;

    % Normalize SOC to [-1,1]
    SOC_prime = 2 * (SOC - 0) / (1 - 0) - 1; % SOC_prime = 2 * (SOC - min(SOC)) / (max(SOC) - min(SOC)) - 1 in which min(SOC)=0 and max(SOC)=1

    
    % Compute Legendre polynomials
    A = zeros(length(SOC_prime), n+1);
    A(:, 1) = ones(length(SOC_prime), 1);        % P_0(x) = 1
    A(:, 2) = SOC_prime .* ones(length(SOC_prime), 1); % P_1(x) = x
    
    for k = 2:n
        A(:, k+1) = ((2*k - 1) .* SOC_prime .* A(:, k) - (k-1) .* A(:, k-1)) / k;
    end

    % Compute OCV
    ocv = A * coeffs;
end