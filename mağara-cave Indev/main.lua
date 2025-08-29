-- Haritaları çağır
local map1 = require "map1"
local map2 = require "map2"
local map3 = require "map3"
local map4 = require "map4"

-- Oyun durumu
local gameState = "menu"       -- "menu", "mapSelect", "play"
local showTutorial = true      -- öğretici başlangıçta göster

-- Fizik objeleri
local world, player, walls

-- Kamera
local camX, camY = 0, 0
local screenWidth, screenHeight = 800, 600

-- Tutorial dosyası
local tutorial = {}
local file, err = love.filesystem.read("tutorial.txt")
if not file then
    error("tutorial.txt bulunamadı: " .. tostring(err))
end
tutorial.lines = {}
for line in file:gmatch("[^\r\n]+") do
    table.insert(tutorial.lines, line)
end

-- Ana yükleme
function love.load()
    love.window.setTitle("Fizikli Mağara Oyunu")
    love.window.setMode(screenWidth, screenHeight)
end

-- Fare tıklama
function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    if gameState == "menu" then
        if x > 300 and x < 500 and y > 200 and y < 250 then
            gameState = "mapSelect"
        end
        if x > 300 and x < 500 and y > 300 and y < 350 then
            love.event.quit()
        end
    elseif gameState == "mapSelect" then
        if x > 250 and x < 550 then
            if y > 200 and y < 250 then startGame(map1) end
            if y > 300 and y < 350 then startGame(map2) end
            if y > 400 and y < 450 then startGame(map3) end
            if y > 500 and y < 550 then startGame(map4) end
        end
    end
end

-- Oyunu başlat
function startGame(map)
    if not map or type(map) ~= "table" or not map.map then
        error("Hata: Geçersiz harita tablosu!")
    end

    gameState = "play"
    world = love.physics.newWorld(0, 0, true)

    -- Oyuncu
    player = {}
    player.body = love.physics.newBody(world, 100, 100, "dynamic")
    player.shape = love.physics.newCircleShape(8)  -- küçük boyla başla
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setRestitution(0)

    -- Duvarlar
    walls = {}
    for i=1,#map.map do
        for j=1,#map.map[i] do
            if map.map[i][j] == 1 then
                local wall = {}
                wall.body = love.physics.newBody(world, (j-0.5)*map.tileSize, (i-0.5)*map.tileSize, "static")
                wall.shape = love.physics.newRectangleShape(map.tileSize, map.tileSize)
                wall.fixture = love.physics.newFixture(wall.body, wall.shape)
                table.insert(walls, wall)
            end
        end
    end
end

-- Tuşlar
function love.keypressed(key)
    -- Öğretici gösteriliyorsa
    if showTutorial then
        if key == "space" then
            showTutorial = false
        end
        return
    end

    -- Oyuncu boy değiştirme
    if gameState == "play" then
        if key == "c" then
            player.shape:setRadius(8)
        elseif key == "x" then
            player.shape:setRadius(15)
        end
    end
end

-- Güncelleme
function love.update(dt)
    if gameState == "play" and not showTutorial then
        world:update(dt)
        local force = 400
        if love.keyboard.isDown("up") then player.body:applyForce(0, -force) end
        if love.keyboard.isDown("down") then player.body:applyForce(0, force) end
        if love.keyboard.isDown("left") then player.body:applyForce(-force, 0) end
        if love.keyboard.isDown("right") then player.body:applyForce(force, 0) end

        -- Kamera oyuncuyu takip etsin
        camX = player.body:getX() - screenWidth/2
        camY = player.body:getY() - screenHeight/2
    end
end

-- Çizim
function love.draw()
    if showTutorial then
        love.graphics.setColor(1,1,1)
        for i, line in ipairs(tutorial.lines) do
            love.graphics.print(line, 50, 50 + (i-1)*20)
        end
        return
    end

    if gameState == "menu" then
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Fizikli Mağara Oyunu", 0, 100, screenWidth, "center")

        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill", 300, 200, 200, 50)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Başla", 0, 215, screenWidth, "center")

        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", 300, 300, 200, 50)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Çıkış", 0, 315, screenWidth, "center")

    elseif gameState == "mapSelect" then
        love.graphics.setColor(1,1,0)
        love.graphics.printf("Harita Seçin", 0, 100, screenWidth, "center")

        local mapsY = {200, 300, 400, 500}
        local mapsNames = {"Harita 1", "Harita 2", "Harita 3", "Harita 4"}
        for i=1,4 do
            love.graphics.setColor(0,0.5,1)
            love.graphics.rectangle("fill", 250, mapsY[i], 300, 50)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(mapsNames[i], 0, mapsY[i]+15, screenWidth, "center")
        end

    elseif gameState == "play" then
        love.graphics.push()
        love.graphics.translate(-camX, -camY)  -- Kamera takibi

        -- Duvarları çiz
        love.graphics.setColor(0.5,0.5,0.5)
        for _,wall in ipairs(walls) do
            love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
        end

        -- Oyuncu
        love.graphics.setColor(1,0,0)
        love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())

        love.graphics.pop()
    end
end
