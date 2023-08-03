function PickTimes(src,event)

% Interactively pick points in figure with ginput and display a red circle
% with data of x axis.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs





    button = 1;
    h = findobj(gca, 'Tag','PickedPoint');
    if isempty(h)
        counter = 0;
    else
        counter = numel(h);
    end

    while button == 1
        counter = counter + 1;
        [x,y, button] = ginput(1);
        if button ~= 1
            break
        end
        fprintf('Point #%d at time at %e \n',  counter, x)
        obj = plot(x,y,'Parent',gca, 'Color','r', 'Marker','o', 'HandleVisibility',...
            'off','MarkerSize',8, 'DisplayName','','Tag','PickedPoint');
%         obj.Annotation.LegendInformation.IconDisplayStyle = "off";

        text(x,y,sprintf('%.3e', x),'VerticalAlignment','bottom','HorizontalAlignment','left','HandleVisibility','off',...
                'FontSize',9)
        text(x,y,sprintf('#%d', counter),'VerticalAlignment','top','HorizontalAlignment','left','HandleVisibility','off',...
             'FontSize',15)

    end
end