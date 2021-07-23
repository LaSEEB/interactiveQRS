function ClickCallback(ha,~)
% Get current point
currpoint = get(ha,'CurrentPoint');
currtime = currpoint(1,1);
currval = currpoint(1,2);

h = ancestor(ha,'figure');

mode = getappdata(h,'mode');
snap = getappdata(h,'snap');
marker_times = getappdata(h,'marker_times');
markers = getappdata(h,'markers');
start_margin = getappdata(h,'start_margin');
start = getappdata(h,'start');
finish = getappdata(h,'finish');
finish_margin = getappdata(h,'finish_margin');
times = getappdata(h,'times');
data = getappdata(h,'data');
mark_nhood = getappdata(h,'mark_nhood');
snap_nhood = getappdata(h,'snap_nhood');
L_print = getappdata(h,'L_print');

marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
marker_times_win = marker_times(marker_mask);
markers_win = markers(marker_mask);

% Find closest data-point
times_win = times(start_margin:finish_margin);
data_win = data(start_margin:finish_margin);
factor = (max(data_win)-min(data_win))/(max(times_win)-min(times_win));
[~,I] = min(((times_win-currtime)*factor).^2+(data_win-currval).^2);
time = times_win(I);
val = data_win(I);

% Debug
% disp(['mode = ', mode])
% disp(['time = ', num2str(time)])
% disp(['val = ', num2str(val)])

switch mode
    case 'replace'
        % Remove markers_win nearby
        markers_win(ismembertol(marker_times_win, time, mark_nhood, 'DataScale',1)) = [];
        marker_times_win(ismembertol(marker_times_win, time, mark_nhood, 'DataScale',1)) = [];
        
        % Snap
        if strcmp(snap,'max')
            mask = times_win > (time - snap_nhood / 2) & times_win < (time + snap_nhood / 2);
            data_nhood = data_win(mask);
            times_nhood = times_win(mask);
            [~,I] = max(data_nhood); % Change to min to snap to valley (e.g. Q)
            time = times_nhood(I);
            val = data_nhood(I);
        elseif strcmp(snap,'min')
            mask = times_win > (time - snap_nhood / 2) & times_win < (time + snap_nhood / 2);
            data_nhood = data_win(mask);
            times_nhood = times_win(mask);
            [~,I] = min(data_nhood); % Change to min to snap to valley (e.g. Q)
            time = times_nhood(I);
            val = data_nhood(I);
        end
        
        % Add
        marker_times_win = [marker_times_win, time];
        markers_win = [markers_win, val];
        
    case 'remove'
        % Remove markers_win nearby
        markers_win(ismembertol(marker_times_win, time, mark_nhood, 'DataScale',1)) = [];
        marker_times_win(ismembertol(marker_times_win, time, mark_nhood, 'DataScale',1)) = [];
end

% Replot
figure(h)
cla(ha)
plot(times(start_margin:start), data(start_margin:start), 'b','HitTest','off')
hold on
plot(times(start:finish), data(start:finish),'k','HitTest','off')
hold on
plot(times(finish:finish_margin), data(finish:finish_margin), 'b','HitTest','off')
hold on
plot(marker_times_win, markers_win,'rx','HitTest','off')
%     disp(['Adding: [', num2str(time), ', ',num2str(val), ']'])

% Replace stored markers_win
marker_times(marker_mask) = [];
markers(marker_mask) = [];
marker_times = [marker_times, marker_times_win];
markers = [markers, markers_win];
setappdata(h,'marker_times',marker_times);
setappdata(h,'markers',markers);
% Debug
% disp(num2str(marker_times_win))
print_line = num2str(sort(marker_times_win));
fprintf(repmat('\b',1,L_print));
fprintf([print_line, '\n'])
setappdata(h,'L_print',size(print_line,2)+1);
end