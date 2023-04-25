function handle_legend(scr, event, mode, fs)

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

