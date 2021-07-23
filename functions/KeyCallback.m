function KeyCallback(h,~)
currkey = get(h,'CurrentKey');
right_key = getappdata(h,'right_key');
left_key = getappdata(h,'left_key');
replace_key = getappdata(h,'replace_key');
remove_key = getappdata(h,'remove_key');
snap_key = getappdata(h,'snap_key');
exit_key = getappdata(h,'exit_key');
L_hperiod = getappdata(h,'L_hperiod');
L_margin = getappdata(h,'L_margin');
times = getappdata(h,'times');
ecg = getappdata(h,'ecg');
marker_times = getappdata(h,'marker_times');
markers = getappdata(h,'markers');
marker_times_checked = getappdata(h,'marker_times_checked');
markers_checked = getappdata(h,'markers_checked');
start_margin = getappdata(h,'start_margin');
start = getappdata(h,'start');
finish = getappdata(h,'finish');
finish_margin = getappdata(h,'finish_margin');
plot_id = getappdata(h,'plot_id');
N_plots = getappdata(h,'N_plots');
L_data = getappdata(h,'L_data');

switch currkey
    case left_key
        % Display last window markers
        marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
        marker_times_win = marker_times(marker_mask);
        markers_win = markers(marker_mask);
        % Store last window markers
        marker_mask_checked = marker_times_checked > times(start_margin) & marker_times_checked < times(finish_margin);
        marker_times_checked(marker_mask_checked) = [];
        markers_checked(marker_mask_checked) = [];
        marker_times_checked = [marker_times_checked, marker_times_win];
        markers_checked = [markers_checked, markers_win];
        setappdata(h,'marker_times_checked',marker_times_checked);
        setappdata(h,'markers_checked',markers_checked);
        
        switch plot_id
            case 1
                % Do nothing (already at begining)
            case 2
                finish_margin = start - 1;
                finish = start_margin - 1;
                start_margin = 1;
                start = 1;
                plot_id = plot_id - 1;
            otherwise
                finish_margin = start - 1;
                finish = start_margin - 1;
                start = start_margin - L_hperiod;
                start_margin = start_margin - L_hperiod - L_margin;
                plot_id = plot_id - 1;
        end
        % Replot
        figure(h)
        ha = findall(h,'type','axes','tag','');
        cla(ha)
        plot(times(start_margin:start), ecg(start_margin:start), 'b','HitTest','off')
        hold on
        plot(times(start:finish), ecg(start:finish),'k','HitTest','off')
        hold on
        plot(times(finish:finish_margin), ecg(finish:finish_margin), 'b','HitTest','off')
        hold on
        marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
        marker_times_win = marker_times(marker_mask);
        markers_win = markers(marker_mask);
        plot(marker_times_win, markers_win,'rx','HitTest','off')
        
        print_line = num2str(sort(marker_times_win));
        fprintf([print_line, '\n'])
        setappdata(h,'L_print',size(print_line,2)+1);
        
        % Store new lims
        setappdata(h,'start_margin',start_margin)
        setappdata(h,'start',start)
        setappdata(h,'finish',finish)
        setappdata(h,'finish_margin',finish_margin)
        setappdata(h,'plot_id',plot_id)
        
    case right_key
        % Display last window markers
        marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
        marker_times_win = marker_times(marker_mask);
        markers_win = markers(marker_mask);
        % Store last window markers
        marker_mask_checked = marker_times_checked > times(start_margin) & marker_times_checked < times(finish_margin);
        marker_times_checked(marker_mask_checked) = [];
        markers_checked(marker_mask_checked) = [];
        marker_times_checked = [marker_times_checked, marker_times_win];
        markers_checked = [markers_checked, markers_win];
        setappdata(h,'marker_times_checked',marker_times_checked);
        setappdata(h,'markers_checked',markers_checked);
        
        switch plot_id
            case N_plots
                % Do nothing (already at end)
            case N_plots-1
                start_margin = finish + 1;
                start = finish_margin + 1;
                finish = L_data;
                finish_margin = L_data;
                plot_id = plot_id + 1;
            otherwise
                start_margin = finish + 1;
                start = finish_margin + 1;
                finish = finish_margin + L_hperiod;
                finish_margin = finish_margin + L_hperiod + L_margin;
                plot_id = plot_id + 1;
        end
        % Replot
        figure(h)
        ha = findall(h,'type','axes','tag','');
        cla(ha)
        plot(times(start_margin:start), ecg(start_margin:start), 'b','HitTest','off')
        hold on
        plot(times(start:finish), ecg(start:finish),'k','HitTest','off')
        hold on
        plot(times(finish:finish_margin), ecg(finish:finish_margin), 'b','HitTest','off')
        hold on
        marker_mask = marker_times > times(start_margin) & marker_times < times(finish_margin);
        marker_times_win = marker_times(marker_mask);
        markers_win = markers(marker_mask);
        plot(marker_times_win, markers_win,'rx','HitTest','off')
        
        print_line = num2str(sort(marker_times_win));
        fprintf([print_line, '\n'])
        setappdata(h,'L_print',size(print_line,2)+1);

        % Store new lims
        setappdata(h,'start_margin',start_margin)
        setappdata(h,'start',start)
        setappdata(h,'finish',finish)
        setappdata(h,'finish_margin',finish_margin)
        setappdata(h,'plot_id',plot_id)
        
    case replace_key
        setappdata(h,'mode','replace');
        disp(['Mode: ', 'replace'])
        setappdata(h,'L_print',0);
    case remove_key
        setappdata(h,'mode','remove');
        disp(['Mode: ', 'remove'])
        setappdata(h,'L_print',0);
    case snap_key
        snap = getappdata(h,'snap');
        snap_modes = getappdata(h,'snap_modes');
        snap = snap_modes{rem(find(strcmp(snap,snap_modes))-1+1,numel(snap_modes))+1}; % Toggle between 3 states
        disp(['Snap: ', snap])
        setappdata(h,'snap',snap);
        setappdata(h,'L_print',0);
    case exit_key
        % Close figure
        close(h)
end
end