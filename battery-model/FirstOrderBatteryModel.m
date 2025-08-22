classdef FirstOrderBatteryModel < handle
    properties
        ocv_coefficients
        sampling_period
        measurementNoise
        time_const_fraction
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
        function obj = FirstOrderBatteryModel(fraction_of_total_capacity, time_const_fraction, initial_state, sampling_period)
            arguments (Input)
                fraction_of_total_capacity (1,1) double = 1
                time_const_fraction (1,1) double = 1.0
                initial_state (2,1) double = [0; 1]
                sampling_period (1,1) double = 1
            end
            arguments (Output)
                obj FirstOrderBatteryModel
            end
            load("xx_final_cycles.mat", "xx_final_cycles")
            load("coeffs.mat", "coeffs")
            obj.sampling_period = sampling_period;
            obj.ocv_coefficients = coeffs; % store coefficients for OCV calculation
            obj.time_const_fraction = time_const_fraction;

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

            tawd = RD * CD * time_const_fraction;

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
            arguments
                obj FirstOrderBatteryModel
                input_current (1,1) double % in milliAmperes
            end

            output_voltage = measurement_first_order_battery_model(obj.x, input_current, obj.C_d, obj.D_d, obj.ocv_coefficients);
            obj.x = state_transition_first_order_battery_model(obj.x, input_current, obj.A_d, obj.B_d);
            obj.x(2) = clip(obj.x(2), 0, 1);
            SOC = obj.x(2);
        end
    end
end