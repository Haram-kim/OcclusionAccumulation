function [ Id, Kd ] = downscaleImage( I, K, num )

    if(num<=1)
        Id = I;
        Kd = K;
        return;
    end
    I = I(1:end-mod(end,2),1:end-mod(end,2));
    
    Kd = [K(1,1)/2 0 (K(1,3)+0.5)/2-0.5;
          0 K(2,2)/2 (K(2,3)+0.5)/2-0.5;
          0 0 1];
      
    Id = (I(0+(1:2:end), 0+(1:2:end)) + I(1+(1:2:end), 0+(1:2:end)) + I(0+(1:2:end), 1+(1:2:end)) + I(1+(1:2:end), 1+(1:2:end)))*0.25;

    [Id, Kd] = downscaleImage( Id, Kd, num -1 );

end

