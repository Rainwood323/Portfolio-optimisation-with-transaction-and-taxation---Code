%Manually import all elements in Book1.csv to start.

format shortG;

Head = table2array(Book1);
Header=strcat(Head,".L.csv");

%1.Basic data index
Budget = 72000;
beta = 6;
fee_rate = 0.006;
n = 100;
TotalMoney =72000;
l=0.2;
K=12;

x_hold = zeros(n,1);
taxs = 0;
Hold = [];
Money = [];
TC_cost = [];

Invest0 = [];
EndInvest = [];
Final_invest = [];
Hold_invest = [];
profit1 = [];    


%Start position setting:
Start_position = 105;

Mid = 156;

Mid_plus = 157;

End = 208;

End_plus = 209;

Rg_return=104;





%Rolling Setting:
S1=Rg_return/4;
S1_n=2;
S2=Rg_return/8;
S2_n=4;
SM1=Rg_return/2;
SM1_n=1;

%Basic asset data
return_rate = zeros(n,Rg_return);
benchmark_rate = zeros(Rg_return);

Old_price = zeros(n,1);
Start_price = zeros(n,1);
End_price = zeros(n,1);
price_l = zeros(n,Mid);
Price_list=[];
unique = [];

test_result = [];



Strategy = [];

file_name = zeros(n);

for i = 1:n
    file_name(i) = strcat(Header(i),".csv");
end



%循环启动
for ss = 1:S2_n
    Season = S2;
    
    %2.Calculate the core data
    for m = 1:n
        m
        A_data = importdata(Header(m));
        B_return = [];
        C_Start_price = A_data.data(Mid_plus+(ss-1)*Season,5);
        D = A_data.data(Start_position:End_plus,5);
        F_endprice = A_data.data(Mid_plus+ss*Season,5);
        Price_list = [Price_list A_data.data(Start_position:End_plus,5)];

        for i = 1:Rg_return
            B_return = [B_return,D(i+1,1)/D(i,1)];
        end

        return_rate(m,1:Rg_return) = B_return;
        Start_price(m,1)=C_Start_price;
        End_price(m,1)=F_endprice;
    
        clear A_data;
        clear B_return;
        clear C_Start_price;
        clear D;
        clear F_endprice;
    end
    
    Price_test = Price_list(1+Rg_return/2:Rg_return,1:n)';
    return_rate_model = return_rate(:,(1+(ss-1)*Season):(Rg_return/2+(ss-1)*Season));

    mu_model = zeros(n,1);
    sig_model = zeros(n,1);
    

    for i = 1:n
        mu_model(i) = mean(return_rate_model(i,:));
        sig_model(i) = std(return_rate_model(i,:));
    end

    
    %3.Index test calculate
    H_benchmark = importdata("A_HUKX.L.csv");
    I_bench = H_benchmark.data(Start_position:End_plus,5);
    bench_return = [];
    
    for i = 1:Rg_return
        bench_return=[bench_return,I_bench(i+1,1)/I_bench(i,1)];
    end
    bench_model = bench_return(1+(ss-1)*Season:Rg_return/2+(ss-1)*Season);
    bench_test = bench_return(1+Rg_return/2:Rg_return);
       
    
    %setup for benchmark
    b_test = zeros(Rg_return,1);
    bk_test = zeros(Rg_return,1);
    
    for i = 1:(Rg_return/2)
        b_test(i) = bench_model(i);
    end
    
    
    for i =1:(Rg_return/2)
        b_select = [];
        for j = 1:(Rg_return/2)
            b_k = max(b_test(i)-b_test(j),0);%For i, find [bi-bj]+
            b_select=[b_select b_k];
        end
       
        bk_test(i) = (1/(Rg_return/2))*sum(b_select);
        clear b_select;
    end
    
    cov_asset = cov(return_rate_model');
    
    mu_c_model = zeros(n,1);
    for i = 1:n
        mu_c_model(i) = (mu_model(i))^(Season);
    end
    
    %4.CVX build
    X = [], ExpRet = [],M=100000;
    % x(i) is the amount of shares that buy for stock i.
    % s(n*104) is the variable
        
       cvx_begin
        variable buy(n) nonnegative;
        variable sell(n) nonnegative;
        variable s(Rg_return/2,Rg_return/2);
        variable t(n) binary;
        variable p(n) binary;
        variable g(n) binary;
        maximize((mu_c_model'*((x_hold+buy-sell).*Start_price))-beta*sum(t)-Start_price'*buy*fee_rate);
        Budget >= (Start_price'*buy*(1+fee_rate)+beta*sum(t))-(Start_price'*sell);%Budget Constraint
        
        for k =1:(Rg_return/2)
            (1/(Rg_return))*sum(s(:,k))<= bk_test(k);
        end
        for j = 1:(Rg_return/2)
            for k =1:(Rg_return/2)
                sum(return_rate_model(:,j)'*((x_hold+buy-sell).*Start_price))+s(j,k)*(TotalMoney) >= b_test(k)*(TotalMoney);
                s(j,k) >=0 ;
            end          
        end
    
        for i = 1:n
            buy(i) <t(i)*M;   %Integer Constraint
            buy(i) >=0;
            sell(i) <g(i)*M;
            sell(i) >=0;
            (x_hold(i)+buy(i)-sell(i)) <p(i)*M;
            Start_price(i)*(x_hold(i)+buy(i)-sell(i)) <= TotalMoney*l;
            sell(i) >=0;
            x_hold(i) >= sell(i);
        end
        sum(p) <=K;
        %SSD Constraint  
    cvx_end

    

    x_hold = x_hold+buy-sell;
    Budget = Budget - (Start_price'*buy*(1+fee_rate)+beta*sum(t))-(Start_price'*sell*(taxs))+(Start_price'*sell);
    TotalMoney = End_price'*x_hold + Budget;
   
         unique=[unique sum(x_hold>0.0001)];
         TC_cost=[TC_cost beta*sum(t)+Start_price'*buy*fee_rate];

%Get the final build
 Strategy = [Strategy buy sell];
 Hold = [Hold x_hold];
 Money = [Money Budget];
 
 Invest0 = [Invest0 Start_price]; 
 EndInvest = [EndInvest End_price];
 Hold_invest = [Hold_invest x_hold'*Start_price];
 Final_invest = [Final_invest x_hold'*End_price];

 test_result = [test_result (x_hold'*Price_test(:,1+(ss-1)*Season:ss*Season)+Budget)];


end

bench_money = Invest0(1:n,1)'*Hold(1:n,1)+Money(1);
bench_result = [];

for i = 1: Rg_return/2
    bench_result = [bench_result bench_money];
    bench_money= bench_money*bench_test(i);
end

test_return = [];
for i=1:51
test_return = [test_return, test_result(i+1)/test_result(i)];
end

xlabel('Weeks');
ylabel('Asset Price');
title('Simple Line Chart');
plot(1:Rg_return/2,test_result,'o-',1:Rg_return/2,bench_result,'x-');
legend('Optimized Asset','benchmark');
grid on; 

test05=test_result;


unique

TC_cost


