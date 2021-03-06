%% parameter setting
clear,clc
global c eps_0 t w hbar;
c =  2.99792458E8;      % speed of light
eps_0 = 8.854E-12;
lam = 2760E-9;          % m
lamSHG = lam/2;
w0 = 2*pi*c/lam;
t00 = 500E-15;
I00 = 3000;  % peak power units:W
t0 = 500E-15;
I0 = 3000;  % peak power units:W

%% SA behavior of NLM (LN crystal) %%%%%%%%%
deff = 14E-12;          % m/V
Lnl = 10.59E-3;             % length of NL crystal, m
%Anl = pi*(2.832e-6)*(2.233e-6);       % mode area at NL crystal --W1=6.3 W2=7.5
%Anl = pi*(3.9312e-6)*(1.9585e-6);       % mode area at NL crystal --W1=8.4 W2=10
Anl = pi*(2.3751e-6)*(2.0640e-6);       % mode area at NL crystal --W1=5.04 W2=6

Rl = 0.75;              % linear rfeflectivity
n2_NL = 0;%2.1E-20;

%% Sim parameters %%%%%%%%%%%
Nrt = 1;
Nw = 8001;
Nzfi = 300;
Nzcr= 1000;
%dw = 10*BW/(Nw-1);
%w = ( -(Nw-1)/2 : (Nw-1)/2 )*dw;
%t = linspace(-pi/dw,pi/dw,Nw);
%dt = mean(diff(t));
t = linspace(-3e-12,3e-12,Nw);
dt = t(2) - t(1);
w = 2*pi*linspace(-1/2/dt,1/2/dt,Nw);
dw = w(2)-w(1);
w = ifftshift(w);
t = ifftshift(t);
zKTP = linspace(0,Lnl,Nzcr);        % space coordinate
dzKTP = zKTP(2)-zKTP(1);
%%%%%%%%%%%% Initial pulse %%%%%%%%%%%
um=1e-6;
tem=70;
n_FF= n_MgLN(lam/um,tem);
FF=cos(0*pi/t0.*t);
AFF0 = FF.* sqrt(2*I0/Anl/(n_FF*c*eps_0)).*exp(-(sqrt(2*log(2))*t/t0).^2); %*(sech(1.22*t/t0)).^2; % units V/m
E= (Anl*n_FF*eps_0*c/2)*sum(abs(AFF0).^2)*dt;  % initial energy
ASHG0 =0;

%%%%%%%%%%%%%%% GVM and GDD of PPLN%%%%%%%%%%%%
% %W1=6.3 W2=7.5
% beta1_rel = (7.311-7.3597)*1E-9; %2.18/c-2.1845/c;p
% %beta1_rel = -2e-12;
% beta1_offset = 0;%11.4e-12;%5.25E-12;
% beta2_FF =-472E-27;  
% beta3_FF = 26.8E-40;
% beta2_SHG =119.5E-27;
% beta3_SHG =3.101E-40;

% %W1=8.4 W2=10
% beta1_rel = (7.309-7.353)*1E-9; %2.18/c-2.1845/c;p
% %beta1_rel = -2e-12;
% beta1_offset = 0;%11.4e-12;%5.25E-12;
% beta2_FF =-462.5E-27;  
% beta3_FF = 26.6E-40;
% beta2_SHG =122.3E-27;
% beta3_SHG =3.048E-40;

%W1= 5.04 W2=6
beta1_rel = (7.314-7.3665)*1E-9; %2.18/c-2.1845/c;p
%beta1_rel = -2e-12;
beta1_offset = 0;%11.4e-12;%5.25E-12;
beta2_FF =-483E-27;  
beta3_FF = 26.58E-40;
beta2_SHG =116.4E-27;
beta3_SHG =3.155E-40;

D_FF = exp(-j*(beta1_offset*w + beta2_FF/2*w.^2 + beta3_FF/6*w.^3)*dzKTP/2);
D_SHG = exp(-1i*((beta1_rel + beta1_offset)*w + beta2_SHG/2*w.^2 + beta3_SHG/6*w.^3)*dzKTP/2);


supergaussian = exp(-(t./6e-12).^6);
AFF0 = AFF0 .*supergaussian;

