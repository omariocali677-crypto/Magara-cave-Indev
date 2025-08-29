local map = {}
map.tileSize = 32
local width, height = 623, 623

-- Tüm haritayı duvarla başlat
map.map = {}
for i = 1, height do
    map.map[i] = {}
    for j = 1, width do
        map.map[i][j] = 1
    end
end

-- Yardımcı: 2 hücre aralıklı hareket (yollar 1 hücre geniş)
local dirs = {{0,-2},{2,0},{0,2},{-2,0}}

-- Shuffle fonksiyonu
local function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

-- Iteratif DFS / stack yöntemi
local stack = {}
local startX, startY = 2, 2
map.map[startY][startX] = 0
table.insert(stack, {x=startX, y=startY})

while #stack > 0 do
    local cell = stack[#stack]
    local x, y = cell.x, cell.y

    local neighbors = {}
    for _, d in ipairs(dirs) do
        local nx, ny = x + d[1], y + d[2]
        if nx > 1 and nx < width and ny > 1 and ny < height and map.map[ny][nx] == 1 then
            table.insert(neighbors, {x=nx, y=ny, dx=d[1], dy=d[2]})
        end
    end

    if #neighbors > 0 then
        local nextCell = neighbors[math.random(#neighbors)]
        -- Aradaki hücreyi aç
        map.map[y + math.floor(nextCell.dy/2)][x + math.floor(nextCell.dx/2)] = 0
        map.map[nextCell.y][nextCell.x] = 0
        table.insert(stack, {x=nextCell.x, y=nextCell.y})
    else
        table.remove(stack)  -- backtrack
    end
end

-- Kenarları duvar yap
for i = 1, height do
    map.map[i][1] = 1
    map.map[i][width] = 1
end
for j = 1, width do
    map.map[1][j] = 1
    map.map[height][j] = 1
end

-- Başlangıç ve bitiş noktası
map.map[startY][startX] = 0
local endX, endY = width-1, height-1
map.map[endY][endX] = 0
map.endPoint = {x = endX, y = endY}  -- Main.lua’da bitiş kontrolü için

return map

