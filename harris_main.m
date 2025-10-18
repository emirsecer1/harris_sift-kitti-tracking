% =========================================================================
% KITTI Visual Odometry - Harris Corner Detection & Feature Tracking
% =========================================================================
% Bu script KITTI veri setinin ilk 200 karesinde Harris köşe algılama
% ve özellik izleme işlemlerini gerçekleştirir.

clear all; close all; clc;

%% 1. PARAMETRELER
% Veri seti yolu (KITTI veri setinizin yolunu buraya yazın)
dataPath = '/Users/emirsecer/Desktop/2011_09_26_drive_0093_extract/image_00/data/';
numFrames = 200; % İşlenecek kare sayısı

% Harris köşe algılama parametreleri
harrisParams.k = 0.04;           % Harris sabiti (0.04-0.06 arası önerilir)
harrisParams.threshold = 0.01;   % Köşe tespit eşiği (0-1 arası)
harrisParams.windowSize = 3;     % Gradyan hesaplama pencere boyutu
harrisParams.sigma = 1.5;        % Gaussian bulanıklaştırma sigma değeri
harrisParams.maxCorners = 500;   % Maksimum köşe sayısı

% Feature tracking parametreleri
trackParams.patchSize = 15;      % Patch boyutu (tek sayı olmalı)
trackParams.searchRadius = 20;   % Arama yarıçapı (piksel)
trackParams.similarityThreshold = 0.7; % NCC eşik değeri
trackParams.useSIFT = true;      % SIFT kullanımı (true/false)

% Görselleştirme parametreleri
visParams.showDetection = true;  % Köşe tespitini göster
visParams.showTracking = true;   % İzleme sonuçlarını göster
visParams.saveVideo = true;      % Video olarak kaydet
visParams.videoName = 'tracking_results.avi';

%% 2. VERİ SETİ YÜKLEME KONTROLÜ
fprintf('KITTI veri seti kontrol ediliyor...\n');
imageFiles = dir(fullfile(dataPath, '*.png'));

if isempty(imageFiles)
    error('Görüntü dosyaları bulunamadı! Lütfen dataPath değişkenini kontrol edin.');
end

numAvailableFrames = min(length(imageFiles), numFrames);
fprintf('Toplam %d kare işlenecek.\n\n', numAvailableFrames);

%% 3. VİDEO YAZICI HAZIRLIĞI
if visParams.saveVideo
    videoWriter = VideoWriter(visParams.videoName);
    videoWriter.FrameRate = 10;
    open(videoWriter);
end

%% 4. İLK KARE İŞLEME VE KÖŞE TESPİTİ
fprintf('İlk kare işleniyor ve köşeler tespit ediliyor...\n');

% İlk görüntüyü yükle
I1 = imread(fullfile(dataPath, imageFiles(1).name));
if size(I1, 3) == 3
    I1_gray = rgb2gray(I1);
else
    I1_gray = I1;
end
I1_gray = im2double(I1_gray);

% Harris köşe algılama
[corners1, harrisMeasure] = harris_detector(I1_gray, harrisParams);

fprintf('İlk karede %d köşe tespit edildi.\n', size(corners1, 1));

% İlk kare görselleştirme
if visParams.showDetection
    figure('Name', 'İlk Kare - Tespit Edilen Köşeler', 'NumberTitle', 'off');
    imshow(I1); hold on;
    plot(corners1(:, 1), corners1(:, 2), 'g+', 'MarkerSize', 8, 'LineWidth', 1.5);
    title(sprintf('Frame 1 - %d Köşe Tespit Edildi', size(corners1, 1)));
    hold off;
end

%% 5. ÖZELLİK İZLEME - ARDIŞIK KARELER
fprintf('\nÖzellik izleme başlıyor...\n');

% İzleme istatistikleri
trackStats.numTracked = zeros(numAvailableFrames - 1, 1);
trackStats.numLost = zeros(numAvailableFrames - 1, 1);
trackStats.avgDisplacement = zeros(numAvailableFrames - 1, 1);

% Önceki kare bilgileri
prevGray = I1_gray;
prevCorners = corners1;

% İzleme figürü
if visParams.showTracking
    hFig = figure('Name', 'Feature Tracking', 'NumberTitle', 'off', ...
                  'Position', [100, 100, 1200, 500]);
end

