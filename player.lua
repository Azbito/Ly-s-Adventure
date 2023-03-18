player = {}
  player = world:newRectangleCollider(0, 0, 16, 16, {collision_class = 'Player'})
  player.speed = 100
  player.speedRunning = 200
  player.animation = animations.idle
  player:setFixedRotation(true)
  player.grounded = true
  player.direction = 1
  player.y = player:getY()
  player.x = player:getX()
  playerStartX = 0
  playerStartY = 0
function playerUpdate(dt)
  if player.body then
    -- gameMap:update(dt)
    player.animation:update(dt)
    -- When making character move, do not forget to write px, py = player:getPosition()
    px, py = player:getPosition()
    
    local colliders = world:queryRectangleArea(px - 4, py + 8, 10, 2, {'Platform', 'Danger'})
    if #colliders > 0 then
      player.grounded = true
      player.animation = animations.idle
    else
      player.grounded = false
    end

    player.isMoving = false

    if love.keyboard.isDown('d') then
      -- Also, do not forget to write player:setX(props)
      player:setX(px + player.speed * dt)
      player.isMoving = true
      player.direction = 1
    end
    
    if love.keyboard.isDown('a') then
      player:setX(px - player.speed * dt)
      player.isMoving = true
      player.direction = -1
    end
  
    if love.keyboard.isDown('d') and love.keyboard.isDown('k') then
      player:setX(px + player.speedRunning * dt)
      player.isMoving = true
      player.direction = 1
    end

    if love.keyboard.isDown('a') and love.keyboard.isDown('k') then
      player:setX(px - player.speedRunning * dt)
      player.isMoving = true
      player.direction = -1
    end

    if player.grounded then
      if player.isMoving then
      player.animation = animations.idle    
      end
    else
      player.animation = animations.jump
    end
    
    if player:enter('Danger') then
      player:setPosition(playerStartX, playerStartY)
    end
  end
  
  local px, py = player:getPosition()
  cam:lookAt(px, py):zoomTo(2)

end

function playerDraw()
  local px, py = player:getPosition()
  player.animation:draw(sprites.playerSheet, px, py, nil, 1 * player.direction, 1, 7, 8)
end

function love.keypressed(key)
  if key == "up" or key == "j" then
   if player.grounded then
      player:applyLinearImpulse(0, -180)
      player.animation = animations.idle
      sounds.jump:play()
    end
  end
end