function plotDiff(signal, plotID, plotsCnt, name)
  % plotting phase alignment of calculated reference sine and recorded at the end of the array

  % finding end of arrays
  samplesPlotted = 1000;
  endPos = length(signal);
  % align to have a nice graph
  endPos = endPos - mod(endPos, samplesPlotted);
  lowT = endPos - samplesPlotted + 1;
  highT = endPos;

  subplot(plotsCnt,1,plotID);
  ax = plotyy(
    (1:samplesPlotted), signal(1:samplesPlotted),
    (1:samplesPlotted), signal(lowT:highT)
  );
  ylabel (ax(1), "Begin");
  ylabel (ax(2), "End");
  title(name);
endfunction
