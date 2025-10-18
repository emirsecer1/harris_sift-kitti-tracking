% =========================================================================
% DEMO ve TEST SCRİPTİ
% =========================================================================
% Bu script projeyi test etmek ve demo göstermek için kullanılır.
% Sentetik veri veya KITTI veri seti ile test edilebilir.

clear all; close all; clc;

%% KULLANIM MODU SEÇİMİ
% 1: Sentetik veri ile test (KITTI veri seti yoksa)
% 2: KITTI veri seti ile tam çalışma
testMode = 1; % Değiştirin: 1 veya 2

%% MOD 1: SENTETİK VERİ İLE TEST
if testMode == 1
    fprintf('═══════════════════════════════════════════\n');
    fprintf('  SENTETİK VERİ İLE TEST MODU\n');
    fprintf('═══════════════════════════════════════════\n\n');
    
    % Sentetik görüntü oluştur
    testImage = createSyntheticImage(640, 480);
    
    % Harris parametreleri
    harrisParams.k = 0.04;
    harrisParams.threshold = 0.01;
    harrisParams.windowSize = 3;
    harrisParams.sigma = 1.5;
    harrisParams.maxCorners = 200;
    
    % Harris köşe tespiti
    fprintf('Harris köşe algılama test ediliyor...\n');
    [corners, harrisMeasure] = harris_detector(testImage, harrisParams);
    fprintf('✓ %d köşe tespit edildi.\n\n', size(corners, 1));
    
    % Görselleştirme
    figure('Name', 'Harris Test Sonucu', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 3, 1);
    imshow(testImage); title('Orijinal Görüntü');
    
    subplot(1, 3, 2);
    imagesc(harrisMeasure); colormap('hot'); colorbar;
    title('Harris Response Map');
    axis image;
    
    subplot(1, 3, 3);
    imshow(testImage); hold on;
    plot(corners(:, 1), corners(:, 2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
    title(sprintf('Tespit Edilen Köşeler (%d)', size(corners, 1)));
    hold off;
    
    % Tracking testi - Hareket simülasyonu
    fprintf('Feature tracking test ediliyor...\n');
    trackParams.patchSize = 15;
    trackParams.searchRadius = 20;
    trackParams.similarityThreshold = 0.7;
    trackParams.useSIFT = false;
    
    % İkinci görüntü oluştur (hafif kaydırılmış)
    shiftX = 5;
    shiftY = 3;
    testImage2 = imtranslate(testImage, [shiftX, shiftY]);
    
    % Tracking yap
    [trackedCorners, validIdx, displacement] = feature_tracker(...
        testImage, testImage2, corners, trackParams);
    
    fprintf('✓ %d/%d özellik başarıyla izlendi.\n', sum(validIdx), length(validIdx));
    fprintf('✓ Ortalama yer değiştirme: %.2f piksel\n', mean(displacement));
    
    % Tracking sonucunu göster
    figure('Name', 'Tracking Test Sonucu', 'Position', [100, 100, 1200, 500]);
    
    subplot(1, 2, 1);
    imshow(testImage); hold on;
    plot(corners(:, 1), corners(:, 2), 'g+', 'MarkerSize', 8);
    title('Frame 1 - Başlangıç Noktaları');
    hold off;
    
    subplot(1, 2, 2);
    imshow(testImage2); hold on;
    validPrev = corners(validIdx, :);
    validCurr = trackedCorners(validIdx, :);
    plot(validCurr(:, 1), validCurr(:, 2), 'g+', 'MarkerSize', 8);
    quiver(validPrev(:, 1), validPrev(:, 2), ...
           validCurr(:, 1) - validPrev(:, 1), ...
           validCurr(:, 2) - validPrev(:, 2), ...
           0, 'r', 'LineWidth', 1.5);
    title(sprintf('Frame 2 - İzlenen: %d', sum(validIdx)));
    hold off;
    
    fprintf('\n✓ Test başarıyla tamamlandı!\n');
    fprintf('  KITTI veri seti ile çalıştırmak için:\n');
    fprintf('  1. KITTI veri setini indirin\n');
    fprintf('  2. Ana scriptte dataPath değişkenini ayarlayın\n');
    fprintf('  3. Ana scripti çalıştırın\n\n');
    
%% MOD 2: KITTI VERİ SETİ İLE TAM ÇALIŞMA
else
    fprintf('═══════════════════════════════════════════\n');
    fprintf('  KITTI VERİ SETİ İLE TAM ÇALIŞMA\n');
    fprintf('═══════════════════════════════════════════\n\n');
    
    % KITTI veri yolu - BURAYA KENDİ YOLUNUZU YAZIN
    kittiPath = 'C:/KITTI/sequences/00/image_0/';
    
    % Veri seti kontrolü
    if ~exist(kittiPath, 'dir')
        error(['KITTI veri seti bulunamadı!\n' ...
               'Lütfen kittiPath değişkenini düzenleyin.\n' ...
               'Örnek: C:/KITTI/sequences/00/image_0/']);
    end
    
    fprintf('✓ KITTI veri seti bulundu: %s\n', kittiPath);
    fprintf('  Ana script çalıştırılıyor...\n\n');
    
    % Ana scripti çalıştır (önceki artifactta oluşturduğumuz)
    % Not: Bu dosyayı harris_main.m olarak kaydetmelisiniz
    run('harris_main.m');
end

%% YARDIMCI FONKSİYON: Sentetik Görüntü Oluşturma
function img = createSyntheticImage(width, height)
    % Checkerboard pattern ile test görüntüsü
    squareSize = 30;
    img = checkerboard(squareSize, ceil(height/(2*squareSize)), ceil(width/(2*squareSize)));
    img = img(1:height, 1:width);
    
    % Gaussian bulanıklaştırma ekle
    img = imgaussfilt(img, 1);
    
    % Rastgele gürültü ekle
    img = imnoise(img, 'gaussian', 0, 0.001);
    
    % Bazı yapay köşeler ekle (daireler)
    [X, Y] = meshgrid(1:width, 1:height);
    centers = [width/4, height/4; 3*width/4, height/4; ...
               width/2, height/2; width/4, 3*height/4; 3*width/4, 3*height/4];
    
    for i = 1:size(centers, 1)
        cx = centers(i, 1);
        cy = centers(i, 2);
        radius = 20;
        circle = sqrt((X - cx).^2 + (Y - cy).^2) < radius;
        img(circle) = 1;
    end
    
    % 0-1 arasına normalize et
    img = mat2gray(img);
end