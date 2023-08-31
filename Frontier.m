format shortG;

Head = table2array(Book1);
Header=strcat(Head,".L.csv");

n=100;


full_price = zeros(n,210);

return_ratelist = zeros(n,209);


for i=1:100%Asset Index
    rate = [];

    A = importdata(Header(i));
    full_price(i,:) = A.data(1:210,5)';


for n =1:209%Time index
    
    rate = [rate full_price(i,n+1)/full_price(i,n)];
    
end
    return_ratelist(i,:) = rate;

end

mu = zeros(100);
cor = cov(return_ratelist');

for i =1:100
mu(i) = mean(return_ratelist(i,:));
end


% Assuming your returns matrix is named 'returns' with size 100x209
returns = return_ratelist;
% Step 1: Calculate mean returns and covariance matrix
mean_returns = mean(returns, 2);
cov_matrix = cov(returns');

% Step 2: Generate portfolio weights
num_assets = size(returns, 1);
num_portfolios = 10000; % You can adjust this number

rng(42); % For reproducibility
portfolio_weights = rand(num_assets, num_portfolios);
portfolio_weights = portfolio_weights ./ sum(portfolio_weights);

% Step 3: Calculate portfolio mean return and standard deviation
portfolio_mean_returns = portfolio_weights' * mean_returns;
portfolio_std_devs = sqrt(diag(portfolio_weights' * cov_matrix * portfolio_weights));

% Step 4: Plot the efficient frontier
figure;
scatter(portfolio_std_devs, portfolio_mean_returns, 10, 'filled');
xlabel('Portfolio Risk (Standard Deviation)');
ylabel('Portfolio Return');
title('Efficient Frontier');
grid on;

% Step 5: Find optimal portfolios on the efficient frontier
risk_free_rate = 0.05; % You can change this to your desired risk-free rate
sharpe_ratios = (portfolio_mean_returns - risk_free_rate) ./ portfolio_std_devs;

[max_sharpe_ratio, max_sharpe_idx] = max(sharpe_ratios);
min_volatility = min(portfolio_std_devs);
max_return = max(portfolio_mean_returns);

hold on;
scatter(portfolio_std_devs(max_sharpe_idx), portfolio_mean_returns(max_sharpe_idx), 50, 'r', 'filled');
scatter(min_volatility, max_return, 50, 'g', 'filled');
legend('Portfolios', 'Max Sharpe Ratio', 'Min Volatility');
hold off;

% Calculate portfolio mean return and standard deviation
portfolio_mean_returns = portfolio_weights' * mean_returns;
portfolio_std_devs = sqrt(diag(portfolio_weights' * cov_matrix * portfolio_weights));

% Create a portfolio object for efficient frontier plotting
port = Portfolio('AssetMean', portfolio_mean_returns, 'AssetCovar', cov_matrix);

% Calculate efficient frontier
port = setDefaultConstraints(port);
frontier_weights = plotFrontier(port, num_portfolios);

% Plot the efficient frontier using plotFrontier
figure;
plotFrontier(port, num_portfolios);
title('Efficient Frontier');
grid on;

% Mark optimal portfolios
hold on;
scatter(portfolio_std_devs(max_sharpe_idx), portfolio_mean_returns(max_sharpe_idx), 50, 'r', 'filled');
scatter(min_volatility, max_return, 50, 'g', 'filled');
legend('Efficient Frontier', 'Max Sharpe Ratio', 'Min Volatility');
hold off;

