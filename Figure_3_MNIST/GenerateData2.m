clear

% To run this file, you need to download the MNIST dataset (available at
% http://yann.lecun.com/exdb/mnist/index.html) and place it in the folder

% select task by commenting out the one you don't want ...
task = 'parity'; 
% task = 'magnitude';


imgFile         = ['train-images-idx3-ubyte'];
labelFile       = ['train-labels-idx1-ubyte'];
test_imgFile    = ['t10k-images-idx3-ubyte'];
test_labelFile  = ['t10k-labels-idx1-ubyte'];

[imgs labels] = readMNIST(imgFile, labelFile, 60000, 0);
[test_imgs test_labels] = readMNIST(test_imgFile, test_labelFile, 10000, 0);


%% generate two classes
switch task
    
    case 'parity'
    
        [X, T, IM] = makeData_twoGroups([0 2 4 6 8], [1 3 5 7 9], imgs, labels);
        [testX, testT, testIM] = makeData_twoGroups([0 2 4 6 8], [1 3 5 7 9], test_imgs, test_labels);
    
    case 'magnitude'
        
        [X, T, IM] = makeData_twoGroups([0 1 2 3 4], [5 6 7 8 9], imgs, labels);
        [testX, testT, testIM] = makeData_twoGroups([0 1 2 3 4], [5 6 7 8 9], test_imgs, test_labels);

end

%% de-mean images
for i = 1:size(X,2)
    X(:,i) = X(:,i) - mean(X(:,i));
end
for i = 1:size(testX,2)
    testX(:,i) = testX(:,i) - mean(testX(:,i));
end

%% train the teacher network
Nrep = 10;
[teacher, mse, trainACC] = mlp_stochastic_varyNreps(X, T', [50], Nrep, inf, 1/10);

%% compute the difficulty of each training example according to the teacher
[Y, SCORE] = mlpPred(teacher, X);
AA = abs(T - double((Y<0.5))');
teacherTrainACC = mean(AA)
teacherTrainACC0 = mean(AA(T==0))
teacherTrainACC1 = mean(AA(T==1))



%% train at fixed accuracy
% load DEEP_092718_358PM % magnitude
% load DEEP_092718_147PM % parity

% initialize network and test the bias
for rep = 101:1000
    
    
    rep
    % make sure network does not have initial bais
    % bias will be less than 0.1 about 10% of the time
    bias = inf;
    while bias > 0.1
        h = [50];
        Y = T';
        h = [size(X,1);h(:);size(Y,1)];
        L = numel(h);
        W = cell(L-1);
        for l = 1:L-1
            W{l} = randn(h(l),h(l+1));
        end
        model.W = W;
        [Y, S] = mlpPred(model, X);
        initACC = mean(abs(T - double((Y<0.5))'));
        ACC = abs(T - double((Y<0.5))');
        A0 = mean(ACC(T==0));
        A1 = mean(ACC(T==1));
        
        bias = abs(A0-A1);
    end
    init.A0(rep) = A0;
    init.A1(rep) = A1;
    modelInit = model;
    
    % pretrain model
    R = randperm(size(X, 2), 500); % random selection of samples to pretrain on
    [modelInit, mse] = mlp_stochastic_varyNrepsModel(modelInit, X(:,R), T(R)', 50, 1, 500, 1/10);
    
    % get pretrain accuracy 
    [Ypre] = mlpPred(modelInit, X);
    AA = abs(T - double((Ypre<0.5))');
    pret.trainACC(rep) = mean(AA);
    pret.trainACC0(rep) = mean(AA(T==0));
    pret.trainACC1(rep) = mean(AA(T==1));
    
    [Ypre] = mlpPred(modelInit, testX);
    AA = abs(testT - double((Ypre<0.5))');
    pret.testACC(rep) = mean(AA);
    pret.testCC0(rep) = mean(AA(testT==0));
    pret.testACC1(rep) = mean(AA(testT==1));
    
    
    % %% train at fixed accuracy
    ACC_target = [0.65:0.05:0.95];
    for count = 1:length(ACC_target)
        windowSize = 50;
        N_train = 5000; % parameter - number of training trials
        
        dDV = 1;
        refractoryPeriod = 50;
        h = 100;
        eta = 1/10;%1/size(X,2)*100; % learning rate - parameter
        
        model = train_fixedAccuracyOneDV_v1(modelInit, X, T, SCORE, eta, ACC_target(count), windowSize, N_train, dDV, refractoryPeriod);
        
        % get test accuracy
        [testY, testS] = mlpPred(model, testX);
        AA = abs(testT - double((testY<0.5))');
        testACC(count, rep) = mean(AA);
        testACC0(count, rep) = mean(AA(testT==0));
        testACC1(count, rep) = mean(AA(testT==1));
        
        
        AA = model.trainAcc;
        trainACC(count, rep) = nanmean(AA);
        trainACC0(count, rep) = nanmean(AA(end/2:end));
        
    end
    
end

% save result
save(['results3_' task], 'trainACC', 'testACC')

