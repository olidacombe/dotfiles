-- Hyprland Lua configuration
-- See https://wiki.hypr.land/Configuring/

local browser = "brave --ozone-platform=wayland"
local terminal = "ghostty"
local menu = "wofi --show drun"
local mainMod = "SUPER"
local hyper = "SUPER + CTRL + ALT"

-- *arr services (full-screen app mode on ws 2,3,4)
local sonarr = browser .. " --app=http://localhost:8989"
local radarr = browser .. " --app=http://localhost:7878"
local prowlarr = browser .. " --app=http://localhost:9696"
local jellyfin = browser .. " --app=http://localhost:8096"

-- Monitors
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "DP-1", mode = "2560x1440", position = "2560x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "480x1440", scale = 1 })

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("udiskie")
    -- *arr + jellyfin services (auto-start in fullscreen app mode)
    hl.exec_cmd(sonarr)
    hl.exec_cmd(radarr)
    hl.exec_cmd(prowlarr)
    hl.exec_cmd(jellyfin)

    -- Delayed moves (window rules can miss due to dynamic titles from SPAs)
    -- Sonarr -> ws 2, Radarr -> ws 3, Prowlarr -> ws 4, Jellyfin -> ws 1
    hl.exec_cmd("sleep 4 && hyprctl dispatch movetoworkspace 2,title:Sonarr")
    hl.exec_cmd("sleep 4 && hyprctl dispatch movetoworkspace 3,title:Radarr")
    hl.exec_cmd("sleep 4 && hyprctl dispatch movetoworkspace 4,title:'Indexers - Prowlarr'")
    hl.exec_cmd("sleep 4 && hyprctl dispatch movetoworkspace 1,title:504489665a7b")
    -- Also force fullscreen on the target workspaces
    hl.exec_cmd("sleep 5 && hyprctl dispatch fullscreen 1 workspace:2")
    hl.exec_cmd("sleep 5 && hyprctl dispatch fullscreen 1 workspace:3")
    hl.exec_cmd("sleep 5 && hyprctl dispatch fullscreen 1 workspace:4")
    hl.exec_cmd("sleep 5 && hyprctl dispatch fullscreen 1 workspace:1")
end)

-- Environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Permissions
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")

-- Global settings
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 13,
        border_size = 0,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 5,
        rounding_power = 2,
        active_opacity = 0.95,
        inactive_opacity = 0.9,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
        tablet = { output = "DP-2" },
    },
    gestures = {},
})

-- Curves (beziers)
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animations (disabled)
hl.animation({ leaf = "global", enabled = false })

-- Per-device config
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.device({
    name = "wacom-co.-ltd.-wacom-movink-13-touchscreen",
    output = "DP-2",
    enabled = true,
})

-- Workspace rules
-- hl.workspace_rule({ workspace = "10", default_name = "0", monitor = "DP-1", default = true })
-- hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
-- hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
-- hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
-- hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", default = true })
-- hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1" })
-- hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1" })
-- hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-1" })
-- hl.workspace_rule({ workspace = "8", monitor = "DP-2" })
-- hl.workspace_rule({ workspace = "9", monitor = "DP-2" })
-- hl.workspace_rule({
--     workspace = "name:drawing",
--     no_rounding = true,
--     decorate = false,
--     gaps_in = 0,
--     gaps_out = 0,
--     no_border = true,
--     monitor =
--     "DP-2"
-- })

-- Window rules

function drawing_class(matcher)
    hl.window_rule({
        match = { class = matcher },
        workspace = "name:drawing",
    })
    hl.window_rule({
        match = { class = matcher },
        opacity = "1.0 override",
    })
end

drawing_class("^gimp$")
drawing_class("^krita$")
drawing_class("^org\\.freecad\\.FreeCAD$")

hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})
hl.window_rule({
    match = { class = "^audio\\..*" },
    workspace = "audio",
})


