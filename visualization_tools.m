% =========================================================================
% GELİŞMİŞ GÖRSELLEŞTİRME ARAÇLARI
% =========================================================================
% Bu script tracking sonuçlarını detaylı görselleştirmek için araçlar içerir.

%% 1. TRAJECTORY VİZUALİZASYONU
function visualizeTrajectories(trackingData, numFeaturesToShow)
% visualizeTrajectories - Özellik yörüngelerini 2D olarak görselleştirir
%
% Girişler:
%   trackingData      - Nx2xT matris (N özellik, 2 koordinat, T frame)
%   numFeaturesToShow - Görselleştirilecek özellik sayısı

if nargin < 2
    numFeaturesToShow = min(50, size(trackingData, 1));
end

figure('Name', 'Feature Trajectories', 'Position', [100, 100, 1000, 800]);

% Rastgele özellik seç
numFeatures = size(trackingData, 1);
selectedIdx = randperm(numFeatures, numFeaturesToShow);

% Her özellik için yörüngeyi çiz
colors = jet(numFeaturesToShow);
hold on;
for i = 1:numFeaturesToShow
    idx = selectedIdx(i);
    trajectory = squeeze(trackingData(idx, :, :))';
    
    % Yörüngeyi çiz
    plot(trajectory(:, 1), trajectory(:, 2), '-', ...
         'Color', colors(i, :), 'LineWidth', 1.5);
    
    % Başlangıç noktası (yeşil)
    plot(trajectory(1, 1), trajectory(1, 2), 'go', ...
         'MarkerSize', 8, 'MarkerFaceColor', 'g');
    
    % Bitiş noktası (kırmızı)
    plot(trajectory(end, 1), trajectory(end, 2), 'rs', ...
         'MarkerSize', 8, 'MarkerFaceColor', 'r');
end
hold off;

grid on;
xlabel('X Koordinatı (piksel)');
ylabel('Y Koordinatı (piksel)');
title(sprintf('Özellik Yörüngeleri (%d özellik)', numFeaturesToShow));
legend('', 'Başlangıç', 'Bitiş', 'Location', 'best');
axis equal;
set(gca, 'YDir', 'reverse'); % Görüntü koordinat sistemi

end

%% 2. HEATMAP GÖRSELLEŞTİRMESİ
function visualizeFeatureDensity(corners, imgSize)
% visualizeFeatureDensity - Özellik yoğunluğu ısı haritası oluşturur
%
% Girişler:
%   corners - Nx2 matris, köşe koordinatları [x, y]
%   imgSize - [height, width] görüntü boyutu

if nargin < 2
    imgSize = [376, 1241]; % KITTI default boyut
end

% 2D histogram oluştur
edges_x = linspace(1, imgSize(2), 30);
edges_y = linspace(1, imgSize(1), 20);

heatmap = histcounts2(corners(:, 2), corners(:, 1), edges_y, edges_x);

% Görselleştir
figure('Name', 'Feature Density Heatmap', 'Position', [100, 100, 1000, 400]);
imagesc(heatmap);
colormap('hot');
colorbar;
title(sprintf('Özellik Yoğunluğu Haritası (%d özellik)', size(corners, 1)));
xlabel('X Bölgesi');
ylabel('Y Bölgesi');
axis equal tight;

end

%% 3. TEMPORAL ANALİZ GRAFİĞİ
function plotTemporalAnalysis(trackStats, windowSize)
% plotTemporalAnalysis - Zamansal analiz grafikleri oluşturur
%
% Girişler:
%   trackStats - İstatistik yapısı
%   windowSize - Hareketli ortalama pencere boyutu

if nargin < 2
    windowSize = 10;
end

numFrames = length(trackStats.numTracked) + 1;

figure('Name', 'Temporal Analysis', 'Position', [50, 50, 1400, 800]);

% 1. Tracking stability
subplot(2, 3, 1);
stability = movstd(trackStats.numTracked, windowSize);
plot(2:numFrames, stability, 'b-', 'LineWidth', 2);
grid on;
xlabel('Frame');
ylabel('Standart Sapma');
title('Tracking Stabilitesi (Hareketli Std)');

% 2. Kümülatif performans
subplot(2, 3, 2);
successRate = trackStats.numTracked ./ ...
              (trackStats.numTracked + trackStats.numLost) * 100;
cumSuccess = cumsum(successRate) ./ (1:length(successRate))';
plot(2:numFrames, cumSuccess, 'g-', 'LineWidth', 2);
grid on;
xlabel('Frame');
ylabel('Kümülatif Başarı (%)');
title('Zaman İçinde Ortalama Başarı');
ylim([0, 100]);

