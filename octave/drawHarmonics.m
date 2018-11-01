function drawHarmonics(x, y, label, plotID, plotsCnt, use_ylim = [-140 0])
  subplot(plotsCnt,1,plotID);
  semilogx(x, y, 'linewidth', 1.5, 'color', 'black');
  grid('on');
  ylim(use_ylim)
  axis([900 10000]);
  xlabel('Frequency (Hz)', 'fontsize', 10);
  ylabel('Magnitude (dB)', 'fontsize', 10);
  title(label);
  % change the tick labels of the graph from scientific notation to floating point:
  xt = get(gca,'XTick');
  set(gca,'XTickLabel', sprintf('%.0f|',xt))
endfunction
