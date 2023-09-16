Entity = require "entity"
steering = require "steering"

function love.load(arg)
  player = Entity(
    55,
    love.graphics.getHeight()/2,
    "assets/player.png")
  
    enemies = {}
    enemySpawnChance = 0.01
    
    lasers = {}
    weaponInterval = 0
    weaponRoF = 8
end

function love.update(dt)
    
  if love.keyboard.isDown("p") then
    for i = #enemies, 1, -1 do
      table.remove(enemies, i)
    end
  end
  
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
      local smallX, smallY = math.random(400 , 800), math.random(0, 600)
      for i=1,2 do
        enemies[#enemies+1]  = Entity(smallX + math.random(-50, 50), smallY + math.random(-50, 50), "assets/bufbloody.png")
      end
    else
      -- TODO: spawn other enemies
      enemies[#enemies+1] = Entity(math.random(0, 800), math.random(0, 600), "assets/bufbloody.png")
    end        
  end
  
  -- player weapon controls
  if weaponInterval > 0 then
		weaponInterval = weaponInterval - dt
	end
  if love.keyboard.isDown("space") then
    if weaponInterval <= 0 then
      local laser = Entity(player.position.x, player.position.y, "assets/builit.png")
      laser.orientation = player.orientation
      laser.speed = 400
      laser.velocity = vector(math.sin(laser.orientation), -math.cos(laser.orientation)) * laser.speed
      lasers[#lasers+1] = laser
      weaponInterval = 1/weaponRoF
    end
  end
  
  player:update(dt)
  
  for i = #enemies, 1, -1 do
    enemies[i]:update(dt)
  end
  
  for i = #lasers, 1, -1 do
    lasers[i]:update(dt)
  end
  
  -- simple collision check between lasers and enemies
	for i = #lasers, 1, -1 do
		for j = #enemies, 1, -1 do
			if lasers[i].position:dist(enemies[j].position) < enemies[j].width/2 then
				table.remove(lasers, i)
				table.remove(enemies, j)
				enemySpawnChance = enemySpawnChance + 0.001
				break
			end
		end
	end
end

function love.draw()
  player:draw()
  
  for _, v in ipairs(enemies) do
    v:draw()
  end
  
  for _, v in ipairs(lasers) do
    v:draw()
  end
end