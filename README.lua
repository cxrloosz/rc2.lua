local remote = game:GetService("ReplicatedStorage")
	:WaitForChild("rbxts_include")
	:WaitForChild("node_modules")
	:WaitForChild("@rbxts")
	:WaitForChild("remo")
	:WaitForChild("src")
	:WaitForChild("container")
	:WaitForChild("items.setBoostRunning")

while true do
    -- Mythical Potion com 0.7s
    remote:FireServer("Mythical Potion", true)
    task.wait(0.4)

    -- Speed III Boost com 0.8s
    remote:FireServer("Speed III Boost", true)
    task.wait(0.5)

    -- Omega Luck Boost com 0.9s
    remote:FireServer("Omega Luck Boost", true)
    task.wait(0.3)
end
