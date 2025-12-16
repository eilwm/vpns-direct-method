function C = topC_vis(C,topB,P,Q,dx,dy,U,rho,nu,U_lid)
    for i = 1:length(topB)
        m = topB(i);
        u0 = U(2*m-1);
        v0 = U(2*m);
        u1 = U(2*m-3);
        u2 = U(2*m+1);
        ua = U(2*m-2*P-1);
        ub = U_lid;
        v1 = U(2*m-2);
        v2 = U(2*m+2);
        va = U(2*m-2*P);
        vb = 0;
        A = 0.5*u0*(u2-u1)/dx + 0.5*v0*(ub-ua)/dy;
        alpha = nu*( (u2-2*u0+u1)/dx^2 + (ub-2*u0+ua)/dy^2 );
        B = 0.5*u0*(v2-v1)/dx + 0.5*v0*(vb-va)/dy;
        beta = nu*( (v2-2*v0+v1)/dx^2 + (vb-2*v0+va)/dy^2 );
        dm = rho * dx * dy;
        C_point = dm * [ A-alpha B-beta]';
        C(2*m-1:2*m) = C_point;
    end
end
