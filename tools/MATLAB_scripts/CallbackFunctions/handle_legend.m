function handle_legend(scr, event, mode, fs)
% Handle legend object (hide or show it).
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% mode          : character  - show/hide
% fs            : double - font size of legend entries


legend = findobj(gcf, 'Type','Legend');

nLegend = numel(legend);

switch mode
    case 'show'
        for i = 1:nLegend
            legend(i).Visible = 'on';
            legend(i).FontSize = fs;
        end
    case 'hide'
        for i = 1:nLegend
            legend(i).Visible = 'off';
            legend(i).FontSize = 0.0001;

        end
end

