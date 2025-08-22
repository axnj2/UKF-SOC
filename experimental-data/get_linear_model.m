function [A_d, B_d, C_d, D_d] = get_linear_model(SOC, fitresult_1, fitresult_2, fitresult_3, eta, Q, T)
    RO = feval(fitresult_1, SOC);
    RD = feval(fitresult_2, SOC);
    CD = feval(fitresult_3, SOC);
    

    % Recompute time constants
    tawd = RD * CD;

    % Update state-space matrices
    A=[-1/tawd,0;
    0,0];
    
    B=-[1/tawd;eta/Q];  
    C=[RD,0];
    D=-(RO);

    sys_cont = ss(A, B, C, D);
    sys_disc = c2d(sys_cont, T);
    A_d = sys_disc.A;
    B_d = sys_disc.B;
    C_d = sys_disc.C;
    D_d = sys_disc.D;
end