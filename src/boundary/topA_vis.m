function A = topA_vis(A,topB,P,Q,invDx,invDy,U)
    for i = 1:length(topB)
        m = topB(i);
        A(m,2*m-2*P) = -1/invDy;
        A(m,2*m-3) = -1/invDx;
        A(m,2*m+1) = 1/invDx;
        % A(m,2*m+2*P) = 0;
    end
end