function y = sigmoid(x)
% Sigmod function
% Written by Mo Chen (sth4nth@gmail.com).
y = exp(-log1pexp(-x));

function y = log1pexp(x)
% Accurately compute y = log(1+exp(x))
% reference: Accurately Computing log(1-exp(|a|)) Martin Machler
seed = 33.3;
y = x;
idx = x<seed;
y(idx) = log1p(exp(x(idx)));