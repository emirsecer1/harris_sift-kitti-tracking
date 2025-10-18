% =========================================================================
% Sonuç Analizi ve Rapor Oluşturma
% =========================================================================
% Bu script tracking sonuçlarını analiz eder ve detaylı bir rapor oluşturur.

function generateTrackingReport(trackStats, harrisParams, trackParams, numFrames)
% generateTrackingReport - Tracking sonuçları için detaylı rapor oluşturur
%
% Girişler:
%   trackStats   - İstatistik yapısı
%   harrisParams - Harris parametreleri
%   trackParams  - İzleme parametreleri
%   numFrames    - İşlenen toplam kare sayısı

%% 1. İSTATİSTİKLERİ HESAPLA
avgTracked = mean(trackStats.numTracked);
stdTracked = std(trackStats.numTracked);
minTracked = min(trackStats.numTracked);
maxTracked = max(trackStats.numTracked);

avgLost = mean(trackStats.numLost);
avgDisplacement = mean(trackStats.avgDisplacement);
maxDisplacement = max(trackStats.avgDisplacement);

successRate = trackStats.numTracked ./ (trackStats.numTracked + trackStats.numLost) * 100;
avgSuccessRate = mean(successRate);

%% 2. KONSOL RAPORU
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║      KITTI VISUAL ODOMETRY - TRACKING RAPORU               ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  GENEL BİLGİLER\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  • Toplam Kare Sayısı       : %d\n', numFrames);
fprintf('  • İşlenen Kare Aralığı     : Frame 1 - Frame %d\n', numFrames);
fprintf('  • İzleme Yöntemi           : ');
if trackParams.useSIFT
    fprintf('SIFT Tabanlı\n');
else
    fprintf('Patch Tabanlı (NCC)\n');
end
fprintf('\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  HARRIS KÖŞE ALGILAMA PARAMETRELERİ\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  • Harris Sabiti (k)        : %.4f\n', harrisParams.k);
fprintf('  • Eşik Değeri              : %.4f\n', harrisParams.threshold);
fprintf('  • Pencere Boyutu           : %d\n', harrisParams.windowSize);
fprintf('  • Gaussian Sigma           : %.2f\n', harrisParams.sigma);
fprintf('  • Maksimum Köşe Sayısı     : %d\n', harrisParams.maxCorners);
fprintf('\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  İZLEME PARAMETRELERİ\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  • Patch Boyutu             : %d × %d\n', trackParams.patchSize, trackParams.patchSize);
fprintf('  • Arama Yarıçapı           : %d piksel\n', trackParams.searchRadius);
fprintf('  • Benzerlik Eşiği (NCC)    : %.2f\n', trackParams.similarityThreshold);
fprintf('\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  İZLEME PERFORMANSI\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  • Ortalama İzlenen Özellik : %.2f ± %.2f\n', avgTracked, stdTracked);
fprintf('  • Minimum İzlenen          : %d\n', minTracked);
fprintf('  • Maksimum İzlenen         : %d\n', maxTracked);
fprintf('  • Ortalama Kaybedilen      : %.2f\n', avgLost);
fprintf('  • Ortalama Başarı Oranı    : %.2f%%\n', avgSuccessRate);
fprintf('\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  HAREKET ANALİZİ\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  • Ortalama Yer Değiştirme  : %.2f piksel\n', avgDisplacement);
fprintf('  • Maksimum Yer Değiştirme  : %.2f piksel\n', maxDisplacement);
fprintf('  • Tahmini Hız (30 fps)     : %.2f piksel/saniye\n', avgDisplacement * 30);
fprintf('\n');

