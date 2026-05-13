local remote = game:GetService("ReplicatedStorage")
	:WaitForChild("rbxts_include")
	:WaitForChild("node_modules")
	:WaitForChild("@rbxts")
	:WaitForChild("remo")
	:WaitForChild("src")
	:WaitForChild("container")
	:WaitForChild("items.setBoostRunning")

local boosts = {
	"Ultra Drops Boost",
	"Ultra Damage Boost",
	"Mythical Potion",
	"Speed III Boost",
	"Omega Luck Boost"
}

while true do
	for _, boostName in ipairs(boosts) do
		remote:FireServer(boostName, true)
		task.wait(1.5)
	end
end
