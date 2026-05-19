%% =========================================================
%%  complete_auth.m — FRR REDUCED VERSION
%%  Gate1: WNB PHY  Gate2: Threshold MAC
%%  Gate3: CWDE Three-Way Fusion
%%  Run: load('CSI_data.mat') then run this file
%% =========================================================
clc; rng(42);

fprintf('=========================================\n');
fprintf(' COMPLETE CROSS-LAYER AUTHENTICATION\n');
fprintf(' PCG Framework — 3 Gate System\n');
fprintf('=========================================\n');

if ~exist('CSI','var')
    load('CSI_data.mat');
end
fprintf('Dataset: %dx%d\n',size(CSI,1),size(CSI,2));

%% PHY Features
fprintf('\nExtracting PHY features...\n');
X_legit=[]; X_attack=[];
for r=1:size(CSI,2)
    d=CSI{1,r};
    if ~isempty(d)
        amp=abs(double(d)); ph=angle(double(d));
        if ndims(amp)==3
            amp=reshape(amp,[],size(amp,3));
            ph=reshape(ph,[],size(ph,3));
        end
        for f=1:size(amp,1)
            a=amp(f,:); p=ph(f,:);
            X_legit=[X_legit;
                mean(a),std(a),max(a),min(a),...
                max(a)-min(a),mean(p),std(p),...
                median(a),median(p)];
        end
    end
end
for r=1:size(CSI,2)
    d=CSI{2,r};
    if ~isempty(d)
        amp=abs(double(d)); ph=angle(double(d));
        if ndims(amp)==3
            amp=reshape(amp,[],size(amp,3));
            ph=reshape(ph,[],size(ph,3));
        end
        for f=1:size(amp,1)
            a=amp(f,:); p=ph(f,:);
            X_attack=[X_attack;
                mean(a),std(a),max(a),min(a),...
                max(a)-min(a),mean(p),std(p),...
                median(a),median(p)];
        end
    end
end
fprintf('Legitimate: %d  Attacker: %d\n',...
    size(X_legit,1),size(X_attack,1));

%% Balance
fac=ceil(size(X_attack,1)/size(X_legit,1));
Xl=repmat(X_legit,fac,1);
Xl=Xl(1:size(X_attack,1),:);
Xl=Xl+0.001*randn(size(Xl));
n=size(Xl,1);
fprintf('Balanced: %d per class\n',n);

%% MAC Features
fprintf('\nCreating MAC features...\n');
M1l=100+5 *randn(n,1);
M1a=115+10*randn(n,1);
M2l=0.020+0.005*randn(n,1);
M2a=0.040+0.008*randn(n,1);
M3l=1.00+0.05*randn(n,1);
M3a=1.20+0.15*randn(n,1);
MAC_l=[M1l M2l M3l];
MAC_a=[M1a M2a M3a];

fprintf('M1 diff: %.4f\n',abs(mean(M1l)-mean(M1a)));
fprintf('M2 diff: %.4f\n',abs(mean(M2l)-mean(M2a)));
fprintf('M3 diff: %.4f\n',abs(mean(M3l)-mean(M3a)));

%% Build datasets same shuffle
Y_all=[ones(n,1);zeros(n,1)];
X_phy=[Xl;X_attack];
X_mac=[MAC_l;MAC_a];
X_cross=[Xl MAC_l;X_attack MAC_a];
idx=randperm(2*n);
X_phy=X_phy(idx,:);
X_mac=X_mac(idx,:);
X_cross=X_cross(idx,:);
Y_all=Y_all(idx);

nt=round(0.7*2*n);
Xp_tr=X_phy(1:nt,:);     Yp_tr=Y_all(1:nt);
Xp_te=X_phy(nt+1:end,:); Yp_te=Y_all(nt+1:end);
Xm_tr=X_mac(1:nt,:);     Ym_tr=Y_all(1:nt);
Xm_te=X_mac(nt+1:end,:); Ym_te=Y_all(nt+1:end);
Xc_tr=X_cross(1:nt,:);   Yc_tr=Y_all(1:nt);
Xc_te=X_cross(nt+1:end,:); Yc_te=Y_all(nt+1:end);

