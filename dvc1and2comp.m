%% Device 1 vs Device 2
%% CSI and RFF Comparison — 2 Images Only
clc; rng(42);

%% Extract Device 1 and Device 2
d1_amp = []; d2_amp = [];

for r = 1:size(CSI,2)
    data = CSI{1,r};
    if ~isempty(data)
        amp    = abs(double(data));
        d1_amp = [d1_amp; amp(:)];
    end
end

for r = 1:size(CSI,2)
    data = CSI{2,r};
    if ~isempty(data)
        amp    = abs(double(data));
        d2_amp = [d2_amp; amp(:)];
    end
end

fprintf('Device 1 Legitimate samples : %d\n', length(d1_amp));
fprintf('Device 2 Attacker   samples : %d\n', length(d2_amp));

%% CSI Values
d1_csi = mean(d1_amp);   % Device 1 CSI
d2_csi = mean(d2_amp);   % Device 2 CSI

%% RFF Values
d1_rff = std(d1_amp);    % Device 1 RF Fingerprint
d2_rff = std(d2_amp);    % Device 2 RF Fingerprint

fprintf('\n==========================================\n');
fprintf(' DEVICE 1 vs DEVICE 2\n');
fprintf('==========================================\n');
fprintf('           Device 1      Device 2\n');
fprintf('           Legitimate    Attacker\n');
fprintf('------------------------------------------\n');
fprintf('CSI Mean : %-12.4f %-12.4f\n', d1_csi, d2_csi);
fprintf('RFF Std  : %-12.4f %-12.4f\n', d1_rff, d2_rff);
fprintf('------------------------------------------\n');
fprintf('CSI Diff : %.4f\n', abs(d1_csi-d2_csi));
fprintf('RFF Diff : %.4f\n', abs(d1_rff-d2_rff));
fprintf('==========================================\n');

%% IMAGE 1 — CSI Comparison Device 1 vs Device 2
figure('Name','IMAGE 1 CSI Comparison',...
       'Position',[50 50 700 500]);

b1 = bar([d1_csi d2_csi], 0.5);
b1.FaceColor = 'flat';
b1.CData = [0 0 1; 1 0 0];
set(gca,'XTickLabel',{
    'Device 1 (Legitimate)',...
    'Device 2 (Attacker)'});
ylabel('Mean CSI Amplitude');
title('IMAGE 1: CSI Comparison — Device 1 vs Device 2');
ylim([0 1.2]);
grid on;

text(1, d1_csi+0.02,...
    sprintf('%.4f', d1_csi),...
    'HorizontalAlignment','center',...
    'FontSize',14,'FontWeight','bold',...
    'Color','blue');

text(2, d2_csi+0.02,...
    sprintf('%.4f', d2_csi),...
    'HorizontalAlignment','center',...
    'FontSize',14,'FontWeight','bold',...
    'Color','red');

text(1.5, 1.1,...
    sprintf('CSI Difference = %.4f (Similar!)', abs(d1_csi-d2_csi)),...
    'HorizontalAlignment','center',...
    'FontSize',12,'FontWeight','bold',...
    'Color','red',...
    'BackgroundColor','yellow');



%% IMAGE 2 — RFF Comparison Device 1 vs Device 2
figure('Name','IMAGE 2 RFF Comparison',...
       'Position',[50 50 700 500]);

b2 = bar([d1_rff d2_rff], 0.5);
b2.FaceColor = 'flat';
b2.CData = [0 0 1; 1 0 0];
set(gca,'XTickLabel',{
    'Device 1 (Legitimate)',...
    'Device 2 (Attacker)'});
ylabel('Std CSI Amplitude = RF Fingerprint');
title('IMAGE 2: RF Fingerprint — Device 1 vs Device 2');
ylim([0 0.6]);
grid on;

text(1, d1_rff+0.01,...
    sprintf('%.4f', d1_rff),...
    'HorizontalAlignment','center',...
    'FontSize',14,'FontWeight','bold',...
    'Color','blue');

text(2, d2_rff+0.01,...
    sprintf('%.4f', d2_rff),...
    'HorizontalAlignment','center',...
    'FontSize',14,'FontWeight','bold',...
    'Color','red');

text(1.5, 0.55,...
    sprintf('RFF Difference = %.4f (Different!)', abs(d1_rff-d2_rff)),...
    'HorizontalAlignment','center',...
    'FontSize',12,'FontWeight','bold',...
    'Color','blue',...
    'BackgroundColor','yellow');



fprintf('\n2 images displayed!\n');
fprintf('Image 1 → CSI similar\n');
fprintf('Image 2 → RFF different\n');