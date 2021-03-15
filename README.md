# interactiveQRS
A semi-automatic QRS detection algorithm in MATLAB. More generally, a way to interactively mark points in a signal through a moving window.

To use it, either call main.m as:
- main(EEG, [])
- main(EEG, heart_rate)
- main(EEG, starter_marker_lats)

, with EEG being a EEGLAB struct containing the ECG signal in EEG.data(32,:). The second argument provides an heart rate (that will determine window width) or an array of previously marked positions (latencies) (perhaps automatically, e.g. w/ EEGLAB's pop_fmrib_qrsdetect) to calculate it. 
If it's empty, these positions must already be in EEG.event under the name 'QRS'. 
If it's a value, it will be read as the heart rate (bpm). 
If it's an array, they will also be plotted by the moving window (they will be called starter markers from now on). 

Once main.m is run, a figure will popup, with the first window of the ECG signal and some starter markers (if they were presented and are in bounds). The starter markers have already been adjusted (snapped) to the maximum of a small neighbourhood. The windows overlap and the overlapping region(s) in each will be shown in blue. The current marked points are also printed in the console. 

Here are the instructions to interact with the figure:
- To move to the previous/next window, use left/right or a/d keys.
- To mark a point, simply click on it. This will also remove any marked point in a small neighbourhood. If you want to just remove a point, press 2 ("Remove mode"). To go back to marking, press 1 ("Replace mode").
- When a click is made, the closest data point is chosen, but the point that will be marked is actually the maximum of a small neighbourhood. To enable/disable snapping, toggle key m.
- When the marking is done, press Esc or simply close the figure in the top-right x button. This will update EEG.event with the chosen marker positions (latencies), named as 'QRSi'. It will also save the marker times and amplitudes into two variables, final_marker_times and final_markers. Finally, a second figure will appear with the starter and final markers.

Some changes to the code can also be easily made:
- To change any key, set it in % Set key constants.
- The length of the snapping neighbourhood and the removing neighbourhood can be changed in % Set window constants.
- The width of the window and overlapping parts can also be changed in % Set window constants.
- If you want to snap (starters and/or selections) to a minimum instead of a maximum, change the 'max' to 'min' in the lines followed by % Change to min to snap to valley.

Happy markings!
