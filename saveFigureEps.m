function saveFigureEps(figHandle, savename)

% saveFigurePdf(figHandle, savename)

figure(figHandle)
set(gcf, 'windowstyle', 'normal')
set(gcf, 'paperpositionmode', 'auto')

pp = get(gcf, 'paperposition');
wp = pp(3);
hp = pp(4);
set(gcf, 'papersize', [wp hp])
% saveas(gcf, savename, 'pdf')
print(gcf, '-depsc', '-opengl', savename);

