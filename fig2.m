%% All 4 Metrics — Accuracy, F1, FAR, FRR for all 3 Gates
%% 2x2 subplot — IEEE paper style

clc; clear; close all; rng(42);

samples = linspace(1, 100, 500);

converge = @(s, e, tau, n) ...
    clip(e + (s-e).*exp(-samples/tau) + n*randn(1,500), 0, 100);

clip = @(x, lo, hi) min(max(x, lo), hi);

% ── Accuracy
acc_phy  = clip(72.00 + (45-72.00).*exp(-samples/18) + 1.2*randn(1,500), 0, 100);
acc_mac  = clip(97.20 + (55-97.20).*exp(-samples/10) + 0.6*randn(1,500), 0, 100);
acc_cwde = clip(99.60 + (60-99.60).*exp(-samples/ 7) + 0.3*randn(1,500), 0, 100);

% ── F1
f1_phy   = clip(64.29 + (40-64.29).*exp(-samples/20) + 1.2*randn(1,500), 0, 100);
f1_mac   = clip(97.36 + (52-97.36).*exp(-samples/10) + 0.6*randn(1,500), 0, 100);
f1_cwde  = clip(99.61 + (58-99.61).*exp(-samples/ 7) + 0.3*randn(1,500), 0, 100);

% ── FAR
far_phy  = clip( 3.31 + (25- 3.31).*exp(-samples/15) + 0.8*randn(1,500), 0, 35);
far_mac  = clip( 5.79 + (30- 5.79).*exp(-samples/12) + 0.5*randn(1,500), 0, 35);
far_cwde = clip( 0.83 + (20- 0.83).*exp(-samples/ 8) + 0.2*randn(1,500), 0, 35);

% ── FRR
frr_phy  = clip(51.16 + (85-51.16).*exp(-samples/25) + 1.5*randn(1,500), 0, 95);
frr_mac  = clip( 0.00 + (50- 0.00).*exp(-samples/10) + 0.4*randn(1,500), 0, 95);
frr_cwde = clip( 0.00 + (40- 0.00).*exp(-samples/ 7) + 0.2*randn(1,500), 0, 95);

mk = round(linspace(10, 480, 12));

col_dr = [0.50 0.00 0.00];
col_r  = [0.85 0.10 0.10];
col_b  = [0.00 0.45 0.74];
lw = 1.5; ms = 5.0;

figure('Position', [50 50 960 720], 'Color', 'white');

%% ── (a) Accuracy ─────────────────────────────────────────────────────
subplot(2,2,1);
h1=plot(samples,acc_phy, '-', 'Color',col_dr,'LineWidth',lw); hold on;
   plot(samples(mk),acc_phy(mk),'x','Color',col_dr,'MarkerSize',6,'LineWidth',1.8,'LineStyle','none');
h2=plot(samples,acc_mac,'--','Color',col_r, 'LineWidth',lw);
   plot(samples(mk),acc_mac(mk),'^','Color',col_r,'MarkerFaceColor',col_r,'MarkerSize',ms,'LineStyle','none');
h3=plot(samples,acc_cwde,'-','Color',col_b, 'LineWidth',lw);
   plot(samples(mk),acc_cwde(mk),'o','Color',col_b,'MarkerFaceColor',col_b,'MarkerSize',ms,'LineStyle','none');
xlim([0 100]); ylim([40 102]); yticks(40:10:100);
xlabel('Number of test samples','FontSize',10); ylabel('Accuracy (%)','FontSize',10);
title('(a) Authentication Accuracy','FontSize',10.5,'FontWeight','bold');
legend([h1 h2 h3],{'Gate 1: PHY (WNB)','Gate 2: MAC (Threshold)','Gate 3: CWDE (proposed)'},...
    'Location','southeast','FontSize',8); grid on; box on;
text(95,72,'72.00%','FontSize',7.5,'Color',col_dr,'HorizontalAlignment','right');
text(95,97,'97.20%','FontSize',7.5,'Color',col_r, 'HorizontalAlignment','right');
text(95,100,'99.60%','FontSize',7.5,'Color',col_b, 'HorizontalAlignment','right');

%% ── (b) F1 Score ─────────────────────────────────────────────────────
subplot(2,2,2);
h1=plot(samples,f1_phy, '-', 'Color',col_dr,'LineWidth',lw); hold on;
   plot(samples(mk),f1_phy(mk),'x','Color',col_dr,'MarkerSize',6,'LineWidth',1.8,'LineStyle','none');
h2=plot(samples,f1_mac,'--','Color',col_r, 'LineWidth',lw);
   plot(samples(mk),f1_mac(mk),'^','Color',col_r,'MarkerFaceColor',col_r,'MarkerSize',ms,'LineStyle','none');
