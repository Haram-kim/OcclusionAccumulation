function [IR, residual, valid] = GetWarpedImage( IRef, DRef, I, xi, K )
T = xi2T(xi);
R = T(1:3, 1:3);
t = T(1:3,4);

[xImg, yImg, xyz_point] = mexGetWarp(DRef,  R * K^-1, t, K);
IR = interp2(I, xImg+1, yImg+1,'nearest');
residual = IR - IRef;
valid = ~isnan(residual);
residual(~valid) = 0;
IR(isnan(IR)) = 0;
end

