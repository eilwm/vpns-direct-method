function A = leftA_vis(A,leftB,P,Q,invDx,invDy,U)
    for i = 1:length(leftB)
        m = leftB(i);
        A(m,2*m-2*P) = -1/invDy;
        % A(m,2*m-3) = 0;
        A(m,2*m+1) = 1/invDx;
        A(m,2*m+2*P) = 1/invDy;
    end
end