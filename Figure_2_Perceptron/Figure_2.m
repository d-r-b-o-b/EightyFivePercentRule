% Figure 2 from The Eighty Five Percent Rule for Optimal Learning
% Robert C. Wilson, Amitai Shenhav, Mark Straccia, Jonathan D. Cohen

% The Eighty Five Percent Rule applied to the Perceptron. (A) The relative 
% precision, $\beta / \beta_{max}$, as a function of training error rate 
% and training duration.  Training at the optimal error rate leads to the 
% fastest learning throughout. (B) The dynamics of learning agree well with 
% the theory.

clear

D = 100;

lambda = 2;
T = 1000;
N = 1000;
ER = [0.01:0.01:0.5];
i = 1;

for i = 1:N
    i
    [err, dd(:,:,i), w, e, th(:,:,i)] = run_perceptron_new_v3(D, T, lambda, ER);
    ERR(:,i) = nanmean(err);
end

AZred = [171,5,32]/256;
AZblue = [12,35,75]/256;

figure(1); clf; 
set(gcf ,'position', [611   356   700   300])
ax(1) = easy_gridOfEqualFigures([0.2 0.12], [0.12 0.47])
ax(2) = easy_gridOfEqualFigures([0.2 0.12], [0.7 0.12])


axes(ax(1)); hold on;
M = nanmean(1./tan(th),3)*sqrt(D);
imagesc(ER, [1:T], M/max(M(:)))
[c,h] = contour(ER, [1:T], M/max(M(:)),10);
set(h, 'color', 'k')
set(gca,'clim', [0 1])

hold on;
shading flat
c =colorbar();
set(c, 'tickdir', 'out')

text(0.1587, 1050, 'ER*', 'horizontalalignment', 'center', 'fontsize', 20)
plot([1 1]*0.1587, [0 1]*T,'k--', 'linewidth', 1)
set(ax(1), 'xtick', [0:0.1:0.5], ...
    'ydir', 'normal', ...
    'tickdir', 'out', 'box', 'off');
xlabel('error rate, ER')
ylabel('trial number')
xlim([0.0 0.5])



axes(ax(2)); hold on; % dynamics ------------------------------------------
tt = [1:T];
ii = [ 6 16 36 ];

FF = sqrt((D)/2+4);

Y = nanmean(1./tan(th(:,ii,:)),3);
Ys = nanstd(1./tan(th(:,ii,:)),[],3)/sqrt(size(th,3));
dum = nanmean(1./tan(th),3);
l1 = plot(tt, Y/max(dum(:)));
idx = 16;
Finv = -erfinv(2*ER(idx) - 1)*sqrt(2);
beta0 = nanmean(1./tan(th(1,idx,:))*FF,3);
beta_max = max(sqrt( beta0^2 + 2*Finv*exp(-Finv^2/2)/sqrt(2*pi)* (tt-1)));
clear txt
for i =1:length(ii)
    Finv = -erfinv(2*ER(ii(i)) - 1)*sqrt(2);
    
    beta0 = nanmean(1./tan(th(1,ii(i),:))*FF,3);
    beta = sqrt( beta0^2 + 2*Finv*exp(-Finv^2/2)/sqrt(2*pi)* (tt-1));
    beta = beta / beta_max;
    
    l2(i) = plot(tt, beta);
    txt(i) = text(T, beta(end), [' ER = ' num2str(ER(ii(i)))], 'fontsize', 14)
    
end
ylim([0 1])

L = length(l1);
for i = 1:length(l1)
    f1 = (i-1)/(L-1);
    f2 = 1-f1;
    set([l1(i)] , 'color', (AZred*f1 + AZblue*f2)*0.5 + 0.5)
    set([l2(i) txt(i)], 'color', AZred*f1 + AZblue*f2)
end
set(l1, 'marker', 'none', 'linestyle', '--', 'markersize', 30)
xlim([0 T])
set(ax, 'tickdir', 'out')

ylabel('relative precision, \beta / \beta_{max}')
xlabel('trial number')
set(ax, 'fontsize', 18)
leg = legend([l2(3) l1(3) ], {'theory' 'simulation'});
set(leg, 'position', [0.7371    0.2183    0.1629    0.1417]);

addABCs(ax, [-0.1 0.12], 32)

saveFigurePdf(gcf, '~/Desktop/pc80_perceptronResults')