%% propagation simulation
%
Iff0 = (Anl*n_FF*eps_0*c/2)*abs(AFF0).^2;
AFF=AFF0;
ASHG=ASHG0; 
%%%%%%%%%%%passing PPLN
      T=1;
      w_pulse = zeros(Nzcr,1);
      L = zeros(Nzcr,1);
      fwhm_1=zeros(Nrt);
    %% first part
     L1 = 206;      % change the length
      for Z1 = zKTP(1:L1)
           % Propagation (1st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);
           % nonlinear step using Runga-Kutta 4th order 
     [AFF, ASHG, n_FF, n_SHG] = dadzLN_rev1(AFF,ASHG,lam,lamSHG,deff,n2_NL,Anl,Lnl,Z1,dzKTP);
           % Propagation (2st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);   
     
     Ishgincry(1,T) = max(abs(ASHG)).^2/max(abs(AFF0)).^2;
     
     RNL=[];
     AFF1=AFF;
     Iff_1(T,:) = (Anl*n_FF*eps_0*c/2)*abs(AFF).^2;
     beam1(T,:) = Iff_1(T,:);
     Total_Energy1(T) = sum(abs(beam1(T,:))*dt);
    
     Intensity1=Iff_1;

     ind = T;
     AA(ind) = max(Intensity1(ind,:));
     fwhm_=find(abs(Intensity1(ind,:))>abs(max(Intensity1(ind,:))/2));
     fwhm_1(ind)=length(fwhm_)+1;
     fwhm_1(ind)=fwhm_1(ind)/(length(t)+1)*(6*1e3);   
     w_pulse(T) = fwhm_1(T);        % every pulse duration
     L(T) = T.*dzKTP;
     
     peakpower(T) = max(Intensity1(ind,:));    %peak power
     T=T+1;
      end     

     %% second part
     L2 = 542;
            for Z2 = zKTP(L1+1:L2)
           % Propagation (1st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);
           % nonlinear step using Runga-Kutta 4th order 
     [AFF, ASHG, n_FF, n_SHG] = dadzLN_rev2(AFF,ASHG,lam,lamSHG,deff,n2_NL,Anl,Lnl,Z2,dzKTP);
           % Propagation (2st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);   
     
     Ishgincry(1,T) = max(abs(ASHG)).^2/max(abs(AFF0)).^2;
     
     RNL=[];
     AFF1=AFF;
     Iff_1(T,:) = (Anl*n_FF*eps_0*c/2)*abs(AFF).^2;
     beam1(T,:) = Iff_1(T,:);
     Total_Energy1(T) = sum(abs(beam1(T,:))*dt);
    
     Intensity1=Iff_1;

     ind = T;
     AA(ind) = max(Intensity1(ind,:));
     fwhm_=find(abs(Intensity1(ind,:))>abs(max(Intensity1(ind,:))/2));
     fwhm_1(ind)=length(fwhm_)+1;
     fwhm_1(ind)=fwhm_1(ind)/(length(t)+1)*(6*1e3);   
     w_pulse(T) = fwhm_1(T);        % every pulse duration
     L(T) = T.*dzKTP;
     
     peakpower(T) = max(Intensity1(ind,:));    %peak power
     T=T+1;
            end   
