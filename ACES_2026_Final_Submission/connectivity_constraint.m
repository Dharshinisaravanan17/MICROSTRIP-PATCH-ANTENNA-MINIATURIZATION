function [c, ceq] = connectivity_constraint(x, params)
    N = params.grid_N;
    half_grid = reshape(round(x), N/2, N);
    pixel_map = [half_grid; flipud(half_grid)]; 
    
    is_connected = check_connectivity(pixel_map);
    % Always allow through, let fitness function handle the penalty
    c = -1; 
    ceq = []; 
end