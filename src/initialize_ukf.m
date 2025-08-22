function ukf_observator = initialize_ukf(transition_fcn, measurement_fcn, initial_state, processNoise, measurementNoise, StateCovariance)
    % Initialize the UKF observator
    arguments (Input)
        transition_fcn function_handle
        measurement_fcn function_handle
        initial_state (2,1) double
        processNoise (1,1) double = 1e-5
        measurementNoise (1,1) double = 0
        StateCovariance (1,1) double = 1e-5
    end
    arguments (Output)
        ukf_observator unscentedKalmanFilter
    end
    ukf_observator = unscentedKalmanFilter(transition_fcn, measurement_fcn, initial_state);
    ukf_observator.ProcessNoise = processNoise;
    ukf_observator.MeasurementNoise = measurementNoise;
    ukf_observator.StateCovariance = StateCovariance;
end