% 3. Displacement velocity
subplot(2, 3, 3);
velocity = [0; diff(trackStats.avgDisplacement)];
plot(2:numFrames, velocity, 'r-', 'LineWidth', 1.5);
hold on;
yline(0, 'k--', 'LineWidth', 1);
hold off;
grid on;
xlabel('Frame');
ylabel('Hız Değişimi (piksel/frame)');
title('Hareket Hızı Değişimi');

% 4. Feature lifetime
subplot(2, 3, 4);
featureLife = trackStats.numTracked ./ max(trackStats.numTracked) * 100;
area(2:numFrames, featureLife, 'FaceColor', 'c', 'EdgeColor', 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frame');
ylabel('Canlı Özellik Oranı (%)');
title('Özellik Yaşam Süresi');
ylim([0, 100]);

% 5. Loss rate
subplot(2, 3, 5);
lossRate = trackStats.numLost ./ ...
           (trackStats.numTracked + trackStats.numLost) * 100;
bar(2:numFrames, lossRate, 'r');
grid on;
xlabel('Frame');
ylabel('Kayıp Oranı (%)');
title('Frame Başına Kayıp Oranı');
ylim([0, 100]);

% 6. Correlation analysis
subplot(2, 3, 6);
scatter(trackStats.avgDisplacement, trackStats.numLost, 50, ...
        2:numFrames, 'filled', 'MarkerEdgeColor', 'k');
colorbar;
xlabel('Ortalama Yer Değiştirme (piksel)');
ylabel('Kaybedilen Özellik Sayısı');
title('Hareket vs Kayıp Korelasyonu');
grid on;

end

%% 4. PARAMETRE KARŞILAŞTIRMA ARACI
function compareParameters()
% compareParameters - Farklı parametre setlerini karşılaştırır

fprintf('═══════════════════════════════════════════\n');
fprintf('  PARAMETRE KARŞILAŞTIRMA ARACI\n');
fprintf('═══════════════════════════════════════════\n\n');

% Test edilecek parametreler
testConfigs = {
    struct('name', 'Conservative', 'k', 0.04, 'threshold', 0.02, 'patchSize', 15),
    struct('name', 'Balanced', 'k', 0.04, 'threshold', 0.01, 'patchSize', 15),
    struct('name', 'Aggressive', 'k', 0.04, 'threshold', 0.005, 'patchSize', 21),
    struct('name', 'Fast', 'k', 0.06, 'threshold', 0.015, 'patchSize', 11)
};

numConfigs = length(testConfigs);
results = struct('avgTracked', zeros(numConfigs, 1), ...
                'avgSuccess', zeros(numConfigs, 1), ...
                'avgDisplacement', zeros(numConfigs, 1), ...
                'runtime', zeros(numConfigs, 1));

% Sentetik test görüntüleri oluştur
img1 = checkerboard(30, 12, 20);
img2 = imtranslate(img1, [5, 3]);

fprintf('Test konfigürasyonları çalıştırılıyor...\n\n');

for i = 1:numConfigs
    fprintf('Konfigürasyon %d/%d: %s\n', i, numConfigs, testConfigs{i}.name);
    
    % Parametreleri ayarla
    harrisParams.k = testConfigs{i}.k;
    harrisParams.threshold = testConfigs{i}.threshold;
    harrisParams.windowSize = 3;
    harrisParams.sigma = 1.5;
    harrisParams.maxCorners = 500;
    
    trackParams.patchSize = testConfigs{i}.patchSize;
    trackParams.searchRadius = 20;
    trackParams.similarityThreshold = 0.7;
    trackParams.useSIFT = false;
    
    % Test çalıştır
    tic;
    [corners, ~] = harris_detector(img1, harrisParams);
    [~, validIdx, displacement] = feature_tracker(img1, img2, corners, trackParams);
    runtime = toc;
    
    % Sonuçları kaydet
    results.avgTracked(i) = sum(validIdx);
    results.avgSuccess(i) = sum(validIdx) / length(validIdx) * 100;
    results.avgDisplacement(i) = mean(displacement);
    results.runtime(i) = runtime;
    
    fprintf('  ✓ İzlenen: %d, Başarı: %.1f%%, Süre: %.3f sn\n\n', ...
            results.avgTracked(i), results.avgSuccess(i), runtime);
end

% Karşılaştırma grafiği
figure('Name', 'Parameter Comparison', 'Position', [100, 100, 1200, 800]);

configNames = {testConfigs.name};

subplot(2, 2, 1);
bar(results.avgTracked);
set(gca, 'XTickLabel', configNames);
ylabel('İzlenen Özellik Sayısı');
title('İzlenen Özellik Karşılaştırması');
grid on;

subplot(2, 2, 2);
bar(results.avgSuccess);
set(gca, 'XTickLabel', configNames);
ylabel('Başarı Oranı (%)');
title('Tracking Başarı Oranı');
ylim([0, 100]);
grid on;

subplot(2, 2, 3);
bar(results.avgDisplacement);
set(gca, 'XTickLabel', configNames);
ylabel('Ortalama Yer Değiştirme (piksel)');
title('Hareket Hassasiyeti');
grid on;

subplot(2, 2, 4);
bar(results.runtime * 1000);
set(gca, 'XTickLabel', configNames);
ylabel('Çalışma Süresi (ms)');
title('Performans Hızı');
grid on;

fprintf('═══════════════════════════════════════════\n');
fprintf('Karşılaştırma tamamlandı!\n');
fprintf('═══════════════════════════════════════════\n');

end

%% 5. 3D TRAJECTORY GÖRSELLEŞTİRMESİ
function visualize3DTrajectory(trackingData)
% visualize3DTrajectory - Yörüngeleri 3D uzayda (x, y, time) gösterir
%
% Girişler:
%   trackingData - Nx2xT matris

numFeatures = min(30, size(trackingData, 1));
selectedIdx = randperm(size(trackingData, 1), numFeatures);

figure('Name', '3D Trajectory Visualization', 'Position', [100, 100, 1000, 800]);
hold on;
grid on;

colors = jet(numFeatures);

for i = 1:numFeatures
    idx = selectedIdx(i);
    trajectory = squeeze(trackingData(idx, :, :))';
    numFrames = size(trajectory, 1);
    
    % 3D çizgi (x, y, time)
    plot3(trajectory(:, 1), trajectory(:, 2), 1:numFrames, ...
          'Color', colors(i, :), 'LineWidth', 2);
    
    % Başlangıç ve bitiş noktaları
    plot3(trajectory(1, 1), trajectory(1, 2), 1, 'go', ...
          'MarkerSize', 10, 'MarkerFaceColor', 'g');
    plot3(trajectory(end, 1), trajectory(end, 2), numFrames, 'rs', ...
          'MarkerSize', 10, 'MarkerFaceColor', 'r');
end

hold off;
xlabel('X (piksel)');
ylabel('Y (piksel)');
zlabel('Frame (zaman)');
title('3D Özellik Yörüngeleri');
view(45, 30);
rotate3d on;

end

%% 6. PERFORMANS DASHBOARD
function createPerformanceDashboard(trackStats, harrisParams, trackParams)
% createPerformanceDashboard - Tüm metrikleri tek bir dashboardda gösterir

fig = figure('Name', 'Performance Dashboard', 'NumberTitle', 'off', ...
             'Position', [50, 50, 1600, 900]);

% Ana başlık
annotation('textbox', [0.35, 0.95, 0.3, 0.04], ...
           'String', 'TRACKING PERFORMANCE DASHBOARD', ...
           'FontSize', 16, 'FontWeight', 'bold', ...
           'HorizontalAlignment', 'center', ...
           'EdgeColor', 'none');

% KPI Kartları (Key Performance Indicators)
numFrames = length(trackStats.numTracked) + 1;
avgTracked = mean(trackStats.numTracked);
avgSuccess = mean(trackStats.numTracked ./ ...
                  (trackStats.numTracked + trackStats.numLost)) * 100;
avgDisplacement = mean(trackStats.avgDisplacement);

% KPI 1: Ortalama İzlenen
annotation('rectangle', [0.05, 0.80, 0.12, 0.10], ...
           'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'k', 'LineWidth', 2);
annotation('textbox', [0.05, 0.85, 0.12, 0.05], ...
           'String', sprintf('%.0f', avgTracked), ...
           'FontSize', 24, 'FontWeight', 'bold', 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');
annotation('textbox', [0.05, 0.80, 0.12, 0.05], ...
           'String', 'Ort. İzlenen', ...
           'FontSize', 10, 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');

% KPI 2: Başarı Oranı
annotation('rectangle', [0.19, 0.80, 0.12, 0.10], ...
           'FaceColor', [0.2, 0.8, 0.4], 'EdgeColor', 'k', 'LineWidth', 2);
annotation('textbox', [0.19, 0.85, 0.12, 0.05], ...
           'String', sprintf('%.1f%%', avgSuccess), ...
           'FontSize', 24, 'FontWeight', 'bold', 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');
annotation('textbox', [0.19, 0.80, 0.12, 0.05], ...
           'String', 'Başarı Oranı', ...
           'FontSize', 10, 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');

% KPI 3: Ortalama Hareket
annotation('rectangle', [0.33, 0.80, 0.12, 0.10], ...
           'FaceColor', [0.8, 0.4, 0.2], 'EdgeColor', 'k', 'LineWidth', 2);
annotation('textbox', [0.33, 0.85, 0.12, 0.05], ...
           'String', sprintf('%.2f px', avgDisplacement), ...
           'FontSize', 24, 'FontWeight', 'bold', 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');
annotation('textbox', [0.33, 0.80, 0.12, 0.05], ...
           'String', 'Ort. Hareket', ...
           'FontSize', 10, 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');

% KPI 4: Toplam Frame
annotation('rectangle', [0.47, 0.80, 0.12, 0.10], ...
           'FaceColor', [0.6, 0.2, 0.8], 'EdgeColor', 'k', 'LineWidth', 2);
annotation('textbox', [0.47, 0.85, 0.12, 0.05], ...
           'String', sprintf('%d', numFrames), ...
           'FontSize', 24, 'FontWeight', 'bold', 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');
annotation('textbox', [0.47, 0.80, 0.12, 0.05], ...
           'String', 'Toplam Frame', ...
           'FontSize', 10, 'Color', 'w', ...
           'HorizontalAlignment', 'center', 'EdgeColor', 'none');

% Grafik alanları
% 1. Ana tracking grafiği
subplot(3, 3, 1);
plot(2:numFrames, trackStats.numTracked, 'b-', 'LineWidth', 2);
grid on;
title('İzlenen Özellikler');
ylabel('Sayı');
xlabel('Frame');

% 2. Başarı oranı
subplot(3, 3, 2);
successRate = trackStats.numTracked ./ ...
              (trackStats.numTracked + trackStats.numLost) * 100;
plot(2:numFrames, successRate, 'g-', 'LineWidth', 2);
hold on;
yline(avgSuccess, 'r--', 'LineWidth', 1.5);
hold off;
grid on;
title('Başarı Oranı');
ylabel('%');
xlabel('Frame');
ylim([0, 100]);

% 3. Yer değiştirme
subplot(3, 3, 3);
plot(2:numFrames, trackStats.avgDisplacement, 'c-', 'LineWidth', 2);
grid on;
title('Yer Değiştirme');
ylabel('Piksel');
xlabel('Frame');

% 4. Kaybedilen özellikler
subplot(3, 3, 4);
bar(2:numFrames, trackStats.numLost, 'r');
grid on;
title('Kaybedilen Özellikler');
ylabel('Sayı');
xlabel('Frame');

% 5. Kümülatif grafik
subplot(3, 3, 5);
hold on;
plot(2:numFrames, cumsum(trackStats.numTracked), 'b-', 'LineWidth', 2);
plot(2:numFrames, cumsum(trackStats.numLost), 'r-', 'LineWidth', 2);
hold off;
grid on;
title('Kümülatif Toplam');
ylabel('Sayı');
xlabel('Frame');
legend('İzlenen', 'Kaybedilen', 'Location', 'best');

% 6. Histogram
subplot(3, 3, 6);
histogram(trackStats.numTracked, 15, 'FaceColor', 'b', 'EdgeColor', 'k');
grid on;
title('İzlenen Dağılımı');
xlabel('İzlenen Özellik');
ylabel('Frekans');

% 7. Scatter plot
subplot(3, 3, 7);
scatter(trackStats.avgDisplacement, trackStats.numTracked, 50, ...
        2:numFrames, 'filled');
colorbar;
grid on;
title('Hareket vs İzlenen');
xlabel('Yer Değiştirme (px)');
ylabel('İzlenen Sayı');

% 8. Box plot
subplot(3, 3, 8);
boxData = [trackStats.numTracked, trackStats.numLost];
boxplot(boxData, 'Labels', {'İzlenen', 'Kaybedilen'});
grid on;
title('İstatistiksel Dağılım');
ylabel('Sayı');

% 9. Parametre bilgisi
subplot(3, 3, 9);
axis off;
paramText = sprintf(['PARAMETRELER\n\n' ...
                    'Harris:\n' ...
                    '  k = %.3f\n' ...
                    '  threshold = %.3f\n' ...
                    '  maxCorners = %d\n\n' ...
                    'Tracking:\n' ...
                    '  patchSize = %d\n' ...
                    '  searchRadius = %d\n' ...
                    '  threshold = %.2f'], ...
                    harrisParams.k, harrisParams.threshold, ...
                    harrisParams.maxCorners, trackParams.patchSize, ...
                    trackParams.searchRadius, trackParams.similarityThreshold);
text(0.1, 0.9, paramText, 'FontSize', 9, ...
     'VerticalAlignment', 'top', 'FontName', 'FixedWidth');

end

%% 7. ÖRNEK KULLANIM
% Bu fonksiyonları kullanmak için:
%
% % Trajectory görselleştirme
% visualizeTrajectories(trackingData, 50);
%
% % Yoğunluk haritası
% visualizeFeatureDensity(corners, [376, 1241]);
%
% % Zamansal analiz
% plotTemporalAnalysis(trackStats, 10);
%
% % Parametre karşılaştırma
% compareParameters();
%
% % 3D görselleştirme
% visualize3DTrajectory(trackingData);
%
% % Dashboard
% createPerformanceDashboard(trackStats, harrisParams, trackParams);