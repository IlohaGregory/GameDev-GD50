PlayerPotLiftState = Class { __includes = BaseState }

function PlayerPotLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    self.offsetX = 5
    self.offsetY = 8
    local direction = self.player.direction
    self.objects = self.dungeon.currentRoom.objects


    self.player:changeAnimation('pot-lift-' .. direction)
end

function PlayerPotLiftState:update(dt)
    for k, object in ipairs(self.objects) do
        if object.equipped == true then
            Timer.tween(0.5, {
                [object] = { x = self.player.x, y = self.player.y + object.height }
            })
        else
            self.player:changeState('idle')
        end
    end
    -- if then
        
    -- end
end

function PlayerPotLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
