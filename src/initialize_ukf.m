function ukf_observator = initialize_ukf(battery_capacity_fraction, time_const_fraction, initial_state, sampling_period, processNoise, measurementNoise, StateCovariance)
    % Initialize the UKF observator for battery state estimation
    arguments (Input)
        battery_capacity_fraction (1,1) double = 1.0
        time_const_fraction (1,1) double = 1.0
        initial_state (2,1) double = [0; 1] % [initial voltage, initial SOC]
        sampling_period (1,1) double = 1.0 % in seconds
        processNoise (1,1) double = 1e-5
        measurementNoise (1,1) double = 0
        StateCovariance (1,1) double = 1e-5
    end
    arguments (Output)
        ukf_observator unscentedKalmanFilter
    end

    try
        simulated_battery_model = BatteryModel(battery_capacity_fraction, time_const_fraction, initial_state, sampling_period);
    catch exception
        error("Failed to initialize battery model check that the folder battery-model is in the path (use addpath to add it): %s.", exception.message);
    end

    transition_fcn = @(x,u) state_transition(x, u, simulated_battery_model.A_d, simulated_battery_model.B_d);
    measurement_fcn = @(x,u) measurement(x, u, simulated_battery_model.C_d, simulated_battery_model.D_d, simulated_battery_model.ocv_coefficients);

    ukf_observator = unscentedKalmanFilter(transition_fcn, measurement_fcn, simulated_battery_model.x);
    ukf_observator.ProcessNoise = processNoise;
    ukf_observator.MeasurementNoise = measurementNoise;
    ukf_observator.StateCovariance = StateCovariance;
end
