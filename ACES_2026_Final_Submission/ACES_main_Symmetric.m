%% =========================================================================
%  ACES 2026 - SYMMETRIC MINIATURIZATION (FINAL WINNING STRATEGY)
%  Strategy: 12x12 Symmetric Grid + Solid Seed + Soft Penalty
%  =========================================================================
clear; clc; close all;
fprintf('==========================================================\n');
fprintf('  ACES 2026 - Final Optimized Run (2.6 GHz Target)\n');
fprintf('==========================================================\n\n');

%% ---- SECTION 1: FIXED ANTENNA PARAMETERS --------------------
params.patch_max      = 53e-3;    
params.gnd_size       = 100e-3;   
params.h_substrate    = 4.3e-3;   
params.er             = 1.0;      
params.f0_initial     = 2.6e9;    
params.BW_initial     = 80e6;     
params.min_BW_req     = 20e6;     
params.feed_diameter  = 0.5e-3;

%% ---- SECTION 2: PIXELIZATION SETTINGS ------------------------
params.grid_N         = 12;        
params.pixel_size     = params.patch_max / params.grid_N;  
params.feed_pos       = [18e-3, 0]; % Edge offset for matching

%% ---- SECTION 3: FREQUENCY SWEEP SETTINGS ---------------------
params.f_center       = 2.6e9;    
params.f_span         = 1.5e9;    
params.nFreq_GA       = 21;       
params.nFreq_final    = 201;      

params.freq_GA    = linspace(params.f_center - params.f_span/2, ...
                             params.f_center + params.f_span/2, params.nFreq_GA);
params.freq_final = linspace(params.f_center - params.f_span/2, ...
                             params.f_center + params.f_span/2, params.nFreq_final);

%% ---- SECTION 4: SIMULATE BASELINE ---------------------------
fprintf('STEP 1: Simulating baseline solid patch...\n');
baseline_pixels = ones(params.grid_N, params.grid_N);
baseline_results = simulate_patch(baseline_pixels, params, 'final');
fprintf('  >> Baseline Resonance : %.4f GHz\n', baseline_results.f_res/1e9);

%% ---- SECTION 5: GA OPTIMIZATION -----------------------------
fprintf('STEP 2: Starting Evolutionary Carving...\n');

nvars  = (params.grid_N / 2) * params.grid_N; % 72 variables
lb = zeros(1, nvars); ub = ones(1, nvars); intcon = 1:nvars;

% SEED: Start from a solid metal patch
initial_guess = ones(1, nvars);

options = optimoptions('ga', ...
    'PopulationSize', 60, ...
    'InitialPopulationMatrix', initial_guess, ...
    'MaxGenerations', 50, ...
    'MutationFcn', {@mutationuniform, 0.1}, ...
    'UseParallel', true, ...
    'Display', 'iter', ...
    'PlotFcn', {@gaplotbestf});

fitness_fn = @(x) compute_fitness(x, params);
constraint_fn = @(x) connectivity_constraint(x, params);

tic;
[x_opt_half, fval, exitflag, output] = ga(fitness_fn, nvars, [], [], [], [], ...
    lb, ub, constraint_fn, intcon, options);
elapsed = toc;

%% ---- SECTION 6: FINAL RESULTS -------------------------------
half_grid = reshape(x_opt_half, params.grid_N/2, params.grid_N);
pixel_map_opt = [half_grid; flipud(half_grid)]; 

opt_results = simulate_patch(pixel_map_opt, params, 'final');
plot_all_results(baseline_results, opt_results, pixel_map_opt, params);
save('ACES_Final_Result.mat', 'params', 'opt_results', 'pixel_map_opt');
fprintf('\nDone! Final Resonance: %.4f GHz\n', opt_results.f_res/1e9);