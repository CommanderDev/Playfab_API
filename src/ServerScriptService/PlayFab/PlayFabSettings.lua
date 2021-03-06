-- Holds the basic settings for PlayFab
-- PlayFabSettings.settings is public and contains the following:
--     titleId -- You must set this before making any PlayFab API calls
-- It may optionally include:
--     devSecretKey       -- Server/Admin only, required for any non-client call

local PlayFabSettings = {
    _internalSettings = {
        sessionTickets = {},
        sdkVersionString = "DefoldSdk_0.101.210802",
        buildIdentifier = "jbuild_luasdk_sdk-generic-3_1",
        requestGetParams = {["sdk"] = "DefoldSdk_0.101.210802"}
    },
    settings = {
        productionUrl = ".playfabapi.com",
        verticalName = nil, -- The name of a customer vertical. This is only for customers running a private cluster. Generally you shouldn't touch this
        devSecretKey = "INSERT KEY",
        titleId = "INSERT TITLE ID"
    }
}

function PlayFabSettings.GetFullUrl(urlPath)
    local fullUrl = "";
    if (not (string.sub(PlayFabSettings.settings.productionUrl, 1, 4) == "http")) then
        if (PlayFabSettings.settings.verticalName) then
            fullUrl = "https://" .. PlayFabSettings.settings.verticalName
        else
            fullUrl = "https://" .. PlayFabSettings.settings.titleId
        end
    end

    fullUrl = fullUrl .. PlayFabSettings.settings.productionUrl .. urlPath

    local getParams = PlayFabSettings._internalSettings.requestGetParams
    local firstParam = true
    for key, value in pairs(getParams) do
        if (firstParam) then
            fullUrl = fullUrl .. "?"
            firstParam = false
        else
            fullUrl = fullUrl .. "&"
        end

        fullUrl = fullUrl .. key .. "=" .. value
    end

    return fullUrl
end

return PlayFabSettings
