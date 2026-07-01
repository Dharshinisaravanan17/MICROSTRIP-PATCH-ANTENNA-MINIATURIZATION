function f_feed = find_feed_point(pixel_map, params)
%FIND_FEED_POINT  Find the best coaxial probe feed location.
%
%  CONCEPT:
%    A microstrip patch antenna needs a feed point where the input impedance
%    is closest to 50 ohms (the standard transmission line impedance).
%    For a rectangular patch, this is typically along the centerline (y=0),
%    at a specific distance from the edge of the patch.
%
%    For a pixelized patch, we:
%    1. Find the centroid (center of mass) of all ON pixels
%    2. Sweep potential feed positions along the dominant axis
%    3. Choose the position that is approximately at the 1/5 point from edge
%       (a common rule-of-thumb for near-50-ohm feed location)
%
%  ALTERNATIVE (more accurate but slower):
%    Use impedance() function to compute actual impedance at each candidate
%    feed point and choose the one closest to 50 ohms. Uncomment that section
%    if you want more accuracy (it runs a full EM simulation per feed point).
%
%  INPUTS:
%    pixel_map - NxN binary matrix
%    params    - Parameter struct
%
%  OUTPUT:
%    f_feed    - [x, y] optimal feed location in meters

    N          = params.grid_N;
    pixel_size = params.pixel_size;

    %% --- Find the centroid and bounding box of the patch ---
    [rows, cols] = find(pixel_map == 1);

    if isempty(rows)
        f_feed = [0, 0];
        return;
    end

    % Bounding box in pixel indices
    row_min = min(rows);  row_max = max(rows);
    col_min = min(cols);  col_max = max(cols);

    % Convert bounding box to physical coordinates (meters)
    x_left  = (col_min - (N+1)/2 - 0.5) * pixel_size;
    x_right = (col_max - (N+1)/2 + 0.5) * pixel_size;
    y_bot   = ((N+1)/2 - row_max - 0.5) * pixel_size;
    y_top   = ((N+1)/2 - row_min + 0.5) * pixel_size;

    patch_length = x_right - x_left;
    patch_height = y_top   - y_bot;

    % Centroid of patch (y center for horizontal feed sweep)
    y_center = (y_top + y_bot) / 2;

    %% --- Feed point by rule of thumb ---
    % For a half-wave resonant patch, the input impedance at the edge is ~200-300 ohms.
    % Moving the feed inward by ~L/5 from the edge typically gives ~50 ohms.
    % We place the feed at 1/5 of the patch length from the leading edge.

    feed_offset = patch_length / 5;
    x_feed      = x_left + feed_offset;

    %% --- Verify the feed point is on a metal pixel ---
    % Convert proposed feed location back to pixel indices
    feed_col = round((x_feed / pixel_size) + (N+1)/2);
    feed_row = round((N+1)/2 - (y_center / pixel_size));

    % Clamp to valid range
    feed_col = max(1, min(N, feed_col));
    feed_row = max(1, min(N, feed_row));

    % If the feed is not on metal, find the nearest metal pixel
    if pixel_map(feed_row, feed_col) == 0
        % Search outward from (feed_row, feed_col) for nearest metal pixel
        min_dist = inf;
        best_r   = feed_row;
        best_c   = feed_col;

        for r = 1:N
            for c = 1:N
                if pixel_map(r, c) == 1
                    d = (r - feed_row)^2 + (c - feed_col)^2;
                    if d < min_dist
                        min_dist = d;
                        best_r   = r;
                        best_c   = c;
                    end
                end
            end
        end

        feed_row = best_r;
        feed_col = best_c;
    end

    % Convert best pixel back to physical coordinates
    x_feed = (feed_col - (N+1)/2) * pixel_size;
    y_feed = ((N+1)/2 - feed_row) * pixel_size;

    f_feed = [x_feed, y_feed];

    %% --- OPTIONAL: Impedance sweep for accurate 50-ohm matching ---
    % Uncomment this block for better accuracy (significantly slower).
    %
    % n_candidates = 8;
    % x_candidates = linspace(x_left + patch_length/8, x_left + patch_length/2, n_candidates);
    % best_z_diff  = inf;
    % for k = 1:n_candidates
    %     [ant_test, ~] = build_patch_geometry_with_feed(pixel_map, params, [x_candidates(k), y_center]);
    %     try
    %         Z = impedance(ant_test, params.f0_initial);
    %         z_diff = abs(real(Z) - 50) + abs(imag(Z));
    %         if z_diff < best_z_diff
    %             best_z_diff = z_diff;
    %             f_feed = [x_candidates(k), y_center];
    %         end
    %     catch
    %         continue;
    %     end
    % end

end
