function xi = Estimate_motion(c1,c2,d1,d2,xi,K)

depth_weight = 0.01;
% use robust weights
useHuber = false;
useBisquare = true;

% useHuber = true;
% useBisquare = true;

% exactly one of those should be true.
useGN = false; % Gauss-Newton
useLM = true; % Levenberg Marquad
useGD = false; % Gradiend descend

% coarse to fine maximun iteration
lvl_max = 4;

for lvl = lvl_max:-1:1
    % get downscaled image, depth image, and K-matrix of down-scaled image.
    [IRef, Klvl] = downscaleImage(c1,K,lvl);
    I = downscaleImage(c2,K,lvl);
    [DRef] = downscaleDepth(d1,lvl);
    D = downscaleDepth(d2,lvl);
    lambda = 0.1;

    errLast = 1e10;
    for i=1:40
        
        % calculate Jacobian of residual function (Matrix of dim (width*height) x 6)
        [Jac_I, Jac_D, residual_I, residual_D] = deriveErrAnalytic(IRef,DRef,I,D,xi,Klvl);   % ENABLE ME FOR ANALYTIC DERIVATIVES
        axis equal
        
        valid = ~isnan(sum(Jac_I,2));
        residualTrim = [residual_I(valid,:); residual_D(valid,:)];
        JacTrim = [Jac_I(valid,:); Jac_D(valid,:)];
        weight = ones(size(residual_I));
        weightTrim = [weight(valid); weight(valid)];
        
        if (useHuber)
            % compute Huber Weights
            huber = ones(size(residual_I));
            huberDelta = 4/255;
            huber(abs(residual_I) > huberDelta) = huberDelta ./ abs(residual_I(abs(residual_I) > huberDelta));
            
            huber_D = ones(size(residual_D));
            huberDelta_D = 0.01;
            huber_D(abs(residual_D) > huberDelta_D) = huberDelta_D ./ abs(residual_D(abs(residual_D) > huberDelta_D));

            weightTrim = [huber(valid); huber_D(valid)];
        end
        
        if (useBisquare)
            % compute useBisquare Weights
            bisquare = zeros(size(residual_I));
            bisquareDelta = (64-exp(lvl)/exp(lvl_max)*48)/255;
            bisquare(abs(residual_I) <= bisquareDelta) = (1-(residual_I(abs(residual_I) <= bisquareDelta)/bisquareDelta).^2).^2;
            
            bisquare_D = zeros(size(residual_D));
            bisquareDelta_D = 0.25;
            bisquare_D(abs(residual_D) <= bisquareDelta_D) = (1-(residual_D(abs(residual_D) <= bisquareDelta_D)/bisquareDelta_D).^2).^2;

            weightTrim = [bisquare(valid); bisquare_D(valid)];
        end
        
        weightTrim(end/2+1:end) = weightTrim(end/2+1:end)*depth_weight;
        if (useGN)
            % do Gauss-Newton step
            upd = - (JacTrim' * (repmat(weightTrim,1,6) .* JacTrim))^-1 * JacTrim' * (weightTrim .* residualTrim);
        end
        
        if (useGD)
            % do gradient descend
            upd = - JacTrim' * (weightTrim .* residualTrim);
            upd = 0.001 * upd / norm(upd);   % choose step size such that the step is always 0.001 long.
        end
        
        if (useLM)
            % do LM
            H = (JacTrim' * (repmat(weightTrim,1,6) .* JacTrim));
            upd = - (H + lambda * diag(diag(H)))^-1 * JacTrim' * (weightTrim .* residualTrim);
        end
        
        % MULTIPLY increment from left onto the current estimate.
        lastXi = xi;
        xi = T2xi(xi2T(upd) * xi2T(xi));

        % get mean and display
        err = mean((weightTrim.*residualTrim) .* residualTrim);
        
        if (useLM)
            if(err >= errLast)
                lambda = lambda * 3;
                xi = lastXi;
                
                if(lambda > 200)
                    break;
                end
            else
                lambda = lambda /1.5;
            end
        end  

        if (useGN || useGD)
            if(err / errLast > 0.99995)
                break;
            end
        end 
        errLast = err;
    end
end

end


