local mapData = {}

mapData.tileSize = 10
mapData.map = {}

math.randomseed(os.time())

for i = 1, 543 do
    mapData.map[i] = {}
    for j = 1, 543 do
        -- Dış çerçeve duvar
        if i == 1 or i == 543 or j == 1 or j == 543 then
            mapData.map[i][j] = 1
        else
            -- Rastgele iç duvarlar %10 yoğunluk
            if math.random() < 0.1 then
                mapData.map[i][j] = 1
            else
                mapData.map[i][j] = 0
            end
        end
    end
end

-- Ana yollar oluştur
for i = 2, 542 do
    mapData.map[i][271] = 0  -- dikey orta yol
    mapData.map[271][i] = 0  -- yatay orta yol
    mapData.map[136][i] = 0  -- üst yatay yol
end

-- Başlangıç noktası açıldı
mapData.map[50][50] = 0
mapData.map[51][50] = 0
mapData.map[50][51] = 0

return mapData
