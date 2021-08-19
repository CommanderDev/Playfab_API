local HttpService = game:GetService("HttpService")

local Knit = require(game.ReplicatedStorage.Knit)

local Promise = Knit.Util.Promise

local PlayerService = Knit.CreateService {Name = "PlayerService"}

local WebhookData = require(script.Parent.Parent.Data.WebhookData)

local function onPlayerAdded(player: Player) 
     local playerData = HttpService:GetAsync(WebhookData["GetProfile"].."?userId="..player.UserId)
     print(playerData)
end 

function PlayerService:KnitInit()
    game.Players.PlayerAdded:Connect(onPlayerAdded)   
end 

return PlayerService