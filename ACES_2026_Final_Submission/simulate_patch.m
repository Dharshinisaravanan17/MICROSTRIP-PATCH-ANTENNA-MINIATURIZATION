function results = simulate_patch(input_map, params, mode)
% SIMULATE_PATCH (SYMMETRIC VERSION)
% Handles the mirrored map and fixes the pattern plotting error.

    %% --- 1. Symmetry Check & Reconstruction ---
    if numel(input_map) == (params.grid_N^2 / 2)
        N = params.grid_N;
        half_grid = reshape(input_map, N/2, N);
        % Mirror the top half to the bottom to ensure symmetry
        pixel_map = [half_grid; flipud(half_grid)]; 
    else
        % If it's already a full map (like for baseline), use as is
        pixel_map = input_map;
    end

    %% --- 2. Select frequency vector based on mode ---
    if strcmp(mode, 'ga')
        freq = params.freq_GA;
    else
        freq = params.freq_final;
    end

    %% --- 3. Build the antenna geometry ---
    [ant, f_feed] = build_patch_geometry(pixel_map, params);
    
    if isempty(ant)
        results = default_bad_results(freq);
        return;
    end

    %% --- 4. Compute S-parameters ---
    try
        sp = sparameters(ant, freq);
        s11_complex = squeeze(sp.Parameters(1, 1, :));
        s11_db      = 20 * log10(abs(s11_complex));
    catch ME
        warning('sparameters failed: %s', ME.message);
        results = default_bad_results(freq);
        return;
    end

    %% --- 5. Extract resonance and bandwidth ---
    [s11_min, idx_res] = min(s11_db);
    f_res = freq(idx_res);
    
    below_10dB = s11_db < -10;
    if any(below_10dB)
        idx_start = find(below_10dB, 1, 'first');
        idx_end   = find(below_10dB, 1, 'last');
        BW = freq(idx_end) - freq(idx_start);
    else
        BW = 0;
    end

    %% --- 6. Compute Gain (Final Only) ---
    if strcmp(mode, 'final')
        try
            % Corrected pattern call for standard Toolbox compatibility
            g_data = pattern(ant, f_res, 0, 90); 
            max_gain = max(g_data(:));
        catch
            max_gain = NaN;
        end
    else
        max_gain = NaN;
    end

    %% --- 7. Package Results ---
    results.f_res    = f_res;
    results.BW       = BW;
    results.max_gain = max_gain;
    results.s11_db   = s11_db;
    results.s11_min  = s11_min;
    results.freq     = freq;
    results.ant      = ant;
    results.f_feed   = f_feed;
    results.pixel_map = pixel_map;
end

function results = default_bad_results(freq)
    results.f_res    = 1e12; 
    results.BW       = 0;
    results.max_gain = -100;
    results.s11_db   = zeros(size(freq));
    results.s11_min  = 0;
    results.freq     = freq;
    results.ant      = [];
    results.f_feed   = [0, 0];
    results.pixel_map = [];
end