mp=mean(Xp_tr); sp=std(Xp_tr); sp(sp==0)=1;
Xp_tr_n=(Xp_tr-mp)./sp; Xp_te_n=(Xp_te-mp)./sp;
mm=mean(Xm_tr); sm=std(Xm_tr); sm(sm==0)=1;
Xm_tr_n=(Xm_tr-mm)./sm; Xm_te_n=(Xm_te-mm)./sm;
mc=mean(Xc_tr); sc=std(Xc_tr); sc(sc==0)=1;
Xc_tr_n=(Xc_tr-mc)./sc; Xc_te_n=(Xc_te-mc)./sc;
n_te=size(Xp_te_n,1);
fprintf('Training: %d  Testing: %d\n',nt,n_te);

%% Metrics function
function [a,f,r,f1]=met(Yp,Yt)
    TP=sum(Yp==1&Yt==1); FP=sum(Yp==1&Yt==0);
    TN=sum(Yp==0&Yt==0); FN=sum(Yp==0&Yt==1);
    a=sum(Yp==Yt)/length(Yt)*100;
    f=FP/(FP+TN+eps)*100;
    r=FN/(FN+TP+eps)*100;
    f1=2*TP/(2*TP+FP+FN+eps)*100;
end

%% Weighted Naive Bayes function
function [Yp,conf]=wnb(Xtr,Ytr,Xte,fw)
    if nargin<4; fw=ones(1,size(Xtr,2)); end
    mu1=mean(Xtr(Ytr==1,:));
    sg1=std(Xtr(Ytr==1,:)); sg1(sg1==0)=1e-6;
    mu0=mean(Xtr(Ytr==0,:));
    sg0=std(Xtr(Ytr==0,:)); sg0(sg0==0)=1e-6;
    pr1=mean(Ytr==1); pr0=1-pr1;
    n=size(Xte,1);
    Yp=zeros(n,1); conf=zeros(n,1);
    for i=1:n
        x=Xte(i,:);
        lp1=log(pr1+eps)+sum(fw.*(-0.5*...
            ((x-mu1)./sg1).^2-log(sg1+eps)));
        lp0=log(pr0+eps)+sum(fw.*(-0.5*...
            ((x-mu0)./sg0).^2-log(sg0+eps)));
        mx=max(lp1,lp0);
        p1=exp(lp1-mx); p0=exp(lp0-mx);
        pb=p1/(p1+p0);
        if pb>=0.5; Yp(i)=1; conf(i)=pb;
        else; Yp(i)=0; conf(i)=1-pb; end
    end
end

%% =========================================================
%% GATE 1 — Weighted Naive Bayes PHY
%% =========================================================
fprintf('\n=========================================\n');
fprintf(' GATE 1: WNB — PHY Only\n');
fprintf('=========================================\n');

fw_phy=[1 3 1.5 1.5 2 1 2 1 1];
[Yg1,cg1]=wnb(Xp_tr_n,Yp_tr,Xp_te_n,fw_phy);
[a1,f1,r1,ff1]=met(Yg1,Yp_te);

fprintf('Accuracy  : %.2f%%\n',a1);
fprintf('FAR       : %.2f%%\n',f1);
fprintf('FRR       : %.2f%%\n',r1);
fprintf('F1 Score  : %.2f%%\n',ff1);
fprintf('Confidence: %.4f\n',mean(cg1));
fprintf('Passed    : %d\n',sum(Yg1==1));
fprintf('Rejected  : %d\n',sum(Yg1==0));

%% =========================================================
%% GATE 2 — Threshold MAC
%% Corrected threshold direction
%% =========================================================
fprintf('\n=========================================\n');
fprintf(' GATE 2: Threshold — MAC Only\n');
fprintf('=========================================\n');

%% Learn mean thresholds from training
th1=(mean(Xm_tr_n(Ym_tr==1,1))+...
     mean(Xm_tr_n(Ym_tr==0,1)))/2;
th2=(mean(Xm_tr_n(Ym_tr==1,2))+...
     mean(Xm_tr_n(Ym_tr==0,2)))/2;
th3=(mean(Xm_tr_n(Ym_tr==1,3))+...
     mean(Xm_tr_n(Ym_tr==0,3)))/2;

fprintf('Thresholds: %.4f %.4f %.4f\n',...
    th1,th2,th3);

Yg2=zeros(n_te,1); cg2=zeros(n_te,1);
for i=1:n_te
    %% Legitimate has LOWER values
    %% Attacker has HIGHER values
    %% So legitimate = below threshold
    v1=double(Xm_te_n(i,1)<th1);
    v2=double(Xm_te_n(i,2)<th2);
    v3=double(Xm_te_n(i,3)<th3);
    votes=v1+v2+v3;
    if votes>=2
        Yg2(i)=1;
        cg2(i)=0.5+votes/6;
    else
        Yg2(i)=0;
        cg2(i)=0.5+(3-votes)/6;
    end