%% 3. PERFORMANS DEĞERLENDİRMESİ
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('  PERFORMANS DEĞERLENDİRMESİ\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

if avgSuccessRate > 85
    fprintf('  ✓ Mükemmel - Tracking başarı oranı çok yüksek!\n');
elseif avgSuccessRate > 70
    fprintf('  ✓ İyi - Tracking genel olarak başarılı.\n');
elseif avgSuccessRate > 50
    fprintf('  ⚠ Orta - Tracking performansı geliştirilmeli.\n');
else
    fprintf('  ✗ Zayıf - Parametre optimizasyonu gerekli.\n');
end

if avgDisplacement < 5
    fprintf('  ✓ Düşük Hareket - Sabit kamera veya yavaş hareket.\n');
elseif avgDisplacement < 15
    fprintf('  ✓ Normal Hareket - Tipik araç hareketi.\n');
else
    fprintf('  ⚠ Yüksek Hareket - Hızlı hareket veya ani değişimler.\n');
end

fprintf('\n');

%% 4. DETAYLI GRAFİKLER
figure('Name', 'Detaylı Tracking Analizi', 'NumberTitle', 'off', ...
       'Position', [50, 50, 1400, 900]);

% Subplot 1: Zaman serisi - İzlenen özellikler
subplot(3, 3, 1);
plot(2:numFrames, trackStats.numTracked, 'b-', 'LineWidth', 1.5);
hold on;
yline(avgTracked, 'r--', 'LineWidth', 1.5, 'Label', sprintf('Ort: %.1f', avgTracked));
hold off;
grid on;
xlabel('Frame Numarası');
ylabel('İzlenen Özellik Sayısı');
title('İzlenen Özellikler (Zaman Serisi)');
legend('İzlenen', 'Ortalama', 'Location', 'best');

% Subplot 2: Kaybedilen özellikler
subplot(3, 3, 2);
plot(2:numFrames, trackStats.numLost, 'r-', 'LineWidth', 1.5);
hold on;
yline(avgLost, 'b--', 'LineWidth', 1.5, 'Label', sprintf('Ort: %.1f', avgLost));
hold off;
grid on;
xlabel('Frame Numarası');
ylabel('Kaybedilen Özellik Sayısı');
title('Kaybedilen Özellikler (Zaman Serisi)');
legend('Kaybedilen', 'Ortalama', 'Location', 'best');

% Subplot 3: Başarı oranı
subplot(3, 3, 3);
plot(2:numFrames, successRate, 'g-', 'LineWidth', 1.5);
hold on;
yline(avgSuccessRate, 'm--', 'LineWidth', 1.5, 'Label', sprintf('Ort: %.1f%%', avgSuccessRate));
hold off;
grid on;
xlabel('Frame Numarası');
ylabel('Başarı Oranı (%)');
title('İzleme Başarı Oranı');
ylim([0, 100]);
legend('Başarı Oranı', 'Ortalama', 'Location', 'best');

% Subplot 4: Yer değiştirme
subplot(3, 3, 4);
plot(2:numFrames, trackStats.avgDisplacement, 'c-', 'LineWidth', 1.5);
hold on;
yline(avgDisplacement, 'r--', 'LineWidth', 1.5, 'Label', sprintf('Ort: %.2f', avgDisplacement));
hold off;
grid on;
xlabel('Frame Numarası');
ylabel('Yer Değiştirme (piksel)');
title('Ortalama Özellik Yer Değiştirmesi');
legend('Yer Değiştirme', 'Ortalama', 'Location', 'best');

% Subplot 5: Histogram - İzlenen özellikler
subplot(3, 3, 5);
histogram(trackStats.numTracked, 20, 'FaceColor', 'b', 'EdgeColor', 'k');
xline(avgTracked, 'r--', 'LineWidth', 2, 'Label', 'Ortalama');
grid on;
xlabel('İzlenen Özellik Sayısı');
ylabel('Frekans');
title('İzlenen Özellik Dağılımı');

% Subplot 6: Histogram - Yer değiştirme
subplot(3, 3, 6);
histogram(trackStats.avgDisplacement, 20, 'FaceColor', 'c', 'EdgeColor', 'k');
xline(avgDisplacement, 'r--', 'LineWidth', 2, 'Label', 'Ortalama');
grid on;
xlabel('Yer Değiştirme (piksel)');
ylabel('Frekans');
title('Yer Değiştirme Dağılımı');

% Subplot 7: Kümülatif kayıp
subplot(3, 3, 7);
cumulativeLoss = cumsum(trackStats.numLost);
plot(2:numFrames, cumulativeLoss, 'r-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('Kümülatif Kayıp');
title('Zaman İçinde Toplam Kayıp');

% Subplot 8: Tracking stabilitesi (hareketli ortalama)
subplot(3, 3, 8);
windowSize = 10;
movingAvg = movmean(trackStats.numTracked, windowSize);
plot(2:numFrames, movingAvg, 'b-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('Hareketli Ortalama');
title(sprintf('Tracking Stabilitesi (%d-Frame Hareketli Ort.)', windowSize));

% Subplot 9: Scatter - İzlenen vs Kaybedilen
subplot(3, 3, 9);
scatter(trackStats.numTracked, trackStats.numLost, 30, 2:numFrames, 'filled');
colorbar;
xlabel('İzlenen Özellik Sayısı');
ylabel('Kaybedilen Özellik Sayısı');
title('İzlenen vs Kaybedilen (Renk: Frame)');
grid on;

%% 5. RAPORU DOSYAYA KAYDET
reportFileName = sprintf('tracking_report_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
fid = fopen(reportFileName, 'w');

fprintf(fid, '================================================================\n');
fprintf(fid, 'KITTI VISUAL ODOMETRY - TRACKING PERFORMANS RAPORU\n');
fprintf(fid, '================================================================\n');
fprintf(fid, 'Tarih: %s\n\n', datestr(now));

fprintf(fid, '1. GENEL BİLGİLER\n');
fprintf(fid, '   - Toplam Kare: %d\n', numFrames);
fprintf(fid, '   - İzleme Yöntemi: %s\n', ...
        iif(trackParams.useSIFT, 'SIFT Tabanlı', 'Patch Tabanlı (NCC)'));
fprintf(fid, '\n');

fprintf(fid, '2. HARRIS PARAMETRELERİ\n');
fprintf(fid, '   - k: %.4f\n', harrisParams.k);
fprintf(fid, '   - Threshold: %.4f\n', harrisParams.threshold);
fprintf(fid, '   - Window Size: %d\n', harrisParams.windowSize);
fprintf(fid, '   - Sigma: %.2f\n', harrisParams.sigma);
fprintf(fid, '   - Max Corners: %d\n', harrisParams.maxCorners);
fprintf(fid, '\n');

fprintf(fid, '3. PERFORMANS İSTATİSTİKLERİ\n');
fprintf(fid, '   - Ortalama İzlenen: %.2f ± %.2f\n', avgTracked, stdTracked);
fprintf(fid, '   - Min İzlenen: %d\n', minTracked);
fprintf(fid, '   - Max İzlenen: %d\n', maxTracked);
fprintf(fid, '   - Ortalama Kaybedilen: %.2f\n', avgLost);
fprintf(fid, '   - Başarı Oranı: %.2f%%\n', avgSuccessRate);
fprintf(fid, '   - Ortalama Yer Değiştirme: %.2f piksel\n', avgDisplacement);
fprintf(fid, '\n');

fclose(fid);
fprintf('📄 Rapor dosyası kaydedildi: %s\n', reportFileName);

end

%% Yardımcı Fonksiyon: Inline If
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end