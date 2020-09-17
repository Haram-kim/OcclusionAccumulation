function xi = T2xi(T)
list_num = size(T,3);
xi = zeros(6,list_num);

for iter = 1:list_num
    lg = logm(T(:,:,iter));
    xi(:,iter) = [lg(1,4) lg(2,4) lg(3,4) lg(3,2) lg(1,3) lg(2,1)]';
end

% w_abs = invcos((trace(R)-1)/2);
% if(w_abs ==0)
%     w = zeros(3,1);
% else
%     w_hat = log(R);
%     w = unhat(omgea_hat);
% end
%
% xi = [omgea; v]

% for iter = 1:list_num
%     R = G(1:3,1:3,iter);
%     T = G(1:3,4,iter);
%     
%     w_abs = acos((trace(R)-1)/2);
%     if w_abs < 0.001
%         w = unhat(R);
%     else
%         w = w_abs/sin(w_abs)*unhat(R);
%     end
%     len_w = sqrt(w.'*w);
%     Wx = hat(w);
%     if len_w < 0.001
%         Tv = eye(3) + 0.5*Wx + (Wx*Wx)/3;
%     else
%         Tv = eye(3) + (1-cos(len_w))/len_w^2*Wx + (len_w-sin(len_w))/len_w^3*(Wx*Wx);
%     end
%     v = Tv\T;
%     xi(:,iter) = [v;w];
% end
end