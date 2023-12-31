--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class { __includes = BaseState }

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.ball = {}
    self.ballcount = 1
    self.ball[self.ballcount] = params.ball

    self.recoverPoints = params.recoverPoints
    self.powerUp = {}
    self.ballTimer = 0
    self.KeySpawnTimer = 0
    self.KeyDurTimer = 0
    -- give ball random starting velocity
    self.ball[self.ballcount].dx = math.random(-200, 200)
    self.ball[self.ballcount].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for i = 1, self.ballcount do
        self.ball[i]:update(dt)
    end
    for i = 1, self.ballcount do
        if self.ball[i]:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.ball[i].y = self.paddle.y - 8
            self.ball[i].dy = -self.ball[i].dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.ball[i].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.ball[i].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball[i].x))

                -- else if we hit the paddle on its right side while moving right...
            elseif self.ball[i].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.ball[i].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball[i].x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect for every ball instance
    for i = 1, #self.ball do
        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and self.ball[i]:collides(brick) then
                -- add to score
                if brick.color == 6 and self.KeyDurTimer < 0 then
                    gSounds['brick-hit-2']:stop()
                    gSounds['brick-hit-2']:play()
                else
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = self.ball[i],
                            recoverPoints = self.recoverPoints
                        })
                    end
                end
                --
                -- collision code for bricks
                --
                --  we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.ball[i].x + 2 < brick.x and self.ball[i].dx > 0 then
                    -- flip x velocity and reset position outside of brick
                    self.ball[i].dx = -self.ball[i].dx
                    self.ball[i].x = brick.x - 8

                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                elseif self.ball[i].x + 6 > brick.x + brick.width and self.ball[i].dx < 0 then
                    -- flip x velocity and reset position outside of brick
                    self.ball[i].dx = -self.ball[i].dx
                    self.ball[i].x = brick.x + 32

                    -- top edge if no X collisions, always check
                elseif self.ball[i].y < brick.y then
                    -- flip y velocity and reset position outside of brick
                    self.ball[i].dy = -self.ball[i].dy
                    self.ball[i].y = brick.y - 8

                    -- bottom edge if no X collisions or top collision, last possibility
                else
                    -- flip y velocity and reset position outside of brick
                    self.ball[i].dy = -self.ball[i].dy
                    self.ball[i].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.ball[i].dy) < 150 then
                    self.ball[i].dy = self.ball[i].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end
    for k, ball in pairs(self.ball) do
        if ball.y >= VIRTUAL_HEIGHT then
            gSounds['hurt']:play()
            table.remove(self.ball, k)
            self.ballcount = self.ballcount - 1
        end
        if self.ballcount == 0 then
            self.health = self.health - 1

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    ballcount = self.ballcount,
                    recoverPoints = self.recoverPoints
                })
            end
        end
    end

    -- spawning the ball powerup
    self.ballTimer = self.ballTimer + dt
    local ball_spawn = math.random(10, 20)
    if self.ballTimer > ball_spawn then
        table.insert(self.powerUp, PowerUp(9))
        -- reset timer
        self.ballTimer = 0
    end
    -- keeping track of key power up durattion
    self.KeyDurTimer = self.KeyDurTimer - dt
    -- spawning the key powerup
    self.KeySpawnTimer = self.KeySpawnTimer + dt
    local key_spawn = math.random(25, 35)
    for k, Brick in pairs(self.bricks) do
        if self.KeySpawnTimer > key_spawn and Brick.keyBrick_on == true then
            table.insert(self.powerUp, PowerUp(10))
            self.KeySpawnTimer = 0
        end
    end


    for k, powerUp in pairs(self.powerUp) do
        powerUp:update(dt)
        if powerUp:collides(self.paddle) then
            if powerUp.type == 9 then
                powerUp.y = powerUp.y - 16
                self.ballcount, self.ball = BallDuplicate(self.ballcount, self.ball[self.ballcount], self.ball)
                table.remove(self.powerUp, k)
            elseif powerUp.type == 10 then
                powerUp.y = powerUp.y - 16
                self.KeyDurTimer = 30
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for i = 1, self.ballcount do
        self.ball[i]:render()
    end

    for k, powerUp in pairs(self.powerUp) do
        powerUp:render()
    end
    renderScore(self.score)
    renderHealth(self.health)

    -- Key power running time
    if self.KeyDurTimer > 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gFonts['small'])
        love.graphics.print('PowerUp Duration: ' .. tostring(math.floor(self.KeyDurTimer)) .. 'secs', 5, 20)
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED\n" .. tostring(self.ballcount), 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
