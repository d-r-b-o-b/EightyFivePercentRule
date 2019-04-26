% Figure 5 from The Eighty Five Percent Rule for Optimal Learning
% Robert C. Wilson, Amitai Shenhav, Mark Straccia, Jonathan D. Cohen

% Figure 5 - Proposed relationship between the Eighty Five Percent Rule and Flow. (A)
% Original model of flow as a state that is achieved when skill and
% challenge are well balanced. Normalized learning rate, $\partial ER /
% \partial\beta$, (B)  and accuracy (C) as a function of skill and
% challenge suggests that flow corresponds to high learning and accuracy, 
% boredom corresponds to low learning and high accuracy, while anxiety is 
% associated with low learning and low accuracy.

clear
db = 0.1;
dd = 0.1;

d = logspace(-1,1,100);
b = logspace(-1,1,100);

[B,D] = meshgrid(b,d);

LR = exp(-(B./D).^2/2)./D/sqrt(pi*2);
ER = 0.5*(1-erf(B./D/sqrt(2)));
for i = 1:size(LR,2)
    LR_norm(:,i) = LR(:,i)/max(LR(:,i));
end


figure(1); clf;
set(gcf, 'position', [560   657   850   300], 'color', 'w');

ax = easy_gridOfEqualFigures([0.19 0.12], [0.09 0.12 0.12 0.03]);
axes(ax(1)); hold on;
set(ax(1), 'units', 'points');
pp = get(ax(1), 'position');
ang = atan(pp(4)/pp(3));
set(ax(1), 'units', 'normalized');

f = 0.7;
plot([10^(-f) 10^1], [10^(-1) 10^(f)],'k-')
plot([10^(-1) 10^f], [10^(-f) 10^(1)],'k-')
t = text(1, 1, 'flow');
t(2) = text(0.3, 3, 'anxiety');
t(3) = text(3, 0.3, 'boredom');
set(t(1), 'rotation', 360*ang/2/pi)
set(t, 'fontsize', 20, 'horizontalAlignment', 'center')
ttl = title('flow model');

axes(ax(2));
imagesc(b,d,LR_norm)
ttl(2) = title('learning gradient');
axes(ax(3));
imagesc(b,d,1-ER)
ttl(3) = title('accuracy')

for i = 1:length(ax)
    axes(ax(i));
    
    hold on;
    if i >1
        plot([0.01 10], [0.01 10],'k--')
        xl(i) = xlabel('skill level, \beta');
        yl(i) = ylabel('challenge level, 1/|\Delta|');
    else
        xl(i) = xlabel('skill level');
        yl(i) = ylabel('challenge level');
    end
    shading flat
    xlim([0.1 10]);
    ylim([0.1 10]);
end
set(ax, 'ydir', 'normal', 'yscale', 'log', 'xscale', 'log', ...
    'tickdir', 'out', 'fontsize', 16, 'box', 'on')

set(ax(1), 'xticklabel', {'low' 'mid' 'high'}, 'yticklabel', {'low' 'mid' 'high'})
set(ttl, 'fontsize', 20, 'fontweight', 'normal')

set([xl yl], 'fontsize', 18)

addABCs(ax, [-0.07 0.13], 36)
saveFigurePdf(gcf, '~/Desktop/epc_flow')



