function [y, C, r] = vec_makeDecision_v1(x, w, N_vec, sigma_noise, dir)

% decision variable
y = sum(w.*x,1) + sigma_noise * randn(1, N_vec);

% choice
C = 2*(y > 0) -1; % -1 left, +1 right

% reward
r = C == dir;

