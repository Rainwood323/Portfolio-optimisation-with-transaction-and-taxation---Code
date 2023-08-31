xlabel('Weeks');
ylabel('Asset Price');


range_xxx = 1:52;
plot(range_xxx,test05,'o-', 'color', 'red', 'LineWidth', 1.2);   % 红色线
hold on;
plot(range_xxx, test15, '*-','color', 'blue', 'LineWidth', 1.2);  % 蓝色线
plot(range_xxx, test25, 'x-','color', 'green', 'LineWidth', 1.2); % 绿色线
plot(range_xxx, bench5, '.-','color', 'black', 'LineWidth', 1.2); % 黑色线

title('Comparision Line Chart');
legend('Model 1', 'Model 2: Rebalance 26 weeks', 'Model 2: Rebalance 13 weeks', 'Benchmark');
grid on;
hold off;
