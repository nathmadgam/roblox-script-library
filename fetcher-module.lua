local httpService = game:GetService("HttpService")

local function getGameIdsForUser(userId, cursor, gameIds)
	cursor = cursor or ""
	gameIds = gameIds or {}

	local url = string.format("https://games.roproxy.com/v2/users/%s/games?limit=50&cursor=%s", userId, cursor)
	local success, response = pcall(httpService.GetAsync, httpService, url)

	if success and response then
		local decodedData = httpService:JSONDecode(response)
		for _, gameData in ipairs(decodedData.data) do
			table.insert(gameIds, gameData.id)
		end
		if decodedData.nextPageCursor then
			return getGameIdsForUser(userId, decodedData.nextPageCursor, gameIds)
		end
	else
		warn(response)
	end

	return gameIds
end

local function getGamePassesForUser(userId, gamePasses, universeIds)
	gamePasses = gamePasses or {}
	universeIds = universeIds or getGameIdsForUser(userId)

	for index = #universeIds, 1, -1 do
		local universeId = universeIds[index]
		local url = string.format("https://games.roproxy.com/v1/games/%s/game-passes?limit=50", universeId)
		local success, response = pcall(httpService.GetAsync, httpService, url)

		if success and response then
			table.remove(universeIds, index)
			local decodedData = httpService:JSONDecode(response)
			for _, gamePassData in ipairs(decodedData.data) do
				if gamePassData.price and gamePassData.price > 0 then
					table.insert(gamePasses, {
						Name = gamePassData.name,
						Price = gamePassData.price,
						Id = gamePassData.id,
						ItemType = Enum.InfoType.GamePass
					})
				end
			end
		else
			warn(response)
		end
	end

	if #universeIds > 0 then
		return getGamePassesForUser(userId, gamePasses, universeIds)
	end

	return gamePasses
end

local function getCatalogAssetsForUser(userId, cursor, catalogAssets)
	cursor = cursor or ""
	catalogAssets = catalogAssets or {}

	local creatorName = game.Players:GetNameFromUserIdAsync(userId)
	local url = string.format("https://catalog.roproxy.com/v1/search/items/details?Category=1&Sort=4&Limit=30&CreatorName=%s&cursor=%s", creatorName, cursor)
	local success, response = pcall(httpService.GetAsync, httpService, url)

	if success and response then
		local decodedData = httpService:JSONDecode(response)
		for _, catalogAssetData in ipairs(decodedData.data) do
			if catalogAssetData.price and catalogAssetData.price > 0 then
				table.insert(catalogAssets, {
					Name = catalogAssetData.name,
					Description = catalogAssetData.description,
					Price = catalogAssetData.price,
					Id = catalogAssetData.id,
					ItemType = Enum.InfoType[catalogAssetData.itemType]
				})
			end
		end
		if decodedData.nextPageCursor then
			return getCatalogAssetsForUser(userId, decodedData.nextPageCursor, catalogAssets)
		end
	else
		warn(response)
	end

	return catalogAssets
end

return {
	GetGamePasses = function(userId)
		local gamePasses = getGamePassesForUser(userId)
		table.sort(gamePasses, function(firstPass, secondPass)
			return firstPass.Price < secondPass.Price
		end)
		return gamePasses
	end,
	GetCatalogAssets = function(userId)
		local catalogAssets = getCatalogAssetsForUser(userId)
		table.sort(catalogAssets, function(firstAsset, secondAsset)
			return firstAsset.Price < secondAsset.Price
		end)
		return catalogAssets
	end
}
