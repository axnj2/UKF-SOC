clc;
clear;
close all;
addpath("../battery-model")
% https://nl.mathworks.com/help/control/ref/unscentedkalmanfilter.html

simulated_battery_model = BatteryModel(1);


transition_fcn = @(x,u) state_transition(x, u, simulated_battery_model.A_d, simulated_battery_model.B_d);
measurement_fcn = @(x,u) measurement(x, u, simulated_battery_model.C_d, simulated_battery_model.D_d, simulated_battery_model.ocv_coefficients);


observator = unscentedKalmanFilter(transition_fcn, measurement_fcn, simulated_battery_model.x);
observator.ProcessNoise = 1e-7;
observator.MeasurementNoise = 0;
observator.StateCovariance = 1e-6;


tt = 0:simulated_battery_model.sampling_period:3600; %s
current_amplitude = 1/4 * simulated_battery_model.OneC;
input_current = [current_amplitude * ones(1, round(size(tt, 2)*3/4)), -current_amplitude * ones(1, floor(size(tt, 2)/4))];
size(input_current)
real_battery_model = BatteryModel(0.3, 0.001, 0.001);

y_hist = zeros(size(tt));
real_SOC_hist = zeros(size(tt));
predicted_states_hist = zeros([2, size(tt)]);
for k = 1:length(tt)
    [y_hist(k), real_SOC_hist(k)] = real_battery_model.step(input_current(k));
    if mod(k, 1)==0
        observator.correct(y_hist(k), input_current(k));
    end
    [predicted_states_hist(:,k), ~] = observator.predict(input_current(k));
end

figure
tiledlayout(2,1)

nexttile
plot(tt, real_SOC_hist)
hold on;
plot(tt, predicted_states_hist(2,:))
legend('Real SOC', 'Predicted SOC')
xlabel('Time (s)')
ylabel('State of Charge (SOC)')
title('Battery State of Charge Estimation using UKF')
grid on;

nexttile
plot(tt, y_hist)
hold on;
legend('Real Output')
xlabel('Time (s)')
ylabel('Output')
title('Battery Output from model')


