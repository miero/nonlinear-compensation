if (strcmp(cmd{1}, PAUSE))
  status = PAUSED;
  
elseif (strcmp(cmd{1}, CALIBRATE))
  % cal extraCircuit
  % start/restart joint-device calibration 
  status = CALIBRATING;
  % reading optional  extra circuit specifier string (will be stored in cal file name)
  if (rows(cmd) > 1)
    extraCircuit = cmd{2};
  else
    extraCircuit = '';
  endif
  % clearing calibration buffer
  restartCal = true;
  showFFTFigureConfig.restartAvg = 1;

elseif (strcmp(cmd{1}, COMPENSATE))
  % comp calDeviceName extraCircuit
  % start/restart analysis first, compensation will run after measuring current stream parameters
  status = ANALYSING;
  % reading optional deviceName string
  if (rows(cmd) > 1)
    calDeviceName = cmd{2};
  else
    calDeviceName = jointDeviceName;
  endif
  % reading optional extraCircuit string
  if (rows(cmd) > 2)
    extraCircuit = cmd{3};
  else
    extraCircuit = '';
  endif
  
  restartAnalysis = true;
  % re-determine freqs in case of change
  freqs = -1;
  showFFTFigureConfig.restartAvg = 1;

% distortion allowed only for status PASSING and COMPENSATING
elseif (strcmp(cmd{1}, DISTORT) && (statusContains(status, PASSING) || statusContains(status, COMPENSATING)))
  % enable distortion
  status = [status, DISTORTING];

elseif (strcmp(cmd{1}, PASS))
  status = PASSING;
  showFFTFigureConfig.restartAvg = 1;

elseif strcmp(cmd{1}, AVG) && (rows(cmd) > 1)
  showFFTFigureConfig.numAvg = str2num(cmd{2});
  showFFTFigureConfig.restartAvg = 1;

elseif strcmp(cmd{1}, FFT) && (rows(cmd) > 1)
  showFFTFigureConfig.fftSize = str2num(cmd{2});
  showFFTFigureConfig.restartAvg = 1;

elseif strcmp(cmd{1}, GENERATE) && (rows(cmd) > 1)
  % gen freq
  % start generating sine at freq, at genAmpl level (fixed in consts.m for now)
  status = GENERATING;
  genFreq = str2num(cmd{2});
  % zeroing time
  startingT = 0;
  showFFTFigureConfig.restartAvg = 1;
elseif strcmp(cmd{1}, MEASURE) && (rows(cmd) > 2)
  % meas freq channelID
  % measure transfer of channelID against the other channel at freq, store to transf.dat
  status = MEASURING;
  transfer.freq = str2num(cmd{2});
  % channel ID for transfer measurement. The other channel receives the original signal
  transfer.channel = str2num(cmd{3});
  restartMeasuring = true;
elseif (strcmp(cmd{1}, SPLIT))
  % split joint-device calibration to DAC/ADC sides. Requires direct cal file, filter cal file at same freq, measured filter transfer file containing freq harmonics
  status = SPLITTING;
  
endif
% clear new command
cmd = cellstr(NO_CMD);
