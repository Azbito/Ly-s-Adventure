enemies = {}
function enemiesUpdate(dt)
  for i, e in ipairs(enemies) do
    e.animation:update(dt)

    ex, ey = e:getPosition()
  
    local colliders = world:queryRectangleArea(ex - 8, ey + 8, 16, 8, {'Platform'})

    if #colliders == 0 then
      e.direction = e.direction * -1
    end

    e:setX(ex + e.speed * dt * e.direction )
  end
end

function enemiesDraw()
  for i, e in ipairs(enemies) do
    local ex, ey = e:getPosition()
    e.animation:draw(sprites.enemySheet, ex, ey, nil, e.direction, 1, 7, 8)
  end
end

function spawnEnemy(x, y)
  enemy = world:newRectangleCollider(x, y, 16, 16, {collision_class = "Enemies"})
  enemy.direction = 1
  enemy.speed = 50
  enemy.animation = animations.enemyIdle
  enemy:setFixedRotation(true)
  table.insert(enemies, enemy)
end