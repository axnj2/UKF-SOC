function [new_x] = state_transition_first_order_battery_model(x, u, A_d, B_d)
        new_x = A_d * x + B_d * u;
        new_x(2) = clip(new_x(2), 0, 1); % Ensure SOC is within bounds
end