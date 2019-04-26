function [model, dvt, i_actual] = train_fixedAccuracyOneDV_v1(model, X, T, SCORE, eta, ...
    ACC_target, windowSize, N_train, dDV, refractoryPeriod)

% ACC_target = 0.8;
% windowSize = 50;
% N_train = 20000; % parameter - number of training trials
% 
% dDV = 1;
% refractoryPeriod = 500;
% h = 100; % parameter - number of hidden layer units
% eta = 1/size(X,2)*100; % learning rate - parameter

% transform into easiness score
SS = SCORE;
SS(T==0) = -SCORE(T==0);
SS = SS * sign(mean(SS)); % increase DV => easier trial

% first break down X into 1 and 0 examples
% XX{1} = X(:, T==0);
% XX{2} = X(:, T==1);
% SS{1} = SCORE(T == 0)';
% SS{2} = SCORE(T == 1)';


% keep a list of all examples used and when they were used
lastUsed = -inf(size(SS,1), 1);

% initialize target DV to median of SS
DV_target = median(SS(:,1));




Y = T';
% % initialize network
% 
% h = [size(X,1);h(:);size(Y,1)];

% W = cell(L-1, 1);
% for l = 1:L-1
%     W{l} = randn(h(l),h(l+1));
%     W{l} = W{l} - mean(W{l}(:));
% end
% Z = cell(L);

W = model.W;
L = length(W)+1;

clear err

% preallocate accuracy
acc = nan(N_train,1);
dvt = nan(N_train,1);

for i = 1:N_train
    
    
    %     % alternate between +ve examples and -ve examples
    %     if mod(i,2) == 0
    %
    %         tt = 1;
    %         % t = 0 example on this trial
    %
    %     else
    %
    %         tt = 2;
    %         % t = 1 example on this trial
    %
    %     end
    %
    
    % find the closest stimulus to DV_target
    dist = abs( SS - DV_target );
    
    % exclude those used within refractory period
    i_refractory = lastUsed > (i - refractoryPeriod);
    dist(i_refractory ) = inf;
    
    % find unused example with lowest distance
    [~,idx] = min(dist);
    x = X(:,idx);
    t = T(idx);
    
    
    % store the example used
    dv_actual(i) = (SS(idx));
    i_actual(i) = idx;
    
    % label example as used on this trial
    lastUsed(idx) = i;
    
    % update network weights with this example
    Z{1} = x;
    %     forward
    for l = 2:L
        Z{l} = sigmoid(W{l-1}'*Z{l-1});
    end
    %     backward
    y = Z{L};
    E = t-y;
    mse = mean(dot(E(:),E(:)));
    for l = L-1:-1:1
        df = Z{l+1}.*(1-Z{l+1});
        dG = df.*E;
        dW = Z{l}*dG';
        W{l} = W{l}+eta*dW;
        E = W{l}*dG;
    end
    % yy(i) = y;
    
    % compute accuracy
    acc(i) = 1-abs(t-double(y>0.5));
    
    % update targetDV based on difference between target and actual
    % accuracy
    imin = max(i-windowSize, 1);
    imax = i;
    
    model.IMIN(i)= imin;
    model.IMAX(i)= imax;
    % update correspond DV_target - get harder if too accurate, get easier
    % if too easy
    DV_target = DV_target + dDV * (ACC_target - nanmean(acc(imin:imax)));
    acc_actual(i) = nanmean(acc(imin:imax));
    % keep DV_target within the range of scores for each option
    if DV_target > max(SS)
        DV_target = max(SS);
    end
    if DV_target < min(SS)
        DV_target = min(SS);
    end
    
    
    % store target DV for this trial
    dvt(i,:) = DV_target;
end

model.W = W;
model.trainAcc = acc;
model.dvt = dvt;
model.dv_actual = dv_actual;
model.i_actual = i_actual;
model.acc_actual = acc_actual;
