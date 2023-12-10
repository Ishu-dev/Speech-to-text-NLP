% Specify the path to the WAV file
filename = 'C:\Users\Ishu Chaudhary\MATLAB\Projects\Sem7Project\engmale.wav';

try
    % Read the audio file using audioread
    [y, Fs] = audioread(filename);

    % Play the audio
    soundsc(y, Fs); % Use soundsc for automatic scaling
    
    % Wait for the audio to finish playing
    pause(length(y) / Fs);

    % Release the audio player (if needed)
    clear sound;

catch exception
    fprintf('Error: %s\n', exception.message);
end
