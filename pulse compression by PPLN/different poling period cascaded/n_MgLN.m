function n=n_MgLN(w,t)
% ����5%doped MgLN������, w���� t�¶� n������,Appl Phys B (2010) 101: 481,Appl. Phys. B
% 91, 343�C348 (2008)



z=w.*w;
a1=5.756;
a2=0.0983;
a3=0.2020;
a4=189.32;
a5=12.52;
a6=1.32e-2;
b1=2.86e-6;
b2=4.7e-8;
b3=6.113e-8;
b4=1.516e-4;
f=(t-24.5).*(t+570.82);
x=a1+b1*f+(a2+b2*f)./(z-(a3+b3*f).^2)+(a4+b4*f)./(z-a5*a5)-a6.*z;
n=sqrt(x);