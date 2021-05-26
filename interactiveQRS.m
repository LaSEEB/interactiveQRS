function interactiveQRS(EEG,starter_marker_lats)

% Set constants
varsbefore = who; % Later, clear variables after this point (except for results)
chan_ecg = 32;
times = EEG.times/1000;
data = EEG.data(chan_ecg,:);
srate = EEG.srate;

% Get heart rate and starter markers (if any)
switch length(starter_marker_lats)
    case 0      % Empty
        hrate_markers = [EEG.event(strcmp('QRS', {EEG.event(:).type})).latency];
        hrate = 1/mean(diff(times(hrate_markers)));         % in bps
    case 1      % Value
        hrate = starter_marker_lats/60;
        starter_marker_lats = [];
    otherwise   % Vector
        hrate = 1/mean(diff(times(starter_marker_lats)));   % in bps
end

disp(['Estimated heart rate: ', num2str(round(hrate*60)), ' bpm'])
hperiod = 1/hrate;

% Set window constants
N_hperiods_show = 4;
N_hperiods_marginshow = 1;
L_hperiod = round(N_hperiods_show*hperiod*srate);
L_margin = round(N_hperiods_marginshow*hperiod*srate);
L_data = size(times, 2);
N_plots = ceil(L_data/(L_hperiod+L_margin));
mark_nhood = 0.04; % 0.04 seconds, ~4% of a normal cadiac cycle (1 second)
snap_nhood = 0.02; % seconds, ~2%
markers_checked = [];
marker_times_checked = [];

% Set key constants
right_key = {'d','rightarrow'};
left_key = {'a','leftarrow'};
replace_key = {'1'};
remove_key = {'2'};
exit_key = {'escape'};
snap_key = {'m'};

% Snap starter markers_win
snap_margins = ceil(snap_nhood * srate / 2) * ones(1,size(starter_marker_lats,2));
low_mask = (starter_marker_lats-snap_margins)<1;
high_mask = (starter_marker_lats+snap_margins)>L_data;
snap_margins(low_mask) = starter_marker_lats(low_mask)-1;
snap_margins(high_mask) = L_data - starter_marker_lats(high_mask);
marker_lats_snap = zeros(size(starter_marker_lats));
for i = 1:size(starter_marker_lats,2)
    lat = starter_marker_lats(i);
    snap_margin = snap_margins(i);
    [~,I] = max(data(lat - snap_margin : lat + snap_margin)); % Change to min to snap to valley (e.g. Q)
    marker_lats_snap(i) = lat - snap_margin - 1 + I;
end
marker_times = times(marker_lats_snap);
markers = data(marker_lats_snap);

% Set window starting lims
start_margin = 1;
start = 1;
finish = L_hperiod;
finish_margin = L_hperiod+L_margin;

% Set modes
mode = 'replace'; % replace / remove
snap = true;
disp(['Mode: ', mode])
disp(['Snap: ', num2str(snap)])

% Store window lims / mode / keys / data in figure
fig = figure;
setappdata(fig,'start_margin',start_margin)
setappdata(fig,'start',start)
setappdata(fig,'finish',finish)
setappdata(fig,'finish_margin',finish_margin)
setappdata(fig,'L_hperiod',L_hperiod)
setappdata(fig,'L_margin',L_margin)
setappdata(fig,'L_data',L_data)
setappdata(fig,'N_plots',N_plots)
setappdata(fig,'plot_id',1)
setappdata(fig,'mode',mode)
setappdata(fig,'snap',snap)
setappdata(fig,'right_key',right_key)
setappdata(fig,'left_key',left_key)
setappdata(fig,'replace_key',replace_key)
setappdata(fig,'remove_key',remove_key)
setappdata(fig,'exit_key',exit_key)
setappdata(fig,'snap_key',snap_key)
setappdata(fig,'marker_times',marker_times)
setappdata(fig,'markers',markers)
setappdata(fig,'marker_times_checked',marker_times_checked)
setappdata(fig,'markers_checked',markers_checked)
setappdata(fig,'times',times)
setappdata(fig,'data',data)
setappdata(fig,'mark_nhood',mark_nhood)
setappdata(fig,'snap_nhood',snap_nhood)
setappdata(fig,'EEG',EEG)
setappdata(fig,'starter_marker_lats',starter_marker_lats)

% Plot
figure(fig)
plot(times(start_margin:start), data(start_margin:start), 'b','HitTest','off')
hold on
plot(times(start:finish), data(start:finish),'k','HitTest','off')
hold on
plot(times(finish:finish_margin), data(finish:finish_margin), 'b','HitTest','off')
hold on
marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
marker_times_win = marker_times(marker_mask);
markers_win = markers(marker_mask);
plot(marker_times_win, markers_win,'rx','HitTest','off')
print_line = num2str(sort(marker_times_win));
fprintf([print_line, '\n'])
setappdata(fig,'L_print',size(print_line,2)+1);

% Callbacks
fig.KeyPressFcn = @KeyCallback;
fig.CloseRequestFcn = @CloseCallback;
ax = findall(fig,'type','axes','tag','');
ax.ButtonDownFcn = @ClickCallback;

% Clear
varsafter = [];
varsnew = [];
varsafter = who;
varsnew = setdiff(varsafter, varsbefore);
clear(varsnew{:})
end


