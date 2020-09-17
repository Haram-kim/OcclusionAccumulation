function [depth_cur_comp, depth_next_comp, depth_prev_warped] = DepthCompensation(depth_prev_warped, depth_cur, depth_next, xi, K)



% copy current depth 
depth_cur_comp = depth_cur;
% fill  depth by prev depth
depth_cur_comp(depth_cur == 0) = depth_prev_warped(depth_cur == 0);

depth_cur_warped = GetWarpedImage(depth_cur_comp,depth_cur_comp,depth_cur_comp,-xi,K);
% copy next depth 
depth_next_comp = depth_next;
% fill next depth by current depth
depth_next_comp(depth_next == 0) = depth_cur_warped(depth_next == 0);

% trim nan value 
depth_next_comp(isnan(depth_next_comp))=0;

% fill current depth by next depth
depth_cur_warped(depth_cur_warped == 0) = depth_next_comp(depth_cur_warped == 0);
% update previous depth
depth_prev_warped = depth_cur_warped;
end
