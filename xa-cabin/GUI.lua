local GUI = {};
local FIRST_ROW_HEIGHT_PERCENT = 0.5
local SECOND_ROW_HEIGHT_PERCENT = (1 - FIRST_ROW_HEIGHT_PERCENT) * 0.85

function GUI.SimbriefInfo(win_width, win_height)
    if imgui.BeginChild("SimbriefInfo", win_width * 0.6, win_height * FIRST_ROW_HEIGHT_PERCENT) then
        imgui.TextUnformatted("Departue: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("       " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Arrival: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("        " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Flight Time: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("    " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Cruise Altitude: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("" .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Route: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("    " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.Spacing()
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.TextUnformatted("Flight State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("      " .. XA_CABIN_STATES.flight_state.current_state)
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Cabin State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("       " .. XA_CABIN_STATES.cabin_state.current_state)
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Plane State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("       " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Event: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("             " .. "TODO")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Announcement State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("TODO")
        imgui.PopStyleColor()
        imgui.Spacing()
    end
    imgui.End()
end

function GUI.Configuration(win_width, win_height)
    if imgui.BeginChild("Configuration", win_width * 0.4, win_height * FIRST_ROW_HEIGHT_PERCENT) then
        imgui.Spacing()
        imgui.Spacing()
        imgui.TextUnformatted("Simbrief Username")
        imgui.SameLine()

        if XA_CABIN_SETTINGS.simbrief.username == nil then
            XA_CABIN_SETTINGS.simbrief.username = ""
        end
        local sbfUsernameChanged, newUsername = imgui.InputText("", XA_CABIN_SETTINGS.simbrief.username, 255)
        if sbfUsernameChanged then
            XA_CABIN_SETTINGS.simbrief.username = newUsername
            LIP.save(SCRIPT_DIRECTORY .. "xa-cabin.ini", XA_CABIN_SETTINGS)
        end
        imgui.Spacing()
        imgui.Spacing()

        imgui.Separator()

        imgui.Spacing()
        imgui.Spacing()

        local currentMode = XA_CABIN_SETTINGS.mode.automated
        local modeChanged, newMode = imgui.Checkbox("Mode: ", currentMode)
        if modeChanged then
            currentMode = newMode
            XA_CABIN_SETTINGS.mode.automated = newMode
            LIP.save(SCRIPT_DIRECTORY .. "xa-cabin.ini", XA_CABIN_SETTINGS)
        end

        imgui.SameLine()
        if XA_CABIN_SETTINGS.mode.automated then
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
            imgui.TextUnformatted("Automated")
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF0000FF)
            imgui.TextUnformatted("Manual")
        end
        imgui.PopStyleColor()

        imgui.Spacing()
        local currentLiveMode = XA_CABIN_SETTINGS.mode.live
        local liveModeChanged, newLiveMode = imgui.Checkbox("Announcements Generation: ", currentLiveMode)
        if liveModeChanged then
            currentLiveMode = newLiveMode
            XA_CABIN_SETTINGS.mode.live = newLiveMode
            LIP.save(SCRIPT_DIRECTORY .. "xa-cabin.ini", XA_CABIN_SETTINGS)
        end

        imgui.SameLine()
        if XA_CABIN_SETTINGS.mode.live then
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
            imgui.TextUnformatted("Live")
        else
            imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF0000FF)
            imgui.TextUnformatted("Offline")
        end
        imgui.PopStyleColor()
    end
    imgui.EndChild()
end

function GUI.Announcements(win_width, win_height)
    if imgui.BeginChild("Announcements", win_width - 32, win_height * SECOND_ROW_HEIGHT_PERCENT) then
        imgui.SetWindowFontScale(1.2)
        if imgui.BeginTable("XA Cabin", 3) then
            for i = 2, #XA_CABIN_CABIN_XA_CABIN_STATES, 3
            do
                imgui.Spacing()
                imgui.Spacing()
                imgui.Spacing()
                imgui.Spacing()
                imgui.TableNextRow()
                imgui.TableNextColumn()
                if imgui.Button(XA_CABIN_CABIN_XA_CABIN_STATES[i], win_width * 0.3 - 16, 50) then -- Bigger than normal sized button
                    ANNOUNCEMENTS.play_sound(XA_CABIN_CABIN_XA_CABIN_STATES[i])
                end
                imgui.TableNextColumn()
                if imgui.Button(XA_CABIN_CABIN_XA_CABIN_STATES[i + 1], win_width * 0.3 - 16, 50) then -- Bigger than normal sized button
                    ANNOUNCEMENTS.play_sound(XA_CABIN_CABIN_XA_CABIN_STATES[i + 1])
                end
                imgui.TableNextColumn()
                if imgui.Button(XA_CABIN_CABIN_XA_CABIN_STATES[i + 2], win_width * 0.3 - 16, 50) then -- Bigger than normal sized button
                    ANNOUNCEMENTS.play_sound(XA_CABIN_CABIN_XA_CABIN_STATES[i + 2])
                end
            end
        end
        imgui.EndTable()
    end
    imgui.EndChild()
end

return GUI;
