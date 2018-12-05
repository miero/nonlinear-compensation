#!/usr/bin/octave -qf
% clearing all variables
% note - 'clear' clears only local/global variables, not persistent variables in functions!


more off;

pkg load miscellaneous;
pkg load control;
pkg load optim;

addpath(fileparts(mfilename('fullpath')));

source 'config.m';

if direction == DIR_PLAY
  % overriden playback config values
  source 'configPlay.m';
  cmdFile = [varDir filesep() CMD_FILE_PLAY];
else
  cmdFile = [varDir filesep() CMD_FILE_REC];
endif


% default initial command
cmd = PAUSE;

fs = 0;
genFreq = 0;

% first run -> restart, reading all files
restartReading = true;
restartCal = true;
restartAnalysis = true;
restartWriting = true;
% unknown frequencies - measured by calibration or by determineFundamentalFreqs() in analysis
freqs = -1;

startingT = 0;
buffer = [0];

global deviceName;
if exist('wavPath', 'var') && !isempty(wavPath)
    [wavDir, wavName, wavExt] = fileparts(wavPath);
    deviceName = [wavName wavExt];
else
    global playRecConfig;
    deviceName = sprintf('rec%d', playRecConfig.recDeviceID);
end

while(true)
  % checking command file for new commands
  if (exist(cmdFile, 'file'))
    cmd = textread(cmdFile, '%s');
    delete(cmdFile);
  endif;

  % process new command if any
  if (!strcmp(cmd, NO_CMD))
    source 'run_process_cmd.m';  
  endif

%  printf('Status: %d\n', status);
  drawnow();

  if (status == PAUSED)
    % no reading/writing
    pause(0.5);
    % next cycle
    continue;
  endif

  % not stopped, will need data
  if exist('wavPath', 'var') && !isempty(wavPath)
    [buffer, fs] = readData(-1, fs, restartReading);
  else
    % reading/writing to soundcards
    [buffer, fs] = readWritePlayrec(-1, buffer, restartReading);
  end
  restartReading = false;

  if (bitand(status, DISTORTING) && (bitand(status, PASSING) || bitand(status, COMPENSATING)))
    source 'run_distortion.m';
  endif
  
  if (bitand(status, COMPENSATING))
    source 'run_compensation.m';
  endif
  
  if (status == GENERATING)
    source 'run_generator.m';
  endif
  
  
  % not stopped, always writing
  writeData(buffer, fs, restartWriting);
  restartWriting = false;
  
  
  % do additional processing - calibration or analysis
  if (status == CALIBRATING)
    source 'run_calibration.m';    
  elseif (bitand(status, ANALYSING))
    source 'run_analysis.m';
  endif
  
  
endwhile
