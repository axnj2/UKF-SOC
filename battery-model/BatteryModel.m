classdef BatteryModel < handle
    properties
        ocv_coefficients
        sampling_period
        measurementNoise
        processNoise
        Q
        OneC
        eta
        A_d
        B_d
        C_d
        D_d
        x % internal state
    end

    methods
        function obj = BatteryModel(fraction_of_total_capacity, measurementNoise, processNoise, initial_state, sampling_period)
            arguments (Input)
                fraction_of_total_capacity (1,1) double = 1
                measurementNoise (1,1) double = 0
                processNoise (1,1) double = 0
                initial_state (2,1) double = [0; 1]
                sampling_period (1,1) double = 1
            end
            arguments (Output)
                obj BatteryModel
            end
            load("xx_final_cycles.mat", "xx_final_cycles")
            load("coeffs.mat", "coeffs")
            obj.sampling_period = sampling_period;
            obj.measurementNoise = measurementNoise;
            obj.processNoise = processNoise;
            obj.ocv_coefficients = coeffs; % store coefficients for OCV calculation

            RO_vec=xx_final_cycles(:,1);
            RD_vec=xx_final_cycles(:,2);
            CD_vec=xx_final_cycles(:,3);
            % parameters are found by averaging
            RO=mean(RO_vec);
            RD=mean(RD_vec);
            CD=mean(CD_vec);

            obj.Q=36.4787*3600; %capacity
            obj.OneC=obj.Q/3600; % value of 1C
            eta=1; %coulombic efficiency

            obj.Q = obj.Q * fraction_of_total_capacity;

            tawd = RD * CD;

            A=[-1/tawd,0;
            0,0];

            B=-[1/tawd;eta/obj.Q];  
            C=[RD,0];
            D=-(RO);

            sys_cont = ss(A, B, C, D);
            sys_disc = c2d(sys_cont, sampling_period);
            obj.A_d = sys_disc.A;
            obj.B_d = sys_disc.B;
            obj.C_d = sys_disc.C;
            obj.D_d = sys_disc.D;

            obj.x = initial_state;
        end

        function [output_voltage, SOC] = step(obj, input_current)
            output_voltage = measurement(obj.x, input_current, obj.C_d, obj.D_d, obj.ocv_coefficients) + obj.measurementNoise * randn();
            obj.x = state_transition(obj.x, input_current, obj.A_d, obj.B_d) + obj.processNoise * randn(size(obj.x));
            obj.x(2) = clip(obj.x(2), 0, 1);
            SOC = obj.x(2);
        end

        function output_voltage = open_circuit_voltage(obj, SOC)
            % this is a function for finding the OCV at any SOC using legandre
            % Degree of polynomial
            n = length(obj.ocv_coefficients)-1;

            % Normalize SOC to [-1,1]
            SOC_prime = 2 * (SOC - 0) / (1 - 0) - 1; % SOC_prime = 2 * (SOC - min(SOC)) / (max(SOC) - min(SOC)) - 1 in which min(SOC)=0 and max(SOC)=1

            
            % Compute Legendre polynomials
            A = zeros(length(SOC_prime), n+1);
            A(:, 1) = ones(length(SOC_prime), 1);        % P_0(x) = 1
            A(:, 2) = SOC_prime .* ones(length(SOC_prime), 1); % P_1(x) = x
            
            for k = 2:n
                A(:, k+1) = ((2*k - 1) .* SOC_prime .* A(:, k) - (k-1) .* A(:, k-1)) / k;
            end

            % Compute OCV
            output_voltage = A * obj.ocv_coefficients;
        end
    end
end