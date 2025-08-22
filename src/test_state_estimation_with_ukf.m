clc;
clear;
close all;

%% Kalman filter initialisation
% First load a battery model, you need to define 2 functions for it where x is the state vector and u is the input : 
% - state_transition(x, u)  (example in battery-model/state_transition.m)
% - measurement(x) (example in battery-model/measurement.m)

% change this with the folder of the model you are using
addpath("../battery-model");

ukf_relative_battery_capacity = 2;
ukf_relative_time_constant = 0.5;
ukf_initial_state = [0;1];
ukf_time_step = 1;
ukf_battery_model  = FirstOrderBatteryModel(ukf_relative_battery_capacity,...
                                            ukf_relative_time_constant,...
                                            ukf_initial_state,...
                                            ukf_time_step);

% change these function with the functions of your model
ukf_state_transition_fct = @(x, u) state_transition_first_order_battery_model(x,...
                                                                              u,...
                                                                              ukf_battery_model.A_d,...
                                                                              ukf_battery_model.B_d);
ukf_measurement_fct = @(x, u) measurement_first_order_battery_model(x,...
                                                                    u,... 
                                                                    ukf_battery_model.C_d,... 
                                                                    ukf_battery_model.D_d,...
                                                                    ukf_battery_model.ocv_coefficients);


% create the kalman filter
ukf_initial_state = [0;1];
ukf_state_variance = 1e-5; 
ukf_measurement_noise = 0.01; % should be close to the real measurement_noise
% the ukf_process_noise should be really small (not 0) (the bigger it the the more accurate the filter but if it is too big the filter diverges (1e-4 is already often too big))
% it is important to adjust it.
ukf_process_noise = 1e-6; 
observator = initialize_ukf(ukf_state_transition_fct,...
                     ukf_measurement_fct,...
                     ukf_initial_state,...
                     ukf_process_noise,...
                     ukf_measurement_noise,...
                     ukf_state_variance);

%% Data initialisation
% Load or create the voltage and current data (2 examples : 1 with creating data and 1 with loading data)
voltage_data = [];
current_data = [];
ground_truth_SOC = [];
data_capacity_relative= 1;
data_time_constant_relative = 1;

use_first_order_model_data = false;
if use_first_order_model_data
    data_capacity_relative = 0.5;
    data_time_constant_relative = 1/0.7;
    % here we will use the same model to create the data but any source of the data will do
    data_synthetisation_model = FirstOrderBatteryModel(data_capacity_relative, data_time_constant_relative);
    current_data = [0.5 * data_synthetisation_model.OneC * ones(1, 1800), -0.5 * data_synthetisation_model.OneC * ones(1, 1800)];
    voltage_data = NaN(size(current_data));
    ground_truth_SOC = NaN(size(current_data));

    for k = 1:length(current_data)                                                                                                  
        [voltage_data(k), ground_truth_SOC(k)] = data_synthetisation_model.step(current_data(k));
    end

    % adding noise : 
    voltage_data = voltage_data + 0.01 * randn(size(voltage_data));
    current_data = current_data + 1 * randn(size(current_data));
else
    data_capacity_relative = 1;
    data_time_constant_relative = 1;
    % load synthetic data from SPMe
    % the units are not clear here sorry (I didn't make this data set and did not receive the units with it)
    addpath("../battery-data-from-SPMe/")
    load("Voltage_SPMe.mat", "V") % called V
    voltage_data = V;
    time_step = 1; % in seconds (don't change it unless you change the data)
    battery_capacity = 36.4787*3600;
    assert(ukf_time_step == time_step, "the time step of the model and the data must be the same");

    load("US06.csv")
    partial_current_data = 10*US06(:,2)';
    current_data = repmat(partial_current_data, 1, 15);

    % compute the ground truth SOC by coulomb counting using trapz
    ground_truth_SOC = 1 - cumtrapz(current_data)/battery_capacity;
    figure
    plot(partial_current_data)
    title('Sample of the current data')
    xlabel('Time (s)')
    ylabel('Current')
end

%% Run estimation
% see run_state_estimation.m in this folder for the details
estimated_SOC = run_state_estimation(observator, current_data, voltage_data, 1);


%% Plot the results
% you can plot everything you want to see here is a simple example with the SOC only
time_vector = 1:length(current_data);
figure;
plot(time_vector, ground_truth_SOC, 'g', 'DisplayName', 'Ground Truth SOC');
hold on;
plot(time_vector, estimated_SOC, 'b', 'DisplayName', 'Estimated SOC');
xlabel('Time (s)');
ylabel('State of Charge (SOC)');
title(sprintf('State of Charge Estimation using UKF\n on a battery of relative capacity %.2f, relative time constant %.2f ', data_capacity_relative/ukf_relative_battery_capacity, data_time_constant_relative/ukf_relative_time_constant));
legend show;
grid on;
