function x = vec_computeActivity_v1(theta, COH, T, MT, N_MT, N_vec)

% vectorized function to compute activity for network MT and multiple
% coherences, COH


fThetaTHETA = exp(-(theta-MT.THETA).^2/2./MT.sigma_theta.^2);
m = T .* ( MT.k0 + ((MT.kn + (MT.kp - MT.kn) .* fThetaTHETA))*COH);
v = MT.phi.*m;

% rr = randn(N_MT, N_vec);
rr = repmat(randn(N_MT,1),[1 N_vec]);
x = m + sqrt(v) .*rr;
x(x<0) = 0;
