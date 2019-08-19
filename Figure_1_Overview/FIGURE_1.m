% Figure 1 from The Eighty Five Percent Rule for Optimal Learning
% Robert C. Wilson, Amitai Shenhav, Mark Straccia, Jonathan D. Cohen

% Figure 1 - Illustration of the model. (A) Distributions over decision variable $h$ 
% given a particular difficulty, $\Delta$ = 16, with lower precision before 
% learning and higher precision after learning.  The shaded regions 
% corresponds to the error rate -- the probability of making an incorrect 
% response at each difficulty.  (B) The error rate as a function of 
% difficulty before and after learning.  (C) The derivative that determines 
% the rate of learning as a function of difficulty before and after 
% learning showing that the optimal difficulty for learning is lower after 
% learning than before.  (D) The same derivative as in (C) re-plotted as a 
% function of error rate showing that the optimal error rate (at 15.87\% or 
% approximately 85\% accuracy) is the same both before and after learning.

clear


AZred = [171,5,32]/256;
AZblue = [12,35,75]/256;


clear F xl yl y  l
x = [-3:0.01:5]*16;
x = [-30:0.01:80];
ERstar = 1/2*(1-erf(1/sqrt(2)));
Delta = [0:0.01:50];
sigma = [1 0.5]*16;
mu = [1 1]*16;
for i = 1:length(sigma)
    y(i,:) = 1 / sqrt(2*pi)/sigma(i) * exp(-1/2/sigma(i)^2*(x-mu(i)).^2);
    F(i,:) = 1/2*(1+erf(Delta/sqrt(2)/sigma(i)));
    dERdB(i,:) = -Delta / sqrt(2*pi) .* exp(-(Delta./sigma(i)).^2/2);
end

figure(1); clf;

set(gcf, 'position', [560   200   700   500], 'color', 'w')
ax = easy_gridOfEqualFigures([0.12 0.21 0.07], [0.14 0.18 0.03]);


for count = 1:2
    axes(ax(1)); hold on;
    ind = x <= 0;
    top = y(count,ind);
    bot = 0*x(ind);
    
    
    k = x(ind);
    
    yy = [top bot(end:-1:1)];
    xx = [k   k(end:-1:1) ];
    
    
    
    f(count) = fill(xx, yy, 'r');
    l(count) = plot(x,y(count,:));
    plot([0 0], [0 0.06], 'k-')
    xl(count) = xlabel('decision variable, h');
    yl(count) = ylabel('probability of h');
end
plot(mu(1)*[1 1], [0 0.057], 'k--')
text(mu(1), 0.06, '\Delta', 'horizontalAlignment', 'center', 'fontsize', 20)
ylim([0 0.06])
set(ax(1), 'ytick', [], 'xtick', [-75:25:75])


set(f(1), 'facecolor', AZblue*0.25+0.75, 'linestyle', 'none', 'facealpha', 1)
set(f(2), 'facecolor', AZred*0.5+0.5, 'linestyle', 'none', 'facealpha', 1)
set(l, 'linewidth', 3)
set(l(1), 'color', AZblue)
set(l(2), 'color', AZred)
set(ax(1:2), 'xlim', [min(x) max(x)])
legend(l,{'before' 'after'},2)
axes(ax(2));
l = plot( Delta, 1-F);
set(l(1), 'color', AZblue)
set(l(2), 'color', AZred)
set(l, 'linewidth', 3)
xl(end+1) = xlabel('difficulty, \Delta');
yl(end+1) = ylabel('error rate, ER');
ylim([0.5 1.01]-0.5)
xlim([min(Delta) max(Delta)])




axes(ax(3));
l = plot(Delta, -dERdB);
set(l(1), 'color', AZblue)
set(l(2), 'color', AZred)
set(l, 'linewidth', 3)
yl(end+1) = ylabel({'learning rate' 'dER/d\beta'});
xl(end+1) = xlabel('difficulty, \Delta');
xlim([min(Delta) max(Delta)])


axes(ax(4)); hold on;
l = plot(1-F', -dERdB');
set(l(1), 'color', AZblue)
set(l(2), 'color', AZred)
set(l, 'linewidth', 3)
plot([ERstar ERstar], [0 4], 'k--')
yl(end+1) = ylabel({'learning rate' 'dER/d\beta'});
xl(end+1) = xlabel('error rate, ER');

xlim([0.5 1]-0.5)
set(ax(2), 'ytick', [0 0.25 0.5])
set(ax(4), 'xtick', [0 ERstar 0.5])

set(ax(2:3), 'xtick', [0:25:50])

set(ax, 'tickdir','out', 'fontsize', 20, 'box', 'off')
addABCs(ax, [-0.11 0.07], 32, 'abcd')
saveFigurePdf(gcf, '~/Desktop/Figure_1')
saveFigureEps(gcf, '~/Desktop/Figure_1')
