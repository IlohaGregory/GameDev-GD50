--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class {}
-- particle colour
colourpallette = {
    ['r'] = 251,
    ['g'] = 242,
    ['b'] = 54
}

function Tile:init(x, y, color, variety)
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    -- flag for special block
    self.special = false
    -- creating particle system
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 50)
    -- particle sysem lifetime
    self.psystem:setParticleLifetime(0.5, 1)
    -- particle system speed
    self.psystem:setLinearAcceleration(-50, -50, 50, 50)
    -- spread of particles
    self.psystem:setEmissionArea("normal", 10, 10)
end

function Tile:update(dt)
    if self.special then
        self.psystem:setColors(
        -- white
            1,
            1,
            1,
            0.6,
            -- gold
            colourpallette['r'] / 255,
            colourpallette['g'] / 255,
            colourpallette['b'] / 255,
            255 / 255,
            -- transparent
            colourpallette['r'] / 255,
            colourpallette['g'] / 255,
            colourpallette['b'] / 255,
            0
        )
        self.psystem:emit(50)
        self.psystem:update(dt)
    end
end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
    -- making special blocks glow
    if self.special then
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
    end
end
