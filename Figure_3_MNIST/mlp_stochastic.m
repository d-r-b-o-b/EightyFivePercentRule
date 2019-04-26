function [model, mse] = mlp_stochastic(X, Y, h)
% Multilayer perceptron
% Input:
%   X: d x n data matrix
%   Y: p x n response matrix
%   h: L x 1 vector specify number of hidden nodes in each layer l
% Ouput:
%   model: model structure
%   mse: mean square error
% Written by Mo Chen (sth4nth@gmail.com).
h = [size(X,1);h(:);size(Y,1)];
L = numel(h);
W = cell(L-1);
for l = 1:L-1
    W{l} = randn(h(l),h(l+1));
end
Z = cell(L);

eta = 1/size(X,2);
maxiter = size(X,2);
mse = zeros(1,maxiter);
for rep = 1:100
    rep
    for iter = 1:maxiter
        Z{1} = X(:,iter);
        %     forward
        for l = 2:L
            Z{l} = sigmoid(W{l-1}'*Z{l-1});
        end
        %     backward
        E = Y(iter)-Z{L};
        mse(iter) = mean(dot(E(:),E(:)));
        for l = L-1:-1:1
            df = Z{l+1}.*(1-Z{l+1});
            dG = df.*E;
            dW = Z{l}*dG';
            W{l} = W{l}+eta*dW;
            E = W{l}*dG;
        end
    end
end
mse = mse(1:iter);
model.W = W;