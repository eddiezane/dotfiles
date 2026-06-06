-- Hyprland 0.55+ Lua config. Migrated from hyprland.conf on 2026-05-15.
--
-- If something here misbehaves, you can revert to the legacy hyprlang
-- config by removing/renaming this file — Hyprland will fall back to
-- ~/.config/hypr/hyprland.conf when hyprland.lua is absent.
--
-- Spots marked "MIGRATION NOTE" are best-effort translations of
-- directives whose Lua API shape isn't fully documented yet. Verify
-- them on first reload.

local home = os.getenv("HOME")
local palette = require("catppuccin")

local mod = "SUPER"
local terminal = "ghostty"
local fileManager = "thunar"
local menu = "wofi --show drun"

local brightness_script = home .. "/.config/hypr/scripts/brightness.sh"
local volume_script = home .. "/.config/hypr/scripts/volume.sh"

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "eDP-1", mode = "2256x1504", position = "0x0", scale = 1.333333 })

-- External multi-monitor setup.
-- To use: uncomment the three lines below and comment out the eDP-1 / auto
-- lines above. Reverse to go back to laptop-only.
--
-- Dell Alienware ultrawide - default, centered at origin
-- hl.monitor({ output = "desc:Dell Inc. AW3423DWF B99G2S3", mode = "3440x1440@164.90Hz", position = "0x0", scale = 1 })
-- Samsung - to the left of the Dell
-- hl.monitor({ output = "desc:Samsung Electric Company LS24DG30X H8CY300680", mode = "1920x1080@180.00Hz", position = "-1920x0", scale = 1 })
-- Laptop - centered underneath the Dell
-- hl.monitor({ output = "desc:BOE 0x0BCA", mode = "2256x1504@60.00Hz", position = "874x1440", scale = 1.333333 })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- SSH via 1Password's agent (matches home.sessionVariables; both for safety).
hl.env("SSH_AUTH_SOCK", home .. "/.1password/agent.sock")

-------------------
---- AUTOSTART ----
-------------------

-- UWSM + graphical-session.target start hypridle, hyprpolkitagent, nm-applet,
-- swaync, waybar, and yubikey-touch-detector via their upstream user units.
-- Only things without a packaged systemd unit need an exec here.
hl.on("hyprland.start", function()
	hl.exec_cmd("tailscale systray")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 2,
		border_size = 1,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		layout = "dwindle",
		allow_tearing = false,
	},

	binds = {
		workspace_back_and_forth = true,
	},

	decoration = {
		rounding = 0,
		blur = {
			enabled = false,
			size = 3,
			passes = 1,
		},
		shadow = {
			enabled = false,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	gestures = {
		workspace_swipe_invert = false,
		workspace_swipe_cancel_ratio = 0.2,
	},

	group = {
		groupbar = {
			font_family = "SauceCodePro Nerd Font",
			font_size = 14,
			gradients = false,
			scrolling = false,
			col = {
				active = palette.pink,
				inactive = palette.overlay2,
			},
		},
	},

	misc = {
		focus_on_activate = true,
		force_default_wallpaper = 0,
		disable_splash_rendering = true,
	},

	cursor = {
		-- Hardware cursors glitch on virtio-gpu and some real GPUs. Software
		-- cursors have negligible cost on modern hardware.
		no_hardware_cursors = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_options = "caps:swapescape",

		follow_mouse = 2,
		mouse_refocus = false,

		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
			clickfinger_behavior = true,
			scroll_factor = 0.2,
			disable_while_typing = false,
			tap_to_click = false,
			-- drag_3fg          = 1,
		},
	},
})

-----------------------------
---- WORKSPACE / WINDOW RULES
-----------------------------

-- App-specific workspace rules
hl.window_rule({ match = { class = "Spotify" }, workspace = "8 silent" })
hl.window_rule({ match = { class = "slack" }, workspace = "9 silent" })
hl.window_rule({ match = { class = "signal" }, workspace = "9 silent", no_initial_focus = true })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })
hl.window_rule({ match = { class = "1password" }, no_screen_share = true })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, focus_on_activate = false })

