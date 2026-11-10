local ADDON, AF = ...
local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(_, event, addon)
  if event == "ADDON_LOADED" and addon == ADDON then
    AF:Init()
  elseif event == "PLAYER_LOGIN" then
    AF:Login()
    AF.Motion.Start()
    AF.Jump.Start()
    AF.UI:Init()
    SLASH_AZEROTHFITNESS1 = "/af"
    SLASH_AZEROTHFITNESS2 = "/azerothfitness"
    SlashCmdList.AZEROTHFITNESS = function(raw)
      local arg = string.lower((raw or ""):match("^%s*(.-)%s*$"))
      if arg == "stats" then
        AF.UI:Show("today")
      elseif arg == "history" then
        AF.UI:Show("history")
      elseif arg == "settings" then
        AF.UI:Show("settings")
      elseif arg == "reset" then
        AF.Achievements:RequestReset()
      elseif arg == "debug" then
        local p = AF.Motion.probe
        AF:Say(string.format(AF:T("PROBE"), p.mode, p.source))
      elseif arg == "" then
        AF.UI:Toggle()
      else
        AF:Say(AF:T("HELP"))
      end
    end
    boot:UnregisterAllEvents()
  end
end)
