-- LocalScript (StarterPlayer → StarterPlayerScripts)
local player = game.Players.LocalPlayer

local JUMP_SOUND_ID = "rbxassetid://100936483086925"
local DAMAGE_SOUND_ID = "rbxassetid://12222058"
local DEATH_SOUND_ID = "rbxassetid://12222058"  -- ダメージ音と同じにした
local WALK_SOUND_ID = "rbxassetid://174960816"
local VOLUME = 1

local function playSound(id, parent, loop)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = VOLUME
	sound.Looped = loop or false
	sound.Parent = parent
	sound:Play()
	return sound
end

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
	if not humanoid or not hrp then return end

	-- ジャンプ音
	humanoid.Jumping:Connect(function(isActive)
		if isActive then
			local s = playSound(JUMP_SOUND_ID, hrp)
			s.Ended:Connect(function() s:Destroy() end)
		end
	end)

	-- ダメージ＆死亡音（死亡時は一回だけ鳴らす）
	local lastHealth = humanoid.Health
	local deathSoundPlayed = false
	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			if newHealth <= 0 and not deathSoundPlayed then
				deathSoundPlayed = true
				local s = playSound(DEATH_SOUND_ID, hrp)
				s.Ended:Connect(function() s:Destroy() end)
			elseif newHealth > 0 then
				local s = playSound(DAMAGE_SOUND_ID, hrp)
				s.Ended:Connect(function() s:Destroy() end)
			end
		end
		lastHealth = newHealth
	end)

	-- リスポーンしたら死亡音フラグをリセット
	player.CharacterAdded:Connect(function()
		deathSoundPlayed = false
	end)

	-- 歩行音（歩いている間だけループ）
	local walkingSound = nil
	game:GetService("RunService").RenderStepped:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
			if not walkingSound then
				walkingSound = playSound(WALK_SOUND_ID, hrp, true)
			end
		else
			if walkingSound then
				walkingSound:Stop()
				walkingSound:Destroy()
				walkingSound = nil
			end
		end
	end)
end

if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)
