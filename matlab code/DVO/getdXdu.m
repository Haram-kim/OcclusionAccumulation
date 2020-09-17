function [dXdu, dxI, dyI] = getdXdu(I)
    dxI = zeros(size(I));
    dyI = zeros(size(I));
    dyI(2:(end-1),:) = 0.5*(I(3:(end),:) - I(1:(end-2),:));
    dxI(:,2:(end-1)) = 0.5*(I(:,3:(end)) - I(:,1:(end-2)));
    dXdu = sqrt(dxI.^2+dyI.^2);