% Ardışık kareleri işle
for frameIdx = 2:numAvailableFrames
    % Mevcut kareyi yükle
    I_current = imread(fullfile(dataPath, imageFiles(frameIdx).name));
    if size(I_current, 3) == 3
        I_gray = rgb2gray(I_current);
    else
        I_gray = I_current;
    end
    I_gray = im2double(I_gray);
    
    % Özellik izleme
    [trackedCorners, validIdx, displacement] = feature_tracker(...
        prevGray, I_gray, prevCorners, trackParams);
    
    % İstatistikleri güncelle
    trackStats.numTracked(frameIdx - 1) = sum(validIdx);
    trackStats.numLost(frameIdx - 1) = sum(~validIdx);
    if ~isempty(displacement)
        trackStats.avgDisplacement(frameIdx - 1) = mean(displacement);
    end
    
    % İlerleme raporu
    if mod(frameIdx, 20) == 0
        fprintf('Frame %d/%d işlendi - İzlenen: %d, Kaybedilen: %d\n', ...
                frameIdx, numAvailableFrames, ...
                trackStats.numTracked(frameIdx - 1), ...
                trackStats.numLost(frameIdx - 1));
    end
    
    % Görselleştirme
    if visParams.showTracking
        figure(hFig); clf;
        
        % Sol: Önceki kare
        subplot(1, 2, 1);
        imshow(prevGray); hold on;
        plot(prevCorners(:, 1), prevCorners(:, 2), 'g+', 'MarkerSize', 6);
        title(sprintf('Frame %d', frameIdx - 1));
        hold off;
        
        % Sağ: Mevcut kare ve izleme
        subplot(1, 2, 2);
        imshow(I_gray); hold on;
        
        % İzlenen noktaları yeşil ile göster
        validPrev = prevCorners(validIdx, :);
        validCurr = trackedCorners(validIdx, :);
        plot(validCurr(:, 1), validCurr(:, 2), 'g+', 'MarkerSize', 6);
        
        % İzleme vektörlerini çiz
        quiver(validPrev(:, 1), validPrev(:, 2), ...
               validCurr(:, 1) - validPrev(:, 1), ...
               validCurr(:, 2) - validPrev(:, 2), ...
               0, 'r', 'LineWidth', 1);
        
        % Kaybedilen noktaları kırmızı ile göster
        lostCorners = prevCorners(~validIdx, :);
        plot(lostCorners(:, 1), lostCorners(:, 2), 'rx', 'MarkerSize', 6);
        
        title(sprintf('Frame %d - İzlenen: %d, Kaybedilen: %d', ...
                     frameIdx, sum(validIdx), sum(~validIdx)));
        hold off;
        
        drawnow;
        
        % Video kaydet
        if visParams.saveVideo
            frame = getframe(hFig);
            writeVideo(videoWriter, frame);
        end
    end
    
    % Yeni köşe tespiti (eğer izlenen nokta sayısı azaldıysa)
    if sum(validIdx) < harrisParams.maxCorners * 0.5
        [newCorners, ~] = harris_detector(I_gray, harrisParams);
        % Mevcut köşelerle yeni köşeleri birleştir
        trackedCorners = [trackedCorners(validIdx, :); newCorners];
        validIdx = true(size(trackedCorners, 1), 1);
        fprintf('  Yeni %d köşe eklendi.\n', size(newCorners, 1));
    end
    
    % Sonraki iterasyon için güncelle
    prevGray = I_gray;
    prevCorners = trackedCorners(validIdx, :);
end

%% 6. VİDEO YAZICIYI KAPAT
if visParams.saveVideo
    close(videoWriter);
    fprintf('\nVideo kaydedildi: %s\n', visParams.videoName);
end

%% 7. SONUÇLARIN ANALİZİ VE RAPORLAMA
fprintf('\n========================================\n');
fprintf('SONUÇ ANALİZİ\n');
fprintf('========================================\n');
fprintf('Toplam işlenen kare: %d\n', numAvailableFrames);
fprintf('Ortalama izlenen özellik: %.2f\n', mean(trackStats.numTracked));
fprintf('Ortalama kaybedilen özellik: %.2f\n', mean(trackStats.numLost));
fprintf('Ortalama yer değiştirme: %.2f piksel\n', mean(trackStats.avgDisplacement));

% İstatistik grafikleri
figure('Name', 'Tracking Statistics', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);

subplot(2, 2, 1);
plot(2:numAvailableFrames, trackStats.numTracked, 'b-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('İzlenen Özellik Sayısı');
title('Zaman İçinde İzlenen Özellik Sayısı');

subplot(2, 2, 2);
plot(2:numAvailableFrames, trackStats.numLost, 'r-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('Kaybedilen Özellik Sayısı');
title('Zaman İçinde Kaybedilen Özellik Sayısı');

subplot(2, 2, 3);
plot(2:numAvailableFrames, trackStats.avgDisplacement, 'g-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('Ortalama Yer Değiştirme (piksel)');
title('Ortalama Özellik Yer Değiştirmesi');

subplot(2, 2, 4);
successRate = trackStats.numTracked ./ (trackStats.numTracked + trackStats.numLost) * 100;
plot(2:numAvailableFrames, successRate, 'm-', 'LineWidth', 2);
grid on;
xlabel('Frame Numarası');
ylabel('Başarı Oranı (%)');
title('İzleme Başarı Oranı');
ylim([0, 100]);

fprintf('\n========================================\n');
fprintf('İşlem tamamlandı!\n');
fprintf('========================================\n');