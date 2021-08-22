-- PlayFabHttps_Defold.lua
--
-- Defold HTTPS implementation for PlayFab LuaSdk
-- This implementation is specifically for running a Defold project, and won't work anywhere else
local HttpService = game:GetService("HttpService")

local json = require(script.Parent.json)
local PlayFabSettings = require(script.Parent.PlayFabSettings)

local PlayFabHttps_Defold = {
}

local function InternalCallbackWrapper(onSuccess, onError)
	return function(httpResponse)
		if (httpResponse.code == 200) then
			--local _, response = pcall(json.decode, httpResponse.data or "null")
			if (httpResponse and httpResponse.code == 200 and httpResponse.data and onSuccess) then
				onSuccess(httpResponse.data)
			elseif (httpResponse and onError) then
				onError(httpResponse)
			elseif (onError) then
				onError({
					code = httpResponse.status,
					status = httpResponse.status, -- TODO: this is supposed to be the string value for the status code
					errorCode = 1123,
					error = "ServiceUnavailable",
					errorMessage = "Could not deserialize reseponse from server: " .. tostring(httpResponse.data)
				})
			end
		elseif (onError) then
			onError({
				code = httpResponse.status,
				status = httpResponse.status, -- TODO: this is supposed to be the string value for the status code
				errorCode = 1123,
				error = "ServiceUnavailable",
				errorMessage = "Could not deserialize reseponse from server: " .. tostring(httpResponse.data)
			})
		end
	end
end

function PlayFabHttps_Defold.MakePlayFabApiCall(urlPath, request, authKey, authValue, onSuccess, onError)
	local ok, requestJson = pcall(json.encode, request)
	if not ok then
		error(requestJson or "request could not be converted to json")
	end

	local requestHeaders = {
		["X-PlayFabSDK"] = PlayFabSettings._internalSettings.sdkVersionString,
	}
	if authKey then
		requestHeaders[authKey] = authValue
	end

	local fullUrl = PlayFabSettings.GetFullUrl(urlPath)

	local success, result = pcall(function()
		local response = HttpService:PostAsync(fullUrl, requestJson, Enum.HttpContentType.ApplicationJson, false, requestHeaders)
		return HttpService:JSONDecode(response)
	end)
	InternalCallbackWrapper(onSuccess, onError)(result)
	return result
end

return PlayFabHttps_Defold
