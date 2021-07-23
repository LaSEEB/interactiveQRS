function interactiveQRS(data,markers,varargin)
% data:         EEGLAB-struct | cell: {vector of points, sampling frequency}
% markers:      vector | string ('event' to search in struct) | scalar (no markers, just the heart rate)
% window_width: scalar (<4>) (in number of periods to show) 
% snap:         [] | 'min' | <'max'>
%
% Eg.: 1 - add interactiveQRS folder/subfolders to path
%       2 - load('EEG.mat'), load('markers.mat')
%       3 - interactiveQRS(EEG, markers)

N_hperiods_show = 4;
snap = 'max';

% Data
if isstruct(data)
    EEG = data;
    srate = EEG.srate;
    times = EEG.times/1000;
    data = EEG.data(ismember(upper({EEG.chanlocs(:).labels}),{'ECG','EKG'}),:);
elseif iscell(data)
    srate = data{2};
    data = data{1};
    times = 0:numel(data)/srate;
end

% Markers | heart rate
if isstring(markers)
    starter_marker_lats = [EEG.event(strcmp(markers, {EEG.event(:).type})).latency];
    hrate = 1/mean(diff(times(starter_marker_lats)));
    fprintf('Estimated heart rate: %d bpm\n',hrate*60)
elseif isvector(markers)
    starter_marker_lats = markers(markers<numel(times));
    hrate = 1/mean(diff(times(starter_marker_lats)));   % in bps
    fprintf('Estimated heart rate: %d bpm\n',hrate*60)
elseif isscalar(markers)
    hrate = markers/60;
    starter_marker_lats = [];
end    

% Window width and snap
if nargin > 2
    N_hperiods_show = varargin{1};
    if nargin > 3
        snap = varargin{2};
    end
end

hperiod = 1/hrate;

% Set window constants
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

if strcmp(snap,'max')
    for i = 1:size(starter_marker_lats,2)
        lat = starter_marker_lats(i);
        snap_margin = snap_margins(i);
        [~,I] = max(data(lat - snap_margin : lat + snap_margin));
        marker_lats_snap(i) = lat - snap_margin - 1 + I;
    end
    marker_times = times(marker_lats_snap);
    markers = data(marker_lats_snap);
elseif strcmp(snap,'min')
    for i = 1:size(starter_marker_lats,2)
        lat = starter_marker_lats(i);
        snap_margin = snap_margins(i);
        [~,I] = min(data(lat - snap_margin : lat + snap_margin));
        marker_lats_snap(i) = lat - snap_margin - 1 + I;
    end
    marker_times = times(marker_lats_snap);
    markers = data(marker_lats_snap);
else
    marker_times = times(starter_marker_lats);
    markers = data(starter_marker_lats);
end

% Set window starting lims
start_margin = 1;
start = 1;
finish = L_hperiod;
finish_margin = L_hperiod+L_margin;

% Set modes
mode = 'replace'; % replace / remove
snap_modes = {'max','min','0'};
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
setappdata(fig,'snap_modes',snap_modes)
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

end


