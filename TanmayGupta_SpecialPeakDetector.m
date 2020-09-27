clc;
clear;
close all;

% Initilization
fs = 10; % Sampling frequency of 10 Hz
time=5;  % 5 seconds of consideration to check for invalid peaks
step = time*fs; % 5 seconds in terms of number of samples
data = csvread('Signal.csv');

% Finding the Gradient to determine trend (rise or fall) of signal samples
% which will indicate a Peak or Valley. A positive gradient indicates that
% the signal is increasing and a negative gradient means signal is
% decreasing in successive sample. Gradient of 0 means that the signal is
% flat (neither increasing nor decreasing).
gradient = [0 diff(data)];
ind = find(gradient ~= 0,1);                    % First non-zero gradient value of the signal
index_zeros = find(gradient(ind:end) == 0) + ind - 1; % All zero-valued signal gradients

% Removing the zero-valued gradients to ensure proper peak detection and selection
gradient(index_zeros) = [];

% A Zero-crossing indicates a change in sign (+ve or -ve) of gradient
% values which indicates we have encountered a peak or valley in the signal
% data as the gradient may have gone from positive to negative (indicating
% a peak) or it may have gone from negative to positive (indicating a
% valley) in the signal.
zc = gradient(2:end).*gradient(1:end-1);

% As we had removed zero gradient values above, we now need to shift our 
% 'zc' to obtain the correct index of peaks and valleys.
for i= 1:length(index_zeros)
    zc = [zc(1:index_zeros(i)-2) 0 zc(index_zeros(i)-1:end)];
end


% Finding the index of all the Peaks and Valleys in the original signal
temp = find(zc<0);

% It's intuitive that a Peak will follow a Valley which will follow a Peak.
% Thus, in order to select only the Peaks, we need to select every
% alternate index. If our very first non-zero gradient value is positive,
% that indicates we will encounter a Peak first so we begin selecting the
% Peaks from first index. And if, our very first non-zero gradient value is
% negative that indicates we will encounter a Valley first so we begin 
% selecting the Peaks from the second index.
if gradient(ind) > 0
    % Signal starts with a Peak
    peakInd = temp(1:2:end);
    peakVal = data(peakInd);
    allPeakData = [peakVal; peakInd];
else
    % Signal starts with a Valley
    peakInd = temp(2:2:end);
    peakVal = data(peakInd);
    allPeakData = [peakVal; peakInd];
end

% Setting a flag of '0' indicating the Peak has not been tested for the
% validity yet. It is considered as 'Undesignated' or 'Untested'.
allPeakData(3,:) = 0;

clearvars peakInd peakVal gradient ind zc temp

% Designating the Peaks as Valid/Removed based on the conditions
% 0 : Undesignated/Untested, 1 : Removed/Invalid, 2 : Valid

testedPeakData=[];

% Now we will iteratively find the values and index of all Valid Peaks
while(ismember(0, allPeakData(3,:)))
    % Finding the undesignated (Flag == 0) peak with largest amplitude
    [validPeakVal, I] = max(allPeakData(1,:));
    validPeakInd = allPeakData(2,I);
    threshold = validPeakVal/2;
    
    % Designating current peak as 'Valid'
    allPeakData(3, I) = 2;  
    
    % Finding Indices of other Peaks in +/- 5 second range of the current peak
    testingInd = find(allPeakData(2,:) > validPeakInd-step & ...
    allPeakData(2,:)< validPeakInd+step & allPeakData(2,:) ~= validPeakInd);
    
    % Designating peaks as 'Removed/Invalid' based on given condition
    for i=1:length(testingInd)
        if allPeakData(1, testingInd(i)) > threshold
            allPeakData(3, testingInd(i)) = 1;
        end
    end
    
    % Removing Valid/Removed Peaks from 'allPeakData' so that in each
    % successive iteration we only consider Undesignated Peaks
    % We store the Valid/Removed Peaks in another object
    testedPeakData = [testedPeakData allPeakData(:, allPeakData(3,:) ~= 0)];
    allPeakData = allPeakData(:, allPeakData(3,:) == 0);
end
clearvars threshold validPeakInd validPeakVal i allPeakData index_zeros
clearvars testingInd

% Selecting only Valid peaks (Flag set as 2 means Valid Peak)
validPeakData = testedPeakData(:, testedPeakData(3,:) == 2);
[~, order] = sort(validPeakData(2,:));
validPeakData = validPeakData(:,order);

% Now we find the Special peak with  smallest amplitude from Valid Peaks.
% If more than one peak meets the Special Peak criteria, the Valid Peak 
% detection code written above works in the way that automatically, we will
% return the Peak which is closest to the beginning of the signal.
[specialPeakVal, I] = min(validPeakData(1,:));
specialPeakInd = validPeakData(2,I);

% Plotting all detected peaks, Valid peaks and the Special peak
figure;
plot((1:length(data)), data);
hold on;
plot(testedPeakData(2, :), testedPeakData(1, :), 'o', 'MarkerEdgeColor', 'red');
legend('Input Signal','All Peaks');
title('All peaks detected in Input signal');
xlabel('Sample Number');
ylabel('Signal Amplitude');

figure;
plot((1:length(data)), data);
hold on;
plot(validPeakData(2, :), validPeakData(1, :), 'o', 'MarkerEdgeColor', 'black');
hold on;
plot(specialPeakInd, specialPeakVal, 'o', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'red');
legend('Input signal','Valid peaks', 'Special peak');
title('Special Peak and Valid Peaks detected in Input signal');
xlabel('Sample Number');
ylabel('Signal Amplitude');
txt = ['The sample index at which the special peak occurs is: ' num2str(specialPeakInd)];
text(200,0.1,txt)

fprintf("The sample index at which the special peak occurs is: %d \n", specialPeakInd);