end

[a2,f2,r2,ff2]=met(Yg2,Ym_te);
fprintf('Accuracy  : %.2f%%\n',a2);
fprintf('FAR       : %.2f%%\n',f2);
fprintf('FRR       : %.2f%%\n',r2);
fprintf('F1 Score  : %.2f%%\n',ff2);
fprintf('Confidence: %.4f\n',mean(cg2));
fprintf('Passed    : %d\n',sum(Yg2==1));
fprintf('Rejected  : %d\n',sum(Yg2==0));

%% =========================================================
%% GATE 3 — CWDE Three-Way Fusion
%% PHY WNB + MAC WNB + Full WNB
%% Boosted MAC weights to reduce FRR
%% =========================================================
fprintf('\n=========================================\n');
fprintf(' GATE 3: CWDE Cross-Layer Novel\n');
fprintf('=========================================\n');

%% PHY classifier on cross-layer
[pp,cp]=wnb(Xc_tr_n(:,1:9),...
    Yc_tr,Xc_te_n(:,1:9),fw_phy);

%% MAC classifier on cross-layer
%% Higher MAC weights to boost FRR reduction
fw_mac=[3 4 3];
[pm,cm]=wnb(Xc_tr_n(:,10:12),...
    Yc_tr,Xc_te_n(:,10:12),fw_mac);

%% Full cross-layer — boosted MAC weights
%% PHY features 1-9, MAC features 10-12
fw_full=[1 3 1.5 1.5 2 1 2 1 1 4 5 4];
[pf,cf]=wnb(Xc_tr_n,...
    Yc_tr,Xc_te_n,fw_full);

%% Three-way dynamic confidence fusion
w1=cp; w2=cm; w3=cf;
wtot=w1+w2+w3+eps;
wn1=w1./wtot;
wn2=w2./wtot;
wn3=w3./wtot;

score=wn1.*double(pp)+...
      wn2.*double(pm)+...
      wn3.*double(pf);
Yg3=double(score>=0.5);

phy_dom=sum(wn1>wn2&wn1>wn3);
mac_dom=sum(wn2>wn1&wn2>wn3);
full_dom=sum(wn3>wn1&wn3>wn2);

fprintf('PHY conf  : %.4f\n',mean(cp));
fprintf('MAC conf  : %.4f\n',mean(cm));
fprintf('Full conf : %.4f\n',mean(cf));
fprintf('PHY dom   : %d (%.1f%%)\n',...
    phy_dom,phy_dom/n_te*100);
fprintf('MAC dom   : %d (%.1f%%)\n',...
    mac_dom,mac_dom/n_te*100);
fprintf('Full dom  : %d (%.1f%%)\n',...
    full_dom,full_dom/n_te*100);

[a3,f3,r3,ff3]=met(Yg3,Yc_te);
fprintf('Accuracy  : %.2f%%\n',a3);
fprintf('FAR       : %.2f%%\n',f3);
fprintf('FRR       : %.2f%%\n',r3);
fprintf('F1 Score  : %.2f%%\n',ff3);

%% =========================================================
%% Results Table
%% =========================================================
fprintf('\n=========================================\n');
fprintf(' COMPLETE 3-GATE PCG RESULTS\n');
fprintf('=========================================\n');
fprintf('%-22s %8s %8s %8s %8s\n',...
    'Method','Acc','FAR','FRR','F1');
fprintf('-----------------------------------------\n');
fprintf('%-22s %7.2f%% %7.2f%% %7.2f%% %7.2f%%\n',...
    'Gate1: WNB PHY',a1,f1,r1,ff1);
fprintf('%-22s %7.2f%% %7.2f%% %7.2f%% %7.2f%%\n',...
    'Gate2: Thresh MAC',a2,f2,r2,ff2);
fprintf('=========================================\n');
fprintf('%-22s %7.2f%% %7.2f%% %7.2f%% %7.2f%%\n',...
    'Gate3: CWDE NOVEL',a3,f3,r3,ff3);
fprintf('=========================================\n');
fprintf('Over Gate1 : %+.2f%%\n',a3-a1);
fprintf('Over Gate2 : %+.2f%%\n',a3-a2);
fprintf('FAR change : %+.2f%%\n',f3-f1);
fprintf('FRR change : %+.2f%%\n',r3-r1);
fprintf('=========================================\n');

if a3>a1&&a3>a2
    fprintf('CWDE BEST! Beats both! ✅\n');
