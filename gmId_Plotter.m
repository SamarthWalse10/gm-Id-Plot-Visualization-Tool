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
        W = 10e-6; % Default extraction width (10um)
        plot_decimation = 10; % Decimation factor for GUI performance
        
        % --- Process NMOS ---
        df_nmos_raw.gm_Id = df_nmos_raw.GM ./ df_nmos_raw.ID;
        df_nmos_raw.gm_gds = df_nmos_raw.GM ./ df_nmos_raw.GDS;
        df_nmos_raw.gm_cgg = df_nmos_raw.GM ./ df_nmos_raw.CGG;
        df_nmos_raw.Id_W = df_nmos_raw.ID / W;
        df_nmos_raw.gm_W = df_nmos_raw.GM / W;
        df_nmos_raw.gds_Id = df_nmos_raw.GDS ./ df_nmos_raw.ID;
        df_nmos_raw.Vov = df_nmos_raw.VGS - df_nmos_raw.VTH;
        df_nmos = df_nmos_raw(1:plot_decimation:end, :);
        
        % --- Process PMOS ---
        df_pmos_raw.gm_Id = df_pmos_raw.GM ./ df_pmos_raw.ID;
        df_pmos_raw.gm_gds = df_pmos_raw.GM ./ df_pmos_raw.GDS;
        df_pmos_raw.gm_cgg = df_pmos_raw.GM ./ df_pmos_raw.CGG;
        df_pmos_raw.Id_W = df_pmos_raw.ID / W;
        df_pmos_raw.gm_W = df_pmos_raw.GM / W;
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
        
        h_legend_plots = [];
        legend_labels = {};
        
        % [OPTIMIZATION 1] Fast Native Array Extraction
        L_array = data.L;
        X_array = data.(x_param);
        Y_array = data.(y_param);
        
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
            l_str = formatLength(l_val); 
            
            color_idx = find(unique_lengths == l_val, 1);
            line_color = colors(color_idx, :);
            
            % [OPTIMIZATION 1] Fast Logical Indexing
            idx = (L_array == l_val);
            x_data = X_array(idx);
            y_data = Y_array(idx);
            
            valid_idx = ~isnan(x_data) & ~isnan(y_data);
            x_clean = x_data(valid_idx);
            y_clean = y_data(valid_idx);
            
            if isempty(x_clean); continue; end
            
            markerStyle = 'none';
            if chkMarkers.Value
                markerStyle = 'o';
            end
            
            if chkInterp.Value && length(x_clean) > 3
                [x_sorted, sort_idx] = sort(x_clean);
                y_sorted = y_clean(sort_idx);
                [x_unique, unique_idx] = unique(x_sorted);
                y_unique = y_sorted(unique_idx);
                
                if length(x_unique) > 3
                    x_dense = linspace(min(x_unique), max(x_unique), min(500, length(x_clean)*10));
                    y_dense = interp1(x_unique, y_unique, x_dense, 'spline');
                    
                    p = plot(ax, x_dense, y_dense, 'Color', line_color, 'LineWidth', 2);
                    h_legend_plots = [h_legend_plots, p];
                    legend_labels{end+1} = l_str;
                    
                    setupHoverData(p, l_str, displayNames{x_idx}, displayNames{y_idx});
                    
                    if chkMarkers.Value
                        p_mark = plot(ax, x_unique, y_unique, 'LineStyle', 'none', ...
                            'Marker', 'o', 'MarkerSize', 4, 'MarkerFaceColor', line_color, 'MarkerEdgeColor', line_color);
                        setupHoverData(p_mark, l_str, displayNames{x_idx}, displayNames{y_idx});
                    end
                    calculateIntersections(x_unique, y_unique, line_color, true);
                end
            else
                p = plot(ax, x_clean, y_clean, 'Color', line_color, 'LineWidth', 2, ...
                    'Marker', markerStyle, 'MarkerSize', 4);
                h_legend_plots = [h_legend_plots, p];
                legend_labels{end+1} = l_str;
                
                setupHoverData(p, l_str, displayNames{x_idx}, displayNames{y_idx});
                calculateIntersections(x_clean, y_clean, line_color, false);
            end
        end
        
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

    % --- Helper Function: Format Length (nm/um) ---
    function str = formatLength(L)
        if L < 0.99e-6
            str = sprintf('%gnm', round(L * 1e9, 2));
        else
            str = sprintf('%gum', round(L * 1e6, 2));
        end
    end

    % --- Helper Function: Custom Hover Data (DataTips) ---
    function setupHoverData(plotObj, l_str, x_name, y_name)
        try
            numPts = length(plotObj.XData);
            % [OPTIMIZATION 3] Native Cell Arrays instead of Strings to prevent memory thrashing
            L_array = repmat({l_str}, numPts, 1);
            plotObj.DataTipTemplate.DataTipRows(1) = dataTipTextRow('L', L_array);
            plotObj.DataTipTemplate.DataTipRows(2) = dataTipTextRow(x_name, plotObj.XData);
            plotObj.DataTipTemplate.DataTipRows(3) = dataTipTextRow(y_name, plotObj.YData);
        catch
        end
    end

    % --- Helper Function: Intersections ---
    function calculateIntersections(x_pts, y_pts, pColor, isInterpolated)
        if chkXGuide.Value
            x_target = edtXGuide.Value;
            if isInterpolated && min(x_pts) <= x_target && max(x_pts) >= x_target
                y_int = interp1(x_pts, y_pts, x_target, 'spline');
                plot(ax, x_target, y_int, 'o', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
            elseif ~isInterpolated
                [~, idx] = min(abs(x_pts - x_target));
                plot(ax, x_pts(idx), y_pts(idx), 'o', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
            end
        end
        
        if chkYGuide.Value
            y_target = edtYGuide.Value;
            if isInterpolated && min(y_pts) <= y_target && max(y_pts) >= y_target
                % [OPTIMIZATION 2] Reduced root-finding resolution from 1000 to 200 points
                % This maintains sub-pixel visual accuracy for the diamond marker but executes 5x faster
                x_dense = linspace(min(x_pts), max(x_pts), 200);
                y_dense = interp1(x_pts, y_pts, x_dense, 'spline');
                [min_dist, idx] = min(abs(y_dense - y_target));
                if min_dist < (max(y_dense) - min(y_dense))*0.05
                    plot(ax, x_dense(idx), y_dense(idx), 'd', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
                end
            elseif ~isInterpolated
                [~, idx] = min(abs(y_pts - y_target));
                plot(ax, x_pts(idx), y_pts(idx), 'd', 'MarkerSize', 10, 'MarkerFaceColor', pColor, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
            end
        end
    end
end