%% third part  
% change the length
      for Z3 = zKTP(L2+1:Nzcr)
           % Propagation (1st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);
           % nonlinear step using Runga-Kutta 4th order 
     [AFF, ASHG, n_FF, n_SHG] = dadzLN_rev3(AFF,ASHG,lam,lamSHG,deff,n2_NL,Anl,Lnl,Z3,dzKTP);
           % Propagation (2st half)
     sAFF = fft(AFF);
     sSHG = fft(ASHG);
     AFF = ifft(D_FF.*sAFF);
     ASHG = ifft(D_SHG.*sSHG);   
     
     Ishgincry(1,T) = max(abs(ASHG)).^2/max(abs(AFF0)).^2;
     
     RNL=[];
     AFF1=AFF;
     Iff_1(T,:) = (Anl*n_FF*eps_0*c/2)*abs(AFF).^2;
     beam1(T,:) = Iff_1(T,:);
     Total_Energy1(T) = sum(abs(beam1(T,:))*dt);
    
     Intensity1=Iff_1;

     ind = T;
     AA(ind) = max(Intensity1(ind,:));
     fwhm_=find(abs(Intensity1(ind,:))>abs(max(Intensity1(ind,:))/2));
     fwhm_1(ind)=length(fwhm_)+1;
     fwhm_1(ind)=fwhm_1(ind)/(length(t)+1)*(6*1e3);   
     w_pulse(T) = fwhm_1(T);        % every pulse duration
     L(T) = T.*dzKTP;
     
     peakpower(T) = max(Intensity1(ind,:));    %peak power
     T=T+1;
      end     

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  figure(1); plot(zKTP',Ishgincry);
  AFF1=AFF;
  Iff1(1,:) = (Anl*n_FF*eps_0*c/2)*abs(AFF).^2;
  Ishg1(1,:) = (Anl*n_SHG*eps_0*c/2)*abs(ASHG).^2;
 
%% result
fwhm=[];
RNL=[];
Intensity=Iff1;
fwhm1=zeros(Nrt);
for ind = 1:Nrt
    AA(ind) = max(Intensity(ind,:));
    fwhm=find(abs(Intensity(ind,:))>abs(max(Intensity(ind,:))/2));
    fwhm1(ind)=length(fwhm)+1;
    fwhm1(ind)=fwhm1(ind)/(length(t)+1)*(6*1e3);
    
end

fwhm1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
po=1;
AFF00 = FF.*sqrt(2*I00/Anl/(n_FF*c*eps_0)).*exp(-(sqrt(2*log(2))*t/t00).^2);  % units V/m
Iff00 = (Anl*n_FF*eps_0*c/2)*abs(AFF00).^2;
%plot(t,Ii(po,:)./max(Ii(po,:)),'r',t,Iff0(po,:)./max(Iff0(po,:)),'b',t,Iff1(po,:)./max(Iff1(po,:)),'k',t,Ishg1(po,:)./max(Ishg1(po,:)),'g--')
%legend('i','ff0','ff1','shg1')
plot(t,Iff00(po,:)./max(1),'k',t,Iff1(po,:)./max(1),'r')

figure(3)
po=1;
fre=(w+2*w0);
lamm=2*pi*c./fre;
plot(lamm,10*log10(abs(fft(AFF00(po,:))./max(fft(AFF00(po,:))))),'k',lamm,10*log10(abs(fft(ASHG(po,:))./max(fft(ASHG(po,:))))),'r')
axis([0 8e-6 -20 0])
hold on;
po=1;
fre=(w+w0);
lamm=2*pi*c./fre;
plot(lamm,10*log10(abs(fft(AFF00(po,:))./max(fft(AFF00(po,:))))),'k',lamm,10*log10(abs(fft(AFF(po,:))./max(fft(AFF(po,:))))),'r')
axis([0 8e-6 -20 0])
%plot(zNrd,AA)
%plot(t,Ii(Nrt,:))
% yyaxis right
% plot(t,Ii(Nrt,:))
% yyaxis left
% plot(t,Ii(1,:))

%%%%%%%%%% conversion efficiency
FF0 = max(abs(Iff0(1,:)).^2);
FF1 = max(abs(Iff1(1,:)).^2);
SHG1 = max(abs(Ishg1(1,:)).^2);
SHG_conversion=(FF0-FF1)/FF0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% beam quality judgement
beam=[];
beam = Iff1(1,:);

Total_Energy = sum(abs(beam(1,:))*dt);

RR=0;
LL=0;
for TT = 1:1:length(t)
    if beam(1,length(t)-TT+1)>(max(beam)/2)
        RR=length(t)-TT+1; 
        break
    end 
end

for TT = 1:1:length(t)       
    if beam(1,RR-TT)<=(max(beam)/2)
        LL=RR-TT;
        break
    end
end

beam_Energy= sum(abs(beam(1,LL:RR))*dt);
Q=beam_Energy/Total_Energy

ita=fwhm1*1e-15*max(Iff1)/(I0*t0)

figure(4)
[AX,H1,H2] = plotyy(L,w_pulse,L,peakpower,'plot');
set(get(AX(1),'Ylabel'),'String','Pulse Duration(fs)'); 
set(get(AX(2),'Ylabel'),'String','Peak Power(W)'); 
xlabel('Length of Crystal(m)'); 
title('Pulse durantion and Peak power versus length of crystal');
%set(AX(2),'ylim',[0 4e4])
set(H1,'LineWidth',3);
set(H2,'LineWIdth',3);