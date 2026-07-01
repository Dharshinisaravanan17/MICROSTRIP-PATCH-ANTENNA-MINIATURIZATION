function [ant, f_feed] = build_patch_geometry(pixel_map, params)
%BUILD_PATCH_GEOMETRY  Convert a binary pixel map to a MATLAB pcbStack antenna.
%   Verified for MATLAB R2025b compatibility.

    N          = params.grid_N;
    pixel_size = params.pixel_size;

    %% --- STEP 1: Build the patch shape from ON pixels ---
    patch_shape = [];
    pixel_count = 0;

    for i = 1:N        % row index
        for j = 1:N    % column index
            if pixel_map(i, j) == 1
                cx = (j - (N+1)/2) * pixel_size;
                cy = ((N+1)/2 - i) * pixel_size;
                
                % Create 2D rectangle (Center must be 2-element vector)
                r = antenna.Rectangle( ...
                    'Length', pixel_size * 0.99, ...
                    'Width',  pixel_size * 0.99, ...
                    'Center', [cx, cy]);

                if isempty(patch_shape)
                    patch_shape = r;
                else
                    patch_shape = patch_shape + r;
                end
                pixel_count = pixel_count + 1;
            end
        end
    end

    if pixel_count < 2
        ant = []; f_feed = [0, 0]; return;
    end

    %% --- STEP 2: Create the ground plane ---
    gnd_shape = antenna.Rectangle( ...
        'Length', params.gnd_size, ...
        'Width',  params.gnd_size, ...
        'Center', [0, 0]);

    %% --- STEP 3: Find the optimal feed point ---
    f_feed = find_feed_point(pixel_map, params);

    %% --- STEP 4: Assemble pcbStack (R2025b compatible) ---
    ant = pcbStack;
    ant.Name = 'ACES_Pixelized_Patch';
    
    % Define Conductor
    ant.Conductor = metal('PEC'); 
    
    % Define Substrate
    sub = dielectric('Air');
    sub.Thickness = params.h_substrate;
    
    % Define Board Properties (Set before Layers)
    ant.BoardThickness = params.h_substrate;
    ant.BoardShape = antenna.Rectangle('Length', params.gnd_size, 'Width', params.gnd_size);
    
    % Define the stack: Top Metal (1), Dielectric (2), Bottom Metal (3)
    ant.Layers = {patch_shape, sub, gnd_shape};
    
    % Define feed: Connect Layer 1 to Layer 3 at [x, y]
    ant.FeedLocations = [f_feed(1), f_feed(2), 1, 3];
    ant.FeedDiameter  = params.feed_diameter;
end