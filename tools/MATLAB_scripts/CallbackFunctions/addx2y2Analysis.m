function addx2y2Analysis(src, evt,offset,axisObj)
% Make interactively a NMO velocity estimation in B-scan.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% offset        : [nx1] vector containing offset information of x axis
% axisObj       : axis object 

if nargin < 4 || isempty(axisObj)
    axisObj = gca;
end

[~, t0] = ginput(1);

v_stack = 0.1; % m/ns
v_stack_max = 0.2;
v_stack_min = 0.0;

offset = offset - offset(1);

t_nmoFormula = @(t0,offset,v_stack) sqrt(t0^2 + offset.^2 ./ (v_stack^2));

h = plot(offset,t_nmoFormula(t0,offset,v_stack) ,'Tag','velocityEst','Color','white','LineWidth',3);
txt  = text((offset(1)+offset(3))/2, (h.YData(3) + h.YData(1))/2, sprintf('v_stack = %.4f m/ns',v_stack),...
        'Tag', 'velocityEst','Color','white','FontSize',10,'Interpreter','none');


f = figure;

% create GUI with 
bgcolor = f.Color;
b = uicontrol('Parent',f,'Style','slider','Position',[81,54,419,23],...
              'value',v_stack, 'min',v_stack_min, 'max',v_stack_max);
bl1 = uicontrol('Parent',f,'Style','text','Position',[50,54,23,23],...
                'String',num2str(v_stack_min),'BackgroundColor',bgcolor);
bl2 = uicontrol('Parent',f,'Style','text','Position',[500,54,23,23],...
                'String',num2str(v_stack_max),'BackgroundColor',bgcolor);
bl3 = uicontrol('Parent',f,'Style','text','Position',[240,25,100,23],...
                'String',sprintf('v_stack = %f m/ns',b.Value),'BackgroundColor',bgcolor);

b.Callback = {@updatePlot,h,txt,t_nmoFormula,t0,offset,bl3};

h.DisplayName = sprintf('v_stack = %.4f m/ns', v_stack);
end

function updatePlot(src,evt,h,txt,t_nmoFormula,t0,offset,bl3)
    v_stack = src.Value ;
    h.YData = t_nmoFormula(t0,offset,v_stack);
    h.DisplayName = sprintf('v_stack = %.4f m/ns', v_stack);
    bl3.String = sprintf('v_stack = %.4f m/ns',v_stack);
    txt.String = sprintf('v_stack = %.4f m/ns',v_stack);
    txt.Position = [(h.XData(3)+h.XData(1))/2, (h.YData(3) + h.YData(1))/2];
end