hl.on("window.title", function(w)
    if w == nil then return end
    local title_map = {
        Radarr = 2,
        Sonarr = 3,
        Jellyfin = 1,
        Prowlarr = 4
    }
    local target = title_map[w.title]

    if target ~= nil then
        hl.dispatch(hl.dsp.window.move({ window = w, workspace = target }))
    end
end)
-- Media/*arr UIs: fullscreen app mode on dedicated workspaces
-- Note: matches on window title (set by the web UI). Also requires the backend services to be running on the ports.
hl.window_rule({
    match = { class = "brave-localhost__-Default", title = "Sonarr" },
    workspace = 2,
    fullscreen = true,
})
hl.window_rule({
    match = { class = "brave-localhost__-Default", title = "Radarr" },
    workspace = 3,
    fullscreen = true,
})
hl.window_rule({
    match = { class = "brave-localhost__-Default", title = "Prowlarr" },
    workspace = 4,
    fullscreen = true,
})
-- Jellyfin on workspace 1 (fullscreen app mode)
-- Note: Jellyfin title can be a hash or "Jellyfin"; we rely on delayed dispatch for reliability
hl.window_rule({
    match = { class = "brave-localhost__-Default", title = "Jellyfin" },
    workspace = 1,
    fullscreen = true,
})
hl.window_rule({
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_initial_focus = true,
})

--  ██                              ██                  ██   ██
-- ░██                             ░██                 ░██  ██           ██   ██
-- ░██        █████   ██████       ░██  █████  ██████  ░██ ██    █████  ░░██ ██
-- ░██       ██░░░██ ░░░░░░██   ██████ ██░░░██░░██░░█  ░████    ██░░░██  ░░███
-- ░██      ░███████  ███████  ██░░░██░███████ ░██ ░   ░██░██  ░███████   ░██
-- ░██      ░██░░░░  ██░░░░██ ░██  ░██░██░░░░  ░██     ░██░░██ ░██░░░░    ██
-- ░████████░░██████░░████████░░██████░░██████░███     ░██ ░░██░░██████  ██
-- ░░░░░░░░  ░░░░░░  ░░░░░░░░  ░░░░░░  ░░░░░░ ░░░      ░░   ░░  ░░░░░░  ░░

function move_to_workspace(target_workspace)
    return function()
        hl.dispatch(hl.dsp.window.move({ workspace = target_workspace }))
        -- we're done
        hl.dispatch(hl.dsp.submap("reset"))
    end
end

hl.bind("ALT + SPACE", hl.dsp.submap("leader"))
hl.define_submap("leader", function()
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("0", move_to_workspace(10))
    hl.bind("1", move_to_workspace(1))
    hl.bind("2", move_to_workspace(2))
    hl.bind("3", move_to_workspace(3))
    hl.bind("4", move_to_workspace(4))
    hl.bind("5", move_to_workspace(5))
    hl.bind("6", move_to_workspace(6))
    hl.bind("7", move_to_workspace(7))
    hl.bind("8", move_to_workspace("drawing"))
    -- hl.bind("M", hl.dsp.submap("move"))
end)

-- TODO kill
hl.define_submap("move", "reset", function()
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("0", hl.dsp.window.move({ workspace = 10 }))
    hl.bind("1", hl.dsp.window.move({ workspace = 1 }))
    hl.bind("2", hl.dsp.window.move({ workspace = 2 }))
    hl.bind("3", hl.dsp.window.move({ workspace = 3 }))
    hl.bind("4", hl.dsp.window.move({ workspace = 4 }))
    hl.bind("5", hl.dsp.window.move({ workspace = 5 }))
    hl.bind("6", hl.dsp.window.move({ workspace = 6 }))
    hl.bind("7", hl.dsp.window.move({ workspace = 7 }))
    hl.bind("8", hl.dsp.window.move({ workspace = "drawing" }))
end)

-- Normal keybinds
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind("CTRL + SHIFT + E", hl.dsp.exec_cmd("wlogout -b 3 -T 400 -B 400 -L 700 -R 700"))
-- Useful during dev of hyprland startup behaviour
hl.bind("CTRL + SHIFT + X", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd("hyprlock"))

-- screenshot
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/scripts/screenshot"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("grim -g \"$(slurp -d)\" - | wl-copy"))
hl.bind(mainMod .. " + CTRL + G", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/scripts/screenshot full"))

-- wallpaper
hl.bind(hyper .. " + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper.sh"))

-- window operations
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("CTRL + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + Apostrophe", hl.dsp.exec_cmd("[float] alacritty -e bluetuith"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/scripts/hyprland-audio-workspace.sh"))
hl.bind(mainMod .. " + Comma", hl.dsp.exec_cmd("[float] alacritty -e nmtui"))
hl.bind(mainMod .. " + ALT + b", hl.dsp.exec_cmd("gimp -b '(blackboard)' --batch-interpreter plug-in-script-fu-eval"))

-- Move focus with ALT + arrow keys (vim-style)
hl.bind("ALT + H", hl.dsp.focus({ direction = "l" }))
hl.bind("ALT + L", hl.dsp.focus({ direction = "r" }))
hl.bind("ALT + K", hl.dsp.focus({ direction = "u" }))
hl.bind("ALT + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with ALT + [0-9]
hl.bind("ALT + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("ALT + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("ALT + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("ALT + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("ALT + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("ALT + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("ALT + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("ALT + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("ALT + 8", hl.dsp.focus({ workspace = "drawing" }))

-- Quick switch to *arr workspaces (ctrl-2/3/4)
hl.bind("CTRL + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("CTRL + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("CTRL + 4", hl.dsp.focus({ workspace = 4 }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move windows with mainMod + ALT + vim keys
hl.bind(mainMod .. " + ALT + n", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + ALT + c", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + ALT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + ALT + t", hl.dsp.window.move({ direction = "d" }))

-- Mouse resize binds
hl.bind("Alt_L + Super_L", hl.dsp.window.resize(), { mouse = true })
hl.bind("Super_L + Alt_L", hl.dsp.window.resize(), { mouse = true })
hl.bind("Alt_R + Super_R", hl.dsp.window.resize(), { mouse = true })
hl.bind("Super_R + Alt_R", hl.dsp.window.resize(), { mouse = true })

-- Keyboard resize (no mouse)
hl.bind("ALT + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind("ALT + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind("ALT + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("ALT + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media player controls (require playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
