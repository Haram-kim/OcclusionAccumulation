% Only for superpixel node.
% Takes O(n^2) time
% 
% Seoul Nat'l Univ ICSL
% Haram. Kim  2018-01-05
% 
% L : label data
% N : number of label
% Ref : reference img, main subject of connection

function result = BWconnect(L, N, Ref)
result = zeros(N,1);

dxL = ones(size(L));
dyL = ones(size(L));

dxL(:,2:(end-1)) = (L(:,3:(end)) ~= L(:,1:(end-2)));
dyL(2:(end-1),:) = (L(3:(end),:) ~= L(1:(end-2),:));

dxyL = (dxL+dyL)>0;

dxR = ones(size(L));
dyR = ones(size(L));

dxR(:,2:(end-1)) = (Ref(:,3:(end)) ~= Ref(:,1:(end-2)));
dyR(2:(end-1),:) = (Ref(3:(end),:) ~= Ref(1:(end-2),:));

dxyR = (dxR+dyR)>0;

dxy = dxyL.*dxyR;

La = NaN(size(L));
La(2:end-1,2:end-1) = L(2:end-1,2:end-1);
LaVec = La(logical(dxy));

for i = 1:length(LaVec)
    if isnan(LaVec(i))||LaVec(i)==0
        continue;
    end
    result(LaVec(i)) = 1;
end

end
