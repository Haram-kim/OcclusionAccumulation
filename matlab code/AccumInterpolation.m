function source_func = AccumInterpolation(source_func, source_mask, target_mask, source_depth, seq)
IsNearSomthing = inf;
[dxn, dyn, dxp, dyp] = getdxynp(source_depth);
dxy_thres = 0.05; 

near_xp = zeros(size(source_mask));
near_yp = zeros(size(source_mask));
near_xn = zeros(size(source_mask));
near_yn = zeros(size(source_mask));
restoration = zeros(size(source_mask));

    while(sum(sum(IsNearSomthing))>10)
        near_xp(2:end-1,2:end-1) = source_mask(2:end-1,3:end).*target_mask(2:end-1,2:end-1).*(abs(dxp(2:end-1,2:end-1))<dxy_thres);
        near_yp(2:end-1,2:end-1) = source_mask(3:end,2:end-1).*target_mask(2:end-1,2:end-1).*(abs(dyp(2:end-1,2:end-1))<dxy_thres);
        near_xn(2:end-1,2:end-1) = source_mask(2:end-1,1:end-2).*target_mask(2:end-1,2:end-1).*(abs(dxn(2:end-1,2:end-1))<dxy_thres);
        near_yn(2:end-1,2:end-1) = source_mask(1:end-2,2:end-1).*target_mask(2:end-1,2:end-1).*(abs(dyn(2:end-1,2:end-1))<dxy_thres);

        IsNearSomthing = near_xp+near_yp+near_xn+near_yn;

        restoration(2:end-1,2:end-1) ...
            = (((source_func(2:end-1,3:end) + dxp(2:end-1,2:end-1)).*near_xp(2:end-1,2:end-1)) ...
            + ((source_func(3:end,2:end-1) + dyp(2:end-1,2:end-1)).*near_yp(2:end-1,2:end-1)) ...
            + ((source_func(2:end-1,1:end-2) + dxn(2:end-1,2:end-1)).*near_xn(2:end-1,2:end-1)) ...
            + ((source_func(1:end-2,2:end-1) + dyn(2:end-1,2:end-1)).*near_yn(2:end-1,2:end-1)))./IsNearSomthing(2:end-1,2:end-1);

        source_func(logical(IsNearSomthing)) = restoration(logical(IsNearSomthing));
        target_mask(logical(IsNearSomthing)) = 0;
        source_mask(logical(IsNearSomthing)) = 1;
    end
end