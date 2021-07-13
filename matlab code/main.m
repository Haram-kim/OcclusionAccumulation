%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Occlusion Acculation                                   %
%               2018-03-21           Haram Kim                         %
%               rlgkfka614@gmail.com                                   %
%               Seoul Nat'l Univ. ICSL                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mex mexGetWarp.cpp
% mex mexAccumInterpolation.cpp

% clear all;
% close all;
% clc;

addpath('DVO\');
addpath('SE(3)\');
%% data load
%               fx      fy      cx      cy      d0      d1      d2      d3      d4
TUM = [	520.9	521.0	325.1	249.7	0.2312	-0.7849 -0.0033	-0.0001	0.9172  ];
ICSL= [ 537.6   539.0   316.1   245.5   0       0        0      0       0       ];
LARR= [ 544.3   546.1   326.9   236.1   0       0.0369  -0.0557 0       0       ];

Inparam = LARR; depth_unit = 1000; 

% Select dataset
Dir = 'dataset\dynamic_board\'; start = 1;

K = eye(3);
K(1,1) = Inparam(1);
K(2,2) = Inparam(2);
K(1,3) = Inparam(3);
K(2,3) = Inparam(4);

% Load image
global updateDir;
if (~strcmp(Dir,updateDir))
    [rgb_data, depth_data, rgb_time, depth_time] = LoadData(Dir);
    [height, width] = size(depth_data{1});
    rgb_length = size(rgb_time,1);
    xi_data = zeros(rgb_length,6);
    updateDir = Dir;
end

%% Initialization
ZEROS = zeros(height,width);

depth_prev_warped = ZEROS;
accumulated_dZdt = ZEROS;
predicted_area = ZEROS;

background_mask = ones(height,width);
depth_cur_compensated = ones(height,width);
depth_next_compensated = ones(height,width);

time_idx = TimeAlign(rgb_time,depth_time);
xi_init = [0 0 0 0 0 0]';


figure(1);
hf1 = imshow(zeros(height, width, 3),[0 1]);

%% variable description
% A(u): accumulated_dZdt
% Z_i(u): depth_cur || depth_cur_compensated
% Z_{i+1}(u): depth_next || depth_next_compensated
% Delta Z(u) : dZdt
% tilde Omega: newly_discovered_area
% B(u): background_mask

%% parameter setting
start = 1; final = rgb_length-1;
% truncation parameter for A(u)
alpha = 0.15;
% truncation parameter for Delta_Z(u)
beta = 0.225;
% threshold to ignore small moving object / depth sensor error
object_threshold = 5e2;
% Use VO module or not
useRobustVOModule = false; 

% load preestimated pose data on 'xi_data'
load('dataset\dynamic_board_pose'); 


%%
for iter = start:final
% tic
    img_cur = rgb2gray(double(rgb_data{iter})/255);
    img_next = rgb2gray(double(rgb_data{iter+1})/255);
    depth_cur = double(depth_data{time_idx(iter)})/depth_unit;
    depth_next = double(depth_data{time_idx(iter+1)})/depth_unit;

    %% main process
    %%%% Pose estimation
    if(useRobustVOModule)
        background_mask_warped = GetWarpedImage(depth_cur_compensated, depth_next_compensated, double(background_mask), xi, K);
        background_nan = imgaussfilt(background_mask_warped,2);
        background_nan(background_nan < 1) = nan;
        background_nan(background_nan >= 1) = 1;
        xi_data(iter,:) = Estimate_motion(img_cur, img_next, depth_cur .* background_nan, depth_next, xi_init, K)';
    end
    xi = xi_data(iter,:).';

    %%%% Moving object detection
    %%% Depth compensation
    [depth_cur_compensated, depth_next_compensated, depth_prev_warped] = DepthCompensation(depth_prev_warped, depth_cur, depth_next, xi, K);

    %%% Occlusion accumulation
    % Compute the occlusion dZdt
    [depth_cur_warped, dZdt] = GetWarpedImage(depth_next_compensated, depth_cur_compensated, depth_cur_compensated, -xi, K);
    % Warp the occlusion accumulation map, newly discovered area
    accumulated_dZdt = GetWarpedImage(depth_next_compensated, depth_cur_compensated, accumulated_dZdt, -xi, K);
    predicted_area = GetWarpedImage(depth_next_compensated, depth_cur_compensated, predicted_area, -xi, K);
    % Accumulate the occlusion
    accumulated_dZdt = accumulated_dZdt + dZdt;
    accumulated_dZdt(isnan(accumulated_dZdt)) = 0;
    
    % Set threshold 
    tau_alpha = alpha * depth_next_compensated;
    tau_beta = beta * depth_next_compensated;
    % Truncate error values
    % Equation 5
    accumulated_dZdt(accumulated_dZdt <= tau_alpha) = 0; 
    % Equation 6
    accumulated_dZdt(dZdt <= - tau_beta) = 0; 

    %%% Occlusion Prediction on Newly Discovered Area
    newly_discovered_area = logical(abs((depth_cur_warped == 0) - (depth_next_compensated == 0)));
    % Initial background mask
    background_mask = ~(accumulated_dZdt > tau_alpha);

    % Label objects
    [object_label, object_num] = bwlabel(~background_mask);
    for object_idx = 1:object_num
        object_area = (object_label == object_idx);
        if(sum(sum(object_area)) < object_threshold)
            % Ignore small object segmentations
            accumulated_dZdt(object_area)=0;
            continue;
        end
        % occlusion prediction, Equation 10
        accumulated_dZdt = AccumInterpolation(accumulated_dZdt, object_area, newly_discovered_area, depth_next_compensated, iter);
    end
    % Equation 7
    object_mask = (accumulated_dZdt > tau_alpha);
    
    % Erase predicted areas that are not neighborhood of moving objects
    % Update predicted area
    predicted_area = (predicted_area + newly_discovered_area).*object_mask;
    % Label predicted area
    [predicted_area_label, predicted_area_num] = bwlabel(predicted_area);
    % Check predicted area is neighborhood of moving object
    connect_label = BWconnect(predicted_area_label, predicted_area_num, (object_mask - predicted_area));
    unconnect_index = find(~connect_label).';
    % Erase unconnected area
    if(size(unconnect_index,2))
        for cidx = unconnect_index
            newly_discovered_area(cidx==predicted_area_label) = 0;
            object_mask(cidx==predicted_area_label) = 0;
            accumulated_dZdt(cidx==predicted_area_label) = 0;
        end
    end
    
    %%%% Moving object detection result
    background_mask = ~(object_mask);

    %%%% Visualization
    set(hf1,'CData',(double(rgb_data{iter+1}) / 255 + cat(3, 0.4 * (~background_mask), ZEROS, 0.4 * (~background_mask))));
    drawnow;
 
end
