function [estimated_SOC] = run_state_estimation(ukf_observator, measured_input_current, measured_output_voltage, correction_interval)
    arguments (Input)
        ukf_observator unscentedKalmanFilter
        measured_input_current (1,:) double
        measured_output_voltage (1,:) double
        correction_interval (1,1) double
    end
    arguments (Output)
        estimated_SOC (1,:) double
    end

    estimated_SOC = NaN(size(measured_input_current));
    % Loop through each time step
    for k = 1:length(measured_input_current)
        if mod(k, correction_interval) == 0
            % Correct the UKF with the new measurements
            ukf_observator.correct(measured_output_voltage(k), measured_input_current(k));
        end
        % Predict the next state
        [estimated_state, ~] = ukf_observator.predict(measured_input_current(k));
        if isnan(estimated_state)
            return
        end

        % Extract the estimated SOC from the state
        estimated_SOC(k) = estimated_state(2);
    end
end
