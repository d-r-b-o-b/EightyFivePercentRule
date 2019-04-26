function [X, T, IM] = makeData_twoNumbers(group1, group2, imgs, labels)


ind = ismember(labels, group1) | ismember(labels, group2);

IM = imgs(:,:,ind);
LB = labels(ind);


% convert images into vector form
X = reshape(IM, [size(IM,1)*size(IM,2) size(IM,3)]);
T = ismember(LB, group2);
