function [new_x] = state_transition_experimental(x, u, fitresult_1, fitresult_2, fitresult_3, eta, Q, T)
    [A_d, B_d, C_d, D_d] = get_linear_model(x(2), fitresult_1, fitresult_2, fitresult_3, eta, Q, T);
    new_x = A_d * x + B_d * u;
    new_x(2) = clip(new_x(2), 0, 1); % Ensure SOC is within bounds
end