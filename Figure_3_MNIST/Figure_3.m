% Code to generate Figure 2 from:
%
% Wilson, R. C., Shenhav, A., Straccia, M., & Cohen, J. D. (in press). 
% The Eighty Five Percent Rule for Optimal Learning. Nature Communications
%
% Figure 2:
% The Eighty Five Percent Rule applied to the Perceptron. {\bf a} The 
% relative precision, $\beta / \beta_{max}$, as a function of training 
% error rate and training duration.  Training at the optimal error rate 
% leads to the fastest learning throughout. {\bf b} The dynamics of 
% learning agree well with the theory.
%
% Robert Wilson 2019

% NOTE: To run simulations use GenerateData.m and GenerateData2.m

clear


%% colors
global AZred AZblue AZcactus AZsky AZriver AZsand AZmesa AZbrick

AZred = [171,5,32]/256;
AZblue = [12,35,75]/256;
AZcactus = [92, 135, 39]/256;
AZsky = [132, 210, 226]/256;
AZriver = [7, 104, 115]/256;
AZsand = [241, 158, 31]/256;
AZmesa = [183, 85, 39]/256;
AZbrick = [74, 48, 39]/256;

% lighten blue
AZblue = 1*AZblue + 0*[1 1 1];



% new
L1 = load('example_parity');
L2 = load('example_magnitude');
%

figure(1); clf; 
set(gcf, 'Position', [267   487   600   300]);
ax = easy_gridOfEqualFigures([0.2 0.1], [0.12 0.15 0.03]);

% PARITY
axes(ax(1)); hold on;
trainACC = L1.trainACC;
testACC = L1.testACC;
l = plot(1-trainACC', testACC','.', 'markersize', 30);
for i = 1:length(l)
    f = (i-1) / (length(l)-1);
    set(l(i), 'color', (f*AZred+(1-f)*AZblue)*1 + [1 1 1]*0)
end
plot(1-nanmean(trainACC,2), mean(testACC,2), 'ko-', 'markersize', 12, ...
    'markerfacecolor', 'w', 'markeredgecolor', 'k')
plot((0.1587)*[ 1 1], [0.5 1], 'k--')
xlabel('training error rate')
ylabel('test accuracy')
t = title('Parity Task', 'fontweight', 'normal');

% fraction best
[~,ind] = max(testACC);
mean(ind == 4) % fraction of times training at 85% is best


% MAGNITUDE
axes(ax(2)); hold on;
trainACC = L2.trainACC;
testACC = L2.testACC;

l = plot(1-trainACC', testACC','.', 'markersize', 30);
for i = 1:length(l)
    f = (i-1) / (length(l)-1);
    set(l(i), 'color', (f*AZred+(1-f)*AZblue)*1 + [1 1 1]*0)
end
plot(1-nanmean(trainACC,2), mean(testACC,2), 'ko-', 'markersize', 12, ...
    'markerfacecolor', 'w', 'markeredgecolor', 'k')
plot((0.1587)*[ 1 1], [0.5 1], 'k--')
xlabel('training error rate')
ylabel('test accuracy')
t(2) = title('Magnitude Task', 'fontweight', 'normal');





set(ax, 'fontsize', 18, 'ytick', [0.6:0.1:1], ...
    'xtick', [0 0.1 (0.1587) 0.2 0.3], ...
    'xticklabel', {0 0.1 'ER*' 0.2 0.3}, 'tickdir', 'out', ...
    'ylim', [0.6 0.9], 'xlim', [0.04 0.31])
set(t, 'fontsize', 24)
addABCs(ax, [-0.09 0.1], 32, 'ab')
saveFigurePdf(gcf, '~/Desktop/Figure_3')
saveFigureEps(gcf, '~/Desktop/Figure_3')

[~,ind] = max(testACC);
mean(ind == 4) % fraction of times training at 85% is best
mean(ind == 3) % fraction of times training at 80% is best

