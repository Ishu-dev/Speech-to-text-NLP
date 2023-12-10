%%
clear y Fs
[y, Fs] = audioread('engmale.wav');
player = audioplayer(y, Fs);
play(player);

filename = 'engmale.wav';
audiowrite(filename,y,Fs);
%clear y Fs  

%% 
% Read the data back into MATLAB using |audioread|. 
%[y,Fs] = audioread('engmale.wav');  

%% 
% Play the audio. 
%sound(y,Fs); 

%% 
%Read in an audio signal.
[audioIn,fs] = audioread("engmale.wav");
%% 
%Create an audioFeatureExtractor to extract the centroid of the Bark spectrum, the kurtosis of the Bark spectrum, and the pitch of an audio signal.
aFE = audioFeatureExtractor("SampleRate",fs, ...
    "SpectralDescriptorInput","barkSpectrum", ...
    "spectralCentroid",true, ...
    "spectralKurtosis",true, ...
    "pitch",true)
%% 
%Call extract to extract the features from the audio signal. Normalize the features by their mean and standard deviation.

features = extract(aFE,audioIn);
features = (features - mean(features,1))./std(features,[],1);

%% 
%Plot the normalized features over time.
idx = info(aFE);
duration = size(audioIn,1)/fs;


%% 
%doing mfcc extraction technique
[audioIn_mfcc,fs_mfcc] = audioread("engmale.wav");
[coeffs,delta,deltaDelta,loc] = mfcc(audioIn_mfcc,fs_mfcc);
%Plot the normalized coefficients.
figure(3);
mfcc(audioIn_mfcc,fs_mfcc)
%% 
%
[audioIn,fs] = audioread("engmale.wav");

win = hann(1024,"periodic");
S = stft(audioIn,"Window",win,"OverlapLength",512,"Centered",false);
%To extract the mel-frequency cepstral coefficients, call mfcc with the frequency-domain audio. Ignore the log-energy.

coeffs = mfcc(S,fs,"LogEnergy","Ignore");
%In many applications, MFCC observations are converted to summary statistics for use in classification tasks. Plot a probability density function for one of the mel-frequency cepstral coefficients to observe its distributions.

nbins = 60;
coefficientToAnalyze = 4;

figure(4);
histogram(coeffs(:,coefficientToAnalyze+1),nbins,"Normalization","pdf")
title(sprintf("Coefficient %d",coefficientToAnalyze))

