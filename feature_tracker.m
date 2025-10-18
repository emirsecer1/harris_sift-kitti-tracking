function [trackedCorners, validIdx, displacement] = trackFeatures(prevImg, currImg, prevCorners, params)
% trackFeatures - Patch tabanlı özellik izleme (Template Matching)
%
% Girişler:
%   prevImg     - Önceki kare (gri seviye, double)
%   currImg     - Mevcut kare (gri seviye, double)
%   prevCorners - Nx2 matris, önceki karede tespit edilen köşeler [x, y]
%   params      - Parametre yapısı:
%                 .patchSize: Patch boyutu (tek sayı)
%                 .searchRadius: Arama yarıçapı (piksel)
%                 .similarityThreshold: NCC eşik değeri
%                 .useSIFT: SIFT kullanımı (true/false)
%
% Çıkışlar:
%   trackedCorners - Nx2 matris, mevcut karede izlenen köşeler [x, y]
%   validIdx       - Nx1 mantıksal vektör, başarılı izleme göstergesi
%   displacement   - Nx1 vektör, her özellik için yer değiştirme miktarı

%% Parametreleri ayarla
patchSize = params.patchSize;
searchRadius = params.searchRadius;
threshold = params.similarityThreshold;
useSIFT = params.useSIFT;

%% Başlangıç değerleri
numFeatures = size(prevCorners, 1);
trackedCorners = zeros(numFeatures, 2);
validIdx = false(numFeatures, 1);
displacement = zeros(numFeatures, 1);

[rows, cols] = size(prevImg);
halfPatch = floor(patchSize / 2);

%% Her özellik için izleme yap
for i = 1:numFeatures
    x_prev = round(prevCorners(i, 1));
    y_prev = round(prevCorners(i, 2));
    
    % Patch sınırlarını kontrol et
    if x_prev - halfPatch < 1 || x_prev + halfPatch > cols || ...
       y_prev - halfPatch < 1 || y_prev + halfPatch > rows
        continue;
    end
    
    % Önceki karede patch çıkar
    prevPatch = prevImg(y_prev - halfPatch : y_prev + halfPatch, ...
                        x_prev - halfPatch : x_prev + halfPatch);
    
    % Arama bölgesini belirle
    searchMinX = max(1, x_prev - searchRadius);
    searchMaxX = min(cols - patchSize + 1, x_prev + searchRadius);
    searchMinY = max(1, y_prev - searchRadius);
    searchMaxY = min(rows - patchSize + 1, y_prev + searchRadius);
    
    % Template matching için SIFT veya NCC kullan
    if useSIFT
        % SIFT tabanlı eşleştirme (basitleştirilmiş versiyon)
        % Not: Tam SIFT implementasyonu için Computer Vision Toolbox gerekir
        % Burada NCC kullanacağız ama SIFT benzeri bir yaklaşım da eklenebilir
        [maxCorr, bestX, bestY] = templateMatchNCC(currImg, prevPatch, ...
                                                    searchMinX, searchMaxX, ...
                                                    searchMinY, searchMaxY, ...
                                                    patchSize);
    else
        % Normalized Cross Correlation (NCC) ile eşleştirme
        [maxCorr, bestX, bestY] = templateMatchNCC(currImg, prevPatch, ...
                                                    searchMinX, searchMaxX, ...
                                                    searchMinY, searchMaxY, ...
                                                    patchSize);
    end
    
    % Eşleştirme başarılı mı?
    if maxCorr > threshold
        trackedCorners(i, :) = [bestX + halfPatch, bestY + halfPatch];
        validIdx(i) = true;
        
        % Yer değiştirmeyi hesapla
        dx = trackedCorners(i, 1) - prevCorners(i, 1);
        dy = trackedCorners(i, 2) - prevCorners(i, 2);
        displacement(i) = sqrt(dx^2 + dy^2);
    end
end

% Geçersiz özellikleri temizle (opsiyonel - ana scriptte kullanılacak)
displacement = displacement(validIdx);

end

%% Yardımcı Fonksiyon: Template Matching with NCC
function [maxCorr, bestX, bestY] = templateMatchNCC(img, template, ...
                                                     minX, maxX, minY, maxY, ...
                                                     patchSize)
% Normalized Cross Correlation ile template matching
%
% Çıkışlar:
%   maxCorr - Maksimum korelasyon değeri
%   bestX, bestY - En iyi eşleşme koordinatları (sol üst köşe)

maxCorr = -inf;
bestX = minX;
bestY = minY;

halfPatch = floor(patchSize / 2);

% Template'i normalize et
templateNorm = template - mean(template(:));
templateNorm = templateNorm / (norm(templateNorm(:)) + eps);

% Arama bölgesinde tara
for y = minY:maxY
    for x = minX:maxX
        % Aday patch'i çıkar
        candidatePatch = img(y:y + patchSize - 1, x:x + patchSize - 1);
        
        % Patch'i normalize et
        candidateNorm = candidatePatch - mean(candidatePatch(:));
        candidateNorm = candidateNorm / (norm(candidateNorm(:)) + eps);
        
        % NCC hesapla
        correlation = sum(sum(templateNorm .* candidateNorm));
        
        % En iyi eşleşmeyi bul
        if correlation > maxCorr
            maxCorr = correlation;
            bestX = x;
            bestY = y;
        end
    end
end

end