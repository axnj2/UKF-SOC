function [y] = measurement_experimental(x, u, fitresult_1, fitresult_2, fitresult_3, eta, Q, T, ocv_coefficients)
    [A_d, B_d, C_d, D_d] = get_linear_model(x(2), fitresult_1, fitresult_2, fitresult_3, eta, Q, T);
    y = open_circuit_voltage(x(2), ocv_coefficients) + C_d * x + D_d * u;
end