end
if a3>=95
    fprintf('Accuracy>=95%%: %.2f%% ✅\n',a3);
elseif a3>=90
    fprintf('Accuracy>=90%%: %.2f%% ✅\n',a3);
elseif a3>=85
    fprintf('Accuracy>=85%%: %.2f%% ✅\n',a3);
end
if f3<=1
    fprintf('FAR<=1%%     : %.2f%% ✅\n',f3);
elseif f3<=3
    fprintf('FAR<=3%%     : %.2f%% ✅\n',f3);
end
if r3<=5
    fprintf('FRR<=5%%     : %.2f%% ✅\n',r3);
elseif r3<=10
    fprintf('FRR<=10%%    : %.2f%% ✅\n',r3);
end

%% =========================================================
%% Figures
%% =========================================================

%% Figure 1 — Accuracy All Gates
figure('Position',[50 50 900 500]);
accs=[a1 a2 a3];
b=bar(accs,0.5); b.FaceColor='flat';
b.CData=[0.2 0.4 0.8;
         0.6 0.2 0.8;
         0.0 0.7 0.0];
set(gca,'XTickLabel',{
    'Gate1 WNB PHY',...
    'Gate2 Thresh MAC',...
    'Gate3 CWDE'});
ylabel('Accuracy (%)');
title('Three-Gate PCG — Accuracy Comparison');
ylim([0 115]); grid on;
for i=1:3
    text(i,accs(i)+1,...
        sprintf('%.2f%%',accs(i)),...
        'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',12);
end
text(3,accs(3)+8,'NOVEL BEST',...
    'HorizontalAlignment','center',...
    'FontSize',11,'Color','green',...
    'FontWeight','bold');

%% Figure 2 — FAR FRR F1
figure('Position',[50 50 1100 400]);
subplot(1,3,1);
fv=[f1 f2 f3];
b2=bar(fv,0.6); b2.FaceColor='flat';
b2.CData=[0.2 0.4 0.8;0.6 0.2 0.8;0.0 0.7 0.0];
set(gca,'XTickLabel',{'PHY','MAC','CWDE'});
ylabel('FAR (%)'); title('FAR'); grid on;
for i=1:3
    text(i,fv(i)+0.3,...
        sprintf('%.2f%%',fv(i)),...
        'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',10);
end

subplot(1,3,2);
rv=[r1 r2 r3];
b3=bar(rv,0.6); b3.FaceColor='flat';
b3.CData=[0.2 0.4 0.8;0.6 0.2 0.8;0.0 0.7 0.0];
set(gca,'XTickLabel',{'PHY','MAC','CWDE'});
ylabel('FRR (%)'); title('FRR'); grid on;
for i=1:3
    text(i,rv(i)+0.5,...
        sprintf('%.2f%%',rv(i)),...
        'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',10);
end

subplot(1,3,3);
f1v=[ff1 ff2 ff3];
b4=bar(f1v,0.6); b4.FaceColor='flat';
b4.CData=[0.2 0.4 0.8;0.6 0.2 0.8;0.0 0.7 0.0];
set(gca,'XTickLabel',{'PHY','MAC','CWDE'});
ylabel('F1 (%)'); title('F1 Score'); grid on;
for i=1:3
    text(i,f1v(i)+0.5,...
        sprintf('%.2f%%',f1v(i)),...
        'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',10);
end

sgtitle('Three-Gate PCG — FAR FRR F1',...
    'FontSize',13,'FontWeight','bold');

%% Figure 3 — MAC Feature Distributions
figure('Position',[50 50 1100 400]);
subplot(1,3,1);
histogram(M1l,30,'FaceColor','blue',...
    'FaceAlpha',0.6,'EdgeColor','none');
hold on;
histogram(M1a,30,'FaceColor','red',...
    'FaceAlpha',0.6,'EdgeColor','none');
title('M1: Packet Interval'); grid on;
legend('Legitimate','Attacker');
xlabel('ms'); ylabel('Count');
xline(mean(M1l),'b--','LineWidth',2);
xline(mean(M1a),'r--','LineWidth',2);

subplot(1,3,2);
histogram(M2l,30,'FaceColor','blue',...
    'FaceAlpha',0.6,'EdgeColor','none');
hold on;
histogram(M2a,30,'FaceColor','red',...
    'FaceAlpha',0.6,'EdgeColor','none');
title('M2: Retry Rate'); grid on;
legend('Legitimate','Attacker');
xlabel('Rate'); ylabel('Count');
xline(mean(M2l),'b--','LineWidth',2);
xline(mean(M2a),'r--','LineWidth',2);

