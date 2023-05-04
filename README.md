# interactiveQRS
A semi-automatic QRS detection algorithm in MATLAB. More generally, a way to interactively mark points in a signal through a moving window.

To use it, either call interactiveQRS.m as:
- data = interactiveQRS(data, markers);
- data = interactiveQRS(data, heart_rate);
- data = interactiveQRS(data, _, window_width, snap);

The first argument is either a EEGLAB struct containing the ECG signal under the channel name "ECG"/"EKG", or a cell containing the ECG (vector) and its sampling frequency (scalar).
The second argument provides an heart rate (that will determine window width), or an array of previously marked positions (the "starter markers", that could have been previously calculated with e.g. EEGLAB's pop_fmrib_qrsdetect, or deepQRS: https://github.com/LaSEEB/deepQRS) that will be used to calculate the heart rate and will be shown in the moving window.
The third argument is the number of heart periods to show in the moving window.
The fourth argument defines wether to snap the starter and selected markers to the maximum ('max') or minimum ('min') of a small neighbourhood, or to not snap at all ('0').

Once interactiveQRS.m is run, a figure will popup, with the first window of the ECG signal and some starter markers (if they were presented and are in bounds). The starter markers have already been adjusted (snapped). The windows overlap and the overlapping region(s) in each will be shown in blue. 

Here are the instructions to interact with the figure:
- To move to the previous/next window, use left/right or a/d keys.
- To mark a point, simply click on it. This will also remove any marked point in a small neighbourhood. If you want to just remove a point, press 2 ("Remove mode"). To go back to marking, press 1 ("Replace mode").
- When a click is made, the closest data point is chosen, and snapped (if snap is enabled). To switch between snapping options, toggle key m.
- When the marking is done, close the figure in the top-right x button. This will update EEG.event with the chosen marker positions (latencies), named as 'QRSi'. Finally, a second figure will appear with the starter and final markers.

Some changes to the code can also be easily made:
- To change any key, set it in % Set key constants.
- The length of the snapping neighbourhood and the removing neighbourhood can be changed in % Set window constants.

Happy markings!
