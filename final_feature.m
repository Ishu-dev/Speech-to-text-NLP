% Clear variables and read audio file
clear y Fs
[y, Fs] = audioread('engmale.wav');

% Apply pre-emphasis
alpha = 0.97;
y = filter([1 -alpha], 1, y);

% Normalize the entire audio signal
y = y / max(abs(y));

% Apply endpoint detection (assuming energy-based)
% Segmentation
energyThreshold = 0.02;

% Detect the start and end points for each segment
segmentStartPoints = find(diff(abs(y) > energyThreshold) > 0);
segmentEndPoints = find(diff(abs(y) > energyThreshold) < 0);

% Divide the audio into segments
audioSegments = cell(length(segmentStartPoints), 1);
for i = 1:length(segmentStartPoints)
    audioSegments{i} = y(segmentStartPoints(i):segmentEndPoints(i));
end

% Loop through each audio segment for further processing
for segmentIdx = 1:length(audioSegments)
    % Perform further processing on each segment
    % You can add feature extraction and other processing steps here
    % ...

    % For example, you can save or analyze each segment separately
    audiowrite(['segment', num2str(segmentIdx), '.wav'], audioSegments{segmentIdx}, Fs);
end

% Play the preprocessed audio
player = audioplayer(y, Fs);
play(player);

% Save the preprocessed audio
filename = 'preprocessed_engmale.wav';
audiowrite(filename, y, Fs);

% Read the preprocessed data back into MATLAB
[audioIn, fs] = audioread(filename);

% Create an audioFeatureExtractor with additional preprocessing
% (Uncomment and modify if needed)
% aFE = audioFeatureExtractor( ...
%     SampleRate=fs, ...
%     Window=hamming(round(0.03*fs), "periodic"), ...
%     OverlapLength=round(0.02*fs), ...
%     mfcc=true, ...
%     mfccDelta=true, ...
%     mfccDeltaDelta=true, ...
%     pitch=true, ...
%     spectralCentroid=true, ...
%     zerocrossrate=true, ...
%     shortTimeEnergy=true);

% Create an audioFeatureExtractor to extract features
aFE = audioFeatureExtractor("SampleRate", fs, ...
    "SpectralDescriptorInput", "barkSpectrum", ...
    "spectralCentroid", true, ...
    "spectralKurtosis", true, ...
    "pitch", true);

% Extract and normalize features
features = extract(aFE, audioIn);
features = (features - mean(features, 1)) ./ std(features, [], 1);

%% Plot the normalized features over time.
idx = info(aFE);
duration = size(audioIn, 1) / fs;

% Plot the original audio signal
t = linspace(0, duration, size(audioIn, 1));
figure(1);
plot(t, audioIn)
title('Original Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot the extracted features over time
t = linspace(0, duration, size(features, 1));
figure(2);
plot(t, features(:, idx.spectralCentroid), ...
     t, features(:, idx.spectralKurtosis), ...
     t, features(:, idx.pitch));
legend('Spectral Centroid', 'Spectral Kurtosis', 'Pitch');
title('Extracted Features over Time');
xlabel('Time (s)');

%% MFCC extraction technique
% Read the audio for MFCC extraction
[audioIn_mfcc, fs_mfcc] = audioread("engmale.wav");

% Specify the desired number of MFCC coefficients
numCoeffs = 20;

% Extract MFCCs with the specified number of coefficients
[coeffs, delta, deltaDelta, loc] = mfcc(audioIn_mfcc, fs_mfcc, 'NumCoeffs', numCoeffs);

% Plot the raw MFCCs
figure(3);
subplot(2, 1, 1);
mfcc(audioIn_mfcc, fs_mfcc, 'NumCoeffs', numCoeffs);
title('MFCCs');
xlabel('Time (s)');

% Plot the normalized MFCCs for better visualization
subplot(2, 1, 2);
t_mfcc = linspace(0, size(coeffs, 1) / fs_mfcc, size(coeffs, 1));
plot(t_mfcc, zscore(coeffs));  % Normalize the coefficients for better visualization
title('Normalized MFCCs');
xlabel('Time (s)');

%% Additional MFCC extraction from frequency-domain audio

% Extract MFCCs from frequency-domain audio using STFT
[audioIn_stft, fs_stft] = audioread("engmale.wav");
win = hann(1024, "periodic");
S = stft(audioIn_stft, "Window", win, "OverlapLength", 512, "Centered", false);

% Extract MFCCs, ignoring the log-energy
coeffs = mfcc(S, fs_stft, "LogEnergy", "Ignore");

% Plot a probability density function for one of the coefficients
nbins = 60;
coefficientToAnalyze = ;
figure(4);
histogram(coeffs(:, coefficientToAnalyze + 1), nbins, "Normalization", "pdf");
title(sprintf("Coefficient %d", coefficientToAnalyze));
