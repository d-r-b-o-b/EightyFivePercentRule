function [err, dd, w, e, th] = run_perceptron_new_v2(D, T, lambda, ER)

% vectorize over ER
E = length(ER);

% true weights
e = randn(D,1);
e = e - repmat(mean(e), D, 1); % center it
e = e ./ sqrt(repmat(sum(e.*e), D, 1)); % make std = 1;



% perceptron
% initialize weights
flag = 0;
while ~flag
    
    ww = 1*randn(D,1);
    theta = acos(e'*ww/sqrt(ww'*ww));
    
    if abs(theta) < pi/2*0.8;
        flag = 1;
    end
end

w = repmat(ww, [1 E]);;


err = nan(T,E);
dd = nan(T,E);
th = nan(T,E);

% get the null space of e (all vectors orthogonal to e)
dum=e.'/norm(e);
R=null(dum).';

Finv = -erfinv(2*ER - 1)*sqrt(2);

for i = 1:T
    
    % true label for this trial
    t = rand<0.5;
    s = 2*t - 1;
    
    % compute desired difficulty
    theta = acos(e'*w./sqrt(diag(w'*w))');
    Delta = abs(lambda * tan(theta) .* Finv);
    
    % add noise which is orthogonal to e
    
    % sample noise
    n = randn(D-1,1)*lambda;
    
    % rotate noise so there's no noise along e
    N = R'*n;
    
    % stimulus
    x = s * repmat(Delta, D, 1) .* repmat(e, [1 E]) + repmat(N, [1 E]);
    
    % compute perceptron output
    y = sum(w.*x) > 0;
    
    % learn!
    w = w + (t - repmat(y, D, 1) ).*x;
    
    
    err(i,:) = abs(t-y);
    dd(i,:) = Delta;
    th(i,:) = theta;
end