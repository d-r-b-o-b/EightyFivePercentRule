function saveFigurePng(figHandle, savename)

% saveFigurePdf(figHandle, savename)

set(figHandle, 'windowstyle', 'normal')
set(figHandle, 'paperpositionmode', 'auto')

pp = get(figHandle, 'paperposition');
wp = pp(3);
hp = pp(4);
set(figHandle, 'papersize', [wp hp])
% saveas(gcf, savename, 'pdf')

print(savename, '-dpng')