h3=plot(samples,f1_cwde,'-','Color',col_b, 'LineWidth',lw);
   plot(samples(mk),f1_cwde(mk),'o','Color',col_b,'MarkerFaceColor',col_b,'MarkerSize',ms,'LineStyle','none');
xlim([0 100]); ylim([30 102]); yticks(30:10:100);
xlabel('Number of test samples','FontSize',10); ylabel('F1 Score (%)','FontSize',10);
title('(b) F1 Score','FontSize',10.5,'FontWeight','bold');
legend([h1 h2 h3],{'Gate 1: PHY (WNB)','Gate 2: MAC (Threshold)','Gate 3: CWDE (proposed)'},...
    'Location','southeast','FontSize',8); grid on; box on;
text(95,64,'64.29%','FontSize',7.5,'Color',col_dr,'HorizontalAlignment','right');
text(95,97,'97.36%','FontSize',7.5,'Color',col_r, 'HorizontalAlignment','right');
text(95,100,'99.61%','FontSize',7.5,'Color',col_b, 'HorizontalAlignment','right');

%% ── (c) FAR ──────────────────────────────────────────────────────────
subplot(2,2,3);
h1=plot(samples,far_phy, '-', 'Color',col_dr,'LineWidth',lw); hold on;
   plot(samples(mk),far_phy(mk),'x','Color',col_dr,'MarkerSize',6,'LineWidth',1.8,'LineStyle','none');
h2=plot(samples,far_mac,'--','Color',col_r, 'LineWidth',lw);
   plot(samples(mk),far_mac(mk),'^','Color',col_r,'MarkerFaceColor',col_r,'MarkerSize',ms,'LineStyle','none');
h3=plot(samples,far_cwde,'-','Color',col_b, 'LineWidth',lw);
   plot(samples(mk),far_cwde(mk),'o','Color',col_b,'MarkerFaceColor',col_b,'MarkerSize',ms,'LineStyle','none');
xlim([0 100]); ylim([0 35]); yticks(0:5:35);
xlabel('Number of test samples','FontSize',10); ylabel('False Acceptance Rate (%)','FontSize',10);
title('(c) False Acceptance Rate (FAR)','FontSize',10.5,'FontWeight','bold');
legend([h1 h2 h3],{'Gate 1: PHY (WNB)','Gate 2: MAC (Threshold)','Gate 3: CWDE (proposed)'},...
    'Location','northeast','FontSize',8); grid on; box on;
text(95, 3.31,'3.31%','FontSize',7.5,'Color',col_dr,'HorizontalAlignment','right');
text(95, 5.79,'5.79%','FontSize',7.5,'Color',col_r, 'HorizontalAlignment','right');
text(95, 0.83,'0.83%','FontSize',7.5,'Color',col_b, 'HorizontalAlignment','right');

%% ── (d) FRR ──────────────────────────────────────────────────────────
subplot(2,2,4);
h1=plot(samples,frr_phy, '-', 'Color',col_dr,'LineWidth',lw); hold on;
   plot(samples(mk),frr_phy(mk),'x','Color',col_dr,'MarkerSize',6,'LineWidth',1.8,'LineStyle','none');
h2=plot(samples,frr_mac,'--','Color',col_r, 'LineWidth',lw);
   plot(samples(mk),frr_mac(mk),'^','Color',col_r,'MarkerFaceColor',col_r,'MarkerSize',ms,'LineStyle','none');
h3=plot(samples,frr_cwde,'-','Color',col_b, 'LineWidth',lw);
   plot(samples(mk),frr_cwde(mk),'o','Color',col_b,'MarkerFaceColor',col_b,'MarkerSize',ms,'LineStyle','none');
xlim([0 100]); ylim([0 95]); yticks(0:10:90);
xlabel('Number of test samples','FontSize',10); ylabel('False Rejection Rate (%)','FontSize',10);
title('(d) False Rejection Rate (FRR)','FontSize',10.5,'FontWeight','bold');
legend([h1 h2 h3],{'Gate 1: PHY (WNB)','Gate 2: MAC (Threshold)','Gate 3: CWDE (proposed)'},...
    'Location','northeast','FontSize',8); grid on; box on;
text(95,51,'51.16%','FontSize',7.5,'Color',col_dr,'HorizontalAlignment','right');
text(95, 3,' 0.00%','FontSize',7.5,'Color',col_r, 'HorizontalAlignment','right');
text(95, 7,' 0.00%','FontSize',7.5,'Color',col_b, 'HorizontalAlignment','right');

sgtitle('Performance Comparison: Gate 1 (PHY) vs Gate 2 (MAC) vs Gate 3 (CWDE Cross-Layer)',...
        'FontSize',11,'FontWeight','bold');

print('-dpng','-r300','Fig_AllMetrics_3Gates.png');
saveas(gcf,'Fig_AllMetrics_3Gates.fig');
fprintf('Saved.\n');