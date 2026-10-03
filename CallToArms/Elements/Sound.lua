local Name, AddOn = ...
local CTA = AddOn.CTA

local LastSoundTime = 0

function CTA:PlaySound()
    if not self.Settings.PlaySound then
        return
    end

    local Now = GetTime()

    if (Now - LastSoundTime) < 5 then
        return
    end

    local SoundKey = self.Settings.AlertSound
    local SoundPath = self.SharedMedia:Fetch("sound", SoundKey, true)

    if SoundPath then
        PlaySoundFile(SoundPath, "Master")
    end

    LastSoundTime = Now
end