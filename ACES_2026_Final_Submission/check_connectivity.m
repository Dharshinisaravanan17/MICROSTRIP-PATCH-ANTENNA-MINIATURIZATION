function [is_connected, ratio] = check_connectivity(pixel_map)
    % Manual Flood Fill (No Toolbox Required)
    [rows, cols] = size(pixel_map);
    visited = false(rows, cols);
    
    % 1. Find the first metal pixel to start the "flood"
    % We'll look near the feed point (usually middle or edge)
    [r_idx, c_idx] = find(pixel_map, 1);
    
    if isempty(r_idx)
        is_connected = false; ratio = 0; return;
    end
    
    % 2. Flood Fill algorithm
    queue = [r_idx, c_idx];
    visited(r_idx, c_idx) = true;
    head = 1;
    
    while head <= size(queue, 1)
        curr = queue(head, :);
        head = head + 1;
        
        % Check 4-neighbors (Up, Down, Left, Right)
        neighbors = [curr(1)-1, curr(2); curr(1)+1, curr(2); ...
                     curr(1), curr(2)-1; curr(1), curr(2)+1];
        
        for i = 1:4
            nr = neighbors(i,1); nc = neighbors(i,2);
            if nr >= 1 && nr <= rows && nc >= 1 && nc <= cols
                if pixel_map(nr, nc) && ~visited(nr, nc)
                    visited(nr, nc) = true;
                    queue = [queue; nr, nc]; %#ok<AGROW>
                end
            end
        end
    end
    
    % 3. Calculate Results
    total_metal = sum(pixel_map(:));
    connected_metal = sum(visited(:));
    ratio = connected_metal / total_metal;
    
    % If all metal pixels were reached by the flood fill, it is connected
    is_connected = (connected_metal == total_metal);
end