function CloseCallback(h,~)
try
times = getappdata(h,'times');
ecg = getappdata(h,'ecg');
marker_times = getappdata(h,'marker_times');
markers = getappdata(h,'markers');
marker_times_checked = getappdata(h,'marker_times_checked');
markers_checked = getappdata(h,'markers_checked');
start_margin = getappdata(h,'start_margin');
finish_margin = getappdata(h,'finish_margin');
data = getappdata(h,'data');
starter_marker_lats = getappdata(h,'starter_marker_lats');
mark_nhood = getappdata(h,'mark_nhood');
verbose = getappdata(h,'verbose');

% Store last window markers
marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
marker_times_win = marker_times(marker_mask);
markers_win = markers(marker_mask);
marker_mask_checked = marker_times_checked > times(start_margin) & marker_times_checked < times(finish_margin);
marker_times_checked(marker_mask_checked) = [];
markers_checked(marker_mask_checked) = [];
marker_times_checked = [marker_times_checked, marker_times_win];
markers_checked = [markers_checked, markers_win];
setappdata(h,'marker_times_checked',marker_times_checked);
setappdata(h,'markers_checked',markers_checked);

marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
if verbose
    disp(num2str(marker_times(marker_mask)));
end

% Save to workspace
% assignin('base','final_marker_times',marker_times);
% assignin('base','final_markers',markers);
% assignin('base','checked_marker_times',marker_times_checked);
% assignin('base','checked_markers',markers_checked);

% Update data w/ selections
marker_lats = dsearchn(times',marker_times');
if isstruct(data) % EEG
    EEG = data;
    temp_array = EEG.event(1);
    for i = 1:size(marker_lats,1)
        temp_array(i).type = 'QRSi';
        temp_array(i).latency = marker_lats(i);
    end
    EEG.event = [EEG.event, temp_array];
    [~,I] = sort([EEG.event(:).latency]);
    EEG.event = EEG.event(I);
    for i = 1:size(EEG.event,2)
        EEG.event(i).urevent = i;
    end
    % Save EEG to workspace
    % assignin('base','EEG',EEG);
    assignin('caller','EEG',EEG);
elseif iscell(data) % cell
    data = {data{1}, data{2}, marker_lats};
    assignin('caller','data',data);
end

if ~isempty(starter_marker_lats)
    [~,dists] = dsearchn(times(starter_marker_lats)', marker_times');
    N_altered = sum(dists <= mark_nhood/2 & dists > 0);
    disp(['Num. starter markers: ', num2str(size(starter_marker_lats,2))])
    disp(['Num. markers altered: ', num2str(N_altered)])
end
N_added = size(marker_times,2) - size(starter_marker_lats,2);
disp(['Num. markers added: ', num2str(N_added)])

figure
plot(times,ecg)
hold on
p1 = plot(times(starter_marker_lats),ecg(starter_marker_lats),'ok');
hold on
p2 = plot(marker_times,markers,'xr');
legend([p2,p1], {'Final markers','Starter markers'})

delete(h)

catch e
    fprintf(2,'Error in interactiveQRS CloseCallback!:\n%s',e.message);
    delete(h) 
end
end