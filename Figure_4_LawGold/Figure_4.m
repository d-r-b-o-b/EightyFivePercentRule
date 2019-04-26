clear

global AZred AZblue AZcactus AZsky AZriver AZsand AZmesa AZbrick

AZred = [171,5,32]/256;
AZblue = [12,35,75]/256;
AZcactus = [92, 135, 39]/256;
AZsky = [132, 210, 226]/256;
AZriver = [7, 104, 115]/256;
AZsand = [241, 158, 31]/256;
AZmesa = [183, 85, 39]/256;
AZbrick = [74, 48, 39]/256;



N_MT        = 7200;     % number of MT neurons
N_acc       = 11;       % number of training accuracies
N_rep       = 5;        % number of repetitions
alpha       = 7e-7;     % learning rate
w_amp       = 0.02;     % normalization parameter for weights
sigma_noise = 8;        % irreducible decision noise
offset      = 90;       % +/- offset are angles to be discriminated between

% vectorize across N_acc
N_vec = N_acc;

for REPEAT = 1:100
    REPEAT
    % initialize MT neuron parameters - same network for each replication
    MT = vec_initializeMTnetwork_v1(N_MT, N_vec);
    
    % initialize weights - same initial conditions for each network
    w = vec_initializeWeights_v1(N_MT, N_vec, w_amp);
    
    % compute activity of these networks for a particular theta but different
    % coherences for each of the N_vecs
    tic
    trialMax = 500;
    
    COH_BETA = log(9*ones(1,N_vec));
    COH = 1 ./ (1 + exp(-COH_BETA));
    dCOH = 0.1;
    
    A_target = [linspace(0.5,1,N_acc)];
    A = 0.5;
    
    
    
    
    for trial = 1:trialMax
        dir = 2*(rand<0.5)-1; % left -1, right +1
        theta = dir * offset;
        
        T = 1;
        
        % compute activity
        x = vec_computeActivity_v1(theta, COH, T, MT, N_MT, N_vec);
        
        % make decision
        [y, C, r] = vec_makeDecision_v1(x, w, N_vec, sigma_noise, dir);
        
        % store results
        ACC(trial,:) = r;
        YYY(trial,:) = y;
        
        % make a prediction
        if trial > 50
            tAcc_width = 300;
            
            L = min(trial, tAcc_width);
            yy = ACC(trial-L+1:trial,:);
            xx = abs(YYY(trial-L+1:trial,:));
            
            for i = 1:N_vec
                if (mean(yy(:,i)) == 1) | (mean(yy(:,i)) == 0)
                    beta(i) = 10000; % hack to speed up (hopefully!)
                else
                    beta(i) = glmfit(xx(:,i), yy(:,i), 'binomial', 'constant', 'off');
                end
            end
            
            Er = 1 ./ (1 + exp(-beta .* abs(y)));
            
        else
            Er = repmat(0.5, [1 N_vec]);
        end
        
        
        
        % update weights
        w = vec_updateWeights_v1(w, C, r, Er, x, alpha, N_MT, w_amp);
        
        
        
        
        % update coherences for next trial        
        if trial > 50
            tAcc_width = 300;
            
            L = min(trial, tAcc_width);
            A = mean(ACC(trial-L+1:trial,:));
            
            COH_BETA = COH_BETA + dCOH * (A_target- A);
            COH = 1 ./ (1 + exp(-COH_BETA));
        end
        
        
        
    end
    toc
    
    
    %% compute beta for each network
    tic
    COH = logspace(-3,0,20);
    nRep = 100;
    count = 1;
    for i = 1:length(COH)
        for j = 1:nRep
            
            dir = 2*(rand<0.5)-1; % left -1, right +1
            theta = dir * offset;
            
            x = vec_computeActivity_v1(theta, repmat(COH(i), [1 N_vec]), T, MT, N_MT, N_vec);
            [y, C, r] = vec_makeDecision_v1(x, w, N_vec, sigma_noise, dir);
            RR(:,count) = r;
            CO(:,count) = COH(i);
            RRR(:,i,j) = r;
            count = count + 1;
        end
    end
    
    %
    for i = 1:N_vec
        beta2(i,REPEAT) = glmfit(CO, RR(i,:)', 'binomial', 'constant', 'off');
        REWARD(i,:,REPEAT) = nanmean(RRR(i,:,:),3);
    end
    toc
    accuracy(:,REPEAT) = mean(ACC);
    
end

%% plot results
ER = 0.01:0.01:0.4;
Finv = -erfinv(2*ER - 1)*sqrt(2);


beta0 = 0;
tt = 500;
beta_max = (sqrt( beta0^2 + 2*Finv.*exp(-Finv.^2/2)/sqrt(2*pi)* (tt-1)));


figure(1); clf;
set(gcf ,'position', [611   356   700   300])
ax = easy_gridOfEqualFigures([0.2 0.05], [0.1 0.15 0.03]);
axes(ax(1)); hold on;
M = nanmean(beta2,2);
S = nanstd(beta2,[],2);%/sqrt(size(beta2,2));
Sa = nanstd(1-accuracy, [], 2);
l1 = plot(1-accuracy, beta2,'.', 'markersize', 10, 'color', [1 1 1]*0.75);
l2 = plot(ER, beta_max/max(beta_max)*max(M), '-','color', AZblue, 'linewidth', 3);
e1 = errorbar(1-nanmean(accuracy,2), M, S,'.', 'markersize', 30);
e2 = herrorbar(1-nanmean(accuracy,2), M, Sa);
set([e1 e2'], 'color', AZred, 'linewidth', 1)
set(e2(2), 'linestyle', 'none')
leg =legend([l2 e1(1) l1'], {'theory' 'simulation (average)' 'simulation (all)'}, 'fontsize', 12);

xlabel('training error rate')
ylabel('precision, \beta')
yl = get(gca, 'ylim');
plot(0.1587*[1 1], yl,'k--')
text(0.1587, 13.25, 'ER*', 'horizontalalignment', 'center' ,'fontsize', 18)
xlim([0 0.4])
set(ax(1), 'fontsize',18)
set(leg, 'Position', [0.1343    0.2283    0.2114    0.1617]);

clear pc
axes(ax(2)); hold on;
COH2 = [0:0.01:1];
for i = 1:size(beta2,1)
    for j = 1:size(beta2,2)
        pc(i,:,j) = 1./(1 + exp(-beta2(i,j)*COH2));
    end
end
ER_emp = round((1-nanmean(accuracy,2))*100)/100;
M = nanmean(pc,3);

plot(COH2*100, M(7,:), 'linewidth', 3, 'color', AZsand)
plot(COH2*100, M(4,:), 'linewidth', 3, 'color', (AZred))
plot(COH2*100, M(10,:), 'linewidth', 3, 'color', (AZblue))
set(gca, 'xscale', 'log', 'xticklabel', [1 10 100])

legend({['ER = ' num2str(ER_emp(7))] ['ER = ' num2str(ER_emp(5))] ['ER = ' num2str(ER_emp(9))]}, ...
    'location', 'northwest', 'fontsize', 12)
xlabel('coherence %')
ylabel('accuracy')

set(ax, 'fontsize', 18, 'tickdir', 'out')



addABCs(ax, [-0.07 0.05], 32)
saveFigurePdf(gcf, '~/Desktop/LawAndGold')
