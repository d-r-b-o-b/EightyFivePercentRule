function MT = vec_initializeMTnetwork_v1(N_MT, N_vec);

% only one vector for MT cells - i.e. all networks learn from identical
% network
% preferred direction - make it uniform random between -180 and +180
% note sort theta for better visualization
MT.THETA = sort(rand(N_MT,1)*360-180);
% baseline firing rate to zero coherence - will be convenient to have this
% replicated
MT.k0 = rand(N_MT,N_vec)*20;
% sensitivity to stimulus in preferred direction
MT.kp = rand(N_MT,1)*50;
% sensitivity to stimulus in null direction
% note .*MT.k0 to prevent -ve average firing rates for 100% coherence
MT.kn = -rand(N_MT,1).*MT.k0(:,1);
% fano factor - convenient to have replicated
MT.phi = 1+rand(N_MT,N_vec)*4;
% tuning curve width in degrees
MT.sigma_theta = repmat(30, [N_MT 1]);
