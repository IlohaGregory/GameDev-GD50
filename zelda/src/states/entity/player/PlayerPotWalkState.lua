-- Player  walking with pot

PlayerPotWalkState = Class { __includes = EntityWalkState }

function PlayerPotWalkState:init(Player, dungeon)
    self.entity = Player
    self.dungeon = dungeon
end
