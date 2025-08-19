% clc
% clear all
% close all

load("coeffs.mat")
load("xx_final_cycles.mat")

Q=36.4787*3600; %capacity
p.OneC=Q/3600; % value of 1C
eta=1; %coulombic efficiency

% validation profile with C/4
T=1; %sampling time
t=0:T:3*3600;
I=1/4*p.OneC*ones(1,length(t));

%%
RO_vec=xx_final_cycles(:,1);
RD_vec=xx_final_cycles(:,2);
CD_vec=xx_final_cycles(:,3);
% parameters are found by averaging
RO=mean(RO_vec);
RD=mean(RD_vec);
CD=mean(CD_vec);
%%

% initialization
x=zeros(2,length(t)); %states over time 
y=zeros(1,length(t)); %voltages over time
initialsoc=1;
x(:,1)=[0;initialsoc];


tawd = RD * CD;

A=[-1/tawd,0;
0,0];

B=-[1/tawd;eta/Q];  
C=[RD,0];
D=-(RO);


% Discretize the state-space system
sys_cont = ss(A, B, C, D);
sys_disc = c2d(sys_cont, T);
A_d = sys_disc.A;
B_d = sys_disc.B;
C_d = sys_disc.C;
D_d = sys_disc.D;

for k = 1:length(t) - 1
    x(:, k+1) = A_d * x(:, k) + B_d * I(k);
    y(k)=ocv(coeffs,x(2,k))+C_d*x(:,k)+D_d*I(k);
end
% the last output is computed outside of the loop

y(end)=ocv(coeffs,x(2,end))+C_d*x(:,end)+D_d*I(end);



plot(t, y, ":", 'DisplayName', 'Model Voltage',LineWidth=1.5)
xlabel('Time [s]','FontSize',13)
ylabel('Voltage [V]','FontSize',13)
legend
grid on
box on
ax=gca;
ax.FontSize=15;

function ocv = ocv(coeffs,SOC)
% this is a function for finding the OCV at any SOC using legandre
    % Degree of polynomial
    n = length(coeffs)-1;

    % Normalize SOC to [-1,1]
    SOC_prime = 2 * (SOC - 0) / (1 - 0) - 1; % SOC_prime = 2 * (SOC - min(SOC)) / (max(SOC) - min(SOC)) - 1 in which min(SOC)=0 and max(SOC)=1

    
    % Compute Legendre polynomials
    A = zeros(length(SOC_prime), n+1);
    A(:, 1) = ones(length(SOC_prime), 1);        % P_0(x) = 1
    A(:, 2) = SOC_prime .* ones(length(SOC_prime), 1); % P_1(x) = x
    
    for k = 2:n
        A(:, k+1) = ((2*k - 1) .* SOC_prime .* A(:, k) - (k-1) .* A(:, k-1)) / k;
    end

    % Compute OCV
    ocv = A * coeffs;
end