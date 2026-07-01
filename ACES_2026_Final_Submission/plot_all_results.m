function plot_all_results(baseline, opt, pixel_map, params)
%PLOT_ALL_RESULTS  Generate all plots required by the ACES competition.
% Updated to fix 'eff' field error and pattern plotting compatibility.

    f_res = opt.f_res;
    ant   = opt.ant;
    fprintf('  Generating plots...\n');

    %% ===== FIGURE 1: S11 vs Frequency =====
    fig1 = figure('Name', 'S11 vs Frequency', 'Position', [100, 100, 800, 500]);
    hold on; grid on;
    
    plot(baseline.freq/1e9, baseline.s11_db, 'b--', 'LineWidth', 2, 'DisplayName', ...
        sprintf('Baseline (%.3f GHz)', baseline.f_res/1e9));
    plot(opt.freq/1e9,      opt.s11_db,      'r-',  'LineWidth', 2.5, 'DisplayName', ...
        sprintf('Optimized (%.3f GHz)', opt.f_res/1e9));
    
    yline(-10, 'k--', '-10 dB threshold', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
    
    plot(baseline.f_res/1e9, baseline.s11_min, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    plot(opt.f_res/1e9,      opt.s11_min,      'rv', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r');
    
    % Span ±1 GHz around resonant frequency
    xlim([(opt.f_res - 1e9)/1e9, (opt.f_res + 1e9)/1e9]);
    ylim([-40, 5]);
    xlabel('Frequency (GHz)', 'FontSize', 14);
    ylabel('S_{11} (dB)',     'FontSize', 14);
    title(sprintf('Reflection Coefficient vs Frequency\nResonance: %.3f GHz | BW: %.1f MHz', ...
        opt.f_res/1e9, opt.BW/1e6), 'FontSize', 13);
    legend('Location', 'southeast', 'FontSize', 11);
    saveas(fig1, 'ACES_S11_vs_Frequency.png');
    fprintf('    Saved: ACES_S11_vs_Frequency.png\n');

    %% ===== FIGURE 2-5: Far-Field Patterns =====
    if ~isempty(ant)
        try
            % --- x-y plane (azimuth cut) ---
            fig2 = figure('Name', 'Pattern: x-y plane');
            pattern(ant, f_res, 0:360, 0); 
            title(sprintf('Realized Gain - x-y Plane (El=0°)\nf = %.3f GHz', f_res/1e9));
            saveas(fig2, 'ACES_Pattern_XY_plane.png');

            % --- x-z plane (elevation cut) ---
            fig3 = figure('Name', 'Pattern: x-z plane');
            pattern(ant, f_res, 0, 0:360); 
            title(sprintf('Realized Gain - x-z Plane (Az=0°)\nf = %.3f GHz', f_res/1e9));
            saveas(fig3, 'ACES_Pattern_XZ_plane.png');

            % --- 3D Far-field pattern ---
            fig5 = figure('Name', '3D Far-Field Pattern');
            pattern(ant, f_res);
            title(sprintf('3D Realized Gain Pattern\nf = %.3f GHz', f_res/1e9));
            saveas(fig5, 'ACES_3D_Pattern.png');
        catch ME
            fprintf('    Note: Radiation patterns skipped/limited: %s\n', ME.message);
        end
    end

    %% ===== FIGURE 6: Pixel Map Visualization =====
    fig6 = figure('Name', 'Optimized Pixel Map', 'Position', [600, 100, 600, 650]);
    N = params.grid_N;
    pixel_size_mm = (params.patch_max / N) * 1000;
    
    hold on; axis equal; box on;
    for i = 1:N
        for j = 1:N
            x_left = (j-1) * pixel_size_mm;
            y_bot  = (N-i) * pixel_size_mm;
            if pixel_map(i, j) == 1
                rectangle('Position', [x_left, y_bot, pixel_size_mm, pixel_size_mm], ...
                    'FaceColor', [0.85, 0.65, 0.15], 'EdgeColor', [0.3, 0.3, 0.3]);
            else
                rectangle('Position', [x_left, y_bot, pixel_size_mm, pixel_size_mm], ...
                    'FaceColor', [0.92, 0.92, 0.92], 'EdgeColor', [0.7, 0.7, 0.7]);
            end
        end
    end
    
    % Mark feed point (Shifted to local coordinates)
    f_feed_mm = opt.f_feed * 1000 + (params.patch_max*1000/2);
    plot(f_feed_mm(1), f_feed_mm(2), 'r+', 'MarkerSize', 18, 'LineWidth', 3);
    
    xlim([0, params.patch_max*1000]);
    ylim([0, params.patch_max*1000]);
    xlabel('x (mm)'); ylabel('y (mm)');
    title(sprintf('Optimized Pixelized Patch\n%d/%d pixels ON', sum(pixel_map(:)), N^2));
    saveas(fig6, 'ACES_Pixel_Map.png');
    fprintf('    Saved: ACES_Pixel_Map.png\n');

    %% ===== FIGURE 7: Performance Comparison =====
    fig7 = figure('Name', 'Performance Comparison', 'Position', [700, 100, 700, 500]);
    categories = {'Freq (GHz)', 'BW (MHz)', 'Gain (dBi)'};
    
    % Removed .eff to prevent crash
    baseline_vals = [baseline.f_res/1e9, baseline.BW/1e6, baseline.max_gain];
    opt_vals      = [opt.f_res/1e9,      opt.BW/1e6,      opt.max_gain];
    
    x_pos = 1:3;
    bar_w = 0.35;
    hold on;
    bar(x_pos - bar_w/2, baseline_vals, bar_w, 'FaceColor', [0.2, 0.4, 0.8], 'DisplayName', 'Baseline');
    bar(x_pos + bar_w/2, opt_vals,      bar_w, 'FaceColor', [0.8, 0.2, 0.2], 'DisplayName', 'Optimized');
    
    legend('Location', 'northeast');
    set(gca, 'XTick', x_pos, 'XTickLabel', categories);
    ylabel('Value');
    title('Final Performance Comparison');
    grid on;
    saveas(fig7, 'ACES_Performance_Comparison.png');
    
    fprintf('  All plots generated successfully!\n');
end