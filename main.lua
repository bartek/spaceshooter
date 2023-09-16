Entity = require "entity"
steering = require "steering"

function love.load(arg)
  player = Entity(
    55,
    love.graphics.getHeight()/2,
    "assets/player.png")
  
    enemies = {}
    enemySpawnChance = 0.02 -- 0.01
end

function love.update(dt)
  
  -- make enemies pursue the player
  for i, v in ipairs(enemies) do
    v.acceleration = 0.6 * steering.pursue(v, player, 100, 3) + 0.4 * steering.separation(v, enemies, 20, 10000, 100)
    _, v.angularAcceleration = steering.lookWhereYoureGoing(v, 10, 2, 0.01, 1, 0.1)
  end
  
  -- player movement controls
  local inputVelocity = vector(0, 0)
  
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
    inputVelocity.x = -1
  elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
    inputVelocity.x = 1    
  end
  
  inputVelocity = inputVelocity:rotated(player.orientation) * 100
  player.acceleration = steering.velocityMath(player, {velocity = inputVelocity}, 100, 0.1)
  
  -- enemy spawner
  if math.random() < enemySpawnChance then
    if math.random() < 0.1 then
      local smallX, smallY = math.random(0, 800), math.random(0, 600)
      for i=1,10 do
        enemies[#enemies+1]  = Entity(smallX + math.random(-50, 50), smallY + math.random(-50, 50), "assets/wiggles.png")
      end
    else
      -- spawn other enemies
      -- enemies[#enemies+1] = Entity(math.random(0, 800), math.random(0, 600)
    end        
  end
  
  
  player:update(dt)
  
  for i = #enemies, 1, -1 do
    enemies[i]:update(dt)
  end
end

function love.draw()
  player:draw()
  
  for _, v in ipairs(enemies) do
    v:draw()
  end
end