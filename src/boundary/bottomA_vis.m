function A = bottomA_vis(A,bottomB,P,Q,invDx,invDy,U)
    for i = 1:length(bottomB)
        m = bottomB(i);
        A(m,2*m-3) = -1/invDx;
        A(m,2*m+1) = 1/invDx;
        A(m,2*m+2*P) = 1/invDy;
    end
end