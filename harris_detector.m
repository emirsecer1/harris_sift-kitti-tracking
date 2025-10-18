function [corners, harrisMeasure] = detectHarrisCorners(I, params)
% detectHarrisCorners - Harris köşe algılama algoritması
%
% Girişler:
%   I      - Gri seviye görüntü (double, 0-1 arası normalize)
%   params - Parametre yapısı:
%            .k: Harris sabiti (varsayılan: 0.04)
%            .threshold: Köşe tespit eşiği (varsayılan: 0.01)
%            .windowSize: Gradyan pencere boyutu (varsayılan: 3)
%            .sigma: Gaussian sigma (varsayılan: 1.5)
%            .maxCorners: Maksimum köşe sayısı (varsayılan: 500)
%
% Çıkışlar:
%   corners - Nx2 matris [x, y] köşe koordinatları
%   harrisMeasure - Harris yanıt (response) görüntüsü

%% Parametreleri ayarla
k = params.k;
threshold = params.threshold;
windowSize = params.windowSize;
sigma = params.sigma;
maxCorners = params.maxCorners;

%% 1. Görüntü Gradyanlarını Hesapla
% Sobel filtreleri ile x ve y yönündeki gradyanlar
sobelX = [-1 0 1; -2 0 2; -1 0 1];
sobelY = sobelX';

Ix = imfilter(I, sobelX, 'replicate');
Iy = imfilter(I, sobelY, 'replicate');

%% 2. Gradyan Çarpımlarını Hesapla
Ix2 = Ix .^ 2;
Iy2 = Iy .^ 2;
Ixy = Ix .* Iy;

%% 3. Gaussian Pencereleme ile Düzgünleştirme
% Gaussian filtre oluştur
gaussianSize = 2 * ceil(3 * sigma) + 1;
gaussianFilter = fspecial('gaussian', gaussianSize, sigma);

% Gradyan çarpımlarını düzgünleştir
Sx2 = imfilter(Ix2, gaussianFilter, 'replicate');
Sy2 = imfilter(Iy2, gaussianFilter, 'replicate');
Sxy = imfilter(Ixy, gaussianFilter, 'replicate');

%% 4. Harris Yanıt (Response) Fonksiyonunu Hesapla
% R = det(M) - k * trace(M)^2
% det(M) = Sx2 * Sy2 - Sxy^2
% trace(M) = Sx2 + Sy2

detM = Sx2 .* Sy2 - Sxy .^ 2;
traceM = Sx2 + Sy2;

harrisMeasure = detM - k * (traceM .^ 2);

%% 5. Eşikleme
% Harris yanıtını normalize et
harrisMeasure = harrisMeasure / max(harrisMeasure(:));

% Eşik uygula
cornerMap = harrisMeasure > threshold;

%% 6. Non-Maximum Suppression (Yerel Maksimumları Bul)
% Dilasyon ile yerel maksimumları tespit et
dilatedHarris = imdilate(harrisMeasure, strel('square', windowSize));
localMaxima = (harrisMeasure == dilatedHarris) & cornerMap;

%% 7. Köşe Koordinatlarını Çıkar
[rows, cols] = find(localMaxima);
cornerValues = harrisMeasure(localMaxima);

% Harris yanıtına göre sırala (en güçlü köşeler önce)
[~, sortIdx] = sort(cornerValues, 'descend');
rows = rows(sortIdx);
cols = cols(sortIdx);

% Maksimum köşe sayısını uygula
numDetected = min(length(rows), maxCorners);
corners = [cols(1:numDetected), rows(1:numDetected)];

end