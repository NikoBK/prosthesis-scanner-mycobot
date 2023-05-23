% Name:     inverseKinematics.m
% Created:  5/22/2023
% Author:   264

close all; clear; clc;

% While the geometrical/analytical way of doing inverse kinematics is good
% because it finds all possible solutions, the numerical systematically
% finds as many solutions as possible, doing what can be described as
% bruteforcing it's way to the solutions.

% Error arrays to evaluate how well the found solution has been found.
error = []; % General Error.
p_error = []; % Position Error.
o_error = []; % Orientation Error.
q_error = [];

% Options for the optimization algorithm.
% Currently set to run 6000 times (1000 times per variable), default: 200.
options = optimset('MaxFunEvals', 6 * 1000);

i = 0;
for n = 0:100
    % Try to find the orientation for each joint selected from a random
    % value between 1 and 6. Multiplied with 2pi because it ranges from 0
    % to 6, then with pi subtracted so the range is from [-pi:pi.]
    q_find = rand(1,6) * 2 * pi - pi;

    % Generate a endframe based on joints to then later used that end frame
    % to make the joints and validate the inverse kinematics with forward
    % kinematics.
    [posGoal, oriGoal] = getFinalFrame(q_find);


    % The numeric solutions need a good starting guess. This serves as a
    % seed rather than something like 0, 0, ..., 0, we get random numbers
    % for each entry in q0 which is a vector.
    q0 = q_find + (rand(1,6) * 2 - 1) * 20 * pi/180;

    % Solve the inverse kinematics.
    % fminsearch works similar to 'fminunc' however this one is a better
    % choice, than that and the other option 'fmincon' which takes
    % conditions.
    [q, error_n] = fminsearch(@(q) solveFunction(q, posGoal, oriGoal), q0, options);

    % Check results.
    [posFinal, oriFinal] = getFinalFrame(q);
    disp("Checking result for: " + posGoal + ", result is: " + posFinal)
    disp("Checking result for: " + oriGoal + ", result is: " + oriFinal)

    i = i + 1;
    p_error(i,:) = (posFinal - posGoal).^2;
    o_error(i,:) = angdiff(oriFinal, oriGoal).^2;
    q_error(i,:) = angdiff(q_find, q).^2;
    error(i) = error_n;
end

% Plot the results after exiting the loop iterations.
plot(p_error)
figure()
plot(o_error)
figure()
plot(error)




























% End of document :)