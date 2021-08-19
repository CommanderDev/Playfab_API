local API = script.Parent.API

local PlayFabApi = require(API.PlayFabApi)
local PlayFabAuthenticationApi = require(API.PlayFabAuthenticationApi)
local PlayFabSettings = require(API.PlayFabSettings)

PlayFabAuthenticationApi.GetEntityToken(PlayFabSettings.settings.devSecretKey)

local playerPlayfabIds: table = {}

local function loginPlayer(userId: number)
    print(userId)
    PlayFabApi.LoginWithServerCustomId(
        {
            CreateAccount = true;
            ServerCustomId = userId 
        },
        function(result: table)
            playerPlayfabIds[tostring(userId)] = result.PlayFabId
            print("Successfully logged in: "..userId)    
        end,

        function(error: table)
            PlayFabApi.WriteTitleEvent({
                EventName = "Login Failed";
                Body = {
                    PlayerId = userId;
                    errorInfo = error;
                }
            })
            print("Failed to login", userId..":", error.errorMessage)
        end)
end 

local function onPlayerAdded(player)
    loginPlayer(player.UserId)
    game:GetService("MarketplaceService"):PromptGamePassPurchase(player, 20211151)
end 

game.Players.PlayerAdded:Connect(onPlayerAdded)

for index: number, player: Player in next, game.Players:GetPlayers() do 
    onPlayerAdded(player)
end 