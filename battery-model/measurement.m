function [y] = measurement(x, u, C_d, D_d, ocv_coefficients)
    y = open_circuit_voltage(x(2), ocv_coefficients) + C_d * x + D_d * u;
end