-- Smart borders / no border on solo
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})
hl.window_rule({
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

-- Special workspace styling
hl.window_rule({
	match = { workspace = "special:scratch" },
	border_size = 3,
	border_color = "rgb(ff00ff) rgb(8800ff) 45deg",
})
hl.workspace_rule({ workspace = "special:scratch", gaps_out = 10 })

hl.window_rule({
	match = { workspace = "special:equal" },
	border_size = 3,
	border_color = "rgb(292f56) rgb(005c8b) 45deg",
})
hl.workspace_rule({ workspace = "special:equal", gaps_out = 10 })

hl.window_rule({
	match = { workspace = "special:minus" },
	border_size = 3,
	border_color = "rgb(16e62d)",
})
hl.workspace_rule({ workspace = "special:minus", gaps_out = 10 })

---------------------
---- KEYBINDINGS ----
---------------------

-- Workspace -> monitor moves
-- MIGRATION NOTE: `movecurrentworkspacetomonitor, +1` doesn't have an obvious
-- 1:1 Lua dispatcher. `hl.dsp.workspace.move` is the best guess; if it
-- complains, fall back to an exec of `hyprctl dispatch movecurrentworkspacetomonitor +1`.
hl.bind(mod .. " + SPACE", hl.dsp.workspace.move({ monitor = "+1" }))

-- Clamshell mode. The system-level half is handled by systemd-logind:
-- HandleLidSwitchDocked=ignore keeps the machine awake when docked, while
-- HandleLidSwitch/HandleLidSwitchExternalPower=suspend-then-hibernate cover the
-- undocked cases (see hosts/tehunicorn/default.nix). These binds only handle the
-- remaining gap: blanking the internal panel when the lid closes while docked.
--
-- lid.sh gates on dock state — docked closes disable eDP-1 (Hyprland migrates its
-- workspaces onto the externals), undocked closes are a no-op so logind's
-- suspend-then-hibernate runs without a racing monitor teardown. switch:on = lid
-- closed, switch:off = lid open. { locked = true } is the Lua equivalent of the
-- hyprlang `bindl` flag, so these fire even while locked / inhibited.
--
-- MIGRATION NOTE: the "switch:on:Lid Switch" key form mirrors hyprlang's switch
-- syntax; if the Lua bind layer rejects it, fall back to an exec of
-- `hyprctl keyword ...` or check the wiki's switch section.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/lid.sh close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/lid.sh open"), { locked = true })

-- Launchers / window
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("rofimoji -a clipboard"))

hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Groups
-- MIGRATION NOTE: hyprlang `changegroupactive` (no arg = cycle next).
-- Using hl.dsp.group.next(); if you want previous on a separate bind use hl.dsp.group.prev().
hl.bind(mod .. " + W", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + W", hl.dsp.group.toggle())

-- Bar
hl.bind(mod .. " + M", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/bar.sh"))

-- Session
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + CONTROL + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t"))

hl.bind(mod .. " + CONTROL + N", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wlsunset.sh"))
hl.bind(mod .. " + CONTROL + backspace", hl.dsp.dpms("toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(brightness_script .. " up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(brightness_script .. " down"), { repeating = true })
hl.bind(mod .. " + XF86MonBrightnessUp", hl.dsp.exec_cmd(brightness_script .. " max"))
hl.bind(mod .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd(brightness_script .. " min"))

-- Volume (locked = works even when session locked)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume_script .. " up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(volume_script .. " down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(volume_script .. " mute"), { locked = true, repeating = true })
hl.bind(mod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume_script .. " max"), { locked = true, repeating = true })
hl.bind(mod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd(volume_script .. " min"), { locked = true, repeating = true })

-- Media (Spotify)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl -p spotify previous"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl -p spotify play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl -p spotify next"))
hl.bind(mod .. " + SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl -p spotify volume 0.1+"))
hl.bind(mod .. " + SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl -p spotify volume 0.1-"))

hl.bind(mod .. "+ CONTROL + 0", hl.dsp.exec_cmd("wlogout -s"))

-- Screenshots
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("grim - | satty --filename -"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename -'))

-- Color picker
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Focus (arrows + hjkl)
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + j", hl.dsp.focus({ direction = "down" }))

-- `group_aware = true` routes to the moveWindowOrGroup dispatcher
-- (equivalent to hyprlang's `movewindoworgroup`): moves the window in
-- that direction, or pulls it into an adjacent group if one exists.
hl.bind(mod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left", group_aware = true }))
hl.bind(mod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right", group_aware = true }))
hl.bind(mod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up", group_aware = true }))
hl.bind(mod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down", group_aware = true }))

-- Workspaces 1..9
for i = 1, 9 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Workspace nav
hl.bind(mod .. " + N", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + CONTROL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + P", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CONTROL + left", hl.dsp.focus({ workspace = "e-1" }))

-- fullscreen_state takes integers for internal/client (0=none, 1=maximize,
-- 2=fullscreen, 3=both) and action = "toggle"|"set"|"unset". Hyprlang's
-- `fullscreen, 1` is a toggle of maximize.
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 1, client = 1, action = "toggle" }))

-- Special workspaces
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }))

hl.bind(mod .. " + equal", hl.dsp.workspace.toggle_special("equal"))
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.move({ workspace = "special:equal" }))

hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("minus"))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:minus" }))

-- Scroll-wheel workspace switching
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse drag move/resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- HyprMod managed settings (left disabled; same as before)
-- require("hyprland-gui")
