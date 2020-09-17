function [rgb_data, depth_data, rgb_time, depth_time] = LoadData(Dir)

fprintf('New directory is detected \n');
RGBDir = [Dir 'rgb\'];
% RGBDir = [Dir 'image_02\data\'];
RGBList = dir(fullfile(RGBDir, '*.png'));
rgb_length =length(RGBList);
rgb_time = zeros(rgb_length,1);

DepthDir = [Dir 'depth\'];
DepthList = dir(fullfile(DepthDir,'*.png'));
depth_length =length(DepthList);
depth_time = zeros(depth_length,1);

for i=1:rgb_length
    rgb_data{i}=imread([RGBDir,RGBList(i).name]);
    str = RGBList(i).name;
    str(end-3:end)=[];
    rgb_time(i) = str2double(str);
end

for i=1:depth_length
    depth_data{i}=imread([DepthDir,DepthList(i).name]);
    str = DepthList(i).name;
    str(end-3:end)=[];
    depth_time(i) = str2double(str);
end

end
