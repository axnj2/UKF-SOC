
% plotting the results of automated multi start approach for the whole SOC
% range for fitting HPPC data to ECM
clc
clear all
close all

load("xx_final_cycles.mat") % loading the parameters found from optimization
load("SOC_opt.mat")


SOC_train= cellfun(@(v) v(1), SOC_opt);   % column vector of first elements

SOC_train(1)=1;

taw=zeros(length(SOC_train),2);

%ECM parameters found from optimization
RO=xx_final_cycles(:,1);
RD=xx_final_cycles(:,2);
CD=xx_final_cycles(:,3);




% time constansts
tawD=RD.*CD;



% interpolation of 5 ECM parameters
fitresult_1 = createFit(SOC_train, RO);
fitresult_2 = createFit(SOC_train, RD);
fitresult_3 = createFit(SOC_train, CD);




figure(2)
semilogy(SOC_train, RO, 'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Line with black bullet points
xlabel('SOC'); % Add x-axis label
ylabel('RO'); % Add y-axis label
grid on; % Optional: Add a grid for better clarity

figure(3)
semilogy(SOC_train, RD, 'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Line with black bullet points
xlabel('SOC'); % Add x-axis label
ylabel('RD'); % Add y-axis label
grid on; % Optional: Add a grid for better clarity


figure(4)
semilogy(SOC_train, CD, 'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Line with black bullet points
xlabel('SOC'); % Add x-axis label
ylabel('CD'); % Add y-axis label
grid on; % Optional: Add a grid for better clarity

figure(5)
plot(SOC_train, tawD, 'k-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'k', 'MarkerSize', 6); % Line with black bullet points
xlabel('SOC'); % Add x-axis label
ylabel('tawD'); % Add y-axis label
grid on; % Optional: Add a grid for better clarity


