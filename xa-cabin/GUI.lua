local GUI = {};
local FIRST_ROW_HEIGHT_PERCENT = 0.4
local SECOND_ROW_HEIGHT_PERCENT = (1 - FIRST_ROW_HEIGHT_PERCENT) * 0.85

function GUI.SimbriefInfo(win_width, win_height)
    if imgui.BeginChild("SimbriefInfo", win_width * 0.6, win_height * FIRST_ROW_HEIGHT_PERCENT) then
        imgui.TextUnformatted("Flight No: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("      " .. SIMBRIEF["Callsign"])
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Departue: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("       " .. SIMBRIEF["Origin"] ..
            " / " .. SIMBRIEF["OrigName"] .. " / " .. SIMBRIEF["OrigRwy"])
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Arrival: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("        " .. SIMBRIEF["Destination"] ..
            " / " .. SIMBRIEF["DestName"] .. " / " .. SIMBRIEF["DestRwy"])
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Flight Time: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("    " ..
            tostring(math.floor(SIMBRIEF["Ete"] / 3600)) ..
            " hr " .. tostring(math.floor((SIMBRIEF["Ete"] % 3660) / 60)) .. " min")
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Cruise Altitude: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.SameLine()
        imgui.TextUnformatted("" .. SIMBRIEF["Level"])
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Route: ")
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("    " .. SIMBRIEF["Route"])
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.Spacing()
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.TextUnformatted("Flight State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("      " .. STATE.flight_phase)  -- Use the dynamically updated flight phase
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Cabin State: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("       " .. STATE.cabin_state)  -- Use the dynamically updated cabin state
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
        imgui.Spacing()
        imgui.Spacing()

        imgui.Separator()
        imgui.Spacing()
        imgui.Spacing()
        imgui.TextUnformatted("Language: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("     " .. XA_CABIN_SETTINGS.announcement.language)
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Accent: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("       " .. XA_CABIN_SETTINGS.announcement.accent)
        imgui.PopStyleColor()
        imgui.Spacing()

        imgui.TextUnformatted("Speaker: ")
        imgui.SameLine()
        imgui.PushStyleColor(imgui.constant.Col.Text, 0xFF00FF00)
        imgui.TextUnformatted("      " .. XA_CABIN_SETTINGS.announcement.speaker)
        imgui.PopStyleColor()
        imgui.Spacing()
    end
    imgui.EndChild()
end

function GUI.Announcements(win_width, win_height)
    if imgui.BeginChild("Announcements", win_width - 32, win_height * SECOND_ROW_HEIGHT_PERCENT) then
        imgui.SetWindowFontScale(1.2)
        if imgui.BeginTable("XA Cabin", 3) then
            local total_announcements = #ANNOUNCEMENT_STATES
            for i = 1, total_announcements, 3 do
                imgui.TableNextRow()

                -- First Column
                imgui.TableNextColumn()
                local state1 = ANNOUNCEMENT_STATES[i]
                if state1 then
                    local displayName1 = DISPLAY_NAME_TO_STATE[state1] or state1
                    if imgui.Button(displayName1, win_width * 0.3 - 16, 50) then
                        STATE.change_cabin_state(state1)
                    end
                end

                -- Second Column
                imgui.TableNextColumn()
                local state2 = ANNOUNCEMENT_STATES[i + 1]
                if state2 then
                    local displayName2 = DISPLAY_NAME_TO_STATE[state2] or state2
                    if imgui.Button(displayName2, win_width * 0.3 - 16, 50) then
                        STATE.change_cabin_state(state2)
                    end
                end

                -- Third Column
                imgui.TableNextColumn()
                local state3 = ANNOUNCEMENT_STATES[i + 2]
                if state3 then
                    local displayName3 = DISPLAY_NAME_TO_STATE[state3] or state3
                    if imgui.Button(displayName3, win_width * 0.3 - 16, 50) then
                        STATE.change_cabin_state(state3)
                    end
                end
            end
            imgui.EndTable()
        end
    end
    imgui.EndChild()
end


return GUI;
