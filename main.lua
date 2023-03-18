function love.load()
  wf = require 'libraries/windfield/windfield'
  anim8 = require 'libraries/anim8/anim8'
  sti = require 'libraries/Simple-Tiled-Implementation/sti'
  cameraFile = require 'libraries/hump/camera'

  -- World

  world = wf.newWorld(0, 800, false)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Player')
  world:addCollisionClass('Danger')
  world:addCollisionClass('Enemies', {ignores = {"Enemies"}})
  world:setQueryDebugDrawing(true)
  cam = cameraFile()

  love.graphics.setDefaultFilter('nearest', 'nearest')

  sprites = {}
  sprites.playerSheet = love.graphics.newImage('sprites/idle.png')
  sprites.enemySheet = love.graphics.newImage('sprites/enemy.png')
  sprites.background = love.graphics.newImage('sprites/background.png')

  local grid = anim8.newGrid(16, 16, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
  local enemyGrid = anim8.newGrid(16, 16, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

  animations = {}
  animations.idle = anim8.newAnimation(grid("1-8", 1), .2)
  animations.jump = anim8.newAnimation(grid("1-1", 2), .2)
  animations.enemyIdle = anim8.newAnimation(enemyGrid("1-4", 1), .2)

  sounds = {}
  sounds.jump = love.audio.newSource("audio/jump.wav", "static")
  sounds.music = love.audio.newSource("audio/song.mp3", "stream")
  sounds.music:setLooping(true)
  sounds.music:setVolume(0.5)
  sounds.music:play()

  require('player')
  require('enemies')
  require('libraries/show')

  platforms = {}

  dangerZones = {}
  dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
  flagX = 0
  flagY = 0



  saveData = {}
  saveData.currentLevel = "level1"

  if love.filesystem.getInfo("data.lua") then
    local data = love.filesystem.load("data.lua")  
    data()
  end

  loadMap(saveData.currentLevel)
end

function love.update(dt)
  world:update(dt)
  playerUpdate(dt)
  enemiesUpdate(dt)
  
  local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
  if #colliders > 0 then
    if saveData.currentLevel == "level1" then
    loadMap('level2')
    elseif saveData.currentLevel == "level2" then
      loadMap('level1')
    end
  end
end

function love.draw()
  love.graphics.draw(sprites.background, 0, 0)
  cam:attach()
  gameMap:drawLayer(gameMap.layers["Layer"])
  -- world:draw()
  playerDraw()
  enemiesDraw()
  cam:detach()
end



function loadMap(mapName)
  saveData.currentLevel = mapName
  love.filesystem.write("data.lua", table.show(saveData, "saveData"))
  destroyAll()
  player:setPosition(0, 0)
  gameMap = sti("maps/" .. mapName .. ".lua")
 
  for i, spw in ipairs(gameMap.layers["Start"].objects) do
    playerStartX = spw.x
    playerStartY = spw.y
  end
  player:setPosition(playerStartX, playerStartY)
  for i, obj in ipairs(gameMap.layers["Ground"].objects) do
    spawnPlatform(obj.x, obj.y, obj.width, obj.height)
  end

  for i, dgr in ipairs(gameMap.layers["Danger"].objects) do
    spawnDangerZone(dgr.x, dgr.y, dgr.width, dgr.height)
  end

  for i, e in ipairs(gameMap.layers["Enemies"].objects) do
    spawnEnemy(e.x, e.y)
  end

  for i, f in ipairs(gameMap.layers["Final"].objects) do
    flagX = f.x
    flagY = f.y
  end
end

function spawnPlatform(x, y, width, height)
  if width > 0 and height > 0 then
    local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
    platform:setType('static')
    platform:setCollisionClass('Platform')
    table.insert(platforms, platform)
  end
end

function spawnDangerZone(x, y, width, height)
  if width > 0 and height > 0 then
    local dangerZone = world:newRectangleCollider(x, y, width, height, {collision_class = "Danger"})
    dangerZone:setType('static')
    dangerZone:setCollisionClass('Danger')
    table.insert(dangerZones, dangerZone)
  end
end

function destroyAll()
  local i = #platforms
  while i > -1 do
    if platforms[i] ~= nil then
      platforms[i]:destroy()
    end
    table.remove(platforms, i)
    i = i -1
  end
  
  local i = #enemies
  while i > -1 do
    if enemies[i] ~= nil then
      enemies[i]:destroy()
    end
    table.remove(enemies, i)
    i = i -1
  end

  local i = #dangerZones
  while i > -1 do
    if dangerZones[i] ~= nil then
      dangerZones[i]:destroy()
    end
    table.remove(dangerZones, i)
    i = i -1
  end
end

