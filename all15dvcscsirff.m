%% all 15 dvcs CSI and RFF from here considering one as a legitimate and other has attacker
%% Extract All 15 Devices
all_amp_mean = zeros(15,1);
all_amp_std  = zeros(15,1);

for d = 1:15
    amp_all = [];
    for r = 1:size(CSI,2)
        data = CSI{d,r};
        if ~isempty(data)
            amp     = abs(double(data));
            amp_all = [amp_all; amp(:)];
        end
    end
    if ~isempty(amp_all)
        all_amp_mean(d) = mean(amp_all);
        all_amp_std(d)  = std(amp_all);
    end
end

%% IMAGE 1 — CSI Amplitude All 15 Devices
figure('Name','IMAGE 1 CSI',...
       'Position',[50 50 900 500]);

b1=bar(all_amp_mean,0.6);
b1.FaceColor='flat';
for d=1:15
    if d==1; b1.CData(d,:)=[0 0 1];
    else;    b1.CData(d,:)=[1 0 0]; end
end
ylabel('Mean CSI Amplitude');
xlabel('Blue=Legitimate   Red=Attacker');
title('IMAGE 1: CSI Amplitude — All 15 Devices Same WiFi');
xticks(1:15);
xticklabels({'D1','D2','D3','D4','D5','D6','D7',...
             'D8','D9','D10','D11','D12','D13','D14','D15'});
grid on;
for d=1:15
    text(d,all_amp_mean(d)+0.003,...
        sprintf('%.3f',all_amp_mean(d)),...
        'HorizontalAlignment','center',...
        'FontSize',8,'FontWeight','bold');
end
text(1,all_amp_mean(1)+0.05,'LEGITIMATE',...
    'HorizontalAlignment','center',...
    'FontSize',9,'Color','blue',...
    'FontWeight','bold');

%% IMAGE 2 — RF Fingerprint All 15 Devices
figure('Name','IMAGE 2 RF Fingerprint',...
       'Position',[50 50 900 500]);

b2=bar(all_amp_std,0.6);
b2.FaceColor='flat';
for d=1:15
    if d==1; b2.CData(d,:)=[0 0 1];
    else;    b2.CData(d,:)=[1 0 0]; end
end
ylabel('Std CSI Amplitude = RF Fingerprint');
xlabel('Blue=Legitimate   Red=Attacker');
title('IMAGE 2: RF Fingerprint — All 15 Devices Unique');
xticks(1:15);
xticklabels({'D1','D2','D3','D4','D5','D6','D7',...
             'D8','D9','D10','D11','D12','D13','D14','D15'});
grid on;
for d=1:15
    text(d,all_amp_std(d)+0.003,...
        sprintf('%.3f',all_amp_std(d)),...
        'HorizontalAlignment','center',...
        'FontSize',8,'FontWeight','bold');
end
text(1,all_amp_std(1)+0.05,'LEGITIMATE',...
    'HorizontalAlignment','center',...
    'FontSize',9,'Color','blue',...
    'FontWeight','bold');

fprintf('2 images displayed!\n');