PowerUp = Class {}

function PowerUp:init(type)
    self.y = -30
    self.x = math.random(8, VIRTUAL_WIDTH - 28)

    self.width = 16
    self.height = 16
    self.collected = false

    self.dy = 30
    self.type = type
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt
end

function PowerUp:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end
    self.collected = true
    return true
end

function PowerUp:render()
    if not self.collected then
        love.graphics.draw(gTextures['main'], gFrames['powerUps'][self.type], self.x, self.y)
    end
end

function BallDuplicate(ballcount, ball, balltable)
    ballcount = ballcount + 1
    balltable[ballcount] = Ball()
    balltable[ballcount].x = ball.x
    balltable[ballcount].y = ball.y
    balltable[ballcount].dx = -ball.dx
    balltable[ballcount].dy = ball.dy
    balltable[ballcount].skin = ball.skin

    return ballcount, balltable
end
