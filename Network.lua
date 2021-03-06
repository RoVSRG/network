local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local isServer = RunService:IsServer()

local remotes

if isServer then
	remotes = Instance.new("Folder")
	remotes.Parent = game:GetService("ReplicatedStorage")
	remotes.Name = "Remotes"
else
	remotes = game.ReplicatedStorage:WaitForChild("Remotes")
end

local Network = {}

Network.Client = {}
Network.Server = {}

function Network.Server.all()
	return true
end

-- SERVER FUNCTIONS

function Network.Server.onMessage(name, callback)
	assert(name ~= nil, "Name cannot be nil!")
	assert(callback ~= nil, "Callback cannot be nil!")
	
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	
	remoteEvent.Parent = remotes
	
	return {
		connection = remoteEvent.OnServerEvent:Connect(callback),
		remote = remoteEvent
	}
end

function Network.Server.onRequest(name, callback)
	assert(name ~= nil, "Name cannot be nil!")
	assert(callback ~= nil, "Callback cannot be nil!")

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Parent = remotes
	remoteFunction.Name = name

	remoteFunction.OnServerInvoke = callback
	
	return {
		remote = remoteFunction
	}
end

function Network.Server.sendMessage(name, filter, ...)
	assert(name ~= nil, "Name cannot be nil!")
	assert(filter ~= nil, "Filter cannot be nil!")

	local remote = remotes:WaitForChild(name)
	for _, player in ipairs(Players:GetPlayers()) do
		if filter(player) then
			remote:FireClient(player, ...)
		end
	end
end

-- CLIENT FUNCTIONS

function Network.Client.onMessage(name, callback)
	assert(name ~= nil, "Name cannot be nil!")
	assert(callback ~= nil, "Callback cannot be nil!")
	
	local remote = remotes:WaitForChild(name)
	
	return {
		remote = remote,
		connection = remote.OnClientEvent:Connect(callback)
	}
end

function Network.Client.sendMessage(name, ...)
	assert(name ~= nil, "Name cannot be nil!")

	local remote = remotes:WaitForChild(name)
	remote:FireServer(...)
end

function Network.Client.sendRequest(name, ...)
	assert(name ~= nil, "Name cannot be nil!")

	local remote = remotes:WaitForChild(name)
	return remote:InvokeServer(...)
end

if isServer then
	return Network.Server
else
	return Network.Client
end
