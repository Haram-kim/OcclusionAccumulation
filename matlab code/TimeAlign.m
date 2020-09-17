function result = TimeAlign(ref_time, time)
ref_length = size(ref_time,1);
obj_length = size(time,1);
result = zeros(ref_length,1);

for i = 1:ref_length
    min_interval = inf;
    for j = 1:obj_length
%     j = max(j,1);
    interval = abs(ref_time(i)-time(j));
    if(interval < min_interval)
       min_interval = interval;
       min_j = j;
    end
    end
    result(i) = min_j;
end

end