function gmId_Plotter()
    % Suppress the specific warning caused by plotting negative Vov on a Log scale
    warning('off', 'MATLAB:Axes:NegativeDataInLogAxis');
    warning('off', 'MATLAB:Axes:NegativeXDataInLogAxis');
    warning('off', 'MATLAB:Axes:NegativeYDataInLogAxis');
    
    % ==========================================
    % 1. SMART DATA LOADING AND CACHING
    % ==========================================
    disp('======================================================');
    disp('    gm/Id Plot Visualization Tool Initiated           ');
    disp('======================================================');
    
    csv_nmos_file = 'nmos_LUT.csv';
    csv_pmos_file = 'pmos_LUT.csv';
    cache_file = 'gmId_cache.mat';
    
    nmos_info = dir(csv_nmos_file);
    pmos_info = dir(csv_pmos_file);
    
    if isempty(nmos_info) || isempty(pmos_info)
        error('FATAL ERROR: Could not find nmos_LUT.csv or pmos_LUT.csv in the current directory.');
    end
    
    use_cache = false;
    
    disp('[1/4] Checking fast cache (.mat) status...');
    if isfile(cache_file)
        try
            cache = load(cache_file);
            % If the CSV files were updated via Cadence, the datenum/bytes will mismatch 
            % and automatically trigger a fresh extraction, ensuring dynamic W is captured.
            if isequal(cache.nmos_bytes, nmos_info.bytes) && isequal(cache.nmos_date, nmos_info.datenum) && ...
               isequal(cache.pmos_bytes, pmos_info.bytes) && isequal(cache.pmos_date, pmos_info.datenum)
                use_cache = true;
            end
        catch
            use_cache = false;
        end
    end
    paramNames = {'gm_Id', 'gm_gds', 'gm_cgg', 'Id_W', 'gm_W', 'gds_Id', 'Vov'};
    displayNames = {'gm/Id', 'gm/gds', 'gm/cgg', 'Id/W', 'gm/W', 'gds/Id', 'Vov'};
    
    if use_cache
        disp('  -> Cache hit! Files unchanged. Loading pre-processed data into memory...');
        df_nmos = cache.df_nmos;
        df_pmos = cache.df_pmos;
        unique_lengths = cache.unique_lengths;
        length_strs = cache.length_strs;
    else
        disp('  -> Cache miss or CSVs modified. Parsing raw CSVs... (This may take a moment based on RAM)');
        
        df_nmos_raw = readtable(csv_nmos_file);
        df_pmos_raw = readtable(csv_pmos_file);
        plot_decimation = 10; % Decimation factor for GUI performance
        
        % --- Process NMOS ---
        df_nmos_raw.gm_Id = df_nmos_raw.GM ./ df_nmos_raw.ID;
        df_nmos_raw.gm_gds = df_nmos_raw.GM ./ df_nmos_raw.GDS;
        df_nmos_raw.gm_cgg = df_nmos_raw.GM ./ df_nmos_raw.CGG;
        df_nmos_raw.Id_W = df_nmos_raw.ID ./ df_nmos_raw.W; % DYNAMIC WIDTH SCALING
        df_nmos_raw.gm_W = df_nmos_raw.GM ./ df_nmos_raw.W; % DYNAMIC WIDTH SCALING
        df_nmos_raw.gds_Id = df_nmos_raw.GDS ./ df_nmos_raw.ID;
        df_nmos_raw.Vov = df_nmos_raw.VGS - df_nmos_raw.VTH;
        df_nmos = df_nmos_raw(1:plot_decimation:end, :);
        
        % --- Process PMOS ---
        df_pmos_raw.gm_Id = df_pmos_raw.GM ./ df_pmos_raw.ID;
        df_pmos_raw.gm_gds = df_pmos_raw.GM ./ df_pmos_raw.GDS;
        df_pmos_raw.gm_cgg = df_pmos_raw.GM ./ df_pmos_raw.CGG;
        df_pmos_raw.Id_W = df_pmos_raw.ID ./ df_pmos_raw.W; % DYNAMIC WIDTH SCALING
        df_pmos_raw.gm_W = df_pmos_raw.GM ./ df_pmos_raw.W; % DYNAMIC WIDTH SCALING
        df_pmos_raw.gds_Id = df_pmos_raw.GDS ./ df_pmos_raw.ID;
        df_pmos_raw.Vov = abs(df_pmos_raw.VGS) - abs(df_pmos_raw.VTH); 
        df_pmos = df_pmos_raw(1:plot_decimation:end, :);
        
        % Extract unique lengths and format them for display
        unique_lengths = unique(df_nmos.L);
        length_strs = arrayfun(@formatLength, unique_lengths, 'UniformOutput', false);
        
        % --- Save to Cache ---
        disp('  -> Generating new fast cache (.mat) for future runs...');
        nmos_bytes = nmos_info.bytes; nmos_date = nmos_info.datenum;
        pmos_bytes = pmos_info.bytes; pmos_date = pmos_info.datenum;
        
        save(cache_file, 'df_nmos', 'df_pmos', 'unique_lengths', 'length_strs', ...
                         'nmos_bytes', 'nmos_date', 'pmos_bytes', 'pmos_date');
        disp('  -> Cache successfully saved.');
    end
    
    fprintf('[2/4] Data loaded successfully. Detected %d unique channel lengths.\n', length(unique_lengths));
    disp('[3/4] Initializing interactive GUI layout...');
    
    % ==========================================
    % 2. GUI INITIALIZATION
    % ==========================================
    fig = uifigure('Name', 'Interactive gm/Id Plotter', 'Position', [100 100 1150 600]);
    gl = uigridlayout(fig, [1 2]);
    gl.ColumnWidth = {250, '1x'};
    leftPanel = uipanel(gl);
    ax = uiaxes(gl);
    ax.XGrid = 'on'; ax.YGrid = 'on';
    datacursormode(fig, 'on');
    
    % --- UI Controls ---
    uilabel(leftPanel, 'Text', 'Transistor:', 'Position', [10 550 80 22], 'FontWeight', 'bold');
    ddTransistor = uidropdown(leftPanel, 'Items', {'NMOS', 'PMOS'}, 'Position', [100 550 130 22]);
    uilabel(leftPanel, 'Text', 'Y-Axis:', 'Position', [10 510 80 22], 'FontWeight', 'bold');
    ddY = uidropdown(leftPanel, 'Items', displayNames, 'ItemsData', paramNames, 'Value', 'gm_gds', 'Position', [100 510 130 22]);
    uilabel(leftPanel, 'Text', 'X-Axis:', 'Position', [10 470 80 22], 'FontWeight', 'bold');
    ddX = uidropdown(leftPanel, 'Items', displayNames, 'ItemsData', paramNames, 'Value', 'gm_Id', 'Position', [100 470 130 22]);
    uilabel(leftPanel, 'Text', 'Lengths (L):', 'Position', [10 430 80 22], 'FontWeight', 'bold');
    
    default_indices = round(linspace(1, length(unique_lengths), min(6, length(unique_lengths))));
    lbL = uilistbox(leftPanel, 'Items', length_strs, 'ItemsData', unique_lengths, ...
        'Multiselect', 'on', 'Value', unique_lengths(default_indices), 'Position', [10 320 220 100]);
    
    % --- Guide Lines ---
    uilabel(leftPanel, 'Text', 'Guide Lines:', 'Position', [10 280 100 22], 'FontWeight', 'bold');
    chkXGuide = uicheckbox(leftPanel, 'Text', 'X Value:', 'Position', [10 250 80 22]);
    edtXGuide = uieditfield(leftPanel, 'numeric', 'Position', [100 250 130 22], 'Value', 10.0);
    chkYGuide = uicheckbox(leftPanel, 'Text', 'Y Value:', 'Position', [10 220 80 22]);
    edtYGuide = uieditfield(leftPanel, 'numeric', 'Position', [100 220 130 22], 'Value', 100.0);
    
    % --- Toggles ---
    chkInterp = uicheckbox(leftPanel, 'Text', 'Real Time Interpolation', 'Value', 1, 'Position', [10 170 200 22], 'FontWeight', 'bold');
    chkMarkers = uicheckbox(leftPanel, 'Text', 'Show Markers', 'Value', 0, 'Position', [10 140 200 22], 'FontWeight', 'bold');
    uilabel(leftPanel, 'Text', 'X Scale:', 'Position', [10 90 60 22]);
    ddXScale = uidropdown(leftPanel, 'Items', {'linear', 'log'}, 'Position', [70 90 80 22]);
    uilabel(leftPanel, 'Text', 'Y Scale:', 'Position', [10 50 60 22]);
    ddYScale = uidropdown(leftPanel, 'Items', {'linear', 'log'}, 'Position', [70 50 80 22]);
    
    % --- Assign Callbacks ---
    ddTransistor.ValueChangedFcn = @(src, event) updatePlot();
    ddY.ValueChangedFcn = @(src, event) updatePlot();
    ddX.ValueChangedFcn = @(src, event) updatePlot();
    lbL.ValueChangedFcn = @(src, event) updatePlot();
    chkInterp.ValueChangedFcn = @(src, event) updatePlot();
    chkMarkers.ValueChangedFcn = @(src, event) updatePlot();
    ddXScale.ValueChangedFcn = @(src, event) updatePlot();
    ddYScale.ValueChangedFcn = @(src, event) updatePlot();
    chkXGuide.ValueChangedFcn = @(src, event) updatePlot();
    chkYGuide.ValueChangedFcn = @(src, event) updatePlot();
    
    edtXGuide.ValueChangedFcn = @(src, event) autoCheckXGuide();
    edtYGuide.ValueChangedFcn = @(src, event) autoCheckYGuide();
    
    function autoCheckXGuide()
        chkXGuide.Value = 1; updatePlot();
    end
    function autoCheckYGuide()
        chkYGuide.Value = 1; updatePlot();
    end
    
    colors = lines(length(unique_lengths));
    
    disp('[4/4] GUI Ready. Render completely silent and optimized.');
    updatePlot();
    
    % ==========================================
    % 3. MAIN PLOTTING ENGINE (OPTIMIZED)
    % ==========================================
    function updatePlot()
        cla(ax);
        
        ax.XLimMode = 'auto';
        ax.YLimMode = 'auto';
        
        if strcmp(ddTransistor.Value, 'NMOS')
            data = df_nmos;
        else
            data = df_pmos;
        end
        
        selected_L_vals = lbL.Value; 
        x_param = ddX.Value;
        y_param = ddY.Value;
        x_idx = strcmp(paramNames, x_param);
        y_idx = strcmp(paramNames, y_param);
        
        % Preallocate arrays to prevent MATLAB memory reallocation warnings
        num_selected = length(selected_L_vals);
        h_legend_plots = gobjects(1, num_selected); 
        legend_labels = cell(1, num_selected);
        valid_plot_count = 0; % Counter for successfully plotted lines
        
        % Fast Native Array Extraction
        L_array = data.L;
        W_array = data.W; % Dynamically loaded Width array (Used for calculation, hidden in display)
        X_array = data.(x_param);
        Y_array = data.(y_param);
        Vov_array = data.Vov; % Using Vov as the robust physical sorting parameter
        
        % --- Pre-calculate Bounds for Guide Line Clamping ---
        mask = ismember(L_array, selected_L_vals);
        x_all = X_array(mask);
        y_all = Y_array(mask);
        
        valid_idx_all = ~isnan(x_all) & ~isnan(y_all);
        x_all = x_all(valid_idx_all);
        y_all = y_all(valid_idx_all);
        
        if ~isempty(x_all)
            min_x = min(x_all); max_x = max(x_all);
            min_y = min(y_all); max_y = max(y_all);
            
            if chkXGuide.Value
                if edtXGuide.Value < min_x, edtXGuide.Value = min_x; end
                if edtXGuide.Value > max_x, edtXGuide.Value = max_x; end
            end
            if chkYGuide.Value
                if edtYGuide.Value < min_y, edtYGuide.Value = min_y; end
                if edtYGuide.Value > max_y, edtYGuide.Value = max_y; end
            end
        end
        
        hold(ax, 'on');
        
        for i = 1:length(selected_L_vals)
            l_val = selected_L_vals(i);
            
            color_idx = find(unique_lengths == l_val, 1);
            line_color = colors(color_idx, :);
            
            % Fast Logical Indexing
            idx = (L_array == l_val);
            x_data = X_array(idx);
            y_data = Y_array(idx);
            vov_data = Vov_array(idx);
            w_data = W_array(idx);
            
            % Ensure no NaNs exist in any of the arrays used for interpolation
            valid_idx = ~isnan(x_data) & ~isnan(y_data) & ~isnan(vov_data) & ~isnan(w_data);
            x_clean = x_data(valid_idx);
            y_clean = y_data(valid_idx);
            vov_clean = vov_data(valid_idx);
            
            if isempty(x_clean); continue; end
            
            % Increment plot counter for preallocation indexing
            valid_plot_count = valid_plot_count + 1;
            
            % Extract the exact length for Legend & DataTips
            l_str = formatLength(l_val); 
            
            % Create a dynamic label that shows ONLY L
            display_str = sprintf('L = %s', l_str);
            
            markerStyle = 'none';
            if chkMarkers.Value
                markerStyle = 'o';
            end
            
            % [ROBUST PARAMETRIC INTERPOLATION FIX]
            % Sort data purely by the physical sweep variable (Vov) to fix out-of-order CSV points
            [vov_sorted, sort_idx] = sort(vov_clean);
            x_sorted = x_clean(sort_idx);
            y_sorted = y_clean(sort_idx);
            
            % Remove duplicate Vov points to guarantee strict monotonic progression for spline
            [vov_unique, unique_idx] = unique(vov_sorted);
            x_unique = x_sorted(unique_idx);
            y_unique = y_sorted(unique_idx);
            
            if chkInterp.Value && length(x_unique) > 3
                % Generate a dense array based purely on Vov
                vov_dense = linspace(min(vov_unique), max(vov_unique), min(1000, length(vov_unique)*10));
                
                % Interpolate X and Y independently against Vov
                x_dense = interp1(vov_unique, x_unique, vov_dense, 'spline');
                y_dense = interp1(vov_unique, y_unique, vov_dense, 'spline');
                
                p = plot(ax, x_dense, y_dense, 'Color', line_color, 'LineWidth', 2);
                h_legend_plots(valid_plot_count) = p;
                legend_labels{valid_plot_count} = display_str;
                
                setupHoverData(p, display_str, displayNames{x_idx}, displayNames{y_idx});
                
                if chkMarkers.Value
                    p_mark = plot(ax, x_unique, y_unique, 'LineStyle', 'none', ...
                        'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', line_color, 'MarkerEdgeColor', line_color);
                    setupHoverData(p_mark, display_str, displayNames{x_idx}, displayNames{y_idx});
                end
                
                % Pass the high-res dense curve straight to the intersection function
                calculateIntersections(x_dense, y_dense, line_color);
            else
                p = plot(ax, x_unique, y_unique, 'Color', line_color, 'LineWidth', 2, ...
                    'Marker', markerStyle, 'MarkerSize', 4);
                h_legend_plots(valid_plot_count) = p;
                legend_labels{valid_plot_count} = display_str;
                
                setupHoverData(p, display_str, displayNames{x_idx}, displayNames{y_idx});
                calculateIntersections(x_unique, y_unique, line_color);
            end
        end
        
        % Trim preallocated arrays to remove any empty spaces from skipped lengths
        h_legend_plots = h_legend_plots(1:valid_plot_count);
        legend_labels = legend_labels(1:valid_plot_count);
        
        if chkXGuide.Value
            xline(ax, edtXGuide.Value, '--k', 'LineWidth', 1.5, 'Alpha', 0.5);
        end
        if chkYGuide.Value
            yline(ax, edtYGuide.Value, '--k', 'LineWidth', 1.5, 'Alpha', 0.5);
        end
        
        hold(ax, 'off');
        
        xlabel(ax, displayNames{x_idx}, 'FontWeight', 'bold');
        ylabel(ax, displayNames{y_idx}, 'FontWeight', 'bold');
        title(ax, sprintf('%s - %s vs %s', ddTransistor.Value, displayNames{y_idx}, displayNames{x_idx}));
        
        ax.XScale = ddXScale.Value;
        ax.YScale = ddYScale.Value;
        
        if ~isempty(h_legend_plots)
            legend(ax, h_legend_plots, legend_labels, 'Location', 'northeastoutside');
        else
            legend(ax, 'hide');
        end
    end

    % ==========================================
    % HELPER FUNCTIONS (Formatting & Interactivity)
    % ==========================================

    % --- Helper Function: Format Length/Width (nm/um) ---
    function str = formatLength(val)
        if val < 0.99e-6
            str = sprintf('%g nm', round(val * 1e9, 2));
        else
            str = sprintf('%g %sm', round(val * 1e6, 2), char(181)); 
        end
    end

    % --- Helper Function: Vectorized String Formatting (mV vs V) ---
    function str_array = getFormattedStrings(name, data_array)
        str_array = strings(size(data_array));
        if strcmp(name, 'Vov')
            mV_mask = abs(data_array) > 0 & abs(data_array) < 1;
            if any(mV_mask(:))
                str_array(mV_mask) = compose('%s = %gmV', name, data_array(mV_mask) * 1000);
            end
            if any(~mV_mask(:))
                str_array(~mV_mask) = compose('%s = %gV', name, data_array(~mV_mask));
            end
        else
            str_array = compose(sprintf('%s = %%g', name), data_array);
        end
    end

    % --- Helper Function: Custom Hover Data (DataTips) ---
    function setupHoverData(plotObj, display_str, x_name, y_name)
        try
            numPts = length(plotObj.XData);
            % Display_str contains 'L = ...' format
            Label_array = repmat({display_str}, numPts, 1);
            x_str_array = getFormattedStrings(x_name, plotObj.XData);
            y_str_array = getFormattedStrings(y_name, plotObj.YData);
            
            plotObj.DataTipTemplate.DataTipRows(1) = dataTipTextRow('', Label_array);
            plotObj.DataTipTemplate.DataTipRows(2) = dataTipTextRow('', x_str_array);
            plotObj.DataTipTemplate.DataTipRows(3) = dataTipTextRow('', y_str_array);
        catch
        end
    end

    % --- Helper Function: Intersections ---
    function calculateIntersections(x_curve, y_curve, pColor)
        if chkXGuide.Value
            x_target = edtXGuide.Value;
            if min(x_curve) <= x_target && max(x_curve) >= x_target
                [min_dist, idx] = min(abs(x_curve - x_target));
                if min_dist < (max(x_curve) - min(x_curve))*0.05
                    plot(ax, x_target, y_curve(idx), 'o', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
                end
            end
        end
        
        if chkYGuide.Value
            y_target = edtYGuide.Value;
            if min(y_curve) <= y_target && max(y_curve) >= y_target
                [min_dist, idx] = min(abs(y_curve - y_target));
                if min_dist < (max(y_curve) - min(y_curve))*0.05
                    plot(ax, x_curve(idx), y_target, 'd', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
                end
            end
        end
    end
end