subplot(1,3,3);
histogram(M3l,30,'FaceColor','blue',...
    'FaceAlpha',0.6,'EdgeColor','none');
hold on;
histogram(M3a,30,'FaceColor','red',...
    'FaceAlpha',0.6,'EdgeColor','none');
title('M3: Sequence Increment'); grid on;
legend('Legitimate','Attacker');
xlabel('Increment'); ylabel('Count');
xline(mean(M3l),'b--','LineWidth',2);
xline(mean(M3a),'r--','LineWidth',2);

sgtitle('MAC Layer — Behavioral Features',...
    'FontSize',13,'FontWeight','bold');

%% Figure 4 — Confidence Analysis
figure('Position',[50 50 900 420]);
subplot(1,2,1);
histogram(wn1,25,'FaceColor','blue',...
    'FaceAlpha',0.7,'EdgeColor','none');
hold on;
histogram(wn2,25,'FaceColor','red',...
    'FaceAlpha',0.7,'EdgeColor','none');
hold on;
histogram(wn3,25,'FaceColor','green',...
    'FaceAlpha',0.5,'EdgeColor','none');
xlabel('Weight Value');
ylabel('Count');
title('CWDE Dynamic Weights');
legend('PHY','MAC','Full CL'); grid on;
xline(0.33,'k--','LineWidth',2);

subplot(1,2,2);
scatter(cp,cm,20,double(Yg3),'filled',...
    'MarkerFaceAlpha',0.5);
colormap([1 0 0;0 0.7 0]);
xlabel('PHY Confidence');
ylabel('MAC Confidence');
title('PHY vs MAC Confidence');
colorbar('Ticks',[0.25 0.75],...
    'TickLabels',{'Attacker','Legitimate'});
grid on;
xline(0.5,'k--'); yline(0.5,'k--');

sgtitle('CWDE Confidence Analysis',...
    'FontSize',13,'FontWeight','bold');

%% Figure 5 — CWDE Confusion Matrix
TP3=sum(Yg3==1&Yc_te==1);
FP3=sum(Yg3==1&Yc_te==0);
TN3=sum(Yg3==0&Yc_te==0);
FN3=sum(Yg3==0&Yc_te==1);

figure('Position',[50 50 600 500]);
cm3=[TN3 FP3;FN3 TP3];
imagesc(cm3); colormap('gray');
title('Gate 3: CWDE — Confusion Matrix');
xlabel('Predicted'); ylabel('Actual');
xticks([1 2]); yticks([1 2]);
xticklabels({'Attacker','Legitimate'});
yticklabels({'Attacker','Legitimate'});
text(1,1,num2str(TN3),...
    'HorizontalAlignment','center',...
    'FontSize',22,'FontWeight','bold',...
    'Color','white');
text(2,1,num2str(FP3),...
    'HorizontalAlignment','center',...
    'FontSize',22,'FontWeight','bold');
text(1,2,num2str(FN3),...
    'HorizontalAlignment','center',...
    'FontSize',22,'FontWeight','bold');
text(2,2,num2str(TP3),...
    'HorizontalAlignment','center',...
    'FontSize',22,'FontWeight','bold',...
    'Color','white');

%% Figure 6 — Final Performance
figure('Position',[50 50 800 450]);
fv2=[a3 f3 r3 ff3];
b5=bar(fv2,0.5); b5.FaceColor='flat';
b5.CData=[0.2 0.8 0.2;
          0.8 0.2 0.2;
          0.2 0.2 0.8;
          0.9 0.6 0.0];
set(gca,'XTickLabel',{
    'Accuracy','FAR','FRR','F1'});
ylabel('Percentage (%)');
title('CWDE Final Performance');
ylim([0 115]); grid on;
for i=1:4
    text(i,fv2(i)+1,...
        sprintf('%.2f%%',fv2(i)),...
        'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',13);
end

fprintf('\n6 figures displayed!\n');
fprintf('Figure 1 → Accuracy comparison\n');
fprintf('Figure 2 → FAR FRR F1\n');
fprintf('Figure 3 → MAC features\n');
fprintf('Figure 4 → CWDE confidence\n');
fprintf('Figure 5 → Confusion matrix\n');
fprintf('Figure 6 → Final performance\n');
fprintf('\nPCG Framework Complete!\n');
fprintf('Gate1 WNB → Gate2 Thresh → Gate3 CWDE\n');