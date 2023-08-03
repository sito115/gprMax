function estimateVelocity(src, event, data, fh1)

% Estimate velocity in B-scan by selecting two points.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% data          : structure - containing information of loaded .out-Files 
% fh1           : figure handle for ginput [optional]


if nargin < 4 || isempty(fh1)
    fh1 = gcf;
end


fn  = fieldnames(data);
atr = data.(fn{1}).Attributes.RxData;
drx = diff(atr.Position);
drx = round(drx,5);
drx = unique(drx, 'rows');
offset = data.(fn{1}).Attributes.Offset_x;

if size(drx,1) > 1
    warning('Multiple different receiver spacings detected') 
end
drx = drx(drx(1,:) > 0) ;

[x_raw,time] = ginput(2);

[~,idx] = min(abs(x_raw'-offset));
x = offset(idx);

t     = time./1e9;
m     = ((t(2) - t(1))/(x(2)-x(1)));
t0    = t(2) - m*x(2);
fprintf('Formula: y = %.4e * x + %.4e\n', m, t0)

f = gcf;
f.UserData.m  = m;
f.UserData.t0 = t0;

v     = 1/m;
eps   = (3e8/v)^2;
currentLine = plot(x,time,'DisplayName', sprintf('%.3f m/ns',v/1e9), 'Parent', gca, 'Tag', 'velocityEst',...
                   'LineWidth',3.5,'Color','white');
currentLine.UserData.ShowLine = true;
txt = text((x(2)+x(1))/2, (time(2) + time(1))/2,sprintf('%.3f m/ns (\\epsilon_r = %.2f)',v/1e9,eps),...
    'Tag', 'velocityEst','Color','black');
txt.UserData.ShowLine = true;
txt.FontWeight = 'bold';
txt.FontSize = 13;

end