function w = vec_initializeWeights_v1(N_MT, N_vec, w_amp)

w = randn(N_MT,1);
w = w / sqrt( w'*w/w_amp); % not w_amp^2???
w = repmat(w, [1 N_vec]);