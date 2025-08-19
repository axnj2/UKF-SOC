function [new_x] = state_transition(x, u, A_d, B_d)
        new_x = A_d * x + B_d * u;
end