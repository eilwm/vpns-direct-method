function A = rightA_vis(A,rightB,P,Q,invDx,invDy,U)
    for i = 1:length(rightB)
        m = rightB(i);
        A(m,2*m-2*P) = -1/invDy;
        A(m,2*m-3) = -1/invDx;
        % A(m,2*m+1) = 0;
        A(m,2*m+2*P) = 1/invDy;
    end
end