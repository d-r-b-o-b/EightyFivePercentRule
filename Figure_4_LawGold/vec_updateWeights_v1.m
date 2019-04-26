function w = vec_updateWeights_v1(w, C, r, Er, x, alpha, N_MT, w_amp)

dw = alpha * repmat(C .* (r - Er), [N_MT 1]) .* (x);

% update weights
w = w + dw;
w = w ./ repmat(sqrt( sum(w.*w,1)/w_amp), [N_MT 1]);
