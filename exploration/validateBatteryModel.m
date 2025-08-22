
clear;
close all;

addpath("../battery-model")

bat_test = FirstOrderBatteryModel(1);
tt = 0:1:3600*0.3; % s
y = zeros(1, length(tt)); % output voltage over time
socs = zeros(1, length(tt)); % state of charge over time
i = 1/4 * bat_test.OneC * ones(1, length(tt)); % constant current input

for t = 1:length(tt)
    [y(t), socs(t)] = bat_test.step(i(t));
end


hold on
plot(tt, y, "DisplayName", "BatteryModel class")
plot(tt, socs, "DisplayName", "State of Charge")
clear % caution variables are overwritten in the script that is called
evaluating
