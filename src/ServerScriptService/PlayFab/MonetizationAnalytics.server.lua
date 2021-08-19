local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local PlayFabApi = require(script.Parent.API.PlayFabApi)

local function onEventSuccess(eventName: string, result)
    if not RunService:IsStudio() then return end 
    print("Successfully sent", eventName, "to playfab! result:", result)
end 

local function onEventFailed(eventName: string, error)
    if not RunService:IsStudio() then return end 
    print("Failed to send", eventName, "to playfab! error:", error)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamepassId: number, wasPurchased: boolean)
    if not wasPurchased then 
        if not not MarketplaceService:PlayerOwnsAsset(player, gamepassId)  then return end
        PlayFabApi.WriteTitleEvent({
            EventName = "gamepass_not_purchased";
            Body = {
                gamepass_id = gamepassId;
                player_userId = player.UserId; 
            }
        },

        onEventSuccess("gamepass_not_purchased"),
        onEventFailed("gamepass_not_purchased"))
        return
    end

    PlayFabApi.WriteTitleEvent({
        EventName = "gamepass_purchased";
        Body = {
            gamepass_Id = gamepassId;
            recipient_userId = player.UserId;
        };
    }, 

    function(result: table)
        onEventSuccess("gamepass_purchased", result)
    end,

    function(error: table)
        onEventFailed("gamepass_purchased", error.errorMessage)
    end)
end)

function MarketplaceService.ProcessReceipt(receiptInfo: table)
    PlayFabApi.WriteTitleEvent({
        EventName = "devproduct_purchased";
        Body = {
            receipt_id = receiptInfo.PurchaseId;
            recipient_userId = receiptInfo.PlayerId;
            product_id = receiptInfo.ProductId;
        }
    },

    function(result: table) 
        onEventSuccess("devproduct_purchased", result)
    end,

    function(error: table)
        onEventFailed("devproduct_purchased", error.errorMessage)
    end)
end