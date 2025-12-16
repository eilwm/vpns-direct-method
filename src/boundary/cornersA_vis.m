function A = cornersA_vis(A,corners,P,Q,invDx,invDy,U)
    % Bottom Left Corner
    m = corners(1);
    A(m,2*m+1) = invDx;
    A(m,2*m+2*P) = invDy;

    % Bottom Right Corner
    m = corners(2);
    A(m,2*m-3) = -invDx;
    A(m,2*m+2*P) = invDy;

    % Top Left Corner
    m = corners(3);
    A(m,2*m-2*P) = -invDy;
    A(m,2*m+1) = invDx;

    % Top Right Corner
    m = corners(4);
    A(m,2*m-2*P) = -invDy;
    A(m,2*m-3) = -invDx;
end