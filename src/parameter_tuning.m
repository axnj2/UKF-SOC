clc;
clear;
close all;

addpath("../battery-model")

%--------------model parameters--------------
model_battery_capacity_fraction = 1;
model_time_const_fraction = 1;
model_initial_state = [0; 1];
sampling_period = 1;
processNoises = logspace(-6, -1, 5);
measurementNoise = 1e-2;
StateCovariances = logspace(-8, -2, 5);
% ground truth battery parameters
ground_truth_battery_capacity = 0.3;
ground_truth_time_constant = 1/0.7;
ground_truth_initial_state = [0; 1];
% --------------------------------------------

% --- input current profile and time vector --
input_current_profile = [1*ones(1,1000), zeros(1, 300), -0.5*ones(1,1000), zeros(1, 300), 1*ones(1,1000)];
time = (0:length(input_current_profile)-1) * sampling_period;
% --------------------------------------------

% ------------measurements noises --------------
voltage_noise_std_dev = 0.01;
current_noise_std_dev = 20;
% --------------------------------------------

% generate ground truth data
ground_truth_battery_model = BatteryModel(ground_truth_battery_capacity, ground_truth_time_constant);
ground_truth_voltages = NaN(size(time));
ground_truth_SOCs = NaN(size(time));
input_current = input_current_profile * ground_truth_battery_model.OneC; 

for k = 1:length(time)
    [ground_truth_voltages(k), ground_truth_SOCs(k)] = ground_truth_battery_model.step(input_current(k));
end

RMS_errors = NaN(length(processNoises), length(StateCovariances));

for processNoise = processNoises
    tic
    for StateCovariance = StateCovariances
        % Initialize the UKF observator
        ukf_observator = initialize_ukf(model_battery_capacity_fraction, model_time_const_fraction, model_initial_state, sampling_period, processNoise, measurementNoise, StateCovariance);
        % add noise
        noisy_truth_voltages = ground_truth_voltages + voltage_noise_std_dev * randn(size(ground_truth_voltages));
        noisy_input_current = input_current + current_noise_std_dev * randn(size(input_current));
        % Run state estimation
        estimated_SOC = run_state_estimation(ukf_observator, noisy_input_current, noisy_truth_voltages, 1);
        if sum(isnan(estimated_SOC(:))) == 0
            % Calculate RMS error
            RMS_errors(find(processNoises == processNoise), find(StateCovariances == StateCovariance)) = sqrt(mean((estimated_SOC - ground_truth_SOCs).^2));
        else
            RMS_errors(find(processNoises == processNoise), find(StateCovariances == StateCovariance)) = NaN;
        end
    end
    toc
end

RMS_errors
% plot the result as a color image using the colormap abyss and the NaN as white
figure;
imagesc(RMS_errors, 'AlphaData', ~isnan(RMS_errors)); % NaN will be transparent
colormap(abyss);
colorbar;
xlabel('State Covariances');
ylabel('Process Noises');
title('RMS Errors');
set(gca, 'Color', 'w'); % Set axes background to white for NaN
