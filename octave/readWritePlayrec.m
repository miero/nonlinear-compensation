function [buffer, fs] = readWritePlayrec(cnt, playBuffer, restart)
    global playRecConfig;
    persistent pageNumList;

    if isstruct(playRecConfig) && isfield(playRecConfig, 'recDeviceID')
        recDeviceID = playRecConfig.recDeviceID;
    else
        recDeviceID = 0;
    end
    if isstruct(playRecConfig) && isfield(playRecConfig, 'playDeviceID')
        playDeviceID = playRecConfig.playDeviceID;
    else
        playDeviceID = -1;
    end

    if isstruct(playRecConfig) && isfield(playRecConfig, 'sampleRate')
        fs = playRecConfig.sampleRate;
    else
        fs = 48000;
    end
    if isstruct(playRecConfig) && isfield(playRecConfig, 'recChanList')
        recChanList = playRecConfig.recChanList;
    else
        recChanList = [1 2];
    end
        if isstruct(playRecConfig) && isfield(playRecConfig, 'playChanList')
        playChanList = playRecConfig.playChanList;
    else
        playChanList = [1 2];
    end

    if isstruct(playRecConfig) && isfield(playRecConfig, 'pageBufCount')
        pageBufCount = playRecConfig.pageBufCount;
    else
        pageBufCount = 5;
    end

    if (cnt == -1)
        cnt = floor(fs * 0.2);
    endif

    if((ndims(recChanList)~=2) || (size(recChanList, 1)~=1))
        error ('chanList must be a row vector');
    end

    %Test if current initialisation is ok
    if(playrec('isInitialised'))
        if(playrec('getSampleRate')~=fs)
            fprintf('Changing playrec sample rate from %d to %d\n', playrec('getSampleRate'), fs);
            playrec('reset');
        elseif(playrec('getRecDevice')~=recDeviceID)
            fprintf('Changing playrec record device from %d to %d\n', playrec('getRecDevice'), recDeviceID);
            playrec('reset');
        elseif(playrec('getRecMaxChannel')<max(recChanList))
            fprintf('Resetting playrec to configure device to use more input channels\n');
            playrec('reset');
        end
    end

    %Initialise if not initialised
    if(restart || !playrec('isInitialised'))
        if (playrec('isInitialised'))
          playrec('reset');
        endif
        fprintf('Initialising playrec to use sample rate: %d, recDeviceID: %d , playDeviceID: %d\n', fs, recDeviceID, playDeviceID);
          playrec('init', fs, playDeviceID, recDeviceID, 2, 2, 10000)
        if(~playrec('isInitialised'))
            error ('Unable to initialise playrec correctly');
        elseif(playrec('getRecMaxChannel')<max(recChanList))
            error ('Selected device does not support %d output channels\n', max(recChanList));
        end
        %Clear all previous pages
        playrec('delPage');
        playrec('resetSkippedSampleCount');
        pageNumList = [];
        for page=1:pageBufCount
            pageNumList = [pageNumList playrec('rec', cnt, recChanList)];
        end
        tic();
    end

    printf('Sleeping for %f\n', cnt/fs - toc());
    % blocking read on recording side
    playrec('block', pageNumList(1));
    buffer = playrec('getRec', pageNumList(1));
    global channel;
    if (channel > 0)
      buffer = buffer(:, channel);
    endif
    playrec('delPage', pageNumList(1));
    tic();

    % FIFO - drop first element of pageNumList, read last from recDeviceID
    pageNumList = [pageNumList(2:end) playrec('playrec', playBuffer, playChanList, cnt, recChanList)];

    skipped = playrec('getSkippedSampleCount');
    if(skipped ~= 0)
        playrec('resetSkippedSampleCount');
        printf('XRUN input: %d samples lost!!\n', skipped);
    end
endfunction
