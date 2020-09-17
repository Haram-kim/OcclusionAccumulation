function [ Jac_I, Jac_D, residual_I, residual_D, IR ] = deriveErrAnalytic( IRef, DRef, I, D, xi, K )
% get shorthands (R, t)
T = xi2T(xi); % 0.000462sec
R = T(1:3, 1:3);
t = T(1:3,4);
RKInv = R * K^-1;
Jac_size = size(I,1) * size(I,2);
% ========= warp pixels into other image, save intermediate results ===============
% these contain the x,y image coordinates of the respective
% reference-pixel, transformed & projected into the new image.
xImg = zeros(size(IRef))-10;
yImg = zeros(size(IRef))-10;

% these contain the 3d position of the transformed point
xp = NaN(size(IRef));
yp = NaN(size(IRef));
zp = NaN(size(IRef)); % 0.001086sec

[xImg, yImg, xyz_point] = mexGetWarp(DRef,  RKInv, t, K); % 0.001479sec

xp = xyz_point(:,:,1);
yp = xyz_point(:,:,2);
zp = xyz_point(:,:,3);

% ========= calculate actual derivative. ===============
% 1.: calculate image derivatives, and interpolate at warped positions.

[~, dxI, dyI] = getdXdu(I);
[~, dxD, dyD] = getdXdu(D);

dxInterp_I = K(1,1) * reshape(interp2(dxI, xImg+1, yImg+1),Jac_size,1); % dx*fx with warping
dyInterp_I = K(2,2) * reshape(interp2(dyI, xImg+1, yImg+1),Jac_size,1); % 0.003868sec
dxInterp_D = K(1,1) * reshape(interp2(dxD, xImg+1, yImg+1),Jac_size,1); % dx*fx with warping
dyInterp_D = K(2,2) * reshape(interp2(dyD, xImg+1, yImg+1),Jac_size,1); % 0.003868sec

% 2.: get warped 3d points (x', y', z').
xp = reshape(xp,Jac_size,1);
yp = reshape(yp,Jac_size,1);
zp = reshape(zp,Jac_size,1); % 0.004095sec

% 3. direct implementation of kerl2012msc.pdf Eq. (4.14):
Jac_I = zeros(Jac_size,6);
Jac_I(:,1) = dxInterp_I ./ zp;
Jac_I(:,2) = dyInterp_I ./ zp;
Jac_I(:,3) = - (dxInterp_I .* xp + dyInterp_I .* yp) ./ (zp .* zp);
Jac_I(:,4) = - (dxInterp_I .* xp .* yp) ./ (zp .* zp) - dyInterp_I .* (1 + (yp ./ zp).^2);
Jac_I(:,5) = + dxInterp_I .* (1 + (xp ./ zp).^2) + (dyInterp_I .* xp .* yp) ./ (zp .* zp);
Jac_I(:,6) = (- dxInterp_I .* yp + dyInterp_I .* xp) ./ zp;

Jac_D = zeros(Jac_size,6);
Jac_D(:,1) = dxInterp_D ./ zp;
Jac_D(:,2) = dyInterp_D ./ zp;
Jac_D(:,3) = - (dxInterp_D .* xp + dyInterp_I .* yp) ./ (zp .* zp);
Jac_D(:,4) = - (dxInterp_D .* xp .* yp) ./ (zp .* zp) - dyInterp_I .* (1 + (yp ./ zp).^2);
Jac_D(:,5) = + dxInterp_D .* (1 + (xp ./ zp).^2) + (dyInterp_I .* xp .* yp) ./ (zp .* zp);
Jac_D(:,6) = (- dxInterp_D .* yp + dyInterp_I .* xp) ./ zp;

Jac_I = -Jac_I;
Jac_D = -Jac_D;

IR = interp2(I, xImg+1, yImg+1,'nearest');
DR = interp2(D, xImg+1, yImg+1,'nearest');
residual_I = reshape(IRef - IR,Jac_size,1);
residual_D = reshape(DRef - DR,Jac_size,1);

end

