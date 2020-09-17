function [dxn, dyn, dxp, dyp] = getdxynp(I)
    dxp = NaN(size(I));
    dyp = NaN(size(I));
    dxn = NaN(size(I));
    dyn = NaN(size(I));
    
    dyp(1:(end-1),:) = (I(2:end,:) - I(1:(end-1),:));
    dxp(:,1:(end-1)) = (I(:,2:end) - I(:,1:(end-1)));
    dyn(2:end,:) = (I(1:(end-1),:) - I(2:end,:));
    dxn(:,2:end) = (I(:,(1:end-1)) - I(:,2:end));
