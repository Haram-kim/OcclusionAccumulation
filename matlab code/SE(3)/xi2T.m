function T = xi2T(xi)
list_num = size(xi,2);
T = zeros(4,4,list_num);

for iter = 1:list_num
    M = [   0           -xi(6,iter)  xi(5,iter) xi(1,iter);
            xi(6,iter)  0           -xi(4,iter) xi(2,iter);
            -xi(5,iter) xi(4,iter)  0           xi(3,iter);
            0           0           0           0   ];
    T(:,:,iter) = expm(M);
end


end

%     v = xi(1:3,iter);
%     w = xi(4:6,iter);
%     Wx = hat(w);
%     len_w = sqrt(w.'*w);
%     if len_w < 1e-7
%         R = eye(3) + Wx + 0.5*Wx*Wx;
%         T = (eye(3) + 0.5*Wx + Wx*Wx/3)*v;
%     else
%         R = eye(3) + sin(len_w)/len_w*Wx + (1-cos(len_w))/len_w^2*(Wx*Wx);
%         T = (eye(3) + (1-cos(len_w))/len_w^2*Wx + (len_w-sin(len_w))/len_w^3*(Wx*Wx))*v;
%     end
%     G(:,:,iter) = [R T; 0 0 0 1];