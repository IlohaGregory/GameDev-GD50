--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        frame = 14,
        width = 15,
        height = 15,
        equipped = false,
        solid = true,
        defaultState = 'unbroken',
        states = {
            ['unbroken'] = {
                frame = 14
            },
            ['broken'] = {
                frame = 52
            }

        }
    },
    ['heart'] = {
        type = 'heart',
        texture = 'spawnedHearts',
        frame = 1,
        width = 10,
        height = 9,
        solid = false,
        collected = false,
        defaultState = 'fullHealth',
        states = {
            ['fullHealth'] = {
                frame = 1
            }
        }
    }
}
