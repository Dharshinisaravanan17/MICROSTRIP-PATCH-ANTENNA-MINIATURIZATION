function fitness = compute_fitness(x, params)
    N = params.grid_N;
    half_grid = reshape(round(x), N/2, N);
    pixel_map = [half_grid; flipud(half_grid)]; 

    % Connectivity check with Ratio
    [is_connected, ratio] = check_connectivity(pixel_map);
    if ~is_connected
        fitness = 1000 + (1 - ratio) * 1000;
        return;
    end

    results = simulate_patch(pixel_map, params, 'ga');
    f_res = results.f_res;
    target = 2.6e9;
    
    % Targeter logic
    if f_res > 2.8e9
        freq_score = 100 + (f_res / 1e6); 
    else
        freq_score = abs(f_res - target) / 1e6;
    end

    % Bandwidth check
    bw_penalty = (results.BW < params.min_BW_req) * 50;
    fitness = freq_score + bw_penalty;
end