function [trackedCorners, validIdx, displacement] = trackFeaturesSIFT(prevImg, currImg, prevCorners, params)
% trackFeaturesSIFT - SIFT tanımlayıcıları ile özellik izleme
%
% NOT: Bu fonksiyon Computer Vision Toolbox gerektirir.
% Eğer toolbox yoksa, trackFeatures fonksiyonunu kullanın.
%
% Girişler:
%   prevImg     - Önceki kare (gri seviye, double veya uint8)
%   currImg     - Mevcut kare (gri seviye, double veya uint8)
%   prevCorners - Nx2 matris, önceki karede tespit edilen köşeler [x, y]
%   params      - Parametre yapısı:
%                 .searchRadius: Arama yarıçapı (piksel)
%                 .matchThreshold: Eşleştirme eşiği (0-1 arası)
%
% Çıkışlar:
%   trackedCorners - Nx2 matris, mevcut karede izlenen köşeler [x, y]
%   validIdx       - Nx1 mantıksal vektör, başarılı izleme göstergesi
%   displacement   - Nx1 vektör, her özellik için yer değiştirme miktarı

%% Computer Vision Toolbox kontrolü
if ~license('test', 'video_and_image_blockset')
    warning('Computer Vision Toolbox bulunamadı. Patch tabanlı izleme kullanılıyor.');
    [trackedCorners, validIdx, displacement] = trackFeatures(prevImg, currImg, prevCorners, params);
    return;
end

%% Görüntüleri uint8'e çevir (SIFT için gerekli)
if isa(prevImg, 'double')
    prevImg = im2uint8(prevImg);
end
if isa(currImg, 'double')
    currImg = im2uint8(currImg);
end

%% Parametreleri ayarla
searchRadius = params.searchRadius;
matchThreshold = 0.6; % Lowe's ratio test için

%% Başlangıç değerleri
numFeatures = size(prevCorners, 1);
trackedCorners = zeros(numFeatures, 2);
validIdx = false(numFeatures, 1);
displacement = zeros(numFeatures, 1);

[rows, cols] = size(prevImg);

%% Önceki karedeki noktalar için SIFT özelliklerini çıkar
% SURFPoints yerine cornerPoints kullan (çünkü elimizde Harris köşeleri var)
prevPoints = cornerPoints(prevCorners);

% SIFT özelliklerini çıkar
try
    [prevFeatures, prevValidPoints] = extractFeatures(prevImg, prevPoints, 'Method', 'SURF');
catch
    % SURF yoksa BRISK kullan (daha hızlı alternatif)
    [prevFeatures, prevValidPoints] = extractFeatures(prevImg, prevPoints, 'Method', 'BRISK');
end

%% Mevcut karede arama bölgeleri için SIFT çıkar
for i = 1:size(prevValidPoints, 1)
    x_prev = prevValidPoints.Location(i, 1);
    y_prev = prevValidPoints.Location(i, 2);
    
    % Arama bölgesini belirle
    searchMinX = max(1, round(x_prev - searchRadius));
    searchMaxX = min(cols, round(x_prev + searchRadius));
    searchMinY = max(1, round(y_prev - searchRadius));
    searchMaxY = min(rows, round(y_prev + searchRadius));
    
    % Arama bölgesinde SIFT noktaları tespit et
    searchRegion = currImg(searchMinY:searchMaxY, searchMinX:searchMaxX);
    
    % Arama bölgesinde SURF/BRISK noktaları tespit et
    currPoints = detectSURFFeatures(searchRegion, 'MetricThreshold', 100);
    
    if currPoints.Count == 0
        continue;
    end
    
    % Koordinatları global koordinat sistemine çevir
    currPoints.Location = currPoints.Location + [searchMinX-1, searchMinY-1];
    
    % SIFT özelliklerini çıkar
    try
        [currFeatures, currValidPoints] = extractFeatures(currImg, currPoints, 'Method', 'SURF');
    catch
        [currFeatures, currValidPoints] = extractFeatures(currImg, currPoints, 'Method', 'BRISK');
    end
    
    if isempty(currFeatures)
        continue;
    end
    
    % Önceki özellik ile eşleştir
    indexPairs = matchFeatures(prevFeatures(i, :), currFeatures, ...
                                'MatchThreshold', matchThreshold, ...
                                'MaxRatio', 0.7);
    
    if ~isempty(indexPairs)
        % En iyi eşleşmeyi al
        matchedIdx = indexPairs(1, 2);
        trackedCorners(i, :) = currValidPoints.Location(matchedIdx, :);
        validIdx(i) = true;
        
        % Yer değiştirmeyi hesapla
        dx = trackedCorners(i, 1) - x_prev;
        dy = trackedCorners(i, 2) - y_prev;
        displacement(i) = sqrt(dx^2 + dy^2);
    end
end

% Geçersiz özellikleri temizle
displacement = displacement(validIdx);

end