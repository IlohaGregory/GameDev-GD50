-- creating flagpole class, so animation can be added
FlagPole = Class { _include = GameObject }

function FlagPole:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
    self.animation = Animation {
        frames = { 1, 2 },
        interval = 0.5
    }

    self.pole = math.random(6)
end

function FlagPole:update(dt)
    self.animation:update(dt)
end

function FlagPole:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
        target.y > self.y + self.height or self.y > target.y + target.height)
end

function FlagPole:render()
    love.graphics.draw(gTextures[self.texture], gFrames['poles'][self.pole], self.x, self.y)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.animation:getCurrentFrame()], self.x + 6,
        self.y + 5)
end
