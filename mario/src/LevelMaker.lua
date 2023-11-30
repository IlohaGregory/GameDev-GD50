--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class {}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    -- flag for if key has been collected and key blocks has been spawned
    local keyCollected = false
    local keySpawned = false
    local keyBlockSpawned = false


    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if x ~= 1 and math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

                -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)
                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then
                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then
                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = { y = (blockHeight - 2) * TILE_SIZE }
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                    -- spawning the key
                                elseif math.random() < 0.2 then
                                    -- check if key has already been created if not, create one and flag keyspawned as true
                                    if not keySpawned then
                                        keySpawned = not keySpawned
                                        local key = GameObject {
                                            texture = 'keysAndLocks',
                                            x = (x - 1) * TILE_SIZE,
                                            y = (blockHeight - 1) * TILE_SIZE - 4,
                                            width = 16,
                                            height = 16,
                                            frame = math.random(4),
                                            collidable = true,
                                            consumable = true,
                                            solid = false,

                                            -- gem has its own function to add to the player's score
                                            onConsume = function(player, object)
                                                keyCollected = not keyCollected
                                                gSounds['pickup']:play()
                                            end
                                        }

                                        -- make the gem move up from the block and play a sound
                                        Timer.tween(0.1, {
                                            [key] = { y = (blockHeight - 2) * TILE_SIZE }
                                        })
                                        gSounds['powerup-reveal']:play()
                                        table.insert(objects, key)
                                    end
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
                -- creating locked bricks randomly, and making sure that even if it doesn't get created randomly we forcefully generate it
            elseif math.random(20) == 1 and not keyBlockSpawned then
                keyBlockSpawned = not keyBlockSpawned
                table.insert(objects,
                    GameObject {
                        texture = 'keysAndLocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(5, 8),
                        collidable = true,
                        hit = false,
                        solid = true,

                        onCollide = function(obj)
                            if keyCollected then
                                SpawnFlag(width, blockHeight, objects)
                                for k, object in pairs(objects) do
                                    if object.texture == 'keysAndLocks' then
                                        table.remove(objects, k)
                                    end
                                end
                            end
                        end

                    })
            elseif x > (width - math.random(10)) and not keyBlockSpawned then
                keyBlockSpawned = not keyBlockSpawned
                table.insert(objects,
                    GameObject {
                        texture = 'keysAndLocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(5, 8),
                        collidable = true,
                        hit = false,
                        solid = true,

                        onCollide = function(obj)
                            if keyCollected then
                                SpawnFlag(width, blockHeight, objects)
                                for k, object in pairs(objects) do
                                    if object.texture == 'keysAndLocks' then
                                        table.remove(objects, k)
                                    end
                                end
                            end
                        end
                    })
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end

function SpawnFlag(width, blockHeight, objects)
    -- check to make sure there are no jump blocks here and if there are, remove them
    for k, object in pairs(objects) do
        if object.x == ((width - 2) * TILE_SIZE) and object.y == ((blockHeight - 1) * TILE_SIZE) then
            table.remove(objects, k)
        end
    end
    local flag = FlagPole {
        texture = 'flagAndPoles',
        x = (width - 2) * TILE_SIZE,
        y = (blockHeight - 1) * TILE_SIZE,
        width = 16,
        height = 16,

        -- make it a random variant
        frame = math.random(6),
        collidable = true,
        consumable = true,
        solid = false,

        onConsume = function(player, object)
            gSounds['pickup']:play()
            gStateMachine:change('play', player.score)
        end
    }
    table.insert(objects, flag)
end
