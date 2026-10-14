script_name('Farm Bot Remastered')
script_author('kopnev')
script_version('1.5')
script_version_number(1.5)

local se = require 'samp.events'
local sampev   = require 'lib.samp.events'
local inicfg   = require 'inicfg'
local imgui   = require 'imgui'
local simgui = require 'mimgui'
local notf = import 'lib/imgui_notf.lua'
local imadd    = require 'imgui_addons'
local effil    = require 'effil'
local memory   = require 'memory'
local rkeys    = require 'rkeys'
local vkeys    = require 'vkeys'
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8
local fa = require 'fAwesome5'
local updateid
local ffi = require('ffi')
local json = require("dkjson")

ffi.cdef [[
    typedef int BOOL;
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef int bInvert;

    HWND GetActiveWindow(void);
    BOOL FlashWindow(HWND hWnd, BOOL bInvert);
    BOOL ShowWindow(HWND hWnd, BOOL bInvert);
]]

local control = {
    warningseytg = imgui.ImBool(false),
    telegramNotf = imgui.ImBool(false),
    reversal = imgui.ImBool(false),
    blinking = imgui.ImBool(false),
    autoExit = imgui.ImBool(false),
    autoOff = imgui.ImBool(true),
    skipdialog = imgui.ImBool(false),
    warningsey = imgui.ImBool(false),
    skip1 = imgui.ImInt(1250),
    skip2 = imgui.ImInt(1500),
    lowhp = imgui.ImBool(false),
    golodhelp = imgui.ImBool(false),
    tractorNotify = imgui.ImBool(false),
    zastryal = imgui.ImBool(false),
    flash = imgui.ImInt(1)
}

local vars = {
    lastVehicleSended = -1,
    trailerSync = false,
    route = {
        state = false,
        name = '',
        packets = 0,
        currentPos = {
            x = -1, y = -1, z = -1
        },
        trailerId = -1,
        count = 0
    }
}

local rpcs = {
    [26] = {'int16', 'bool'},
    [50] = {'int32', 'string'},
    [83] = {'int16'},
    [101] = {'int16', 'string'},
    [106] = {'int16', 'int32', 'int32', 'int8', 'int8'},
    [118] = {'int8'},
    [131] = {'int32'},
    [154] = {'int16'},
    [168] = {'int16', 'int16', 'int16', 'int16'},
    [177] = {'bool', 'int16', 'float', 'int32', 'int32'}
}

local loop = simgui.new.bool(false)
local role_idx = imgui.ImInt(0)
local vip_idx = imgui.ImInt(0)
local accessory_idx = imgui.ImInt(0)
local crash = imgui.ImBool(false)
local main_windows_state = imgui.ImBool(false)
local quest_window = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
local loop_window = imgui.ImBool(false)
local changelog_window = imgui.ImBool(false)
local calc_window = imgui.ImBool(false)
local theme9_window = imgui.ImBool(false)
local anniversary_window = imgui.ImBool(false)
local anniversary_open_time = 0
local changelog_ver_idx = imgui.ImInt(5)
local var_0_10 = imgui.ImBool(false)
local var_0_11 = imgui.ImBool(false)

local def = {
    settings = {
        theme = 7,
        style = 1,
        vkladka = 6,
        reload = false,
        reloadR = false,
        post = 0,
        limit = true,
        lim = 30,
        limit1 = true,
        lim1 = 4,
        mode = 0,
        limit2 = false,
        lim2 = 4,
        combineActive = false,
        autoupdate = false,
        autoeat = false,
        eatmethod = 0,
        runenabled = true,
        jumpenabled = false,
        smoothcum = false,
        eatpercent = 20,
        auto = false,
        hidedialog = false,
        bg = false,
        helptext = true,
        autochange = false,
        changeafter = 0,
        invulnerability = false,
        infinitefuel = false,
        infinitefuelengine = false,
        collision = false,
        faedit = false,
        invisible = false,
        autofarmzov = false,
        activationCommand = 'farm',
        customCommand = 'custom',
        statsX = 10,
        statsY = 240,
        selectedRoute = 0,
        selectedAircraft = 0,
        anniversaryShown = false
    },
    Telegram = {
        chat_id = '',
        token = '',
        warningseytg = false
    },
    AntiAdmin = {
        skip11 = 1250,
        skip22 = 1500,
        telegramNotf = false,
        reversal = false,
        blinking = false,
        autoExit = false,
        autoOff = true,
        skipdialog = false,
        warningsey = false,
        lowhp = false,
        golodhelp = false,
        tractorNotify = false,
        zastryal = false,
        flash = 1
    },
    theme9 = {
        WindowBg_r = 0.96,
        WindowBg_g = 0.84,
        WindowBg_b = 0.89,
        WindowBg_a = 1.00,
        ChildWindowBg_r = 0.98,
        ChildWindowBg_g = 0.87,
        ChildWindowBg_b = 0.91,
        ChildWindowBg_a = 0.50,
        PopupBg_r = 0.80,
        PopupBg_g = 0.60,
        PopupBg_b = 0.73,
        PopupBg_a = 0.90,
        Border_r = 1.00,
        Border_g = 0.80,
        Border_b = 0.88,
        Border_a = 0.30,
        BorderShadow_r = 0.00,
        BorderShadow_g = 0.00,
        BorderShadow_b = 0.00,
        BorderShadow_a = 0.00,
        FrameBg_r = 0.95,
        FrameBg_g = 0.75,
        FrameBg_b = 0.85,
        FrameBg_a = 1.00,
        FrameBgHovered_r = 1.00,
        FrameBgHovered_g = 0.65,
        FrameBgHovered_b = 0.80,
        FrameBgHovered_a = 0.68,
        FrameBgActive_r = 1.00,
        FrameBgActive_g = 0.65,
        FrameBgActive_b = 0.80,
        FrameBgActive_a = 1.00,
        TitleBg_r = 0.90,
        TitleBg_g = 0.70,
        TitleBg_b = 0.80,
        TitleBg_a = 0.45,
        TitleBgCollapsed_r = 0.90,
        TitleBgCollapsed_g = 0.70,
        TitleBgCollapsed_b = 0.80,
        TitleBgCollapsed_a = 0.35,
        TitleBgActive_r = 0.90,
        TitleBgActive_g = 0.70,
        TitleBgActive_b = 0.80,
        TitleBgActive_a = 0.78,
        MenuBarBg_r = 0.95,
        MenuBarBg_g = 0.75,
        MenuBarBg_b = 0.85,
        MenuBarBg_a = 0.57,
        ScrollbarBg_r = 0.95,
        ScrollbarBg_g = 0.75,
        ScrollbarBg_b = 0.85,
        ScrollbarBg_a = 1.00,
        ScrollbarGrab_r = 0.85,
        ScrollbarGrab_g = 0.55,
        ScrollbarGrab_b = 0.75,
        ScrollbarGrab_a = 0.31,
        ScrollbarGrabHovered_r = 0.85,
        ScrollbarGrabHovered_g = 0.55,
        ScrollbarGrabHovered_b = 0.75,
        ScrollbarGrabHovered_a = 0.78,
        ScrollbarGrabActive_r = 0.85,
        ScrollbarGrabActive_g = 0.55,
        ScrollbarGrabActive_b = 0.75,
        ScrollbarGrabActive_a = 1.00,
        ComboBg_r = 0.95,
        ComboBg_g = 0.75,
        ComboBg_b = 0.85,
        ComboBg_a = 1.00,
        CheckMark_r = 1.00,
        CheckMark_g = 0.60,
        CheckMark_b = 0.80,
        CheckMark_a = 1.00,
        SliderGrab_r = 0.90,
        SliderGrab_g = 0.65,
        SliderGrab_b = 0.80,
        SliderGrab_a = 0.24,
        SliderGrabActive_r = 0.90,
        SliderGrabActive_g = 0.65,
        SliderGrabActive_b = 0.80,
        SliderGrabActive_a = 1.00,
        Button_r = 0.95,
        Button_g = 0.70,
        Button_b = 0.85,
        Button_a = 0.44,
        ButtonHovered_r = 0.95,
        ButtonHovered_g = 0.70,
        ButtonHovered_b = 0.85,
        ButtonHovered_a = 0.86,
        ButtonActive_r = 1.00,
        ButtonActive_g = 0.60,
        ButtonActive_b = 0.85,
        ButtonActive_a = 1.00,
        Header_r = 0.90,
        Header_g = 0.65,
        Header_b = 0.80,
        Header_a = 0.76,
        HeaderHovered_r = 0.90,
        HeaderHovered_g = 0.65,
        HeaderHovered_b = 0.80,
        HeaderHovered_a = 0.86,
        HeaderActive_r = 0.90,
        HeaderActive_g = 0.65,
        HeaderActive_b = 0.80,
        HeaderActive_a = 1.00,
        ResizeGrip_r = 0.95,
        ResizeGrip_g = 0.75,
        ResizeGrip_b = 0.85,
        ResizeGrip_a = 0.20,
        ResizeGripHovered_r = 0.95,
        ResizeGripHovered_g = 0.75,
        ResizeGripHovered_b = 0.85,
        ResizeGripHovered_a = 0.78,
        ResizeGripActive_r = 0.95,
        ResizeGripActive_g = 0.75,
        ResizeGripActive_b = 0.85,
        ResizeGripActive_a = 1.00,
        CloseButton_r = 1.00,
        CloseButton_g = 0.90,
        CloseButton_b = 0.95,
        CloseButton_a = 0.75,
        CloseButtonHovered_r = 1.00,
        CloseButtonHovered_g = 0.80,
        CloseButtonHovered_b = 0.90,
        CloseButtonHovered_a = 0.59,
        CloseButtonActive_r = 1.00,
        CloseButtonActive_g = 0.80,
        CloseButtonActive_b = 0.90,
        CloseButtonActive_a = 1.00,
        PlotLines_r = 1.00,
        PlotLines_g = 0.85,
        PlotLines_b = 0.90,
        PlotLines_a = 0.63,
        PlotLinesHovered_r = 1.00,
        PlotLinesHovered_g = 0.65,
        PlotLinesHovered_b = 0.80,
        PlotLinesHovered_a = 1.00,
        PlotHistogram_r = 1.00,
        PlotHistogram_g = 0.85,
        PlotHistogram_b = 0.90,
        PlotHistogram_a = 0.63,
        PlotHistogramHovered_r = 1.00,
        PlotHistogramHovered_g = 0.65,
        PlotHistogramHovered_b = 0.80,
        PlotHistogramHovered_a = 1.00,
        TextSelectedBg_r = 0.95,
        TextSelectedBg_g = 0.70,
        TextSelectedBg_b = 0.85,
        TextSelectedBg_a = 0.43,
        ModalWindowDarkening_r = 0.80,
        ModalWindowDarkening_g = 0.60,
        ModalWindowDarkening_b = 0.73,
        ModalWindowDarkening_a = 0.35,
        Text_r = 1.00,
        Text_g = 1.00,
        Text_b = 1.00,
        Text_a = 1.00
    }
}

local directIni = "KopnevScripts\\Farm Bot.ini"
local ini = inicfg.load(def, directIni)
local activationCommand = imgui.ImBuffer(ini.settings.activationCommand, 32)

buffer_token = imgui.ImBuffer(tostring(ini.Telegram.token or ''), 128)
buffer_chatid = imgui.ImBuffer(tostring(ini.Telegram.chat_id or ''), 128)
chat_id = ini.Telegram.chat_id
token = ini.Telegram.token
control.warningseytg = imgui.ImBool(ini.Telegram.warningseytg)
control.skip1 = imgui.ImInt(tonumber(ini.AntiAdmin.skip11) or 1250)
control.skip2 = imgui.ImInt(tonumber(ini.AntiAdmin.skip22) or 1500)
control.telegramNotf = imgui.ImBool(ini.AntiAdmin.telegramNotf)
control.reversal = imgui.ImBool(ini.AntiAdmin.reversal)
control.blinking = imgui.ImBool(ini.AntiAdmin.blinking)
control.autoExit = imgui.ImBool(ini.AntiAdmin.autoExit)
control.autoOff = imgui.ImBool(ini.AntiAdmin.autoOff)
control.skipdialog = imgui.ImBool(ini.AntiAdmin.skipdialog)
control.lowhp = imgui.ImBool(ini.AntiAdmin.lowhp)
control.golodhelp = imgui.ImBool(ini.AntiAdmin.golodhelp)
control.tractorNotify = imgui.ImBool(ini.AntiAdmin.tractorNotify)
control.zastryal = imgui.ImBool(ini.AntiAdmin.zastryal)
control.warningsey = imgui.ImBool(ini.AntiAdmin.warningsey)
control.flash = imgui.ImInt(tonumber(ini.AntiAdmin.flash) or 1)

local theme9_colors = {
    WindowBg = imgui.ImFloat4(ini.theme9.WindowBg_r or 0.96, ini.theme9.WindowBg_g or 0.84, ini.theme9.WindowBg_b or 0.89, ini.theme9.WindowBg_a or 1.00),
    ChildWindowBg = imgui.ImFloat4(ini.theme9.ChildWindowBg_r or 0.98, ini.theme9.ChildWindowBg_g or 0.87, ini.theme9.ChildWindowBg_b or 0.91, ini.theme9.ChildWindowBg_a or 0.50),
    Text = imgui.ImFloat4(ini.theme9.Text_r or 1.0, ini.theme9.Text_g or 1.0, ini.theme9.Text_b or 1.0, ini.theme9.Text_a or 1.0),
    PopupBg = imgui.ImFloat4(ini.theme9.PopupBg_r or 0.80, ini.theme9.PopupBg_g or 0.60, ini.theme9.PopupBg_b or 0.73, ini.theme9.PopupBg_a or 0.90),
    Border = imgui.ImFloat4(ini.theme9.Border_r or 1.00, ini.theme9.Border_g or 0.80, ini.theme9.Border_b or 0.88, ini.theme9.Border_a or 0.30),
    BorderShadow = imgui.ImFloat4(ini.theme9.BorderShadow_r or 0.00, ini.theme9.BorderShadow_g or 0.00, ini.theme9.BorderShadow_b or 0.00, ini.theme9.BorderShadow_a or 0.00),
    FrameBg = imgui.ImFloat4(ini.theme9.FrameBg_r or 0.95, ini.theme9.FrameBg_g or 0.75, ini.theme9.FrameBg_b or 0.85, ini.theme9.FrameBg_a or 1.00),
    FrameBgHovered = imgui.ImFloat4(ini.theme9.FrameBgHovered_r or 1.00, ini.theme9.FrameBgHovered_g or 0.65, ini.theme9.FrameBgHovered_b or 0.80, ini.theme9.FrameBgHovered_a or 0.68),
    FrameBgActive = imgui.ImFloat4(ini.theme9.FrameBgActive_r or 1.00, ini.theme9.FrameBgActive_g or 0.65, ini.theme9.FrameBgActive_b or 0.80, ini.theme9.FrameBgActive_a or 1.00),
    TitleBg = imgui.ImFloat4(ini.theme9.TitleBg_r or 0.90, ini.theme9.TitleBg_g or 0.70, ini.theme9.TitleBg_b or 0.80, ini.theme9.TitleBg_a or 0.45),
    TitleBgCollapsed = imgui.ImFloat4(ini.theme9.TitleBgCollapsed_r or 0.90, ini.theme9.TitleBgCollapsed_g or 0.70, ini.theme9.TitleBgCollapsed_b or 0.80, ini.theme9.TitleBgCollapsed_a or 0.35),
    TitleBgActive = imgui.ImFloat4(ini.theme9.TitleBgActive_r or 0.90, ini.theme9.TitleBgActive_g or 0.70, ini.theme9.TitleBgActive_b or 0.80, ini.theme9.TitleBgActive_a or 0.78),
    MenuBarBg = imgui.ImFloat4(ini.theme9.MenuBarBg_r or 0.95, ini.theme9.MenuBarBg_g or 0.75, ini.theme9.MenuBarBg_b or 0.85, ini.theme9.MenuBarBg_a or 0.57),
    ScrollbarBg = imgui.ImFloat4(ini.theme9.ScrollbarBg_r or 0.95, ini.theme9.ScrollbarBg_g or 0.75, ini.theme9.ScrollbarBg_b or 0.85, ini.theme9.ScrollbarBg_a or 1.00),
    ScrollbarGrab = imgui.ImFloat4(ini.theme9.ScrollbarGrab_r or 0.85, ini.theme9.ScrollbarGrab_g or 0.55, ini.theme9.ScrollbarGrab_b or 0.75, ini.theme9.ScrollbarGrab_a or 0.31),
    ScrollbarGrabHovered = imgui.ImFloat4(ini.theme9.ScrollbarGrabHovered_r or 0.85, ini.theme9.ScrollbarGrabHovered_g or 0.55, ini.theme9.ScrollbarGrabHovered_b or 0.75, ini.theme9.ScrollbarGrabHovered_a or 0.78),
    ScrollbarGrabActive = imgui.ImFloat4(ini.theme9.ScrollbarGrabActive_r or 0.85, ini.theme9.ScrollbarGrabActive_g or 0.55, ini.theme9.ScrollbarGrabActive_b or 0.75, ini.theme9.ScrollbarGrabActive_a or 1.00),
    ComboBg = imgui.ImFloat4(ini.theme9.ComboBg_r or 0.95, ini.theme9.ComboBg_g or 0.75, ini.theme9.ComboBg_b or 0.85, ini.theme9.ComboBg_a or 1.00),
    CheckMark = imgui.ImFloat4(ini.theme9.CheckMark_r or 1.00, ini.theme9.CheckMark_g or 0.60, ini.theme9.CheckMark_b or 0.80, ini.theme9.CheckMark_a or 1.00),
    SliderGrab = imgui.ImFloat4(ini.theme9.SliderGrab_r or 0.90, ini.theme9.SliderGrab_g or 0.65, ini.theme9.SliderGrab_b or 0.80, ini.theme9.SliderGrab_a or 0.24),
    SliderGrabActive = imgui.ImFloat4(ini.theme9.SliderGrabActive_r or 0.90, ini.theme9.SliderGrabActive_g or 0.65, ini.theme9.SliderGrabActive_b or 0.80, ini.theme9.SliderGrabActive_a or 1.00),
    Button = imgui.ImFloat4(ini.theme9.Button_r or 0.95, ini.theme9.Button_g or 0.70, ini.theme9.Button_b or 0.85, ini.theme9.Button_a or 0.44),
    ButtonHovered = imgui.ImFloat4(ini.theme9.ButtonHovered_r or 0.95, ini.theme9.ButtonHovered_g or 0.70, ini.theme9.ButtonHovered_b or 0.85, ini.theme9.ButtonHovered_a or 0.86),
    ButtonActive = imgui.ImFloat4(ini.theme9.ButtonActive_r or 1.00, ini.theme9.ButtonActive_g or 0.60, ini.theme9.ButtonActive_b or 0.85, ini.theme9.ButtonActive_a or 1.00),
    Header = imgui.ImFloat4(ini.theme9.Header_r or 0.90, ini.theme9.Header_g or 0.65, ini.theme9.Header_b or 0.80, ini.theme9.Header_a or 0.76),
    HeaderHovered = imgui.ImFloat4(ini.theme9.HeaderHovered_r or 0.90, ini.theme9.HeaderHovered_g or 0.65, ini.theme9.HeaderHovered_b or 0.80, ini.theme9.HeaderHovered_a or 0.86),
    HeaderActive = imgui.ImFloat4(ini.theme9.HeaderActive_r or 0.90, ini.theme9.HeaderActive_g or 0.65, ini.theme9.HeaderActive_b or 0.80, ini.theme9.HeaderActive_a or 1.00),
    ResizeGrip = imgui.ImFloat4(ini.theme9.ResizeGrip_r or 0.95, ini.theme9.ResizeGrip_g or 0.75, ini.theme9.ResizeGrip_b or 0.85, ini.theme9.ResizeGrip_a or 0.20),
    ResizeGripHovered = imgui.ImFloat4(ini.theme9.ResizeGripHovered_r or 0.95, ini.theme9.ResizeGripHovered_g or 0.75, ini.theme9.ResizeGripHovered_b or 0.85, ini.theme9.ResizeGripHovered_a or 0.78),
    ResizeGripActive = imgui.ImFloat4(ini.theme9.ResizeGripActive_r or 0.95, ini.theme9.ResizeGripActive_g or 0.75, ini.theme9.ResizeGripActive_b or 0.85, ini.theme9.ResizeGripActive_a or 1.00),
    CloseButton = imgui.ImFloat4(ini.theme9.CloseButton_r or 1.00, ini.theme9.CloseButton_g or 0.90, ini.theme9.CloseButton_b or 0.95, ini.theme9.CloseButton_a or 0.75),
    CloseButtonHovered = imgui.ImFloat4(ini.theme9.CloseButtonHovered_r or 1.00, ini.theme9.CloseButtonHovered_g or 0.80, ini.theme9.CloseButtonHovered_b or 0.90, ini.theme9.CloseButtonHovered_a or 0.59),
    CloseButtonActive = imgui.ImFloat4(ini.theme9.CloseButtonActive_r or 1.00, ini.theme9.CloseButtonActive_g or 0.80, ini.theme9.CloseButtonActive_b or 0.90, ini.theme9.CloseButtonActive_a or 1.00),
    PlotLines = imgui.ImFloat4(ini.theme9.PlotLines_r or 1.00, ini.theme9.PlotLines_g or 0.85, ini.theme9.PlotLines_b or 0.90, ini.theme9.PlotLines_a or 0.63),
    PlotLinesHovered = imgui.ImFloat4(ini.theme9.PlotLinesHovered_r or 1.00, ini.theme9.PlotLinesHovered_g or 0.65, ini.theme9.PlotLinesHovered_b or 0.80, ini.theme9.PlotLinesHovered_a or 1.00),
    PlotHistogram = imgui.ImFloat4(ini.theme9.PlotHistogram_r or 1.00, ini.theme9.PlotHistogram_g or 0.85, ini.theme9.PlotHistogram_b or 0.90, ini.theme9.PlotHistogram_a or 0.63),
    PlotHistogramHovered = imgui.ImFloat4(ini.theme9.PlotHistogramHovered_r or 1.00, ini.theme9.PlotHistogramHovered_g or 0.65, ini.theme9.PlotHistogramHovered_b or 0.80, ini.theme9.PlotHistogramHovered_a or 1.00),
    TextSelectedBg = imgui.ImFloat4(ini.theme9.TextSelectedBg_r or 0.95, ini.theme9.TextSelectedBg_g or 0.70, ini.theme9.TextSelectedBg_b or 0.85, ini.theme9.TextSelectedBg_a or 0.43),
    ModalWindowDarkening = imgui.ImFloat4(ini.theme9.ModalWindowDarkening_r or 0.80, ini.theme9.ModalWindowDarkening_g or 0.60, ini.theme9.ModalWindowDarkening_b or 0.73, ini.theme9.ModalWindowDarkening_a or 0.35)

}
local faedit = imgui.ImBool(ini.settings.faedit)
local faico = faedit.v
if faico then
    fa = require 'fAwesome5'
    fa_font = nil
    fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
end

local runEnabled = imgui.ImBool(ini.settings.runenabled)
local jumpEnabled = imgui.ImBool(ini.settings.jumpenabled)
local smoothcumpenis228 = imgui.ImBool(ini.settings.smoothcum)
local autoupdate_checkbox = imgui.ImBool(ini.settings.autoupdate)
local var_collision = imgui.ImBool(ini.settings.collision or false)
local autofarmzov = imgui.ImBool(ini.settings.autofarmzov or false)
local style = imgui.ImInt(ini.settings.style)
local tema = imgui.ImInt(ini.settings.theme)
local post = imgui.ImInt(ini.settings.post)
local limit = imgui.ImBool(ini.settings.limit)
local lim = imgui.ImInt(ini.settings.lim)
local helptext = imgui.ImBool(ini.settings.helptext)
local limit1 = imgui.ImBool(ini.settings.limit1)
local lim1 = imgui.ImInt(ini.settings.lim1)
local autochange = imgui.ImBool(ini.settings.autochange)
local changeafter = imgui.ImInt(ini.settings.changeafter)
local invisible = imgui.ImBool(ini.settings.invisible)
local selectedRoute = imgui.ImInt(ini.settings.selectedRoute)
local auto = imgui.ImBool(ini.settings.auto)
local bg = imgui.ImBool(ini.settings.bg)
local var_0_12 = imgui.ImBool(ini.settings.infinitefuelengine)
var_0_11.v = ini.settings.infinitefuel or false
local hidedildos = imgui.ImBool(ini.settings.hidedialog or false)

value1 = 0
work = false
work1 = false
work2 = false
work3 = false
ww = false
gopay = false
zdorov = false
gou = false
num = 0
gonew = false
paused = false
pipiska = true
yasel = false
sentkyky = false

local questsTakenByBot = true
local lastCheckpoint = nil
local lowhpsent = false
local tractorsent = false
local waitingForStatsTelegram = false
local findGameActive = false
local lowgolod = false
local findGameTimer = 0
local resendInterval = 5000
local scenarioText = nil
local noCollisionObjects = {3276, 19300, 12756, 12918, 3374, 1333, 3594, 1332, 1333, 1334, 1331, 3168, 3172, 3171, 14032, 14034, 12029}
local turnRight = false
local turnLeft = false
local infengine = false
local vehicleFuelLiters = -1
local walking = false
local state = false
local state_taked = false
local state_harvest = false
local wheat_dist = 1.5
local step = {200, 400}
local currentCameraAngle = 0
local lerpSpeed = 0.05
local currentQuest = 0
local maxQuests = 5
local questProgress = {0,0,0,0,0}
local questMax = {15,2,2,1,0}

local kukGuide = {
    active = false,
    pos = {x = 126.76991271973, y = -46.166500091553, z = 1.8315945863724},
    pulse = 0,
    alpha = 0,
    screenX = -1,
    screenY = -1,
    dist = 9999,
    onScreen = false,
}

local kukGuideSkins = {
    [31] = true, [33] = true, [34] = true, [38] = true, [64] = true,
    [132] = true, [133] = true, [157] = true, [158] = true, [161] = true,
    [196] = true, [198] = true, [201] = true, [202] = true,
}

local function kukGuideShouldShow()
    if vars.route.state then return false end
    local skin = getCharModel(PLAYER_PED)
    if not kukGuideSkins[skin] then return false end
    if not isCharInAnyCar(PLAYER_PED) then return false end
    local veh = getCarCharIsUsing(PLAYER_PED)
    if not doesVehicleExist(veh) then return false end
    return getCarModel(veh) == 512
end

lua_thread.create(function()
    while true do
        wait(0)
        local show = kukGuideShouldShow()
        if show then
            kukGuide.active = true
            kukGuide.alpha = math.min(1, kukGuide.alpha + 0.08)
        else
            kukGuide.alpha = math.max(0, kukGuide.alpha - 0.1)
            if kukGuide.alpha <= 0.01 then
                kukGuide.active = false
                kukGuide.onScreen = false
            end
        end
        kukGuide.pulse = kukGuide.pulse + 0.07
        if kukGuide.pulse > math.pi * 2 then kukGuide.pulse = kukGuide.pulse - math.pi * 2 end
        if kukGuide.alpha > 0.01 then
            local px, py, pz = getCharCoordinates(PLAYER_PED)
            if isCharInAnyCar(PLAYER_PED) then
                local veh = getCarCharIsUsing(PLAYER_PED)
                if doesVehicleExist(veh) then
                    px, py, pz = getCarCoordinates(veh)
                end
            end
            local tx, ty, tz = kukGuide.pos.x, kukGuide.pos.y, kukGuide.pos.z
            kukGuide.dist = getDistanceBetweenCoords3d(px, py, pz, tx, ty, tz)
            local mx, my, mz = tx, ty, tz + 0.6
            local sx, sy = convert3DCoordsToScreen(mx, my, mz)
            local resX, resY = getScreenResolution()
            local inFront = false
            local okOnScreen, pointVisible = pcall(isPointOnScreen, mx, my, mz, 1.0)
            if okOnScreen and pointVisible then
                inFront = true
            elseif sx and sy and sx > 0 and sy > 0 and sx < resX and sy < resY then
                local camX, camY, camZ = getActiveCameraCoordinates()
                local lookX, lookY, lookZ = getActiveCameraPointAt()
                local fx, fy, fz = lookX - camX, lookY - camY, lookZ - camZ
                local fLen = math.sqrt(fx * fx + fy * fy + fz * fz)
                if fLen > 0.01 then
                    fx, fy, fz = fx / fLen, fy / fLen, fz / fLen
                    local toX, toY, toZ = mx - camX, my - camY, mz - camZ
                    local toLen = math.sqrt(toX * toX + toY * toY + toZ * toZ)
                    if toLen > 0.01 then
                        toX, toY, toZ = toX / toLen, toY / toLen, toZ / toLen
                        local dot = toX * fx + toY * fy + toZ * fz
                        inFront = (dot > 0.05)
                    end
                end
            end
            if inFront and sx and sy then
                kukGuide.onScreen = true
                kukGuide.screenX, kukGuide.screenY = sx, sy
                local pulse = (math.sin(kukGuide.pulse) + 1) * 0.5
                local a = math.floor(kukGuide.alpha * 255)
                local function argb(aa, r, g, b)
                    return aa * 0x1000000 + r * 0x10000 + g * 0x100 + b
                end
                local sizes = {28 + pulse * 8, 20 + pulse * 5, 12 + pulse * 3, 6 + pulse * 2}
                local alphas = {
                    math.floor(a * 0.18 * (0.5 + pulse * 0.5)),
                    math.floor(a * 0.28 * (0.5 + pulse * 0.5)),
                    math.floor(a * 0.45),
                    math.floor(a * 0.85)
                }
                for i, sz in ipairs(sizes) do
                    local half = sz / 2
                    local col
                    if i == #sizes then
                        col = argb(alphas[i], 255, 255, 255)
                    else
                        col = argb(alphas[i], 30, 200, 255)
                    end
                    renderDrawBox(sx - half, sy - half, sz, sz, col)
                end
                local ch = 22 + pulse * 6
                local lc = argb(math.floor(a * 0.9), 255, 255, 255)
                local t = 2
                renderDrawBox(sx - ch, sy - t / 2, ch - 8, t, lc)
                renderDrawBox(sx + 8, sy - t / 2, ch - 8, t, lc)
                renderDrawBox(sx - t / 2, sy - ch, t, ch - 8, lc)
                renderDrawBox(sx - t / 2, sy + 8, t, ch - 8, lc)
                local distText = string.format("%.0f m", kukGuide.dist)
            else
                kukGuide.onScreen = false
            end
        end
    end
end)

function drawKukPositionGuide()
    if kukGuide.alpha <= 0.01 then return end

    local dist = kukGuide.dist
    local aMul = kukGuide.alpha
    local pulse = (math.sin(kukGuide.pulse) + 1) * 0.5

    local wf = imgui.WindowFlags
    local flags = 0
    for _, name in ipairs({"NoTitleBar", "NoResize", "NoMove", "NoSavedSettings",
        "NoFocusOnAppearing", "NoNav", "NoNavInputs", "NoNavFocus", "NoScrollbar", "NoScrollWithMouse", "NoInputs"}) do
        if wf[name] then flags = flags + wf[name] end
    end

    local disp = imgui.GetIO().DisplaySize
    local w, h = 380, 100
    local posX, posY = (disp.x - w) / 2, disp.y * 0.10
    local winRound = (ini.settings.style == 1) and 10 or 2

    if imgui.SetNextWindowBgAlpha then
        imgui.SetNextWindowBgAlpha(0.82 * aMul)
    end
    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(w, h), imgui.Cond.Always)
    imgui.Begin("##KukPosGuide", nil, flags)

    local wdl = imgui.GetWindowDrawList()
    local o = imgui.GetWindowPos()

    local function col32(r, g, b, a)
        return math.floor(a) * 0x1000000 + math.floor(b) * 0x10000 + math.floor(g) * 0x100 + math.floor(r)
    end

    wdl:AddRectFilled(imgui.ImVec2(o.x, o.y), imgui.ImVec2(o.x + 5, o.y + h),
        col32(30, 200, 255, aMul * 255), winRound)

    imgui.SetCursorPos(imgui.ImVec2(18, 10))
    imgui.TextColored(imgui.ImVec4(0.15, 0.9, 1.0, aMul),
        u8("\xCF\xEE\xF1\xF2\xE0\xE2\xFC\xF2\xE5\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA"))

    imgui.SetCursorPos(imgui.ImVec2(18, 32))
    if kukGuide.onScreen then
        imgui.TextColored(imgui.ImVec4(1, 1, 1, 0.92 * aMul),
            u8("\xCF\xEE\xE4\xEB\xE5\xF2\xE8\xF2\xE5\x20\xEA\x20\xE3\xEE\xEB\xF3\xE1\xEE\xE9\x20\xF2\xEE\xF7\xEA\xE5\x20\xED\xE0\x20\xFD\xEA\xF0\xE0\xED\xE5"))
    else
        imgui.TextColored(imgui.ImVec4(1, 0.85, 0.4, 0.95 * aMul),
            u8("\xD2\xEE\xF7\xEA\xE0\x20\xE7\xE0\x20\xFD\xEA\xF0\xE0\xED\xEE\xEC\x20\x97\x20\xEF\xEE\xE2\xE5\xF0\xED\xE8\xF2\xE5\x20\xEA\xE0\xEC\xE5\xF0\xF3"))
    end

    imgui.SetCursorPos(imgui.ImVec2(18, 54))
    if dist < 3 then
        imgui.TextColored(imgui.ImVec4(0.25, 1.0, 0.4, aMul),
            u8("\xC3\xEE\xF2\xEE\xE2\xEE\x21\x20\xCC\xEE\xE6\xED\xEE\x20\xE7\xE0\xEF\xF3\xF1\xEA\xE0\xF2\xFC\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2"))
    elseif dist < 15 then
        imgui.TextColored(imgui.ImVec4(1.0, 0.92, 0.3, aMul),
            string.format(u8("\xC4\xEE\x20\xF2\xEE\xF7\xEA\xE8\x3A\x20%.0f \xEC  \xB7  \xCF\xEE\xF7\xF2\xE8\x20\xE1\xEB\xE8\xE6\xE5"), dist))
    else
        imgui.TextColored(imgui.ImVec4(1.0, 0.55, 0.3, aMul),
            string.format(u8("\xC4\xEE\x20\xF2\xEE\xF7\xEA\xE8\x3A\x20%.0f \xEC  \xB7  \xCB\xE5\xF2\xE8\xF2\xE5\x20\xEA\x20\xEC\xE0\xF0\xEA\xE5\xF0\xF3"), dist))
    end

    imgui.SetCursorPos(imgui.ImVec2(18, 76))
    imgui.TextColored(imgui.ImVec4(0.65, 0.72, 0.82, 0.75 * aMul),
        u8("\xCC\xE0\xF0\xEA\xE5\xF0\x20\xE8\xF1\xF7\xE5\xE7\xED\xE5\xF2\x20\xEF\xF0\xE8\x20\xE7\xE0\xEF\xF3\xF1\xEA\xE5\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0"))

    wdl:AddRect(imgui.ImVec2(o.x, o.y), imgui.ImVec2(o.x + w, o.y + h),
        col32(255, 255, 255, aMul * 70), winRound)

    imgui.End()
end

local farmStats = {
    earned = 0,
    skill = 0,
    skillMax = 7000,
    showHud = true,
    hovered = false,
    hoveredPrev = false,
    posDirty = false,
    posTimer = 0
}

local satiety
local autoeat = imgui.ImBool(ini.settings.autoeat)
local eatmethod = imgui.ImInt(ini.settings.eatmethod)
local eatpercent = imgui.ImInt(ini.settings.eatpercent)
local method = {
    u8("\xD7\xE8\xEF\xF1\xFB"),
    u8("\xD0\xFB\xE1\xE0"),
    u8("\xCE\xEB\xE5\xED\xE8\xED\xE0"),
    u8("\xCC\xE5\xF8\xEE\xEA\x20\xF1\x20\xEC\xFF\xF1\xEE\xEC"),
    u8("\xC5\xE4\xE0\x20\xF1\x20\xF5\xEE\xEB\xEE\xE4\xE8\xEB\xFC\xED\xE8\xEA\xE0"),
    u8("\xC5\xE4\xE0\x20\xF1\x20\xF1\xE5\xEC\xE5\xE9\xED\xEE\xE9\x20\xEA\xE2\xE0\xF0\xF2\xE8\xF0\xFB")
}

local vkladki = {
    false,
	false,
	false,
	false,
	false,
	false,
    false,
    false
}

vkladki[ini.settings.vkladka] = true

local items = {
	u8("\xD2\xB8\xEC\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD1\xE8\xED\xE8\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xCA\xF0\xE0\xF1\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xC3\xEE\xEB\xF3\xE1\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xC7\xE5\xEB\xB8\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xCE\xF0\xE0\xED\xE6\xE5\xE2\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD4\xE8\xEE\xEB\xE5\xF2\xEE\xE2\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD2\xB8\xEC\xED\xEE\x2D\xF1\xE2\xE5\xF2\xEB\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
    u8("\xCA\xE0\xF1\xF2\xEE\xEC\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0")
}

local styles = {
	u8("\xD1\xF2\xF0\xEE\xE3\xE8\xE9"),
	u8("\xCC\xFF\xE3\xEA\xE8\xE9")
}

local posts = {
	u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xFB\xE9\x20\xF4\xE5\xF0\xEC\xE5\xF0"),
	u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2"),
	u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0"),
    u8("\xC2\xEE\xE4\xE8\xF2\xE5\xEB\xFC\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0")
}

--------------------------------------------MAIN--------------------------------------------------
function goupdate(enable_autoupdate)
    gou = false
    if not enable_autoupdate then return end
    local autoupdate_loaded = false
    local Update = nil

    local updater_loaded, Updater = pcall(loadstring, [[return {
        check = function(json_url, prefix, fallback_url)
            local d = require('moonloader').download_status
            local e = os.tmpname()
            local f = os.clock()
            if doesFileExist(e) then os.remove(e) end
            downloadUrlToFile(json_url, e, function(g,h,i,j)
                if h == d.STATUSEX_ENDDOWNLOAD then
                    if doesFileExist(e) then
                        local k = io.open(e,'r')
                        if k then
                            local l = decodeJson(k:read('*a'))
                            local updatelink = l.updateurl
                            local updateversion = l.latest
                            k:close()
                            os.remove(e)
                            if updateversion ~= thisScript().version then
                                lua_thread.create(function()
                                    local m = -1
                                    SCM(prefix .. ("\xCE\xE1\xED\xE0\xF0\xF3\xE6\xE5\xED\xEE\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x2E\x20\xCF\xFB\xF2\xE0\xFE\xF1\xFC\x20\xEE\xE1\xED\xEE\xE2\xE8\xF2\xFC\xF1\xFF\x20\xF1\x20") .. thisScript().version .. ("\x20\xED\xE0\x20") .. updateversion, m)
                                    wait(250)
                                    downloadUrlToFile(updatelink, thisScript().path, function(n,o,p,q)
                                        if o == d.STATUS_DOWNLOADINGDATA then
                                            print(string.format(("\xC7\xE0\xE3\xF0\xF3\xE6\xE5\xED\xEE\x20\x25\x64\x20\xE8\xE7\x20\x25\x64\x2E"), p, q))
                                        elseif o == d.STATUS_ENDDOWNLOADDATA then
                                            print(("\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xE0\x2E"))
                                            SCM(prefix .. ("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xEE\x21"), m)
                                            lua_thread.create(function() wait(500) thisScript():reload() end)
                                        end
                                    end)
                                end)
                            else
                                print(prefix .. ("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xED\xE5\x20\xF2\xF0\xE5\xE1\xF3\xE5\xF2\xF1\xFF\x2E"))
                            end
                        end
                    end
                else
                    print(prefix .. ("\xCD\xE5\x20\xF3\xE4\xE0\xEB\xEE\xF1\xFC\x20\xEF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x2E\x20\xCF\xF0\xEE\xE2\xE5\xF0\xFC\xF2\xE5\x20\xE2\xF0\xF3\xF7\xED\xF3\xFE\x3A\x20") .. fallback_url)
                end
            end)
        end
    }]])

    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/flupiflufi1/FarmbotRemastered/refs/heads/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/flupiflufi1/FarmbotRemastered"
        end
    end

    return autoupdate_loaded, Update
end
local enable_autoupdate = ini.settings.autoupdate
local autoupdate_loaded, Update = goupdate(enable_autoupdate)
function update()
    if not autoupdate_loaded and ini.settings.autoupdate then
        autoupdate_loaded, Update = goupdate(true)
    end
    if autoupdate_loaded and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    else
        SCM(("\xC0\xE2\xF2\xEE\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xED\xE5\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\xEE\x2E"), -1)
    end
end

function ensureVehicleEngine()
    if not isCharInAnyCar(PLAYER_PED) then return end
    local veh = getCarCharIsUsing(PLAYER_PED)
    if not doesVehicleExist(veh) then return end
    if isCarEngineOn(veh) then return end
    local liters = vehicleFuelLiters
    if liters == 0 then
        if var_0_12.v or var_0_11.v then
            var_0_11.v = true
            infengine = true
            ini.settings.infinitefuel = true
            setCarEngineOn(veh, true)
            SCM(("\xD2\xEE\xEF\xEB\xE8\xE2\xE0\x20\xED\xE5\xF2\x20\x97\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\xEE\x20\xE1\xE5\xF1\xEA\xEE\xED\xE5\xF7\xED\xEE\xE5\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
            sendTelegramNotification(("\xD2\xEE\xEF\xEB\xE8\xE2\xE0\x20\xED\xE5\xF2\x20\x97\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\xEE\x20\xE1\xE5\xF1\xEA\xEE\xED\xE5\xF7\xED\xEE\xE5\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
        else
            SCM(("\xD2\xEE\xEF\xEB\xE8\xE2\xE0\x20\xED\xE5\xF2\x20\x97\x20\xE7\xE0\xEF\xF0\xE0\xE2\xFC\xF2\xE5\x20\xE8\xEB\xE8\x20\xE2\xEA\xEB\xFE\xF7\xE8\xF2\xE5\x20\xE0\xE2\xF2\xEE\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
        end
        return
    end
    sampSendChat('/engine')
end

function main()
    math.randomseed(os.time())
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    getLastUpdate()
    hwin = ffi.C.GetActiveWindow()
    sampRegisterChatCommand("farm", function()
        main_windows_state.v = not main_windows_state.v
    end)
    lua_thread.create(warning)
    lua_thread.create(warning2)
    lua_thread.create(get_telegram_updates)

    sampRegisterChatCommand(ini.settings.customCommand, function()
        main_windows_state.v = not main_windows_state.v
    end)
    if ini.settings.reload == true then
		SCM(("\xD3\xF1\xEF\xE5\xF8\xED\xEE\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xEE\x20\xE8\x20\xEF\xF0\xE8\xEC\xE5\xED\xE5\xED\xEE\x2E"))
		main_windows_state.v = true
		ini.settings.reload = false
		inicfg.save(def, directIni)
	end
    if ini.settings.reloadR == true then
		ini.settings.reloadR = false
		inicfg.save(def, directIni)
    end

    SCM(("\xD1\xEA\xF0\xE8\xEF\xF2\x20\xE7\xE0\xE3\xF0\xF3\xE6\xE5\xED\x2E\x20\xC0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xFF\x3A\x20\x7B\x46\x31\x43\x42\x30\x39\x7D\x2F\x66\x61\x72\x6D"))
    update()
    lua_thread.create(renderInfoBar)
    lua_thread.create(routePlayBack)
    X,Y = getScreenResolution()
    while true do
        wait(0)
        if main_windows_state.v then
            if not ini.settings.anniversaryShown then
                if not anniversary_window.v then
                    anniversary_open_time = os.clock()
                end
                anniversary_window.v = true
            end
        end
        imgui.Process = main_windows_state.v or crash.v or quest_window.v or calc_window.v or anniversary_window.v or (farmStats.showHud and (state or work1 or work2 or work3 or farmStats.earned > 0 or farmStats.skill > 0)) or (kukGuide.alpha > 0.01)
        if farmStats.posDirty and (os.clock() - farmStats.posTimer) > 1 then
            inicfg.save(def, directIni)
            farmStats.posDirty = false
        end

		if state then
			EngineWork()
		end
        if gou == true then
            goupdate()
        end
        if questActive then
            setGameKeyState(21, 255)
            wait(50)
            setGameKeyState(21, 0)
            wait(50)
        end
        if bg.v == true then
            WorkInBackground(true)
        else
            WorkInBackground(false)
        end
        if isCharInAnyCar(PLAYER_PED) then
            local vehicle = getCarCharIsUsing(PLAYER_PED)

            setCarProofs(vehicle, var_0_10.v, var_0_10.v, var_0_10.v, var_0_10.v, var_0_10.v)
            if (var_0_12.v or var_0_11.v) and vehicleFuelLiters == 0 then
                infengine = true
                var_0_11.v = true
                ini.settings.infinitefuel = true
            end
            if var_0_11.v and vehicleFuelLiters == 0 then
                setCarEngineOn(vehicle, true)
            end
        end
        if work2 then
            toggleNoCollisionObjects(false)
        end
        if control.skipdialog.v then
            dialogskip = math.random(control.skip1.v, control.skip2.v)
        end
        if satiety and autoeat.v then
            if satiety <= eatpercent.v then
                if eatmethod.v == 0 then
                    sampSendChat('/cheeps')
                    wait(3500)
                elseif eatmethod.v == 1 then
                    sampSendChat('/jfish')
                    wait(3500)
                elseif eatmethod.v == 2 then
                    sampSendChat('/jmeat')
                    wait(3500)
                elseif eatmethod.v == 3 then
                    sampSendChat('/meatbag')
                    wait(3500)
                elseif eatmethod.v == 4 then
                    sampSendChat('/home')
                    wait(900)
                    sampSendDialogResponse(7238, 1, 0, false)
                    wait(900)
                    sampSendDialogResponse(174, 1, 1, false)
                    wait(900)
                    sampSendDialogResponse(2431, 1, 2, false)
                    wait(900)
                    sampSendDialogResponse(185, 1, 6, false)
                    sampCloseCurrentDialogWithButton(0)
                elseif eatmethod.v == 5 then
                    EmulateKey(1024, false)
                    wait(100)
                    EmulateKey(1024, true)
                    wait(900)
                    sampSendDialogResponse(1825, 1, 6, false)
                end
            end
        end
    end
end

local cyrlo = {}
for i = 0, 31 do cyrlo[string.char(192 + i)] = string.char(224 + i) end
cyrlo[string.char(168)] = string.char(184)

function string.nlower(s)
    s = s:lower()
    return (s:gsub('[%z\1-\255]', cyrlo))
end

function set_camera_direction(point)
	local c_pos_x, c_pos_y, c_pos_z = getActiveCameraCoordinates()
	local vect = {x = point[1] - c_pos_x, y = point[2] - c_pos_y, z = point[3] - c_pos_z}
	local ax = math.atan2(vect.y, -vect.x, vect.z)
    local pitch_offset
    if not state_harvest then
	    pitch_offset = -0.1
    else
        pitch_offset = 0
    end
	setCameraPositionUnfixed(pitch_offset, -ax)
end

function GetNearWheat(wheat)
    local table, dist
    for i, k in pairs(wheat) do
        if (not k.peds or (k.dist < wheat_dist and state_harvest)) and (table == nil or k.dist < dist) then
            table, dist = k, k.dist
        end
    end
    return table
end

function WalkEngine(bool)
    state_harvest = false
    setGameKeyState(1, -255)
    walking = bool
    if bool then
        if getCharSpeed(PLAYER_PED) > 4 and math.random(150) == 1 then
            setGameKeyState(16, runEnabled.v and 0)
            setGameKeyState(14, jumpEnabled.v and 255)
        else
            setGameKeyState(14, jumpEnabled.v and 0)
            setGameKeyState(16, runEnabled.v and 255)
        end
    end
end

function EngineWork()
    local x, y, z = getCharCoordinates(PLAYER_PED)

    if not state_taked then
        local wheat_list = {}
        for id = 0, 2047 do
            if sampIs3dTextDefined(id) then
                local str, col, x1, y1, z1 = sampGet3dTextInfoById(id)
                if str:find(("\xCA\xF3\xF1\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xE5")) then
                    table.insert(wheat_list, {
                        id = id,
                        x = x1, y = y1, z = z1,
                        peds = findAllRandomCharsInSphere(x1, y1, z1, 3, false, true),
                        dist = getDistanceBetweenCoords3d(x, y, z, x1, y1, z1)
                    })
                end
            end
        end

        if #wheat_list == 0 then return end
        local wheat = GetNearWheat(wheat_list)
        if not current_cam_angle then current_cam_angle = 0.0 end
        local target_angle = math.deg(math.atan2(wheat.y - y, wheat.x - x))
        local angle_diff = (target_angle - current_cam_angle + 180) % 360 - 180
        local smooth_factor
        if wheat.dist < 4.0 then
            smooth_factor = 1.0
        else
            smooth_factor = 0.12 * (1 - math.exp(-wheat.dist / 20))
        end
        current_cam_angle = current_cam_angle + angle_diff * smooth_factor
        current_cam_angle = (current_cam_angle + 360) % 360
        local cam_dist = 1.0
        local camX = x + math.cos(math.rad(current_cam_angle)) * cam_dist
        local camY = y + math.sin(math.rad(current_cam_angle)) * cam_dist
        local camZ = z - 10.0
        if ini.settings.smoothcum then
            set_camera_direction({camX, camY, camZ})
        else
            setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(wheat.x-x, wheat.y-y))+4.7)
        end
        if wheat.dist > wheat_dist * 3 then
            WalkEngine(true)
        else
            WalkEngine(false)
        end
        if not state_harvest and sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 163 then
            state_harvest = true
        end
    else
        local x1, y1, z1 = -105.60591125488, 100.61192321777, 3.1171875
        local dist = getDistanceBetweenCoords3d(x, y, z, x1, y1, z1)
        if dist > 1.5 then
            local target_angle = math.deg(math.atan2(y1 - y, x1 - x))
            local angle_diff = (target_angle - current_cam_angle + 180) % 360 - 180
            local smooth_factor = (dist < 2.0) and 1.0 or 0.12 * (1 - math.exp(-dist / 20))
            current_cam_angle = current_cam_angle + angle_diff * smooth_factor
            current_cam_angle = (current_cam_angle + 360) % 360

            local camX = x + math.cos(math.rad(current_cam_angle))
            local camY = y + math.sin(math.rad(current_cam_angle))
            local camZ = z - 10.0
            if ini.settings.smoothcum then
                set_camera_direction({camX, camY, camZ})
            else
                setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(x1-x, y1-y))+4.7)
            end
            WalkEngine(true)
        end
    end
end

local function getInNearestTractor()
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    local bestVeh = nil
    local bestDist = 99999
    local vehicles = getAllVehicles()

    for i = 1, #vehicles do
        local veh = vehicles[i]
        if doesVehicleExist(veh) then
            local model = getCarModel(veh)
            if model == 531 then
                local driver = getDriverOfCar(veh)
                if not driver or driver == -1 then
                    if not isCarInWater(veh) then
                        local vx, vy, vz = getCarCoordinates(veh)
                        local dist = getDistanceBetweenCoords3d(myX, myY, myZ, vx, vy, vz)
                        if dist < 40 and dist < bestDist then
                            bestDist = dist
                            bestVeh = veh
                        end
                    end
                end
            end
        end
    end

    if not bestVeh then
        print(("\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xEE\xE2\x20\xED\xE5\xF2\x2C\x20\xE6\xE4\xF3\x20\x33\x20\xF1\xE5\xEA\x2E\x2E\x2E"))
        wait(3000)
        return getInNearestTractor()
    end

    local tx, ty, tz = getCarCoordinates(bestVeh)
    if isCharInAnyCar(PLAYER_PED) then
        local oldCar = getCarCharIsUsing(PLAYER_PED)
        taskLeaveCar(PLAYER_PED, oldCar)
        repeat wait(0) until not isCharInAnyCar(PLAYER_PED)
        wait(800)
    end
    local walk_done = false
    lua_thread.create(function()
        while not walk_done do
            wait(0)
            local x, y, z = getCharCoordinates(PLAYER_PED)
		 setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(tx-x, ty-y))+4.7)
            WalkEngine(true)
        end
    end)
    while true do
        wait(50)
        myX, myY, myZ = getCharCoordinates(PLAYER_PED)
        local distNow = getDistanceBetweenCoords3d(myX, myY, myZ, tx, ty, tz)
        if distNow < 2.4 then
            walk_done = true
            break
        end
        if not doesVehicleExist(bestVeh) then
            walk_done = true
            return getInNearestTractor()
        end
    end
    walk_done = true
    WalkEngine(false)
    wait(500)
    warpCharIntoCar(PLAYER_PED, bestVeh)
    local timer = os.clock()
    while not isCharInCar(PLAYER_PED, bestVeh) do
        wait(0)
        if os.clock() - timer > 6 then
            print(("\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xCD\xE5\x20\xF1\xE5\xEB\x20\x97\x20\xE8\xF9\xF3\x20\xED\xEE\xE2\xFB\xE9\x21"))
            return getInNearestTractor()
        end
    end
    yasel = true
    if control.tractorNotify.v then
        sendTelegramNotification(("\xEF\xEE\xEB\xE5\xF2\xE5\xEB\x20\xF4\xE0\xF0\xEC\xE8\xF2\xFC\x2E\x20\xD1\xE5\xEB\x20\xE2\x20\xED\xEE\xE2\xFB\xE9\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0"))
        tractorsent = true
    else
        tractorsent = false
        yasel = false
    end
    wait(800)
    work1 = true
    gonew = false
    rideTo(-275.32684326172, -105.43254852295, 2.9767985343933, 60, nil, 1)
    rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
end

lua_thread.create(function()
	while true do
		wait(30)
		if isKeyDown(17) and isKeyDown(82) then
			ini.settings.reloadR = true
			inicfg.save(def, directIni)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Anti-Hungry by Vetrayo---------------------------------------------------
------------------------------------------https://www.blast.hk/threads/212472/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------
function EmulateKey(key, isDown)
    local data = samp_create_sync_data('player')
    if not isDown then
        data.keysData = data.keysData
    else
        data.keysData = key
    end
    data.send()
    return
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end
----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------PackedRedorder by xColorized---------------------------------------------------
------------------------------------------https://www.blast.hk/threads/217287/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------
function emulRpc(rpcId, data, send)
    if rpcs[rpcId] then
        local need_data = rpcs[rpcId]
        local bs = raknetNewBitStream()
        if #need_data > 0 then
            if #data == #need_data then
                for i = 1, #need_data do
                    local dataType, insertData = need_data[i], data[i]
                    if dataType == 'int8' then raknetBitStreamWriteInt8(bs, insertData) elseif dataType == 'int16' then raknetBitStreamWriteInt16(bs, insertData)
                    elseif dataType == 'int32' then raknetBitStreamWriteInt32(bs, insertData) elseif dataType == 'bool' then raknetBitStreamWriteBool(bs, insertData)
                    elseif dataType == 'string' then raknetBitStreamWriteString(bs, insertData) elseif dataType == 'float' then raknetBitStreamWriteFloat(bs, insertData)
                    elseif dataType == 'encoded' then raknetBitStreamEncodeString(bs, insertData) end
                end
            end
        end
        if send then raknetSendRpc(rpcId, bs) else raknetEmulRpcReceiveBitStream(rpcId, bs) end
        raknetDeleteBitStream(bs)
        return true
    end
    return false
end

function msg(text)
    if invisible.v then
        print(text)
    else
        sampAddChatMessage('{ffffff}[{F1CB09}Farmbot{ffffff}]: ' .. text, -1)
    end
end

function sendPlayerSync(x, y, z, mx, my, mz, qx, qy, qz, qw, keys, lrk, udk, hp, ar, sk, sact, fDel, loop, lX, lY, fr, ti, reg, animId, flags)
    local data                  = samp_create_sync_data('player')
    data.position               = { tonumber(x), tonumber(y), tonumber(z) }
    data.moveSpeed              = { tonumber(mx), tonumber(my), tonumber(mz) }
    data.quaternion[0]          = tonumber(qx)
    data.quaternion[1]          = tonumber(qy)
    data.quaternion[2]          = tonumber(qz)
    data.quaternion[3]          = tonumber(qw)
    data.keysData               = tonumber(keys)
    data.leftRightKeys          = tonumber(lrk)
    data.upDownKeys             = tonumber(udk)
    data.health                 = getCharHealth(1)
    data.armor                  = getCharArmour(1)
    data.specialKey             = tonumber(sk)
    data.specialAction          = tonumber(sact)
    data.animation = {
                    frameDelta   = tonumber(fDel),
                    id           = tonumber(animId),
                    flags = {loop   = loop == '1',
                    lockX  = lX == '1',
                    lockY  = lY == '1',
                    freeze = fr == '1',
                    time   = tonumber(ti),
                    regular= reg == '1'}
    }
    data.animationId            = tonumber(animId)
    data.animationFlags         = tonumber(flags)
    data.send()
end

function sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, keys, kkeys, upd, lean, trailer, tx, ty, tz, tmx, tmy, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk)
    local data          = samp_create_sync_data('vehicle')
    data.position       = { tonumber(x), tonumber(y), tonumber(z) }
    data.moveSpeed      = { tonumber(mx), tonumber(my), tonumber(mz) }
    data.quaternion[0]  = tonumber(qx)
    data.quaternion[1]  = tonumber(qy)
    data.quaternion[2]  = tonumber(qz)
    data.quaternion[3]  = tonumber(qw)
    data.keysData       = tonumber(keys)
    data.leftRightKeys  = tonumber(kkeys)
    data.upDownKeys     = tonumber(upd)
    data.bikeLean       = tonumber(lean)
    if isCharInAnyCar(1) or vars.lastVehicleSended ~= -1 then
        data.vehicleId  = isCharInAnyCar(1) and select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1))) or vars.lastVehicleSended
    end
    if trailer then
        data.trailerId = trailer
        data.send()
        local sync = samp_create_sync_data('trailer')
        sync.trailerId = trailer
        sync.position = { tonumber(tx), tonumber(ty), tonumber(tz) }
        sync.moveSpeed = { tonumber(tmx), tonumber(tmy), tonumber(tmz) }
        sync.quaternion[0]  = tonumber(tqx)
        sync.quaternion[1]  = tonumber(tqy)
        sync.quaternion[2]  = tonumber(tqz)
        sync.quaternion[3]  = tonumber(tqw)
        sync.turnSpeed = { tonumber(ttx), tonumber(tty), tonumber(ttz) }
        sync.roll = { tonumber(trx), tonumber(try), tonumber(trz) }
        sync.direction = { tonumber(tdx), tonumber(tdy), tonumber(tdz) }
        sync.speed = { tonumber(tsx), tonumber(tsy), tonumber(tsz) }
        sync.unk = tonumber(unk)
        sync.send()
    else
        data.send()
    end
end

local routeHud = {
    shown = 0,
    alpha = 0,
    shimmer = 0
}

function renderInfoBar()
    while true do wait(0)
        if vars.route.state and vars.route.total and vars.route.total > 0 then
            local target = math.min(1, vars.route.packets / vars.route.total)
            routeHud.shown = routeHud.shown + (target - routeHud.shown) * 0.12
            if math.abs(target - routeHud.shown) < 0.001 then routeHud.shown = target end
            routeHud.alpha = math.min(1, routeHud.alpha + 0.08)
        else
            routeHud.shown = 0
            routeHud.alpha = math.max(0, routeHud.alpha - 0.08)
        end
        routeHud.shimmer = routeHud.shimmer + 0.03
        if routeHud.shimmer > 2 then routeHud.shimmer = routeHud.shimmer - 2 end
    end
end
local function formatNumber(num)
    local formatted = tostring(num)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function drawGradientFill(dl, x, y, w, h, rounding, colorA, colorB)
    if w <= 1.5 then return end
    if rounding <= 0.5 then
        dl:AddRectFilledMultiColor(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), colorA, colorB, colorB, colorA)
    elseif w >= rounding * 2 then
        if w - rounding * 2 >= 0.5 then
            dl:AddRectFilledMultiColor(imgui.ImVec2(x + rounding, y), imgui.ImVec2(x + w - rounding, y + h), colorA, colorB, colorB, colorA)
        end
        dl:AddRectFilled(imgui.ImVec2(x, y + rounding), imgui.ImVec2(x + rounding, y + h - rounding), colorA)
        dl:AddCircleFilled(imgui.ImVec2(x + rounding, y + rounding), rounding, colorA, 24)
        dl:AddCircleFilled(imgui.ImVec2(x + rounding, y + h - rounding), rounding, colorA, 24)
        dl:AddRectFilled(imgui.ImVec2(x + w - rounding, y + rounding), imgui.ImVec2(x + w, y + h - rounding), colorB)
        dl:AddCircleFilled(imgui.ImVec2(x + w - rounding, y + rounding), rounding, colorB, 24)
        dl:AddCircleFilled(imgui.ImVec2(x + w - rounding, y + h - rounding), rounding, colorB, 24)
    else
        local rr = math.max(w / 2, 1)
        dl:AddCircleFilled(imgui.ImVec2(x + w / 2, y + h / 2), rr, colorA, 24)
    end
end

function drawRouteHud()
    if routeHud.alpha <= 0.01 then return end
    local wf = imgui.WindowFlags
    local flags = 0
    for _, name in ipairs({"NoTitleBar", "NoResize", "NoMove", "NoSavedSettings",
        "NoFocusOnAppearing", "NoNav", "NoNavInputs", "NoNavFocus", "NoScrollbar", "NoScrollWithMouse", "NoInputs"}) do
        if wf[name] then flags = flags + wf[name] end
    end
    local w, h = 340, 66
    local disp = imgui.GetIO().DisplaySize
    local posX, posY = (disp.x - w) / 2, disp.y * 0.06
    local winRound = ini.settings.style == 1 and 10 or 2
    if imgui.SetNextWindowBgAlpha then
        imgui.SetNextWindowBgAlpha(0.72 * routeHud.alpha)
    end
    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(w, h), imgui.Cond.Always)
    imgui.Begin("##FarmBotRouteHud", nil, flags)

    local dl = imgui.GetWindowDrawList()
    local o = imgui.GetWindowPos()

    local name = string.gsub(vars.route.name, '%.route', '')
    dl:AddText(imgui.ImVec2(o.x + 12, o.y + 5), 0xFF33D9FF, u8("\xCC\xE0\xF0\xF8\xF0\xF3\xF2: ") .. name)

    local actual = 0
    if vars.route.total and vars.route.total > 0 then
        actual = math.min(1, vars.route.packets / vars.route.total)
    end

    local barX, barY = o.x + 12, o.y + 28
    local barW, barH = w - 24, 20
    local barRound = ini.settings.style == 1 and (barH / 2) or 2
    dl:AddRectFilled(imgui.ImVec2(barX, barY), imgui.ImVec2(barX + barW, barY + barH), 0x59000000, barRound)
    local fillW = math.max(0, math.min(barW, barW * routeHud.shown))
    drawGradientFill(dl, barX, barY, fillW, barH, barRound, 0xFF1A8FE0, 0xFF38C8FF)
    local bw = barW * 0.35
    local bx = barX + (routeHud.shimmer * barW) - bw
    if bx + bw > barX and bx < barX + barW then
        dl:AddRectFilled(
            imgui.ImVec2(math.max(barX, bx), barY),
            imgui.ImVec2(math.min(barX + barW, bx + bw), barY + barH),
            0x33FFFFFF,
            barRound
        )
    end
    dl:AddRect(imgui.ImVec2(barX, barY), imgui.ImVec2(barX + barW, barY + barH), 0x66FFFFFF, barRound)
    local pctText = string.format('%.1f%%', actual * 100)
    local ts = imgui.CalcTextSize(pctText)
    dl:AddText(imgui.ImVec2(barX + (barW - ts.x) / 2, barY + (barH - ts.y) / 2), 0xFFFFFFFF, pctText)

    local packetsText = u8("\xCF\xE0\xEA\xE5\xF2\xEE\xE2: ") .. formatNumber(vars.route.packets) .. " / " .. (vars.route.total and formatNumber(vars.route.total) or "0")
    local ps = imgui.CalcTextSize(packetsText)
    dl:AddText(imgui.ImVec2(o.x + (w - ps.x) / 2, o.y + 52), 0xCCFFFFFF, packetsText)

    dl:AddRect(imgui.ImVec2(o.x, o.y), imgui.ImVec2(o.x + w, o.y + h), 0x33FFFFFF, winRound)
    imgui.End()
end

local xx, yy, zz = 0, 0, 0

local odnotipnie_rpc = {83, 118, 131}

local MAXB = 15
local LENBASE = {3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258}
local LENEXT  = {0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0}
local DISTBASE = {1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577}
local DISTEXT = {0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13}
local CLO = {16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15}

local function inflate(src)
    local slen, spos = #src, 1
    local bitbuf, bitcnt = 0, 0

    local function need(n)
        if spos + n - 1 > slen then error("inflate: unexpected end of input") end
    end

    local function getbit()
        if bitcnt == 0 then
            need(1)
            bitbuf = string.byte(src, spos); spos = spos + 1
            bitcnt = 8
        end
        local b = bitbuf % 2
        bitbuf = (bitbuf - b) / 2
        bitcnt = bitcnt - 1
        return b
    end

    local function getbits(n)
        local v, mul = 0, 1
        while n > 0 do
            if bitcnt == 0 then
                need(1)
                bitbuf = string.byte(src, spos); spos = spos + 1
                bitcnt = 8
            end
            local t = n
            if t > bitcnt then t = bitcnt end
            local pw = 2 ^ t
            local part = bitbuf % pw
            v = v + part * mul
            bitbuf = (bitbuf - part) / pw
            bitcnt = bitcnt - t
            n = n - t
            mul = mul * pw
        end
        return v
    end

    local function build(lengths, n)
        local count = {}
        for i = 0, MAXB do count[i] = 0 end
        for i = 1, n do
            local l = lengths[i]
            if l == nil then l = 0 end
            if l > 0 then count[l] = count[l] + 1 end
        end
        local left = 1
        for len = 1, MAXB do
            left = left * 2 - count[len]
            if left < 0 then error("inflate: over-subscribed code") end
        end
        local offs = {}
        local sym = {}
        local total = 0
        for len = 0, MAXB do
            offs[len] = total
            total = total + count[len]
        end
        for i = 1, n do
            local l = lengths[i] or 0
            if l > 0 then
                sym[offs[l] + 1] = i - 1
                offs[l] = offs[l] + 1
            end
        end
        return count, sym
    end

    local function decode(count, sym)
        local code, first, index, len = 0, 0, 0, 1
        while true do
            code = code * 2 + getbit()
            local c = count[len] or 0
            if code - first < c then
                return sym[index + (code - first) + 1]
            end
            index = index + c
            first = (first + c) * 2
            len = len + 1
            if len > MAXB then error("inflate: invalid huffman code") end
        end
    end

    local fixed_lit, fixed_dist
    local function get_fixed()
        if fixed_lit then return end
        local ll = {}
        for i = 0, 143 do ll[i + 1] = 8 end
        for i = 144, 255 do ll[i + 1] = 9 end
        for i = 256, 279 do ll[i + 1] = 7 end
        for i = 280, 287 do ll[i + 1] = 8 end
        local dl = {}
        for i = 0, 31 do dl[i + 1] = 5 end
        fixed_lit = { build(ll, 288) }
        fixed_dist = { build(dl, 32) }
    end

    local out, on = {}, 0
    local bfinal = 0
    repeat
        bfinal = getbit()
        local btype = getbits(2)
        if btype == 0 then
            bitbuf, bitcnt = 0, 0
            need(4)
            local b1, b2, b3, b4 = string.byte(src, spos, spos + 3)
            spos = spos + 4
            local LENv = b1 + b2 * 256
            local NLEN = b3 + b4 * 256
            if (LENv + NLEN) % 65536 ~= 65535 then error("inflate: bad stored block") end
            need(LENv)
            for _ = 1, LENv do
                on = on + 1
                out[on] = string.byte(src, spos); spos = spos + 1
            end
        elseif btype == 1 or btype == 2 then
            local lit, dist
            if btype == 1 then
                get_fixed()
                lit, dist = fixed_lit, fixed_dist
            else
                local HLIT = getbits(5) + 257
                local HDIST = getbits(5) + 1
                local HCLEN = getbits(4) + 4
                local cl = {}
                for i = 1, 19 do cl[i] = 0 end
                for i = 1, HCLEN do
                    cl[CLO[i] + 1] = getbits(3)
                end
                local cltab = { build(cl, 19) }
                local nlit = HLIT + HDIST
                local lengths, i = {}, 0
                while i < nlit do
                    local sym = decode(cltab[1], cltab[2])
                    if sym < 16 then
                        i = i + 1; lengths[i] = sym
                    elseif sym == 16 then
                        if i == 0 then error("inflate: repeat with no previous") end
                        local rep = 3 + getbits(2)
                        local prev = lengths[i]
                        for _ = 1, rep do i = i + 1; lengths[i] = prev end
                    elseif sym == 17 then
                        local rep = 3 + getbits(3)
                        for _ = 1, rep do i = i + 1; lengths[i] = 0 end
                    else
                        local rep = 11 + getbits(7)
                        for _ = 1, rep do i = i + 1; lengths[i] = 0 end
                    end
                    if i > nlit then error("inflate: code lengths overflow") end
                end
                local ll, dd = {}, {}
                for j = 1, HLIT do ll[j] = lengths[j] or 0 end
                for j = 1, HDIST do dd[j] = lengths[HLIT + j] or 0 end
                lit = { build(ll, HLIT) }
                dist = { build(dd, HDIST) }
            end
            while true do
                local sym = decode(lit[1], lit[2])
                if sym < 256 then
                    on = on + 1
                    out[on] = sym
                elseif sym == 256 then
                    break
                else
                    local lc = sym - 256
                    if lc < 1 or lc > 29 then error("inflate: bad length symbol") end
                    local len = LENBASE[lc] + getbits(LENEXT[lc])
                    local ds = decode(dist[1], dist[2])
                    if ds < 0 or ds > 29 then error("inflate: bad distance symbol") end
                    local d = DISTBASE[ds + 1] + getbits(DISTEXT[ds + 1])
                    local start = on - d + 1
                    if start < 1 then error("inflate: distance too far back") end
                    if start + len - 1 > on then
                        for i = 1, len do
                            out[on + i] = out[start + i - 1]
                        end
                        on = on + len
                    else
                        local p = start
                        for _ = 1, len do
                            on = on + 1
                            out[on] = out[p]
                            p = p + 1
                        end
                    end
                end
            end
        else
            error("inflate: invalid block type")
        end
    until bfinal == 1

    local unp = unpack or table.unpack
    local parts, chunk = {}, {}
    for i = 1, on do
        chunk[#chunk + 1] = out[i]
        if #chunk >= 512 then
            parts[#parts + 1] = string.char(unp(chunk, 1, #chunk))
            chunk = {}
        end
    end
    if #chunk > 0 then
        parts[#parts + 1] = string.char(unp(chunk, 1, #chunk))
    end
    return table.concat(parts)
end

local LZ_IM   = 1
local LZ_IR   = 13
local LZ_IR0  = 25
local LZ_IR1  = 37
local LZ_IR2  = 49
local LZ_IR0L = 61
local LZ_LIT  = 73
local LZ_DSLOT = 6217
local LZ_PSPEC = 6473
local LZ_PALGN = 6587
local LZ_MLC  = 6603
local LZ_MLC2 = 6604
local LZ_MLLOW = 6605
local LZ_MLMID = 6613
local LZ_MLHIGH = 6621
local LZ_RLC  = 6877
local LZ_RLC2 = 6878
local LZ_RLLOW = 6879
local LZ_RLMID = 6887
local LZ_RLHIGH = 6895
local LZ_PROBS = 7150

local function lzma_decode(src)
    local slen, spos = #src, 1
    local function rb()
        if spos > slen then error("lzma: unexpected end of input") end
        local b = string.byte(src, spos)
        spos = spos + 1
        return b
    end
    local b0 = rb()
    if b0 ~= 0 then error("lzma: bad range coder init") end
    local code = rb() * 0x1000000 + rb() * 0x10000 + rb() * 0x100 + rb()
    local range = 0xFFFFFFFF

    local function norm()
        if range < 0x1000000 then
            range = range * 0x100
            code = code * 0x100 + rb()
        end
    end

    local pr = {}
    for i = 1, LZ_PROBS do pr[i] = 1024 end

    local function bitd(idx)
        norm()
        local p = pr[idx]
        if p == nil then error("lzma: bad prob index " .. tostring(idx)) end
        local bound = math.floor(range / 2048) * p
        if code < bound then
            range = bound
            pr[idx] = p + math.floor((2048 - p) / 32)
            return 0
        end
        range = range - bound
        code = code - bound
        pr[idx] = p - math.floor(p / 32)
        return 1
    end

    local function bittree(base, nbits)
        local sym = 1
        for _ = 1, nbits do
            sym = sym * 2 + bitd(base + sym)
        end
        return sym - (2 ^ nbits)
    end

    local function len_dec(choice, choice2, low, mid, high)
        if bitd(choice) == 0 then
            return 2 + bittree(low, 3)
        end
        if bitd(choice2) == 0 then
            return 10 + bittree(mid, 3)
        end
        return 18 + bittree(high, 8)
    end

    local w, n = {}, 0
    local state = 0
    local rep0, rep1, rep2, rep3 = 0, 0, 0, 0

    while true do
        if bitd(LZ_IM + state) == 0 then
            local prev = 0
            if n > 0 then prev = w[n] end
            local base = LZ_LIT + 768 * math.floor(prev / 32)
            local sym
            if state < 7 then
                sym = 1
                for _ = 1, 8 do sym = sym * 2 + bitd(base + sym) end
                sym = sym - 256
                if state <= 3 then state = 0 else state = state - 3 end
            else
                local mb = w[n - rep0]
                local off = 0x100
                sym = 1
                for _ = 1, 8 do
                    mb = (mb * 2) % 512
                    local mbv = 0
                    if off ~= 0 and mb >= 0x100 then mbv = 0x100 end
                    local b = bitd(base + off + mbv + sym)
                    sym = sym * 2 + b
                    if off ~= 0 then
                        if (b == 1 and mbv == 0) or (b == 0 and mbv ~= 0) then
                            off = 0
                        end
                    end
                end
                sym = sym - 256
                if state <= 9 then state = state - 3 else state = state - 6 end
            end
            n = n + 1
            w[n] = sym
        else
            if bitd(LZ_IR + state) == 0 then
                if state < 7 then state = 7 else state = 10 end
                rep3, rep2, rep1 = rep2, rep1, rep0
                local len = len_dec(LZ_MLC, LZ_MLC2, LZ_MLLOW, LZ_MLMID, LZ_MLHIGH)
                local ds
                if len < 6 then ds = len - 2 else ds = 3 end
                local slot = bittree(LZ_DSLOT + ds * 64, 6)
                local dist
                if slot < 4 then
                    dist = slot
                elseif slot < 14 then
                    local lim = math.floor(slot / 2) - 1
                    dist = (2 + (slot % 2)) * (2 ^ lim)
                    local base = LZ_PSPEC + dist - slot - 1
                    local sy = 1
                    local of = 1
                    for _ = 1, lim do
                        local b = bitd(base + sy)
                        sy = sy * 2 + b
                        if b == 1 then dist = dist + of end
                        of = of * 2
                    end
                else
                    local lim = math.floor(slot / 2) - 1 - 4
                    dist = 2 + (slot % 2)
                    for _ = 1, lim do
                        norm()
                        range = math.floor(range / 2)
                        if code >= range then
                            code = code - range
                            dist = dist * 2 + 1
                        else
                            dist = dist * 2
                        end
                    end
                    dist = dist * 16
                    local sy = 0
                    local of = 1
                    for _ = 1, 4 do
                        if bitd(LZ_PALGN + of + sy) == 1 then sy = sy + of end
                        of = of * 2
                    end
                    dist = dist + sy
                end
                rep0 = dist
                if dist == 0xFFFFFFFF then
                    break
                end
                if dist >= n then error("lzma: bad distance") end
                local j = n - dist
                for _ = 1, len do
                    n = n + 1
                    w[n] = w[j]
                    j = j + 1
                end
            else
                if bitd(LZ_IR0 + state) == 0 then
                    if bitd(LZ_IR0L + state) == 0 then
                        if rep0 >= n then error("lzma: bad rep distance") end
                        local b = w[n - rep0]
                        if state < 7 then state = 9 else state = 11 end
                        n = n + 1
                        w[n] = b
                    else
                        if rep0 >= n then error("lzma: bad rep distance") end
                        if state < 7 then state = 8 else state = 11 end
                        local len = len_dec(LZ_RLC, LZ_RLC2, LZ_RLLOW, LZ_RLMID, LZ_RLHIGH)
                        local j = n - rep0
                        for _ = 1, len do
                            n = n + 1
                            w[n] = w[j]
                            j = j + 1
                        end
                    end
                else
                    local nd
                    if bitd(LZ_IR1 + state) == 0 then
                        nd = rep1
                        rep1 = rep0
                        rep0 = nd
                    else
                        if bitd(LZ_IR2 + state) == 0 then
                            nd = rep2
                            rep2 = rep1
                            rep1 = rep0
                            rep0 = nd
                        else
                            nd = rep3
                            rep3 = rep2
                            rep2 = rep1
                            rep1 = rep0
                            rep0 = nd
                        end
                    end
                    if rep0 >= n then error("lzma: bad rep distance") end
                    if state < 7 then state = 8 else state = 11 end
                    local len = len_dec(LZ_RLC, LZ_RLC2, LZ_RLLOW, LZ_RLMID, LZ_RLHIGH)
                    local j = n - rep0
                    for _ = 1, len do
                        n = n + 1
                        w[n] = w[j]
                        j = j + 1
                    end
                end
            end
        end
    end

    local unp = unpack or table.unpack
    local parts, chunk = {}, {}
    for i = 1, n do
        chunk[#chunk + 1] = w[i]
        if #chunk >= 512 then
            parts[#parts + 1] = string.char(unp(chunk, 1, #chunk))
            chunk = {}
        end
    end
    if #chunk > 0 then
        parts[#parts + 1] = string.char(unp(chunk, 1, #chunk))
    end
    return table.concat(parts)
end

local function farm_route_path(name)
    return getWorkingDirectory()..'\\config\\KopnevScripts\\'..name..'.route'
end

local function farm_decrypt_route(name)
    local path = farm_route_path(name)
    if not path then return nil end
    local f = io.open(path, 'rb')
    local d = f:read('*all')
    f:close()
    local m = d:sub(1, 4)
    if m == 'RRL1' then return lzma_decode(d:sub(5)) end
    if m == 'RRD1' then return inflate(d:sub(5)) end
    return d
end

function routePlayBack()
    while true do wait(0)
        if vars.route.state and vars.route.name ~= '' then
            local filePath = farm_route_path(vars.route.name)
            printStringNow('Route playback checking: '..(filePath or vars.route.name), 2000)
            if filePath then
                local r = farm_decrypt_route(vars.route.name)
                local total = 0
                for _ in r:gmatch('[^\r\n]+') do total = total + 1 end
                vars.route.total = total
                local stime = 50
                local px, py, pz = 1, 1, 1
                local q_x, q_y, q_z, q_w = 1, 1, 1, 1
                if isCharInAnyCar(1) then
                    freezeCarPosition(storeCarCharIsInNoSave(1), true)
                else
                    freezeCharPosition(1, true)
                end
                for line in r:gmatch('[^\r\n]+') do
                    local v = line
                    if not v or not (vars.route.state and vars.route.name ~= '') then break end
                    if v:find('Trailer') then
                        local r1, r2 = v:match("Vehicle(.*); Trailer(.*)")
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl = r1:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+)%]')
                        local tx, ty, tz, tmx, tmy, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk, timer = r2:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+); (%S+)%]')
                        px, py, pz = x, y, z
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        stime = timer
                        if vars.route.trailerId ~= -1 then
                            local _, veh = sampGetCarHandleBySampVehicleId(vars.route.trailerId)
                            if _ then
                                vars.trailerSync = true
                                setCarCollision(veh, false)
                                local vehid = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl, vars.route.trailerId, tx, ty, tz, tmx, tmy, tmz, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk)
                                if not isTrailerAttachedToCab(storeCarCharIsInNoSave(1), veh) then
                                    attachTrailerToCab(veh, storeCarCharIsInNoSave(1))
                                end
                            end
                        end
                    elseif v:find('Vehicle') and not v:find('Trailer') then
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl, timer = v:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+); (%S+)%]')
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        px, py, pz = x, y, z
                        stime = timer
                        sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl)
                    elseif v:find('Player') then
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, hp, arm, spAct, spKey, anLoop, anLX, anLY, anFR, anREG, anFD, anTime, animId, animFlags, kd, lrk, udk, timer = v:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+)%); (%S+); (%S+); %((%S+); (%S+); (%S+); (%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+)%]')
                        if not x then
                            local sSpAct, sSpKey, sAnimId, sAnimFlags, sKd, sLrk, sUdk, sTimer
                            x, y, z, mx, my, mz, qx, qy, qz, qw, sSpAct, sSpKey, sAnimId, sAnimFlags, sKd, sLrk, sUdk, sTimer = v:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); %((%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+)%]')
                            if x then
                                hp, arm = '100', '0'
                                spAct, spKey = sSpAct, sSpKey
                                anLoop, anLX, anLY, anFR, anREG, anFD, anTime = '0', '0', '0', '0', '1', '2', '0'
                                animId, animFlags, kd, lrk, udk, timer = sAnimId, sAnimFlags, sKd, sLrk, sUdk, sTimer
                            end
                        end
                        px, py, pz = x, y, z
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        stime = timer
                        sendPlayerSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, hp, arm, spKey, spAct, anFD, anLoop, anLX, anLY, anFR, anTime, anREG, animId, animFlags)
                    elseif v:find('Aim') then
                        local cm, fx, fy, fz, px, py, pz, aimz, cez, ws, ar = v:match('%[(%S+); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+)%]')
                        stime = -1
                        local data = samp_create_sync_data('aim')
                        data.camMode = tonumber(cm)
                        data.camFront, data.camPos = { tonumber(fx), tonumber(fy), tonumber(fz) }, { tonumber(px), tonumber(py), tonumber(pz) }
                        data.aimZ = tonumber(aimz)
                        data.camExtZoom = tonumber(cez)
                        data.weaponState = tonumber(ws)
                        data.aspectRatio = tonumber(ar)
                        data.send()
                    elseif v:find('RPC') then
                        stime = -1
                        local send = v:find('RPCS')
                        local receive = v:find('RPCR')
                        if send then
                            local rpcId = tonumber(v:match('RPCS%((%S+)%)'))
                            local dataToSend = {}
                            if rpcId == 26 then
                                local vehid, passenger, model = v:match('RPCS%(%S+%)%[(%S+); (%S+); (%S+)%]')
                                vehid, passenger, model = tonumber(vehid), (passenger == '1'), tonumber(model)
                                local _, veh = sampGetCarHandleBySampVehicleId(vehid)
                                if _ then
                                    vars.lastVehicleSended = vehid
                                    dataToSend = {vehid, passenger}
                                    warpCharIntoCar(1, veh)
                                else
                                    local id = getClosestCarWithModel(model)
                                    if id ~= -1 then
                                        warpCharIntoCar(1, select(2, sampGetCarHandleBySampVehicleId(id)))
                                        vars.lastVehicleSended = id
                                        dataToSend = {vehid, passenger}
                                    else
                                        if isCharInAnyCar(1) then
                                            vars.lastVehicleSended = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                            dataToSend = {vars.lastVehicleSended, false}
                                        else
                                            print('error with 26 rpc(sendEnterVehicle). Vehicle = nil!')
                                        end
                                    end
                                end
                            elseif rpcId == 50 or rpcId == 101 then
                                local msg = v:match('RPCS%(%S+%)%[(%S+)%]')
                                dataToSend = {msg:len(), msg}
                            elseif rpcId == 154 then
                                dataToSend = {vars.lastVehicleSended ~= -1 and vars.lastVehicleSended or (isCharInAnyCar(1) and select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1))) or -1)}
                                warpCharFromCarToCoord(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                            elseif rpcId == 168 then
                                local z, zov, svo, pasxalkoo = v:match('RPCS%(%S+%)%[(%S+); (%S+); (%S+); (%S+)%]')
                                dataToSend = {tonumber(z), tonumber(zov), tonumber(svo), tonumber(pasxalkoo)}
                            else
                                for k,vl in pairs(odnotipnie_rpc) do
                                    if rpcId == vl then
                                        dataToSend = {tonumber(v:match('RPCS%(%S+%)%[(%S+)%]'))}
                                        break
                                    end
                                end
                            end
                            emulRpc(rpcId, dataToSend, true)
                        elseif receive then
                            local rpcId = tonumber(v:match('RPCR%((%S+)%)'))
                            local dataToSend = {}
                            if rpcId == 26 then
                                local vehid, passenger, model = v:match('RPCR%(%S+%)%[(%S+); (%S+); (%S+)%]')
                                vehid, passenger, model = tonumber(vehid), (passenger == '1'), tonumber(model)
                                local _, veh = sampGetCarHandleBySampVehicleId(vehid)
                                if _ then
                                    vars.lastVehicleSended = vehid
                                    dataToSend = {vehid, passenger}
                                    warpCharIntoCar(1, veh)
                                else
                                    local id = getClosestCarWithModel(model)
                                    if id ~= -1 then
                                        warpCharIntoCar(1, select(2, sampGetCarHandleBySampVehicleId(id)))
                                        vars.lastVehicleSended = id
                                        dataToSend = {vehid, passenger}
                                    else
                                        if isCharInAnyCar(1) then
                                            vars.lastVehicleSended = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                            dataToSend = {vars.lastVehicleSended, false}
                                        else
                                            print('error with 26 rpc(sendEnterVehicle). Vehicle = nil!')
                                        end
                                    end
                                end
                            elseif rpcId == 50 or rpcId == 101 then
                                local msg = v:match('RPCR%(%S+%)%[(%S+)%]')
                                dataToSend = {msg:len(), msg}
                            elseif rpcId == 154 then
                                dataToSend = {vars.lastVehicleSended ~= -1 and vars.lastVehicleSended or -1}
                                warpCharFromCarToCoord(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                            elseif rpcId == 168 then
                                local z, zov, svo, pasxalkoo = v:match('RPCR%(%S+%)%[(%S+); (%S+); (%S+); (%S+)%]')
                                dataToSend = {tonumber(z), tonumber(zov), tonumber(svo), tonumber(pasxalkoo)}
                            else
                                for k,vl in pairs(odnotipnie_rpc) do
                                    if rpcId == vl then
                                        dataToSend = {tonumber(v:match('RPCR%(%S+%)%[(%S+)%]'))}
                                        break
                                    end
                                end
                            end
                            emulRpc(rpcId, dataToSend, false)
                        end
                    end
                    vars.route.currentPos = {x = tonumber(px), y = tonumber(py), z = tonumber(pz)}
                    if isCharInAnyCar(1) then
                        setCarCoordinatesNoOffset(storeCarCharIsInNoSave(1), vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                        setVehicleQuaternion(storeCarCharIsInNoSave(1), tonumber(q_y), tonumber(q_z), tonumber(q_w), -tonumber(q_x))
                    else
                        setCharCoordinatesNoOffset(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                        setCharQuaternion(1, tonumber(q_y), tonumber(q_z), tonumber(q_w), -tonumber(q_x))
                    end
                    vars.route.packets = vars.route.packets + 1
                    if stime ~= -1 then
                        wait(tonumber(stime))
                    end
                end
                if vars.trailerSync then
                    vars.trailerSync = false
                    local v = select(2, sampGetCarHandleBySampVehicleId(vars.route.trailerId))
                    if doesVehicleExist(v) then
                        setCarCollision(v, true)
                    end
                end
                vars.route.packets = 0
                if not loop[0] then
                    vars.route.state = false
                    vars.route.name = ''
                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                    if isCharInAnyCar(1) then
                        freezeCarPosition(storeCarCharIsInNoSave(1), false)
                    else
                        freezeCharPosition(1, false)
                    end
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEF\xF0\xEE\xE8\xE3\xF0\xE0\xED"))
                end
            else
                msg(("\xC4\xE0\xED\xED\xEE\xE3\xEE\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xED\xE5\x20\xF1\xF3\xF9\xE5\xF1\xF2\xE2\xF3\xE5\xF2"))
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                vars.route.state = false
                vars.route.packets = 0
                vars.route.name = ''
            end
        end
    end
end

function getClosestCarWithModel(model)
    local id, dist = -1, 9999
    for i = 0, 2000 do
        local z, v = sampGetCarHandleBySampVehicleId(i)
        if z then
            local my, car = {getCharCoordinates(1)}, {getCarCoordinates(v)}
            local distan = getDistanceBetweenCoords3d(my[1], my[2], my[3], car[1], car[2], car[3])
            if getCarModel(v) == model and distan < dist then
                dist = distan
                id = i
            end
        end
    end
    return id
end

function se.onSendAimSync(data)
    if vars.route.state then return false end
end

function se.onSendPlayerSync(data)
    if vars.route.state then return false end
    if walking then
        data.upDownKeys = 65408
    end
end

function se.onSendVehicleSync(data)
    if vars.route.state then return false end
    if turnLeft then
        data.leftRightKeys = 65408
    end
    if turnRight then
        data.leftRightKeys = 128
    end
end

function drawCalculatorWindow()
    imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(
        imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2),
        imgui.Cond.FirstUseEver,
        imgui.ImVec2(0.5, 0.5)
    )
    imgui.Begin(u8("\xCA\xE0\xEA\xF3\xEB\xFF\xF2\xEE\xF0\x20\xF4\xE5\xF0\xEC\xE5\xF0\xE0"), calc_window, 0)
    local combos = {
        {label = u8("\xC2\xFB\xE1\xEE\xF0\x20\xE4\xEE\xEB\xE6\xED\xEE\xF1\xF2\xE8"), idx = role_idx, options = { u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0"), u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2"), u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0"), u8("\xC2\xEE\xE4\xE8\xF2\xE5\xEB\xFC\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0") }, assign = function(v) selectedRole = v end},
        {label = u8("\xD3\x20\xE2\xE0\xF1\x20\xE5\xF1\xF2\xFC\x20\xE2\xE8\xEF\x3F"), idx = vip_idx, options = { u8("\xCD\xE5\xF2"), u8("\xC4\xE0") }, assign = function(v) hasVip = (v == 1) end},
        {label = u8("\xCC\xEE\xEB\xEE\xF2\x20\xE2\x20\xED\xE0\xEB\xE8\xF7\xE8\xE8\x3F"), idx = accessory_idx, options = { u8("\xCD\xE5\xF2"), u8("\xC4\xE0") }, assign = function(v) hasAxe = (v == 1) end},
    }
    for _, combo in ipairs(combos) do
        if imgui.Combo(combo.label, combo.idx, combo.options, -1) then
            combo.assign(combo.idx.v)
        end
    end
    if imgui.Button(u8("\xD0\xE0\xF7\xB8\xF2\xE0\xF2\xFC\x20\xF7\xEE\x20\xEF\xEE\x20\xEF\xEE\xEB\xF3\xF7\xE8\xF2\xF1\xFF"), imgui.ImVec2(180, 30)) then
        calculateScenario(selectedRole, hasVip, hasAxe)
    end
    if scenarioText ~= nil then
        imgui.TextWrapped(scenarioText)
    end
    if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
        calc_window.v = false
        scenarioText = nil
    end
    imgui.End()
end

-----------------------------------SAMP EVENTS---------------------------------------
function onReceiveRpc(id, bs)
	if state then
		if id == 113 then
			local playerId = raknetBitStreamReadInt16(bs)
			local index = raknetBitStreamReadInt32(bs)
			local create = raknetBitStreamReadBool(bs)
			local model = raknetBitStreamReadInt32(bs)

			if not state_taked and select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) == playerId and model == 2901 then
				state_taked = true
                findGameActive = false
			end
		elseif id == 93 then
			local color = raknetBitStreamReadInt32(bs)
			local len = raknetBitStreamReadInt32(bs)
			local str = raknetBitStreamReadString(bs, len)

			if state_taked and str:find(("\x7B\x46\x46\x36\x33\x34\x37\x7D\x20\xD2\xE5\xEF\xE5\xF0\xFC\x20\xC2\xE0\xF8\x20\xED\xE0\xE2\xFB\xEA\x20\xF4\xE5\xF0\xEC\xE5\xF0\xF1\xF2\xE2\xE0")) then
				state_taked = false
			end
		end
	end
end

function sendCustomPacket(subId, ...)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, subId)
    if subId == 18 then
        local text = ...
        raknetBitStreamWriteInt16(bs, #text)
        raknetBitStreamWriteString(bs, text)
        raknetBitStreamWriteInt32(bs, 0)
    elseif subId == 1 then
        local value = ...
        raknetBitStreamWriteInt8(bs, value)
    end
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end

function onReceivePacket(id, bs)
    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        local packettype = raknetBitStreamReadInt8(bs)

        if packettype == 17 then
            raknetBitStreamIgnoreBits(bs, 32)
            local length = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            local str = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
            if autoeat.v or pipiska then
                local satietyMatch = str:match("event%.arizonahud%.playerSatiety'%s*,%s*`?%s*%[(%d+)")
                if satietyMatch then
                    satiety = tonumber(satietyMatch)
                end
            end

            local fuelMatch = str:match("event%.arizonahud%.vehicleLiters'%s*,%s*`?%s*%[(%d+)")
            if fuelMatch then
                vehicleFuelLiters = tonumber(fuelMatch) or 0
            end

            local addMoneyMatch = str:match("event%.player%.addMoney'%s*,%s*`?%s*%[(%d+)")
            local amount = addMoneyMatch and tonumber(addMoneyMatch)
            if amount and amount > 0 and (state or work1 or work2 or work3) then
                farmStats.earned = farmStats.earned + amount
            end
            local skillUp = str:match('"name":"\xCD\xE0\xE2\xFB\xEA \xF4\xE5\xF0\xEC\xE5\xF0\xE0 %+(%d+)"')
            if skillUp then
                local amount = tonumber(skillUp)
                if state then
                    questProgress[1] = math.min(15, (questProgress[1] or 0) + 1)
                    state_taked = false
                end
                local cur, maxs = str:match('"tag":"(%d+)/(%d+)"')
                if cur and maxs then
                    farmStats.skill = tonumber(cur)
                    farmStats.skillMax = tonumber(maxs)
                elseif amount then
                    farmStats.skill = farmStats.skill + amount
                end
            end
            if str:find([[window%.executeEvent%('event%.setActiveView',%s*`?%s*%[%s*`?%s*"FindGame"`?%s*%]%s*`?%s*%);]]) then
                findGameActive = true
                findGameTimer = os.clock()

                lua_thread.create(function ()
                    for i = 1, 5 do
                        math.randomseed(os.clock() ^ i)
                        wait(math.random(step[1], step[2]))
                        sendCustomPacket(18, 'findGame.Success')
                    end
                    sendCustomPacket(18, 'findGame.finish')
                end)
                return false
            else
                local countKeys = tonumber(str:match('"miniGameKeysCount":(%d+)'))
                if countKeys then
                    lua_thread.create(function()
                        for i = 1, countKeys do
                            math.randomseed(os.clock() ^ i)
                            wait(math.random(step[1], step[2]))
                            sendCustomPacket(18, 'miniGame.DebugKeyID|74|74|true')
                        end
                        sendCustomPacket(18, 'miniGame.keyReaction.finish|' .. countKeys)
                    end)
                    return false
                end
            end
        end
    elseif id == 33 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xF2\xE5\xF0\xFF\xED\xEE\x20\xF1\xEE\xE5\xE4\xE8\xED\xE5\xED\xE8\xE5\x20\xF1\x20\xF1\xE5\xF0\xE2\xE5\xF0\xEE\xEC"))
        end
    elseif id == 32 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification(("\xD1\xE5\xF0\xE2\xE5\xF0\x20\xE7\xE0\xEA\xF0\xFB\xEB\x20\xF1\xEE\xE5\xE4\xE8\xED\xE5\xED\xE8\xE5"))
        end
    end
end

otvet = false
local answerWords = {("\xE2\xFB\x20\xF2\xF3\xF2\x3F"),("\xC2\xFB\x20\xF2\xF3\xF2\x3F")}

sampev.onServerMessage = function(color, text)
    if text:find(("\xE3\xEE\xE2\xEE\xF0\xE8\xF2")) then
        if control.warningseytg.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5\x3A\x20") .. text)
        end
        if control.warningsey.v then
            warn2 = true
        end
    end
    if var_0_12.v then
        if text:find(("\xCD\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xEE\x20\xE7\xE0\xEB\xE8\xF2\xFC\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x20\xE2\x20\xE4\xE0\xED\xED\xEE\xE5\x20\xF2\xF0\xE0\xED\xF1\xEF\xEE\xF0\xF2\xED\xEE\xE5\x20\xF1\xF0\xE5\xE4\xF1\xF2\xE2\xEE")) and (work1 or work2 or work3) then
            infengine = true
            var_0_11.v = true
            ini.settings.infinitefuel = true
            if isCharInAnyCar(PLAYER_PED) then
                setCarEngineOn(getCarCharIsUsing(PLAYER_PED), true)
            end
            SCM(("\xD2\xEE\xEF\xEB\xE8\xE2\xE0\x20\xED\xE5\xF2\x20\x97\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\xEE\x20\xE1\xE5\xF1\xEA\xEE\xED\xE5\xF7\xED\xEE\xE5\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
            sendTelegramNotification(("\xE2\x20\xEC\xE0\xF8\xEE\xED\xEA\xE5\x20\xE7\xE0\xEA\xEE\xED\xF7\xE8\xEB\xEE\xF1\xFC\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
        end
    end
    if state and text:find(("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xE0\xED\xEE")) then
        questProgress[1] = math.min(15, (questProgress[1] or 0) + 1)
    end
    if work1 then
        local left = text:match(("\xCE\xF1\xF2\xE0\xEB\xEE\xF1\xFC\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xEE\xE2\x3A\x20(%d+)"))
        if left then
            local remaining = tonumber(left) or 0
            questProgress[2] = math.max(0, (questMax[2] or 2) - remaining)
        elseif text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E"))
            or text:find(("\xC7\xE0\xE4\xE0\xED\xE8\xE5\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xEE"))
            or (text:find(("\x5B\xCA\xE2\xE5\xF1\xF2\x5D")) and text:find(("\xEF\xEE\xEB\xF3\xF7\xE8\xF2\xE5\x20\xED\xE0\xE3\xF0\xE0\xE4\xF3"))) then
            questProgress[2] = questMax[2] or 2
        end
    end
    if work2 then
        local left = text:match(("\xCE\xF1\xF2\xE0\xEB\xEE\xF1\xFC\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xEE\xE2\x3A\x20(%d+)"))
        if left then
            local remaining = tonumber(left) or 0
            questProgress[3] = math.max(0, (questMax[3] or 2) - remaining)
        elseif text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E"))
            or text:find(("\xC7\xE0\xE4\xE0\xED\xE8\xE5\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xEE"))
            or (text:find(("\x5B\xCA\xE2\xE5\xF1\xF2\x5D")) and text:find(("\xEF\xEE\xEB\xF3\xF7\xE8\xF2\xE5\x20\xED\xE0\xE3\xF0\xE0\xE4\xF3"))) then
            questProgress[3] = questMax[3] or 2
        end
    end
    if work3 and (text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E"))
        or text:find(("\xC7\xE0\xE4\xE0\xED\xE8\xE5\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xEE"))
        or (text:find(("\x5B\xCA\xE2\xE5\xF1\xF2\x5D")) and text:find(("\xEF\xEE\xEB\xF3\xF7\xE8\xF2\xE5\x20\xED\xE0\xE3\xF0\xE0\xE4\xF3")))) then
        questProgress[4] = math.min(1, (questProgress[4] or 0) + 1)
    end
    if autofarmzov.v then
        if currentQuest >= maxQuests then
            autofarmzov.v = false
            questActive = false
            questsTakenByBot = false
        end
        if text:find(("\xC4\xEB\xFF\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE8\xFF\x20\xE7\xE0\xE4\xE0\xED\xE8\xFF")) then
            currentQuest = currentQuest + 1
            if currentQuest >= maxQuests then
                questActive = false
                questsTakenByBot = false
            else
                questActive = true
            end
        elseif text:find(("\xE7\xE0\xE4\xE0\xED\xE8\xE9\x20\xEE\xF2\x20\xF4\xE5\xF0\xEC\xE5\xF0\xE0\x20\xC0\xED\xE0\xF2\xEE\xEB\xE8\xFF")) then
            questActive = false
        elseif text:find(("\xC8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE9\xF2\xE5\x20\x2F\x71\x75\x65\x73\x74"))
            or (text:find(("\xCE\xF8\xE8\xE1\xEA\xE0")) and text:find(("\x2F\x71\x75\x65\x73\x74"))) then
            currentQuest = currentQuest + 1
            if currentQuest >= maxQuests then
                questsTakenByBot = false
                autofarmzov.v = false
                questActive = false
            else
                questActive = true
            end
        elseif text:find(("\xC2\xFB\x20\xF3\xE6\xE5\x20\xE2\xFB\xEF\xEE\xEB\xED\xFF\xEB\xE8\x20\xF3\x20\xEC\xE5\xED\xFF\x20\xFD\xF2\xEE\x20\xE7\xE0\xE4\xE0\xED\xE8\xE5")) then
            currentQuest = currentQuest + 1
            if currentQuest >= maxQuests then
                questsTakenByBot = false
                autofarmzov.v = false
                questActive = false
            else
                questActive = true
            end
        elseif text:find(("\x5B\xCA\xE2\xE5\xF1\xF2\x5D")) and text:find(("\xC4\xEB\xFF\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE8\xFF\x20\xE7\xE0\xE4\xE0\xED\xE8\xFF")) then
            currentQuest = currentQuest + 1
            questActive = false
            if currentQuest >= maxQuests then
                questsTakenByBot = false
                autofarmzov.v = false
            end
        end
        if currentQuest >= maxQuests then
            questActive = false
            questsTakenByBot = false
        end
    end
    if (text:find(("\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0")) or text:find(("\xEE\xF2\xE2\xE5\xF2\xE8\xEB\x20\xE2\xE0\xEC")) or text:find(("\xC0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x28\x2E\x2B\x29\x20\xEE\xF2\xE2\xE5\xF2\xE8\xEB\x20\xE2\xE0\xEC\x25\x3A")) or text:find(("\x25\x28\x25\x28\x20\xC0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x28\x2E\x2B\x29\x25\x5B\x25\x64\x2B\x25\x5D\x25\x3A")) or text:find(("\x25\x28\x25\x28\x20\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x2E\x2B\x25\x5B\x28\x25\x64\x2B\x29\x25\x5D\x25\x3A"))) and color ~= -2686721 then
        if control.autoOff.v then
            if state then
                state = false
                state_taked = false
                walking = false
                SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            elseif work1 then
                work1 = false
                gopay = false
                gonew = false
            elseif work2 then
                work2 = false
            elseif work3 then
                work3 = false
                vars.route.state = false
                vars.route.name = ''
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = false
                farmStats.earned = 0
                farmStats.skill = 0
                if isCharInAnyCar(PLAYER_PED) then
                    freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                else
                    freezeCharPosition(PLAYER_PED, false)
                end
            end
        end
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xE0\xE4\xEC\xE8\xED\xE0\x3A\x20") .. text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            if control.flash.v == 1 then
                warn = true
            end
            if control.flash.v == 2 then
                warn2 = true
            end
        end
        if control.autoExit.v then
            readMemory(0, 1)
            sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x20\xE8\xE3\xF0\xF3"))
        end
    end
    local t = string.nlower(text:gsub('{......}', ''))
    for _, word in ipairs(answerWords) do
        if t:find(word)
        and not t:find(("\xE3\xEE\xE2\xEE\xF0\xE8\xF2"))
        and not t:find('vip')
        and not t:find('forever')
        and not t:find('admin')
        and not t:find('premium') then
            if ini.settings.auto then
                lua_thread.create(function()
                    if not otvet then
                        otvet = true
                        wait(math.random(2000, 3000))
                        sendCustomPacket(1, 128)
                        wait(500)
                        sendCustomPacket(1, 0)
                        sampSendChat(("\xC4\xE0"))
                        wait(math.random(1000, 5000))
                        otvet = false
                    end
                end)
            end
            break
        end
    end
    if control.lowhp.v then
        local health = getCharHealth(PLAYER_PED)
        if health <= 10 and not lowhpsent then
            sendTelegramNotification(("\xC1\xF0\xE0\xF2\x20\xF5\xEF\x20\xEC\xE0\xEB\xE0\x20\xEF\xEE\xEF\xEE\xEB\xED\xE8\x20\xEF\xE6"))
            lowhpsent = true
        else
            lowhpsent = false
        end
    end
    if text:find(("\xC2\xE0\xF8\x20\xF3\xF0\xEE\xE2\xE5\xED\xFC\x20\xF1\xFB\xF2\xEE\xF1\xF2\xE8\x20\xED\xE8\xE6\xE5")) then
        if control.golodhelp.v then
            if not lowgolod then
                sendTelegramNotification(("\xCC\xE0\xEB\xEE\x20\xE3\xEE\xEB\xEE\xE4\xE0\x20\xEF\xEE\xEA\xEE\xF0\xEC\xE8"))
                lowgolod = true
            else
                lowgolod = false
            end
        end
    end
end

sampev.onShowDialog = function(dialogId, style, title, button1, button2, text)
    if waitingForStatsTelegram and dialogId == 235 then
        waitingForStatsTelegram = false
        local money = text:match("%$([%d,]+)")
        if money then
            local cleanMoney = money:gsub(",", "")
            local formattedMoney = formatNumber(cleanMoney)
            sendTelegramNotification(("\xD3\x20\xF2\xE5\xE1\xFF\x20\x24") .. formattedMoney)
        else
            sendTelegramNotification(("\xCD\xE5\x20\xF3\xE4\xE0\xEB\xEE\xF1\xFC\x20\xED\xE0\xE9\xF2\xE8\x20\xF1\xF3\xEC\xEC\xF3\x20\xE4\xE5\xED\xE5\xE3\x2E"))
        end
        sampSendDialogResponse(dialogId, 0, 0, "")
        return false
    end
    if autofarmzov.v and questsTakenByBot then
        if dialogId == 7971 then
            sampSendDialogResponse(dialogId, 1, currentQuest, "")
            return false
        elseif dialogId == 7972 then
            sampSendDialogResponse(dialogId, 1, 65535, "")
            return false
        end
    end
    if hidedildos.v then
        if dialogId == 0 then
            if text:find(("\xC2\x20\xFD\xF2\xEE\xEC\x20\xEC\xE5\xF1\xF2\xE5")) or text:find(("\xCE\xF2\xEF\xF0\xE0\xE2\xEB\xFF\xE9\xF2\xE5\xF1\xFC\x20\xEF\xEE\x20\xF7\xE5\xEA\xEF\xEE\xE8\xED\xF2\xE0\xEC\x20\xE4\xEB\xFF\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE8\xFF\x20\xF1\xE2\xEE\xE5\xE9\x20\xF0\xE0\xE1\xEE\xF2\xFB")) then
                return false
            end
        end
        if dialogId == 1234 then
            return false
        end
    end
    if dialogId == 15039 then
        if control.autoOff.v then
            if state then
                state = false
                state_taked = false
                walking = false
                SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            elseif work1 then
                work1 = false
                gopay = false
                gonew = false
            elseif work2 then
                work2 = false
            elseif work3 then
                work3 = false
                vars.route.state = false
                vars.route.name = ''
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = false
                farmStats.earned = 0
                farmStats.skill = 0
                if isCharInAnyCar(PLAYER_PED) then
                    freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                else
                    freezeCharPosition(PLAYER_PED, false)
                end
            end
        end
        if control.skipdialog.v then
            lua_thread.create(function()
                wait(dialogskip)
                setVirtualKeyDown(27, true)
                wait(50)
                setVirtualKeyDown(27, false)
            end)
        end
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xE0\xE4\xEC\xE8\xED\xE0\x3A\x20") .. text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            if control.flash.v == 1 then
                warn = true
            end
            if control.flash.v == 2 then
                warn2 = true
            end
        end
        if control.autoExit.v then
            readMemory(0, 1)
            sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x20\xE8\xE3\xF0\xF3"))
        end
    end
end

function sampev.onSetRaceCheckpoint(type, pos)
    print(pos.x,pos.y,pos.z)
    lastCheckpoint = {x = pos.x, y = pos.y, z = pos.z}
    if work1 and not (gopay or gonew) then
        local startX, startY, startZ = -118.17479705811, 97.49169921875, 3.0650999546051
        local distToStart = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, startX, startY, startZ)

        if distToStart < 5.0 and num > 10 then
            value1 = value1 + 1
            num = 0
            if ini.settings.autochange and value1 >= ini.settings.changeafter and not gopay then
                gonew = true
                ww = true
                lua_thread.create(function()
                    rideTo(-281.87548828125, -100.08025360107, 2.5294334888458, 50, nil, 1)
                    ww = false
                    getInNearestTractor()
                end)
                value1 = 0
            else
                ww = true
            end

            if value1 >= ini.settings.lim1 and not ini.settings.limit1 and not gonew then
                gopay = true
                ww = true
                lua_thread.create(function()
                    rideTo(-108.5108, 119.1330, 3.0700, 50, nil, 1)
                    rideTo(-121.1731, 85.7734, 3.0719, 50, nil, 1)
                    rideTo(-115.0045, 79.7263, 3.0729, 50, nil, 1)
                    rideTo(-108.6299, 76.0149, 3.0727, 50, nil, 1)
                    rideTo(-96.1733, 75.8351, 3.0727, 50, nil, 1)
                    rideTo(-87.7826, 74.0141, 3.0721, 50, nil, 1)
                    sampSendChat('/engine')
                    ww = false
                    wait(500)
                    while true do
                        wait(150)
                        setGameKeyState(15, 255)
                        break
                    end
                    wait(2000)
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        while true do
                            wait(150)
                            setGameKeyState(15, 255)
                            break
                        end
                        wait(1500)
                    end
                    wait(2000)
                    while true do
                        wait(150)
                        setGameKeyState(21, 255)
                        break
                    end
                end)
            else
                ww = true
            end
        end
        if work1 and not (gopay or gonew) then
            num = num + 1
            lua_thread.create(function()
                if num == 70 then
                    rideTo(-119.7002, 84.2271, 3.0719, 60, nil, 1)
                    rideTo(pos.x, pos.y, pos.z, 60, nil, 1)
                else
                    rideTo(pos.x, pos.y, pos.z, 60, nil, 1)
                end
            end)
        end
    end

    if control.zastryal.v then
        if work1 or work2 then
            lua_thread.create(function()
                if num == num then
                    wait(20000)
                    sentkyky = true
                end
            end)
            if sentkyky then
                sendTelegramNotification(("\xCA\xE0\xE6\xE5\xF2\xF1\xFF\x20\xE1\xEE\xF2\x20\xE7\xE0\xF1\xF2\xF0\xFF\xEB\x2E"))
                sentkyky = false
            end
        end
    end

    if work2 then
        local startX1, startY1, startZ1 = -184.97219848633, -82.751800537109, 4.0306000709534
        local distToStart1 = getDistanceBetweenCoords3d(pos.x, pos.y, pos.z, startX1, startY1, startZ1)
        if distToStart1 < 5.0 and num > 10 then
            value1 = value1 + 1
            num = 0
        end
        num = num + 1
        lua_thread.create(function()
            if num == 19 then
                rideTo(-121.4095, -123.5240, 4.0606, 60, 3.0, 2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            elseif num == 28 then
                rideTo(24.9672, -26.8587, 4.0216, 60, 3.0, 2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            elseif num == 38 then
                rideTo(55.4785, 53.3833, 2.2682, 60, 3.0, 2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            elseif num == 40 then
                rideTo(-7.5333, 30.1100, 4.0611, 60, 3.0, 2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            elseif num == 41 then
                rideTo(-34.6055, 8.3665, 4.0636, 60, 3.0, 2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            elseif value1 > 0 and num == 1 then
                ww = true
                rideTo(-69.6392 ,25.7182, 4.0604, 60, 3.0, 2)
                rideTo(-78.4467, 29.7232, 4.0623, 60, 3.0, 2)
                rideTo(-94.5337, 38.7752, 4.0630, 60, 3.0, 2)
                rideTo(-114.7506, 19.9177, 4.0578, 60, 3.0, 2)
                rideTo(-120.0644, 4.8134, 4.0575, 60, 3.0, 2)
                rideTo(-130.6800, -43.2168, 4.0672, 60, 3.0, 2)
                rideTo(-150.7212, -76.3725, 4.0549, 60, 3.0, 2)
                rideTo(-164.0034, -109.4677, 4.0785, 60, 3.0, 2)
                rideTo(-179.5366, -117.1296, 4.0603, 60, 3.0, 2)
                rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
            else
                rideTo(pos.x, pos.y, pos.z, 60, 1.2, 2)
            end
        end)
    end
end

------------------------------------------------------------------------------------------------------------------
--------------------------------------https://blast.hk/threads/31640/-------------------------------------------
-----------------------------------------------------------------------------------------------------------

function ShowHelpMarker(desc)
    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8'(?)') end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.TextLink(label, url)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.2, 0.5, 1.0, 1.0))
    imgui.Text(label)
    if imgui.IsItemHovered() then
        imgui.SetMouseCursor(imgui.MouseCursor.Move)
    end
    if imgui.IsItemClicked(0) then
        os.execute('start "" "' .. url .. '"')
    end
    imgui.PopStyleColor()
end

function imgui.BeforeDrawFrame()
    if faico then
        if fa_font == nil then
            local font_config = imgui.ImFontConfig()
            font_config.MergeMode = true
            fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 11.0, font_config, fa_glyph_ranges)
        end
    end
    if not texture then
        local path = 'moonloader/resource/background.png'
        if doesFileExist(path) then
            local success, tex = pcall(function()
                return imgui.CreateTextureFromFile(path)
            end)
            if success and tex then
                texture = tex
            else
                sampAddChatMessage(("\xCE\xF8\xE8\xE1\xEA\xE0\x20\xE7\xE0\xE3\xF0\xF3\xE7\xEA\xE8\x20\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x2E\x70\x6E\x67"), -1)
                texture = nil
            end
        else
            texture = nil
        end
    end
end

function draw_tab_bot_settings()
    if vkladki[1] == true then -- Settings bot
        imgui.BeginGroup()
        imgui.NewLine() imgui.NewLine()
        imgui.SameLine(210)
        if faico then imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20")..fa.ICON_FA_ROBOT) else imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0")) end
        imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(30) imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xE4\xEE\xEB\xE6\xED\xEE\xF1\xF2\xE8\x3A")) imgui.SameLine(140)
        imgui.PushItemWidth(250)
        if imgui.Combo('##dl', post, posts, -1)then
            ini.settings.post = post.v
            inicfg.save(def, directIni)
        end imgui.PopItemWidth()
        imgui.NewLine() imgui.Separator() imgui.NewLine()
        imgui.NewLine()
        if ini.settings.post == 0 then -- Nachalniy fermer
            imgui.SameLine() imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xE1\xE5\xE3\x3A")) imgui.SameLine(95)
            if imadd.ToggleButton('##runenabled', runEnabled) then
                ini.settings.runenabled = runEnabled.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine(140) imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xEF\xF0\xFB\xE6\xEE\xEA\x3A")) imgui.SameLine(255)
            if imadd.ToggleButton('##jumpenabled', jumpEnabled) then
                ini.settings.jumpenabled = jumpEnabled.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine(300) imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xEF\xEB\xE0\xE2\xED\xF3\xFE\x20\xEA\xE0\xEC\xE5\xF0\xF3\x3A")) imgui.SameLine(465)
            if imadd.ToggleButton('##smoothcamera', smoothcumpenis228) then
                ini.settings.smoothcum = smoothcumpenis228.v
                inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xC0\xE2\xF2\xEE\xF0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\x4B\x6F\x6E\x74\x69\x78"))

            imgui.Text(u8("\xD1\xF1\xFB\xEB\xEA\xE0\x20\xED\xE0\x20\xF2\xE5\xEC\xF3\x3A"))
            imgui.SameLine(100)
            if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then
                os.execute('start "" "https://www.blast.hk/threads/236168/"')
            end
            imgui.NewLine()

            if imgui.Button(u8("\xCF\xF0\xEE\xE9\xF2\xE8\x20\xEC\xE8\xED\xE8\x2D\xE8\xE3\xF0\xF3"), imgui.ImVec2(150, 20)) then
                sendCustomPacket(18, 'findGame.finish')
            end

            if findGameActive then
                local elapsed = (os.clock() - findGameTimer) * 1000
                local progress = math.min(elapsed / resendInterval, 1.0)

                imgui.Text(u8("\xCF\xEE\xE8\xF1\xEA\x20\xE8\xE3\xF0\xFB\x20\xE0\xEA\xF2\xE8\xE2\xE5\xED\x2E\x2E\x2E"))
                imgui.ProgressBar(progress, imgui.ImVec2(300, 20), string.format(u8("\x25\x2E\x31\x66\x20\xF1\xE5\xEA"), (resendInterval - elapsed) / 1000))

                if elapsed >= resendInterval then
                    sendCustomPacket(18, 'findGame.finish')
                    findGameTimer = os.clock()
                end
            end
            imgui.SetCursorPos(imgui.ImVec2(546, 345))
            if faico then
                if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    state = not state
                    state_taked = false
                    if state then farmStats.earned = 0 end
                    SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xED\xE0\xF7\xE0\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                end
                imgui.SameLine()
                if state then
                    if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        state = false
                        state_taked = false
                        findGameActive = false
                        walking = false
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                    end
                end
            else
                if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    state = not state
                    state_taked = false
                    if state then farmStats.earned = 0 end
                    SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xED\xE0\xF7\xE0\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                end
                imgui.SameLine()
                if state then
                    if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        state = false
                        state_taked = false
                        findGameActive = false
                        walking = false
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                    end
                end
            end
        end
        if ini.settings.post == 1 then -- Tractorist
            imgui.SameLine(30) imgui.Text(u8("\xC1\xE5\xE7\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xE8\xFF\x3A")) imgui.SameLine(170)
            if imadd.ToggleButton('##liimit', limit1) then
                ini.settings.limit1 = limit1.v
                inicfg.save(def, directIni)
            end
            if ini.settings.limit1 == false then
                imgui.NewLine() imgui.NewLine()
                imgui.SameLine(30) imgui.Text(u8("\xCE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xE8\xE5\x3A")) imgui.SameLine(170)
                imgui.PushItemWidth(250)
                    if imgui.InputInt('##lim', lim1) then
                        ini.settings.lim1 = lim1.v
                        inicfg.save(def, directIni)
                    end
                imgui.PopItemWidth()
                imgui.SameLine() ShowHelpMarker(u8("\xCD\xE5\x20\xF0\xE5\xEA\xEE\xEC\xE5\xED\xE4\xF3\xE5\xF2\xF1\xFF\x20\xF1\xF2\xE0\xE2\xE8\xF2\xFC\x20\xE1\xEE\xEB\xFC\xF8\xE5\x20\x34\x2C\x20\xF2\x2E\xEA\x20\xEA\xEE\xED\xF7\xE0\xE5\xF2\xF1\xFF\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
            end
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30)
            imgui.Text(u8("\xC0\xE2\xF2\xEE\xF1\xEC\xE5\xED\xE0\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0\x3A"))
            imgui.SameLine(170)
            if imadd.ToggleButton('##autochange', autochange) then
                ini.settings.autochange = autochange.v
                inicfg.save(def, directIni)
            end
            if ini.settings.autochange then
                imgui.NewLine() imgui.NewLine()
                imgui.SameLine(30)
                imgui.Text(u8("\xD1\xEC\xE5\xED\xE8\xF2\xFC\x20\xF7\xE5\xF0\xE5\xE7\x3A"))
                imgui.SameLine(170)
                imgui.PushItemWidth(250)
                if imgui.InputInt('##changeafter', changeafter) then
                    ini.settings.changeafter = math.max(1, changeafter.v)
                    inicfg.save(def, directIni)
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                ShowHelpMarker(u8("\xCF\xEE\xF1\xEB\xE5\x20\xF3\xEA\xE0\xE7\xE0\xED\xED\xEE\xE3\xEE\x20\xEA\xEE\xEB\xE8\xF7\xE5\xF1\xF2\xE2\xE0\x20\xEA\xF0\xF3\xE3\xEE\xE2\x20\xE1\xEE\xF2\x20\xF1\xE0\xEC\x20\xE2\xFB\xE9\xE4\xE5\xF2\x20\xE8\xE7\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0\x20\xE8\x20\xF1\xFF\xE4\xE5\xF2\x20\xE2\x20\xE1\xEB\xE8\xE6\xE0\xE9\xF8\xE8\xE9\x20\xF1\xE2\xEE\xE1\xEE\xE4\xED\xFB\xE9\x2E"))
            end
            imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xC0\xE2\xF2\xEE\xF0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\x44\x2E\x4B\x6F\x70\x6E\x65\x76"))
            imgui.Text(u8("\xD1\xF1\xFB\xEB\xEA\xE0\x20\xED\xE0\x20\xF2\xE5\xEC\xF3\x3A"))
            imgui.SameLine(100)
            if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then
                os.execute('start "" "https://www.blast.hk/threads/40348/"')
            end
            if faico then
                imgui.SetCursorPos(imgui.ImVec2(436, 345))
                if work1 == true or paused == true then
                    if imgui.Button(fa.ICON_FA_PAUSE_CIRCLE..u8("\x20\x20\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                        work1 = false
                        gopay = false
                        paused = true
                    end
                end imgui.SameLine()
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work1 = true
                            gopay = false
                            value1 = 0
                            num = 0
                            ensureVehicleEngine()
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end
                    else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end

                    if paused then
                        work1 = true
                        gopay = false
                        paused = false
                        if lastCheckpoint then
                            lua_thread.create(function()
                                rideTo(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60, nil, 1)
                            end)
                        else
                            lua_thread.create(function()
                                rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
                            end)
                        end
                    else
                        lua_thread.create(function()
                            rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
                        end)
                    end
                end imgui.SameLine()
                if work1 == true then
                    if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work1 = false
                        gopay = false
                    end
                end
            else
                imgui.SetCursorPos(imgui.ImVec2(436, 345))
                if work1 == true or paused == true then
                    if imgui.Button(u8("\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                        work1 = false
                        gopay = false
                        paused = true
                    end
                end imgui.SameLine()
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work1 = true
                            gopay = false
                            value1 = 0
                            num = 0
                            ensureVehicleEngine()
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end
                    else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end

                    if paused then
                        work1 = true
                        gopay = false
                        paused = false
                        if lastCheckpoint then
                            lua_thread.create(function()
                                rideTo(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60, nil, 1)
                            end)
                        else
                            lua_thread.create(function()
                                rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
                            end)
                        end
                    else
                        lua_thread.create(function()
                            rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
                        end)
                    end
                end imgui.SameLine()
                if work1 == true then
                    if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work1 = false
                        gopay = false
                    end
                end
            end
        end
        if ini.settings.post == 2 then -- Kombainer
            imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xF5\xEE\xF2\xFC\x20\xF7\xF2\xEE\x2D\xF2\xEE\x20\xEF\xF0\xE0\xEA\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xF1\xE4\xE5\xEB\xE0\xED\xEE\x20\xEC\xED\xEE\xE9"))
            imgui.SameLine()
            imgui.PushItemWidth(150)
            imgui.PopItemWidth()
            if faico then
                imgui.SetCursorPos(imgui.ImVec2(436, 345))
                if work2 == true or paused == true then
                    if imgui.Button(fa.ICON_FA_PAUSE_CIRCLE..u8("\x20\x20\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                        work2 = false
                        paused = true
                    end
                end imgui.SameLine()
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work2 = true
                            value1 = 0
                            num = 1
                            ensureVehicleEngine()
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                    else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end

                    if paused then
                        work2 = true
                        paused = false
                        if lastCheckpoint then
                            lua_thread.create(function()
                                rideTo(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60, nil, 2)
                            end)
                        else
                            lua_thread.create(function()
                                rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
                            end)
                        end
                    else
                        lua_thread.create(function()
                            rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
                        end)
                    end
                end imgui.SameLine()
                if work2 == true then
                    if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work2 = false
                    end
                end
            else
                imgui.SetCursorPos(imgui.ImVec2(436, 345))
                if work2 == true or paused == true then
                    if imgui.Button(u8("\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                        work2 = false
                        paused = true
                    end
                end imgui.SameLine()
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work2 = true
                            value1 = 0
                            num = 1
                            ensureVehicleEngine()
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                    else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                    if paused then
                        work2 = true
                        paused = false
                        if lastCheckpoint then
                            lua_thread.create(function()
                                rideTo(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60, nil, 2)
                            end)
                        else
                            lua_thread.create(function()
                                rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
                            end)
                        end
                    else
                        lua_thread.create(function()
                            rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
                        end)
                    end
                end imgui.SameLine()
                if work2 == true then
                    if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work2 = false
                    end
                end
            end
        end
        if ini.settings.post == 3 then -- Vodila kykyryshi
            imgui.TextColored(imgui.ImVec4(1.0, 1.0, 1.0, 1.0), u8("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\xFB\x20\xE7\xE0\xEF\xE8\xF1\xE0\xED\xFB\x20\xF7\xE5\xF0\xE5\xE7\x20\xEF\xE0\xEA\xE5\xF2\x2D\xF0\xE5\xEA\xEE\xF0\xE4\xE5\xF0\x20(\xEC\xED\xEE\xE9)"))
            imgui.TextColored(imgui.ImVec4(0.65, 0.72, 0.82, 0.95), u8("leti / leti3 \x97 config\\KopnevScripts\\"))
            imgui.NewLine()
            imgui.SetCursorPos(imgui.ImVec2(546, 345))
            local function startRoute(routeName)
                vars.route.state = true
                vars.route.name = routeName
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = true
                local filePath = farm_route_path(routeName)
                if filePath then
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20") .. routeName .. ("\x20\xE7\xE0\xEF\xF3\xF9\xE5\xED"))
                    while vars.route.state and work3 do
                        wait(100)
                    end
                else
                    msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..tostring(filePath))
                    work3 = false
                end
            end
            if faico then
                if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work3 = true
                            farmStats.earned = 0
                            ensureVehicleEngine()
                            lua_thread.create(function()
                                startRoute("leti")
                                while work3 do
                                    startRoute("leti3")
                                end
                            end)
                        else
                            SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                        end
                    else
                        SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                    end
                end
                imgui.SameLine()
                if work3 then
                    if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work3 = false
                        vars.route.state = false
                        vars.route.name = ''
                        vars.route.packets = 0
                        vars.route.currentPos = { x = -1, y = -1, z = -1 }
                        var_0_10.v = false
                        farmStats.earned = 0
                        farmStats.skill = 0
                        if isCharInAnyCar(PLAYER_PED) then
                            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                        else
                            freezeCharPosition(PLAYER_PED, false)
                        end
                        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                    end
                end
            else
                if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                        if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                            work3 = true
                            farmStats.earned = 0
                            ensureVehicleEngine()
                            lua_thread.create(function()
                                startRoute("leti")
                                while work3 do
                                    startRoute("leti3")
                                end
                            end)
                        else
                            SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                        end
                    else
                        SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                    end
                end
                imgui.SameLine()
                if work3 then
                    if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        work3 = false
                        vars.route.state = false
                        vars.route.name = ''
                        vars.route.packets = 0
                        vars.route.currentPos = { x = -1, y = -1, z = -1 }
                        var_0_10.v = false
                        farmStats.earned = 0
                        farmStats.skill = 0
                        if isCharInAnyCar(PLAYER_PED) then
                            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                        else
                            freezeCharPosition(PLAYER_PED, false)
                        end
                        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                    end
                end
            end
        end
        imgui.EndGroup()
    end
end

function draw_tab_anti_golod()
    if vkladki[2] == true then -- Anti-Golod
        imgui.BeginGroup()
        imgui.NewLine() imgui.NewLine()
        imgui.SameLine(200) imgui.Text(u8("\xC0\xED\xF2\xE8\x2D\xC3\xEE\xEB\xEE\xE4"))
        imgui.SameLine() ShowHelpMarker(u8("\xC0\xE2\xF2\xEE\xF0\x3A\x20\x56\x65\x74\x72\x61\x79\x6F"))
        imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(15) imgui.Text(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xE5\xF1\xF2\xFC\x20\xEF\xF0\xE8\x20\xE3\xEE\xEB\xEE\xE4\xE5\x3A")) imgui.SameLine(210)
        if imadd.ToggleButton('##autoeat', autoeat) then
            ini.settings.autoeat = autoeat.v
            inicfg.save(def, directIni)
        end
        if autoeat.v then
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xD1\xEF\xEE\xF1\xEE\xE1\x20\xE5\xE4\xFB\x3A")) imgui.SameLine(170)
            imgui.PushItemWidth(250)
            if imgui.Combo('##eatmethod', eatmethod, method, -1) then
                ini.settings.eatmethod = eatmethod.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xC5\xF1\xF2\xFC\x20\xEF\xF0\xE8\x20\xF1\xFB\xF2\xEE\xF1\xF2\xE8\x20\xED\xE8\xE6\xE5\x3A")) imgui.SameLine(170)
            imgui.PushItemWidth(250)
            if imgui.SliderInt('##eatpercent', eatpercent, 1, 99) then
                ini.settings.eatpercent = eatpercent.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
        end
        imgui.EndGroup()
    end
end

function draw_tab_dop()
    if vkladki[3] == true then -- Dop function
        imgui.BeginGroup()
        imgui.NewLine() imgui.NewLine()
        imgui.SameLine(210)
        if faico then imgui.Text(u8("\xC7\xE0\xF9\xE8\xF2\xE0\x20\xEC\xE0\xF8\xE8\xED\xFB\x20\x20")..fa.ICON_FA_SHIELD_ALT) else imgui.Text(u8("\xC7\xE0\xF9\xE8\xF2\xE0\x20\xEC\xE0\xF8\xE8\xED\xFB")) end
        imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(30) imgui.Text(u8("\xCD\xE5\xF3\xFF\xE7\xE2\xE8\xEC\xEE\xF1\xF2\xFC\x20\xEC\xE0\xF8\xE8\xED\xFB\x3A")) imgui.SameLine(170)
        if imadd.ToggleButton('##invulnerability', var_0_10) then
            ini.settings.invulnerability = var_0_10.v
            inicfg.save(def, directIni)
        end
        imgui.SameLine() ShowHelpMarker(u8("\xC4\xE5\xEB\xE0\xE5\xF2\x20\xE2\xE0\xF8\xF3\x20\xEC\xE0\xF8\xE8\xED\xF3\x20\xED\xE5\xF3\xFF\xE7\xE2\xE8\xEC\xEE\xE9\x20\xEA\x20\xEB\xFE\xE1\xFB\xEC\x20\xEF\xEE\xE2\xF0\xE5\xE6\xE4\xE5\xED\xE8\xFF\xEC")) imgui.SameLine(340)
        imgui.SameLine(305) imgui.Text(u8("\xC0\xE2\xF2\xEE\xE2\xE7\xFF\xF2\xE8\xE5\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2\x3A")) imgui.SameLine(430)
        if imadd.ToggleButton(u8'##autofarmzov', autofarmzov) then
            ini.settings.autofarmzov = autofarmzov.v
            inicfg.save(def, directIni)
        end
        imgui.SameLine() ShowHelpMarker(u8("\xCF\xEE\xE4\xEE\xE9\xE4\xE8\x20\xEA\x20\xED\xEF\xF1\x20\xE8\x20\xED\xE0\xE6\xEC\xE8\x20\xE0\xEB\xFC\xF2")) imgui.SameLine(510)
        imgui.NewLine() imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(30) imgui.Text(u8("\xC1\xE5\xF1\xEA\xEE\xED\xE5\xF7\xED\xEE\xE5\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x3A")) imgui.SameLine(170)
        if imadd.ToggleButton('##infinitefuel', var_0_11) then
            ini.settings.infinitefuel = var_0_11.v
            inicfg.save(def, directIni)
        end
        imgui.SameLine() ShowHelpMarker(u8("\xCC\xE0\xF8\xEE\xED\xEA\xE0\x20\xEC\xEE\xE6\xE5\xF2\x20\xE5\xE7\xE4\xE8\xF2\xFC\x20\xF1\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\xED\xFB\xEC\x20\xE4\xE2\xE8\xE3\xE0\xF2\xE5\xEB\xE5\xEC")) imgui.SameLine(340)
        imgui.SameLine(305) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x3A")) imgui.SameLine(390)
        if imadd.ToggleButton('##infinitefuelengine', var_0_12) then
            ini.settings.infinitefuelengine = var_0_12.v
            inicfg.save(def, directIni)
            if not var_0_12.v then
                infengine = false
            end
        end
        imgui.SameLine() ShowHelpMarker(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xE2\xEA\xEB\xFE\xF7\xE5\xF2\x20\xE4\xE2\xE8\xE6\xEE\xEA\x20\xE1\xE5\xE7\x20\xF2\xEE\xEF\xEB\xE8\xE2\xE0")) imgui.SameLine(510)
        imgui.NewLine() imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(30) imgui.Text(u8("\xD1\xEA\xF0\xFB\xF2\xFC\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE8\x3A")) imgui.SameLine(170)
        if imadd.ToggleButton('##hidedialogesis', hidedildos) then
            ini.settings.hidedialog = hidedildos.v
            inicfg.save(def, directIni)
        end
        imgui.SameLine() ShowHelpMarker(u8("\xD1\xEA\xF0\xEE\xE5\xF2\x20\xED\xE5\xEA\xEE\xF2\xEE\xF0\xFB\xE5\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE8\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xE5")) imgui.SameLine(340)
        imgui.NewLine() imgui.NewLine()
        imgui.Separator() imgui.NewLine() imgui.NewLine()
        imgui.SameLine(30)
        if faico then imgui.Text(u8("\xCA\xE0\xEA\xF3\xEB\xFF\xF2\xEE\xF0\x20\xF0\xE0\xE1\xEE\xF2\xFB\x20\x20")..fa.ICON_FA_CALCULATOR) else imgui.Text(u8'') end
        imgui.SameLine(300)
        if faico then imgui.Text(u8("\xD1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xEA\xE2\xE5\xF1\xF2\xE8\xEA\xEE\xE2\x20\x20")..fa.ICON_FA_LIST) else imgui.Text(u8'') end
        imgui.NewLine()
        imgui.SameLine(15)
        if imgui.Button(u8("\xCF\xEE\xF1\xF7\xE5\xF2\xE0\xF2\xFC"), imgui.ImVec2(150, 30)) then
            calc_window.v = true
        end
        imgui.SameLine(300)
        if imgui.Button(u8("\xCD\xE0\xE6\xEC\xE8\x20\xEC\xE5\xED\xFF"), imgui.ImVec2(150, 30)) then
            quest_window.v = true
        end
        imgui.EndGroup()
    end
end

function draw_tab_aviaschool()
    if vkladki[4] == true then -- Aviaschool
        imgui.BeginGroup()
        imgui.NewLine() imgui.NewLine()
        imgui.SameLine(210)
        if faico then imgui.Text(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20\x20")..fa.ICON_FA_PLANE) else imgui.Text(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20")) end
        imgui.NewLine()
        imgui.Separator() imgui.NewLine()
        imgui.NewLine()

        local aircrafts = { u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x31"), u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x32") }
        local selectedAircraft = imgui.ImInt(ini.settings.selectedAircraft or 0)
        imgui.Text(u8("\xC2\xFB\xE1\xE5\xF0\xE8\xF2\xE5\x20\xF1\xE0\xEC\xEE\xEB\xE5\xF2\x3A"))
        imgui.SameLine()
        imgui.PushItemWidth(150)
        if imgui.Combo(u8"##AircraftSelection", selectedAircraft, aircrafts, #aircrafts) then
            ini.settings.selectedAircraft = selectedAircraft.v
            inicfg.save(def, directIni)
        end
        imgui.PopItemWidth()
        imgui.NewLine()
        imgui.SetCursorPos(imgui.ImVec2(546, 345))
        local function startRoute(routeName)
            vars.route.state = true
            vars.route.name = routeName
            vars.route.packets = 0
            vars.route.currentPos = { x = -1, y = -1, z = -1 }
            var_0_10.v = true
            local filePath = farm_route_path(routeName)
            if filePath then
                msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20") .. routeName .. ("\x20\xE7\xE0\xEF\xF3\xF9\xE5\xED"))
            else
                msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED"))
                vars.route.state = false
            end
        end
        if faico then
            if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                if selectedAircraft.v == 0 then
                    startRoute("lol3")
                else
                    startRoute("lol2")
                end
            end
            if vars.route.state and (vars.route.name == "lol3" or vars.route.name == "lol2") then
                imgui.SameLine()
                if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                    vars.route.state = false
                    vars.route.name = ''
                    vars.route.packets = 0
                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                    var_0_10.v = false
                    if isCharInAnyCar(PLAYER_PED) then
                        freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                    else
                        freezeCharPosition(PLAYER_PED, false)
                    end
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                end
            end
        else
            if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                if selectedAircraft.v == 0 then
                    startRoute("lol3")
                else
                    startRoute("lol2")
                end
            end
            if vars.route.state and (vars.route.name == "lol3" or vars.route.name == "lol2") then
                imgui.SameLine()
                if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                    vars.route.state = false
                    vars.route.name = ''
                    vars.route.packets = 0
                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                    var_0_10.v = false
                    if isCharInAnyCar(PLAYER_PED) then
                        freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                    else
                        freezeCharPosition(PLAYER_PED, false)
                    end
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                end
            end
        end
        imgui.EndGroup()
    end
end

function draw_tab_telegram()
        if vkladki[5] == true then -- Telegram
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\x20")..fa.ICON_FA_PAPER_PLANE) else imgui.Text(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D")) end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.NewLine()
            imgui.SameLine(0) imgui.Text(u8'TOKEN:')
            imgui.SameLine(90)
            imgui.PushItemWidth(300)
            if imgui.InputText('##token', buffer_token, imgui.InputTextFlags.Password) then
            end
            imgui.PopItemWidth()
            imgui.NewLine()
            imgui.SameLine(0) imgui.Text(u8'USER ID:')
            imgui.SameLine(90)
            imgui.PushItemWidth(300)
            if imgui.InputText('##chatid', buffer_chatid) then
            end
            imgui.PopItemWidth()
            imgui.SetCursorPos(imgui.ImVec2(560, 100))
            if imgui.Button(u8("\xD2\xE5\xF1\xF2"), imgui.ImVec2(100, 50)) then
                sendTelegramNotification(("\xD2\xE5\xF1\xF2\xEE\xE2\xEE\xE5\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x21"))
            end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            local texts = {
                ("\x21\x73\x65\x6E\x64\x20\x2D\x20\xEE\xF2\xEF\xF0\xE0\xE2\xE8\xF2\xFC\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xE2\x20\xF7\xE0\xF2"),
                ("\x21\x73\x74\x61\x74\x73\x20\x2D\x20\xF1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xF0\xE0\xE1\xEE\xF2\xFB"),
                ("\x21\x73\x74\x61\x72\x74\x20\x2D\x20\xE2\xEA\xEB\xFE\xF7\xE8\xF2\xFC\x20\xE1\xEE\xF2\xE0"),
                ("\x21\x65\x78\x69\x74\x20\x2D\x20\xE2\xFB\xE9\xF2\xE8\x20\xE8\xE7\x20\xE8\xE3\xF0\xFB"),
                ("\x21\x73\x74\x6F\x70\x20\x2D\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE8\xF2\xFC\x20\xE1\xEE\xF2\xE0"),
                ("\x21\x63\x6C\x6F\x73\x65\x20\x2D\x20\xE7\xE0\xEA\xF0\xFB\xF2\xFC\x20\xE4\xE8\xE0\xEB\xEE\xE3\x20\xF7\xE5\xEA\x20\xE1\xEE\xF2\xE0\x28\xE0\xE4\xEC\xE8\xED\xE0\x29"),
                ("\x21\x63\x72\x61\x73\x68\x20\x2D\x20\xEA\xF0\xE0\xF8\xED\xF3\xF2\xFC\x20\xE8\xE3\xF0\xF3"),
                ("\x21\x68\x70\x20\x2D\x20\xF3\xE7\xED\xE0\xE9\x20\xF1\xEA\xEE\xEA\x20\xF3\x20\xF2\xE5\xE1\xFF\x20\xF5\xEF")
            }
            for i, txt in ipairs(texts) do
                if i % 2 == 1 then
                    imgui.SameLine(0)
                    imgui.Text(u8(txt))
                else
                    imgui.SameLine(270)
                    imgui.Text(u8(txt))
                    imgui.NewLine()
                end
            end
            imgui.NewLine()
            imgui.SameLine(0)
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\xEF\xF0\xE8\x20\xEF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE8\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5"), control.warningseytg) then
                ini.Telegram.warningseytg = control.warningseytg.v
                inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if imgui.Button(u8("\xD1\xEE\xF5\xF0\xE0\xED\xE8\xF2\xFC"), imgui.ImVec2(150, 30)) then
                ini.Telegram.chat_id = tostring(buffer_chatid.v)
                ini.Telegram.token = tostring(buffer_token.v)
                local success, err = pcall(function()
                    inicfg.save(ini, directIni)
                end)
                if success then
                    if notf then notf.addNotification(("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xF2\xE5\xEB\xE5\xE3\xF0\xE0\xEC\xEC\xE0\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xFB\x21"), 5, 10) end
                    chat_id = ini.Telegram.chat_id
                    token = ini.Telegram.token
                else
                    print(("\xCE\xF8\xE8\xE1\xEA\xE0\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\xED\xE0\xF1\xF2\xF0\xEE\xE5\xEA\x3A\x20") .. tostring(err))
                end
            end
            imgui.EndGroup()
        end
end

function draw_tab_antiadmin()
        if vkladki[6] == true then -- AntiAdmin
            imgui.BeginGroup()
            imgui.NewLine()
            imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\x41\x6E\x74\x69\x2D\x41\x64\x6D\x69\x6E\x20\xE7\xE0\xF9\xE8\xF2\xE0\x20\x20")..fa.ICON_FA_USER_SLASH) else imgui.Text(u8("\x41\x6E\x74\x69\x2D\x41\x64\x6D\x69\x6E\x20\xE7\xE0\xF9\xE8\xF2\xE0")) end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.SetCursorPos(imgui.ImVec2(170.8, 90));
            if imgui.Checkbox(u8("\xC2\xFB\xEA\xEB\xFE\xF7\xE5\xED\xE8\xE5\x20\xE1\xEE\xF2\xE0"), control.autoOff) then
                ini.AntiAdmin.autoOff = control.autoOff.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC2\xFB\xEA\xEB\xFE\xF7\xE0\xE5\xF2\x20\xE1\xEE\xF2\xE0\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(170.8, 120));
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xE5\x20\xE2\x20\x54\x47"), control.telegramNotf) then
                ini.AntiAdmin.telegramNotf = control.telegramNotf.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED\x2C\x20\xEF\xF0\xE8\xF8\xEB\xB8\xF2\x20\xF3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xE5")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(360, 90));
            if imgui.Checkbox(u8("\xD0\xE0\xE7\xE2\xEE\xF0\xEE\xF2\x20\xE8\xE3\xF0\xFB"), control.reversal) then
                ini.AntiAdmin.reversal = control.reversal.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD0\xE0\xE7\xE2\xE5\xF0\xED\xB8\xF2\x20\xE8\xE3\xF0\xF3\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(370)
            imgui.SetCursorPos(imgui.ImVec2(540, 90));
            if imgui.Checkbox(u8("\xCC\xE8\xE3\xE0\xED\xE8\xE5\x20\xFD\xEA\xF0\xE0\xED\xEE\xEC"), control.blinking) then
                ini.AntiAdmin.blinking = control.blinking.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC1\xF3\xE4\xE5\xF2\x20\xEC\xE8\xE3\xE0\xF2\xFC\x20\xFD\xEA\xF0\xE0\xED\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(550)
            imgui.SetCursorPos(imgui.ImVec2(505, 120));
            if imgui.RadioButton(u8("\x33\x35\x30\x20\xEC\xF1"), control.flash, 1) then
                ini.AntiAdmin.flash = 1
                inicfg.save(def, directIni)
            end
            imgui.SetCursorPos(imgui.ImVec2(585, 120));
            if imgui.RadioButton(u8("\x35\x30\x30\x20\xEC\xF1"), control.flash, 2) then
                ini.AntiAdmin.flash = 2
                inicfg.save(def, directIni)
            end
            imgui.SetCursorPos(imgui.ImVec2(360, 120));
            if imgui.Checkbox(u8("\xCA\xF0\xE0\xF8\xED\xF3\xF2\xFC\x20\xE8\xE3\xF0\xF3"), control.autoExit) then
                ini.AntiAdmin.autoExit = control.autoExit.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCA\xF0\xE0\xF8\xED\xE5\xF2\x20\xE8\xE3\xF0\xF3\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(370)
            imgui.SetCursorPos(imgui.ImVec2(540, 150));
            if imgui.Checkbox(u8("\xD1\xEA\xE8\xEF\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE0"), control.skipdialog) then
                ini.AntiAdmin.skipdialog = control.skipdialog.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEA\xE8\xEF\xED\xE5\xF2\x20\xE4\xE8\xE0\xEB\xEE\xE3\x20\x2F\x70\x6D")) imgui.SameLine(550)
            imgui.SetCursorPos(imgui.ImVec2(170.8, 150));
            if imgui.Checkbox(u8("\xCC\xE8\xE3\xE0\xF2\xFC\x20\xFD\xEA\xF0\xE0\xED\xEE\xEC\x20\xEF\xF0\xE8\x20\xEF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE8\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5"), control.warningsey) then
                ini.AntiAdmin.warningsey = control.warningsey.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCC\xE8\xE3\xE0\xE5\xF2\x20\xFD\xEA\xF0\xE0\xED\x2C\x20\xE5\xF1\xEB\xE8\x20\xEA\xF2\xEE\x2D\xF2\xEE\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(340, 183));
            imgui.Text(u8("\xD1\xEA\xE8\xEF\xE0\xF2\xFC\x20\xE7\xE0\x20\xF1\xEB\xF3\xF7\xE0\xE9\xED\xEE\xE5\x20\xE2\xF0\xE5\xEC\xFF\x20\xEE\xF2"))
            imgui.SetCursorPos(imgui.ImVec2(540, 180));
            imgui.PushItemWidth(103)
            if imgui.InputInt(u8("\xE4\xEE"), control.skip1) then
                ini.AntiAdmin.skip11 = tonumber(control.skip1.v) or 1250
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.SetCursorPos(imgui.ImVec2(540, 210));
            imgui.PushItemWidth(103)
            if imgui.InputInt(u8("\xEC\xF1"), control.skip2) then
                ini.AntiAdmin.skip22 = tonumber(control.skip2.v) or 1500
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.SetCursorPos(imgui.ImVec2(170.8, 250))
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x2E\x20\xE5\xF1\xEB\xE8\x20\xF2\x2F\xF1\x20\xE7\xE0\xF1\xF2\xF0\xFF\xEB"), control.zastryal) then
                ini.AntiAdmin.zastryal = control.zastryal.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC1\xF3\xE4\xE5\xF2\x20\xEF\xF0\xE8\xF1\xFB\xEB\xE0\xF2\xFC\x20\xF3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\xE5\xF1\xEB\xE8\x20\xF2\xEE\xF7\xEA\xE0\x20\xED\xE5\x20\xEC\xE5\xED\xFF\xE5\xF2\xF1\xFF\x28\x32\x30\x20\xF1\xE5\xEA\x29\x2E\x28\xCD\xEE\xF0\xEC\x20\xF0\xE0\xE1\xEE\xF2\xE0\xE5\xF2\x20\xFD\xF2\xEE\x2C\x20\xE5\xF1\xEB\xE8\x20\xF7\xE5\xEA\xEF\xEE\xE8\xED\xF2\x20\xE1\xE5\xF0\xB8\xF2\xF1\xFF\x29"))

            imgui.SetCursorPos(imgui.ImVec2(170.8, 280))
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x2E\x20\xEF\xF0\xE8\x20\xED\xE8\xE7\xEA\xEE\xEC\x20\x48\x50"), control.lowhp) then
                ini.AntiAdmin.lowhp = control.lowhp.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEF\xE0\xEC\xE8\xF2\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xF5\xEF\x20\xEC\xE5\xED\xFC\xF8\xE5\x20\xE8\xEB\xE8\x20\xF0\xE0\xE2\xED\xEE\x20\x31\x30"))
            imgui.SetCursorPos(imgui.ImVec2(170.8, 310))
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xE3\xEE\xEB\xEE\xE4"), control.golodhelp) then
                ini.AntiAdmin.golodhelp = control.golodhelp.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD3\xE2\xE5\xE4\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xE3\xEE\xEB\xEE\xE4\x20\xEC\xE5\xED\xFC\xF8\xE5\x20\x32\x30\x25"))
            imgui.SetCursorPos(imgui.ImVec2(170.8, 340))
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x20\xEF\xF0\xE8\x20\xF1\xEC\xE5\xED\xE5\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0"), control.tractorNotify) then
                ini.AntiAdmin.tractorNotify = control.tractorNotify.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xE8\xF2\x20\xE2\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\xEF\xF0\xE8\x20\xF1\xEC\xE5\xED\xE5\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0"))

            imgui.EndGroup()
        end
end

function draw_tab_settings()
        if vkladki[7] == true then -- Settings
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20")..fa.ICON_FA_COGS) else imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xF2\xE5\xEC\xFB\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##theme', tema, items) then
                ini.settings.theme = tema.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.SameLine(260)
            imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xF1\xF2\xE8\xEB\xFF\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##style', style, styles) then
                ini.settings.style = style.v
                inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.SameLine(15)
            if ini.settings.theme == 8 then
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE8\xF2\xFC\x20\xF2\xE5\xEC\xF3\x20\x39"), imgui.ImVec2(150, 30)) then
                    theme9_window.v = not theme9_window.v
                end
            end
            imgui.PopItemWidth()
            imgui.NewLine() imgui.NewLine() imgui.SameLine(15)
            imgui.Text(u8("\xCE\xE1\xFF\xE7\xE0\xF2\xE5\xEB\xFC\xED\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x3A\x20")) imgui.SameLine()
            imgui.Text(u8'/farm')
            imgui.NewLine() imgui.SameLine(15)
            imgui.Text(u8("\xCF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(100)
            local customCommand = imgui.ImBuffer(ini.settings.customCommand, 32)
            if imgui.InputText('##customCommand', customCommand) then
                ini.settings.customCommand = customCommand.v
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(u8("\xC7\xE0\xE3\xF0\xF3\xE7\xE8\xF2\xFC"), imgui.ImVec2(80, 20)) then
                ini.settings.customCommand = customCommand.v
                inicfg.save(def, directIni)
                SCM(("\xCF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE0\x20\xED\xE0\x3A\x20") .. customCommand.v)
                ini.settings.reload = true
                inicfg.save(def, directIni)
                thisScript():reload()
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC2\xE2\xE5\xE4\xE8\xF2\xE5\x20\xEF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xF3\xFE\x20\xEA\xEE\xEC\xE0\xED\xE4\xF3\x20\xE4\xEB\xFF\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\xE1\xE5\xE7\x20\x2F"))
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\x46\x41\x20\xE8\xEA\xEE\xED\xEA\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##faedit', faedit) then
                ini.settings.faedit = faedit.v
                ini.settings.reload = true
                inicfg.save(def, directIni)
                lua_thread.create(function() wait(130) thisScript():reload() end)
            end
            imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xEE\xF2\xE2\xE5\xF7\xE0\xF2\xFC\x20\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF6\xE8\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##auto', auto) then
                ini.settings.auto = auto.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCE\xF2\xE2\xE5\xF7\xE0\xF2\xFC\x20\xED\xE0\x20\xE2\xEE\xEF\xF0\xEE\xF1\xFB\x3A\x20\xC2\xFB\x20\xF2\xF3\xF2\x3F"))
            imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\xD0\xE0\xE1\xEE\xF2\xE0\x20\xE2\x20\xF1\xE2\xB8\xF0\xED\xF3\xF2\xEE\xEC\x20\xF0\xE5\xE6\xE8\xEC\xE5\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##bg', bg) then
                ini.settings.bg = bg.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCC\xE0\xEB\xFF\xF1\xFC\x20\xE1\xF3\xE4\xE5\xF2\x20\xEF\xEB\xEE\xF5\xEE\x20\xF0\xE0\xE1\xEE\xF2\xE0\xF2\xFC"))
            imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xD0\xE5\xE6\xE8\xEC\x20\xED\xE5\xE2\xE8\xE4\xE8\xEC\xEA\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##invisible', invisible) then
                ini.settings.invisible = invisible.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xFF\x20\xEE\xF2\x20'\x46\x61\x72\x6D\x20\x42\x6F\x74'\x20\xE1\xF3\xE4\xF3\xF2\x20\xE2\xFB\xE2\xEE\xE4\xE8\xF2\xFC\xF1\xFF\x20\xED\xE5\x20\xE2\x20\xF7\xE0\xF2\x2C\x20\xE0\x20\xE2\x20\xEA\xEE\xED\xF1\xEE\xEB\xFC"))

            if faico then
                if imgui.Button(fa.ICON_FA_UPLOAD .. u8("\x20\x20\x20\xCF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF")) then
                    update()
                end
            else
                if imgui.Button(u8("\xCF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF")) then
                    update()
                end
            end
            imgui.SameLine()
            if imgui.Checkbox(u8("\xC0\xE2\xF2\xEE\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5"), autoupdate_checkbox) then
                ini.settings.autoupdate = autoupdate_checkbox.v
                inicfg.save(ini, directIni)
                enable_autoupdate = ini.settings.autoupdate
                if enable_autoupdate and not autoupdate_loaded then
                    autoupdate_loaded, Update = goupdate(true)
                elseif not enable_autoupdate and Update then
                    Update = nil
                    autoupdate_loaded = false
                end
            end
            imgui.SetCursorPos(imgui.ImVec2(560, 280))
            if imgui.Button(u8'ChangeLog', imgui.ImVec2(100, 25)) then
                changelog_window.v = not changelog_window.v
            end
            imgui.EndGroup()
        end
end

function draw_tab_info()
        if vkladki[8] == true then -- Information
			imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x20\x20")..fa.ICON_FA_INFO_CIRCLE) else imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine()
            imgui.NewLine()
			imgui.SameLine(210)
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8("\xC2\xED\xE8\xEC\xE0\xED\xE8\xE5\x21"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xC7\xE0\x20\xE2\xE0\xF8\x20\xE0\xEA\xEA\xE0\xF3\xED\xF2\x20\xED\xE5\xF1\xB8\xF2\xE5\x20\xEE\xF2\xE2\xE5\xF1\xF2\xE2\xE5\xED\xED\xEE\xF1\xF2\xFC\x20\xF2\xEE\xEB\xFC\xEA\xEE\x20\xE2\xFB\x21"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xC5\xF1\xEB\xE8\x20\xE2\xE0\xF1\x20\xE7\xE0\xE1\xE0\xED\xFF\xF2\x20\xE7\xE0\x20\xE1\xEE\xF2\xE0\x2C\x20\xF2\xEE\x20\xFD\xF2\xEE\x20\xF7\xE8\xF1\xF2\xEE\x20\xE2\xE0\xF8\xE0\x20\xE2\xE8\xED\xE0\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xD0\xE5\xEA\xEE\xEC\xE5\xED\xE4\xF3\xE5\xF2\xF1\xFF\x20\xED\xE5\x20\xEE\xF2\xF5\xEE\xE4\xE8\xF2\xFC\x20\xE4\xE0\xEB\xE5\xEA\xEE\x20\xEE\xF2\x20\xEA\xEE\xEC\xEF\xFC\xFE\xF2\xE5\xF0\xE0\x2E\x2E\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\x2E\x2E\x2E\xF7\xF2\xEE\xE1\xFB\x20\xE2\xEE\xE2\xF0\xE5\xEC\xFF\x20\xF1\xF0\xE5\xE0\xE3\xE8\xF0\xEE\xE2\xE0\xF2\xFC\x20\xED\xE0\x20\xEE\xF2\xE2\xE5\xF2\xFB\x20\xE0\xE4\xEC\xE8\xED\xEE\xE2\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF0\x20\xEE\xF0\xE8\xE3\xE8\xED\xE0\xEB\xFC\xED\xEE\xE3\xEE\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20\xC4\xE0\xED\xE8\xE8\xEB\x20\xCA\xEE\xEF\xED\xE5\xE2"))
			imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC3\xF0\xF3\xEF\xEF\xE0\x3A\x20\x76\x6B\x2E\x63\x6F\x6D\x2F\x6B\x73\x63\x72\x69\x70\x74\x73\x20\x20\x20"))
            imgui.SameLine(290) if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then os.execute('explorer "https://vk.com/kscripts"') end
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF0\x20\xEF\xE5\xF0\xE5\xE4\xE5\xEB\xEA\xE8\x3A\x20\x66\x6C\x75\x70\x69\x66\x6C\x75\x66\x69\x20\x20\x20"))
			imgui.NewLine()
            imgui.SameLine(100) imgui.TextLink(u8("\xCC\xEE\xE9\x20\xF2\xE3\xEA\x3A\x20\x40\x66\x6C\x75\x70\x69\x66\x6C\x75\x66\x69"), "https://t.me/flupiflufi")
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8("\xC5\xF1\xEB\xE8\x20\xE5\xF1\xF2\xFC\x20\xE2\xEE\xEF\xF0\xEE\xF1\xFB\x20\xEF\xE8\xF8\xE8\xF2\xE5\x20\xE2\x20\xF2\xE5\xEC\xF3"))
			imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC2\xE5\xF0\xF1\xE8\xFF\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20")..thisScript().version)
		    imgui.SameLine() imgui.Text(u8("\x28\x20\xF5\xE7\x20\xF7\xF2\xEE\x20\xF1\xFE\xE4\xE0\x20\xEF\xE8\xF1\xE0\xF2\xFC\x20\x29"))
			imgui.EndGroup()
		end
end

function draw_theme9_window()
    if theme9_window.v then
        imgui.SetNextWindowSize(imgui.ImVec2(600, 700), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2),
                               imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE0\x20\xF2\xE5\xEC\xFB\x20\x39"), theme9_window, 0)
        imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xF2\xE5\x20\xF6\xE2\xE5\xF2\xE0\x20\xE4\xEB\xFF\x20\xF2\xE5\xEC\xFB\x20\x39"))
        imgui.Separator()
        imgui.PushItemWidth(200)

        local color_names = {
            {key = "WindowBg", label = u8("\xD4\xEE\xED\x20\xEE\xEA\xED\xE0")},
            {key = "ChildWindowBg", label = u8("\xD4\xEE\xED\x20\xE4\xEE\xF7\xE5\xF0\xED\xE5\xE3\xEE\x20\xEE\xEA\xED\xE0")},
            {key = "Text", label = u8("\xD6\xE2\xE5\xF2\x20\xF2\xE5\xEA\xF1\xF2\xE0")},
            {key = "PopupBg", label = u8("\xD4\xEE\xED\x20\xE2\xF1\xEF\xEB\xFB\xE2\xE0\xFE\xF9\xE5\xE3\xEE\x20\xEE\xEA\xED\xE0")},
            {key = "Border", label = u8("\xC3\xF0\xE0\xED\xE8\xF6\xE0")},
            {key = "BorderShadow", label = u8("\xD2\xE5\xED\xFC\x20\xE3\xF0\xE0\xED\xE8\xF6\xFB")},
            {key = "FrameBg", label = u8("\xD4\xEE\xED\x20\xF0\xE0\xEC\xEA\xE8")},
            {key = "FrameBgHovered", label = u8("\xD4\xEE\xED\x20\xF0\xE0\xEC\xEA\xE8\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "FrameBgActive", label = u8("\xD4\xEE\xED\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE9\x20\xF0\xE0\xEC\xEA\xE8")},
            {key = "TitleBg", label = u8("\xD4\xEE\xED\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "TitleBgCollapsed", label = u8("\xD4\xEE\xED\x20\xF1\xE2\xE5\xF0\xED\xF3\xF2\xEE\xE3\xEE\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "TitleBgActive", label = u8("\xD4\xEE\xED\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE3\xEE\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "MenuBarBg", label = u8("\xD4\xEE\xED\x20\xEC\xE5\xED\xFE")},
            {key = "ScrollbarBg", label = u8("\xD4\xEE\xED\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ScrollbarGrab", label = u8("\xD5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ScrollbarGrabHovered", label = u8("\xD5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ScrollbarGrabActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xF5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ComboBg", label = u8("\xD4\xEE\xED\x20\xEA\xEE\xEC\xE1\xEE\xE1\xEE\xEA\xF1\xE0")},
            {key = "CheckMark", label = u8("\xD7\xE5\xEA\xEC\xE0\xF0\xEA\xE0")},
            {key = "SliderGrab", label = u8("\xCF\xEE\xEB\xE7\xF3\xED\xEE\xEA")},
            {key = "SliderGrabActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xEF\xEE\xEB\xE7\xF3\xED\xEE\xEA")},
            {key = "Button", label = u8("\xCA\xED\xEE\xEF\xEA\xE0")},
            {key = "ButtonHovered", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ButtonActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xE0\xFF\x20\xEA\xED\xEE\xEF\xEA\xE0")},
            {key = "Header", label = u8("\xC7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA")},
            {key = "HeaderHovered", label = u8("\xC7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "HeaderActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA")},
            {key = "ResizeGrip", label = u8("\xC3\xF0\xE8\xEF\x20\xE4\xEB\xFF\x20\xE8\xE7\xEC\xE5\xED\xE5\xED\xE8\xFF\x20\xF0\xE0\xE7\xEC\xE5\xF0\xE0")},
            {key = "ResizeGripHovered", label = u8("\xC3\xF0\xE8\xEF\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ResizeGripActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xE3\xF0\xE8\xEF")},
            {key = "CloseButton", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF")},
            {key = "CloseButtonHovered", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "CloseButtonActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xE0\xFF\x20\xEA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF")},
            {key = "PlotLines", label = u8("\xC3\xF0\xE0\xF4\xE8\xEA\x20\xEB\xE8\xED\xE8\xE9")},
            {key = "PlotLinesHovered", label = u8("\xC3\xF0\xE0\xF4\xE8\xEA\x20\xEB\xE8\xED\xE8\xE9\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "PlotHistogram", label = u8("\xC3\xE8\xF1\xF2\xEE\xE3\xF0\xE0\xEC\xEC\xE0")},
            {key = "PlotHistogramHovered", label = u8("\xC3\xE8\xF1\xF2\xEE\xE3\xF0\xE0\xEC\xEC\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "TextSelectedBg", label = u8("\xC2\xFB\xE4\xE5\xEB\xE5\xED\xE8\xE5\x20\xF2\xE5\xEA\xF1\xF2\xE0")},
            {key = "ModalWindowDarkening", label = u8("\xC7\xE0\xF2\xE5\xEC\xED\xE5\xED\xE8\xE5\x20\xEC\xEE\xE4\xE0\xEB\xFC\xED\xEE\xE3\xEE\x20\xEE\xEA\xED\xE0")}
        }

        for i, color in ipairs(color_names) do
            imgui.Separator()
            imgui.Text(color.label)
            local col = imgui.ImFloat4(
                ini.theme9[color.key .. "_r"] or 1.0,
                ini.theme9[color.key .. "_g"] or 1.0,
                ini.theme9[color.key .. "_b"] or 1.0,
                ini.theme9[color.key .. "_a"] or 1.0
            )

            if imgui.ColorEdit4(color.key, col) then
                ini.theme9[color.key .. "_r"] = col.v[1]
                ini.theme9[color.key .. "_g"] = col.v[2]
                ini.theme9[color.key .. "_b"] = col.v[3]
                ini.theme9[color.key .. "_a"] = col.v[4]
                inicfg.save(def, directIni)
            end
        end
        imgui.PopItemWidth()
        imgui.SetCursorPos(imgui.ImVec2(500, 660))
        if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
            theme9_window.v = false
        end
        imgui.End()
    end
end

function draw_changelog_window()
    if changelog_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(480, 520), imgui.Cond.FirstUseEver)
		imgui.Begin(' ', changelog_window, 2)
		imgui.SameLine(160)
		imgui.Text(u8("\xD1\xEF\xE8\xF1\xEE\xEA\x20\xE8\xE7\xEC\xE5\xED\xE5\xED\xE8\xE9"))
		imgui.NewLine()
		imgui.Separator()
		local ver_names = {
			u8("V 1.0"),
			u8("V 1.1"),
			u8("V 1.2"),
			u8("V 1.3"),
			u8("V 1.4"),
			u8("V 1.5")
		}
		imgui.PushItemWidth(200)
		imgui.Combo(u8("\xC2\xE5\xF0\xF1\xE8\xFF"), changelog_ver_idx, ver_names)
		imgui.PopItemWidth()
		imgui.Separator()
		imgui.BeginChild("##cl_scroll", imgui.ImVec2(0, 380), true)
		local v = changelog_ver_idx.v
		if v == 0 then
			imgui.TextWrapped(u8("V 1.0"))
			imgui.BulletText(u8("1. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0 \xED\xEE\xE2\xE0\xFF \xF1\xE8\xF1\xF2\xE5\xEC\xE0 \xC0\xED\xF2\xE8-\xC3\xEE\xEB\xEE\xE4."))
			imgui.BulletText(u8("2. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0 \xED\xEE\xE2\xE0\xFF \xF1\xE8\xF1\xF2\xE5\xEC\xE0 \xCD\xE0\xF7\xE0\xEB\xFC\xED\xEE\xE3\xEE \xF4\xE5\xF0\xEC\xE5\xF0\xE0."))
			imgui.BulletText(u8("3. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED \xEC\xE5\xF2\xEE\xE4 \xF0\xE0\xE1\xEE\xF2\xFB \xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0."))
			imgui.BulletText(u8("4. \xD3\xE1\xF0\xE0\xED\xFB \xEB\xE8\xF8\xED\xE8\xE5 \xF4\xF3\xED\xEA\xF6\xE8\xE8."))
			imgui.BulletText(u8("5. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xFB \xE4\xEE\xEF\xEE\xEB\xED\xE8\xF2\xE5\xEB\xFC\xED\xFB\xE5 \xF4\xF3\xED\xEA\xF6\xE8\xE8."))
		elseif v == 1 then
			imgui.TextWrapped(u8("V 1.1"))
			imgui.BulletText(u8("1. \xC8\xE7\xEC\xE5\xED\xE8\xEB \xEA\xEE\xEE\xF0\xE4\xE8\xED\xE0\xF2\xF3 \xE4\xEB\xFF \xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0."))
		elseif v == 2 then
			imgui.TextWrapped(u8("V 1.2"))
			imgui.BulletText(u8("1. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0 \xF0\xE0\xE1\xEE\xF2\xE0 \"\xC2\xEE\xE4\xE8\xF2\xE5\xEB\xFC \xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\"."))
			imgui.BulletText(u8("2. \xC4\xEE\xE1\xE0\xE2\xE8\xEB \xEF\xF0\xEE\xF5\xEE\xE6\xE4\xE5\xED\xE8\xE5 \xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xFB(\xEC\xE0\xF0\xF8\xF0\xF3\xF2)."))
			imgui.BulletText(u8("3. \xD3\xEA\xF0\xE0\xE4\xE5\xED\xFB \xF1\xE8\xF1\xF2\xE5\xEC\xFB \xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xE9 \xE8 \xC0\xED\xF2\xE8-\xC0\xE4\xEC\xE8\xED\xE0 \xF3 SampHack."))
			imgui.BulletText(u8("4. \xC4\xEE\xF0\xE0\xE1\xEE\xF2\xE0\xED\xFB \xF1\xF2\xE0\xF0\xFB\xE5 \xF4\xF3\xED\xEA\xF6\xE8\xE8(\xF0\xE5\xE6\xE8\xEC \xED\xE5\xE2\xE8\xE4\xE8\xEC\xEA\xE8)."))
			imgui.BulletText(u8("5. \xCF\xEE\xF4\xE8\xEA\xF1\xE8\xEB \xE7\xE5\xEB\xB8\xED\xF3\xFE \xF2\xE5\xEC\xF3(\xE1\xE0\xE3 \xF1 \xF6\xE2\xE5\xF2\xE0\xEC\xE8)."))
			imgui.BulletText(u8("6. \xD3\xE2\xE5\xEB\xE8\xF7\xE8\xEB GUI."))
		elseif v == 3 then
			imgui.TextWrapped(u8("V 1.3"))
			imgui.BulletText(u8("1. \xD1\xE4\xE5\xEB\xE0\xEB \xEA\xF0\xF3\xF2\xEE\xE9 \xEC\xE5\xF2\xEE\xE4 \xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0."))
			imgui.BulletText(u8("2. \xCA\xEE\xEB\xEB\xE8\xE7\xE8\xFF \xEE\xE1\xFA\xE5\xEA\xF2\xEE\xE2 \xF0\xE0\xE4\xE8 \xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0."))
			imgui.BulletText(u8("3. \xCF\xEE\xEB\xED\xE0\xFF \xEB\xE5\xE3\xE8\xF2\xED\xEE\xF1\xF2\xFC \xE2\xF1\xE5\xF5 \xF0\xE0\xE1\xEE\xF2 (\xEE\xF2\xE2\xE5\xF7\xE0\xFE)."))
			imgui.BulletText(u8("4. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0 \xEA\xE0\xF1\xF2\xEE\xEC\xED\xE0\xFF \xF2\xE5\xEC\xE0."))
			imgui.BulletText(u8("5. \xC2\xF1\xFF\xEA\xF3\xFE \xF5\xF0\xE5\xED\xFC \xE4\xEE\xE1\xE0\xE2\xE8\xEB \xF7\xE8\xF1\xF2\xEE \xE4\xEB\xFF \xEA\xF0\xE0\xF1\xEE\xF2\xFB."))
		elseif v == 4 then
			imgui.TextWrapped(u8("V 1.4 (\xD0\xE0\xE1\xEE\xF2\xE0 \xED\xE0\xE4 \xCE\xC3\xD0\xCE\xCC\xCD\xDB\xCC\xC8 \xEE\xF8\xE8\xE1\xEA\xE0\xEC\xE8)"))
			imgui.BulletText(u8("1. \xC2\xF1\xE5 \xF0\xE0\xE1\xEE\xF2\xFB \xEC\xEE\xE3\xF3\xF2 \xF0\xE0\xE1\xEE\xF2\xE0\xF2\xFC \xE2 \xF1\xE2\xB8\xF0\xED\xF3\xF2\xEE\xEC \xF0\xE5\xE6\xE8\xEC\xE5."))
			imgui.BulletText(u8("2. \xD4\xE8\xEA\xF1 \xEA\xE8\xEA\xE0 \xED\xE0 \xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5."))
			imgui.BulletText(u8("3. \xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0 \xF1\xE8\xF1\xF2\xE5\xEC\xE0 \xEF\xE0\xF3\xE7\xFB."))
			imgui.BulletText(u8("4. \xC4\xEE\xE1\xE0\xE2\xE8\xEB \xE0\xE2\xF2\xEE\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5."))
			imgui.BulletText(u8("5. \xD1\xE0\xEC\xEE\xE5 \xEF\xF0\xE8\xEA\xEE\xEB\xFC\xED\xEE\xE5 \xFD\xF2\xEE \xE0\xE2\xF2\xEE\xE7\xE0\xEC\xE5\xED\xE0 \xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0."))
			imgui.BulletText(u8("6. \xCD\xEE\xE2\xE0\xFF \xEA\xEE\xEC\xE0\xED\xE4\xE0 \xE8 \xEA\xED\xEE\xEF\xEE\xF7\xEA\xE8 \xE4\xEB\xFF \xF2\xE3."))
			imgui.BulletText(u8("7. \xC2\xF1\xB8 \xF2\xE0\xEA\xE6\xE5 \xED\xE5 \xEF\xFB\xF2\xE0\xFE\xF1\xFC \xF4\xE8\xEA\xF1\xE8\xF2\xFC \xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\xE0."))
		else
			imgui.TextWrapped(u8("V 1.5"))
			imgui.BulletText(u8("1. \xD3\xEF\xF0\xEE\xF9\xE5\xED\xE8\xE5 \xEA\xEE\xE4\xE0, \xF7\xE8\xF1\xF2\xEA\xE0 \xE5\xE3\xEE \xEE\xF2 \xF5\xEB\xE0\xEC\xE0."))
			imgui.BulletText(u8("2. \xD3\xEB\xF3\xF7\xF8\xE5\xED\xE8\xE5 \xED\xE5\xEA\xEE\xF2\xEE\xF0\xFB\xF5 \xFD\xEB\xE5\xEC\xE5\xED\xF2\xEE\xE2 GUI."))
			imgui.BulletText(u8("3. \xC2\xEE\xF1\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5 \xF0\xE0\xE1\xEE\xF2\xEE\xF1\xEF\xEE\xF1\xEE\xE1\xED\xEE\xF1\xF2\xE8."))
			imgui.BulletText(u8("4. \xCC\xE0\xF0\xF8\xF0\xF3\xF2\xFB \xE1\xFB\xEB\xE8 \xE7\xE0\xEF\xE0\xEA\xEE\xE2\xE0\xED\xFB \xE4\xEB\xFF \xFD\xEA\xEE\xED\xEE\xEC\xE8\xE8."))
			imgui.BulletText(u8("5. \xCD\xEE\xE2\xFB\xE9 \xEC\xE0\xF0\xF8\xF0\xF3\xF2 \xE4\xEB\xFF \xE0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xFB."))
		end
		imgui.EndChild()
		imgui.SetCursorPos(imgui.ImVec2(380, 485))
		if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
			changelog_window.v = false
		end
		imgui.End()
	end
end

function draw_anniversary_window()
    if not anniversary_window.v then return end
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(460, 260), imgui.Cond.Always)
    local flags = imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove
    imgui.Begin(u8("Farm Bot Remastered"), nil, flags)
    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(1.0, 0.84, 0.0, 1.0), u8("\xCF\xEE\xE7\xE4\xF0\xE0\xE2\xEB\xFF\xE5\xEC \xE2\xF1\xE5\xF5 \xEF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xE5\xE9!"))
    imgui.Spacing()
    imgui.TextWrapped(u8("\xCF\xF0\xEE\xE5\xEA\xF2\xF3 \xE8\xF1\xEF\xEE\xEB\xED\xE8\xEB\xEE\xF1\xFC \xE1\xEE\xEB\xFC\xF8\xE5 \xE3\xEE\xE4\xE0. \xD1\xEF\xE0\xF1\xE8\xE1\xEE \xE2\xF1\xE5\xEC, \xEA\xF2\xEE \xE8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE5\xF2 \xFD\xF2\xEE\xF2 \xF1\xEA\xF0\xE8\xEF\xF2!"))
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(1.0, 0.35, 0.35, 1.0), u8("\xC2\xE0\xE6\xED\xEE:"))
    imgui.TextWrapped(u8("\xE1\xFB\xEB \xE4\xEE\xE1\xE0\xE2\xEB\xE5\xED \xED\xEE\xE2\xFB\xE9 \xEC\xE0\xF0\xF8\xF0\xF3\xF2, \xE5\xE3\xEE \xED\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xEE \xF1\xEA\xE0\xF7\xE0\xF2\xFC \xF1 \xF2\xE5\xEC\xFB."))
    imgui.Spacing()
    imgui.Separator()
    local elapsed = os.clock() - anniversary_open_time
    local remain = math.max(0, math.ceil(10 - elapsed))
    local can_close = elapsed >= 10
    imgui.Spacing()
    if can_close then
        if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(-1, 32)) then
            anniversary_window.v = false
            ini.settings.anniversaryShown = true
            def.settings.anniversaryShown = true
            inicfg.save(def, directIni)
        end
    else
        imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.45)
        imgui.Button(string.format(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC (%d)"), remain), imgui.ImVec2(-1, 32))
        imgui.PopStyleVar()
    end
    imgui.End()
end

function draw_crash_window()
    if crash.v then
        imgui.Begin(' ', crash, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    end
end

function draw_quest_window()
    if quest_window.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 250), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(
            imgui.ImVec2(imgui.GetIO().DisplaySize.x/2, imgui.GetIO().DisplaySize.y/2),
            imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.ShowCursor = main_windows_state.v
        imgui.Begin(u8("\xD1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2"), quest_window, 0)
        if not questsTakenByBot then
            for i = 1, 4 do
                local progress = questProgress[i] or 0
                local maxProg = questMax[i] or 1
                imgui.Text(u8("\xCA\xE2\xE5\xF1\xF2\x20")..i..": "..progress.."/"..maxProg)
                if maxProg > 0 then
                    imgui.ProgressBar(progress / maxProg, imgui.ImVec2(-1, 20))
                end
            end
        else
            imgui.Text(u8("\xC1\xEE\xF2\x20\xED\xE5\x20\xE0\xEA\xF2\xE8\xE2\xE5\xED\x20\xE8\xEB\xE8\x20\xEA\xE2\xE5\xF1\xF2\xFB\x20\xE2\xE7\xFF\xF2\xFB\x20\xE2\xF0\xF3\xF7\xED\xF3\xFE\x2E"))
        end
        if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
            quest_window.v = false
        end
        imgui.End()
    end
end

function imgui.OnDrawFrame()
	if ini.settings.style == 0 then strong_style() end
	if ini.settings.style == 1 then easy_style() end
    set_theme(ini.settings.theme)
    if main_windows_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(760, 380), imgui.Cond.FirstUseEver)
        imgui.Begin(thisScript().name..' | version '..thisScript().version, main_windows_state, 2)
        local win_pos = imgui.GetWindowPos()
        local win_size = imgui.GetWindowSize()
        if texture and ini.settings.theme == 8 then
            local draw_list = imgui.GetWindowDrawList()
            local uv0 = imgui.ImVec2(0, 0)
            local uv1 = imgui.ImVec2(1, 1)
            local color = 0xFFFFFFFF

            local bottom_offset = 0
            if ini.settings.style == 1 then
                bottom_offset = 4
            end

            draw_list:AddImage(
                texture,
                imgui.ImVec2(win_pos.x, win_pos.y),
                imgui.ImVec2(win_pos.x + win_size.x, win_pos.y + win_size.y - bottom_offset),
                uv0,
                uv1,
                color
            )
        end
        imgui.BeginChild('left pane', imgui.ImVec2(150, 0), true)
            if faico then
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20\x20")..fa.ICON_FA_ROBOT, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xED\xF2\xE8\x2D\xE3\xEE\xEB\xEE\xE4\x20\x20")..fa.ICON_FA_UTENSILS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC4\xEE\xEF\x2E\x20\xF4\xF3\xED\xEA\xF6\xE8\xE8\x20\x20")..fa.ICON_FA_INFO, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20\x20")..fa.ICON_FA_PLANE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Telegram  "..fa.ICON_FA_PAPER_PLANE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"AntiAdmin  "..fa.ICON_FA_USER_SLASH, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[6] = true
                    ini.settings.vkladka = 6
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20")..fa.ICON_FA_COGS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[7] = true
                    ini.settings.vkladka = 7
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x20\x20")..fa.ICON_FA_INFO_CIRCLE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[8] = true
                    ini.settings.vkladka = 8
                    inicfg.save(def, directIni)
                end
            else
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xED\xF2\xE8\x2D\xE3\xEE\xEB\xEE\xE4\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC4\xEE\xEF\x2E\x20\xF4\xF3\xED\xEA\xF6\xE8\xE8\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Telegram", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"AntiAdmin", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[6] = true
                    ini.settings.vkladka = 6
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[7] = true
                    ini.settings.vkladka = 7
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[8] = true
                    ini.settings.vkladka = 8
                    inicfg.save(def, directIni)
                end
            end
        imgui.EndChild()
        imgui.SameLine()

        draw_tab_bot_settings()
        draw_tab_anti_golod()
        draw_tab_dop()
        draw_tab_aviaschool()
        draw_tab_telegram()
        draw_tab_antiadmin()
        draw_tab_settings()
        draw_tab_info()
        imgui.End()
    end
    draw_theme9_window()
    draw_changelog_window()
    draw_anniversary_window()
    draw_crash_window()
    draw_quest_window()
    if calc_window.v then
        drawCalculatorWindow()
    end

    drawFarmStatsHud()
    drawRouteHud()
    drawKukPositionGuide()
    local statsHudVisible = farmStats.showHud and (state or work1 or work2 or work3 or farmStats.earned > 0 or farmStats.skill > 0)
    local anyMenuOpen = main_windows_state.v or crash.v or quest_window.v or calc_window.v or changelog_window.v or anniversary_window.v
    if kukGuide.alpha > 0.01 and not anyMenuOpen and not farmStats.hovered then
        imgui.ShowCursor = false
    else
        imgui.ShowCursor = anyMenuOpen or farmStats.hovered or not statsHudVisible
    end
end

function drawFarmStatsHud()
    farmStats.hovered = false
    if not farmStats.showHud then return end
    if not (state or work1 or work2 or work3) then return end

    local dragging = farmStats.hoveredPrev and imgui.IsMouseDown(0)
    if not dragging then
        imgui.SetNextWindowPos(imgui.ImVec2(ini.settings.statsX, ini.settings.statsY), imgui.Cond.Always)
    end
    if imgui.SetNextWindowBgAlpha then
        imgui.SetNextWindowBgAlpha(0.72)
    end
    local wf = imgui.WindowFlags
    local flags = 0
    for _, name in ipairs({"NoTitleBar", "NoResize", "AlwaysAutoResize",
        "NoSavedSettings", "NoFocusOnAppearing", "NoNav", "NoNavInputs", "NoNavFocus"}) do
        if wf[name] then flags = flags + wf[name] end
    end
    imgui.Begin("##FarmBotStats", nil, flags)
    imgui.TextColored(imgui.ImVec4(1.0, 0.84, 0.0, 1.0), u8("\xD1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0 \xF4\xE5\xF0\xEC\xE5\xF0\xE0"))
    imgui.Separator()
    imgui.Text(u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xE0\xED\xEE: ") .. "$" .. formatNumber(farmStats.earned))
    if farmStats.skill > 0 or farmStats.skillMax > 0 then
        imgui.Text(u8("\xCD\xE0\xE2\xFB\xEA \xF4\xE5\xF0\xEC\xE5\xF0\xE0: ") .. formatNumber(farmStats.skill) .. "/" .. formatNumber(farmStats.skillMax))
        local progress = farmStats.skillMax > 0 and math.min(1, farmStats.skill / farmStats.skillMax) or 0
        imgui.ProgressBar(progress, imgui.ImVec2(220, 12))
    else
        imgui.Text(u8("\xCD\xE0\xE2\xFB\xEA \xF4\xE5\xF0\xEC\xE5\xF0\xE0: —"))
    end

    local hasQuest = false
    for i = 1, 4 do
        if (questProgress[i] or 0) > 0 or (questMax[i] or 0) > 0 then
            hasQuest = true
            break
        end
    end
    if hasQuest and not questsTakenByBot then
        imgui.Separator()
        imgui.TextColored(imgui.ImVec4(0.4, 0.85, 1.0, 1.0), u8("\xCA\xE2\xE5\xF1\xF2\xFB:"))
        local qnames = {
            u8("\xCA\xE2\xE5\xF1\xF2 1"),
            u8("\xCA\xE2\xE5\xF1\xF2 2"),
            u8("\xCA\xE2\xE5\xF1\xF2 3"),
            u8("\xCA\xE2\xE5\xF1\xF2 4")
        }
        for i = 1, 4 do
            local progress = questProgress[i] or 0
            local maxProg = questMax[i] or 1
            if maxProg > 0 then
                imgui.Text(string.format("%s: %d/%d", qnames[i], progress, maxProg))
                imgui.ProgressBar(math.min(1, progress / maxProg), imgui.ImVec2(220, 20))
            end
        end
    end

    local pos = imgui.GetWindowPos()
    local winSize = imgui.GetWindowSize()
    local mp = imgui.GetMousePos()
    farmStats.hovered = mp.x >= pos.x and mp.x <= pos.x + winSize.x and mp.y >= pos.y and mp.y <= pos.y + winSize.y
    if imgui.IsMouseDown(0) and farmStats.hovered then
        ini.settings.statsX = math.floor(pos.x + 0.5)
        ini.settings.statsY = math.floor(pos.y + 0.5)
        farmStats.posDirty = true
        farmStats.posTimer = os.clock()
    end
    imgui.End()
    farmStats.hoveredPrev = farmStats.hovered
end

function uu()
    for i = 0,8 do
        vkladki[i] = false
    end
end

function calculateScenario(roleIdx, vip, axe)
    local result = ''
    if roleIdx == 0 then
        if vip and axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x31\x32\x35\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x30\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x35\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x31\x32\x35\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x2E\x36\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x35\x30\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x36\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x30\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x35\x30\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x36\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x35\x30\x2E\x30\x30\x30\x24")
        end
    elseif roleIdx == 1 then
        if vip and axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x33\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x32\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x32\x2E\x34\x32\x35\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x32\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x33\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x32\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x37\x2E\x34\x37\x35\x2E\x30\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x36\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x34\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x34\x2E\x38\x35\x30\x2E\x30\x30\x30\x24")
        else
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x36\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x34\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x37\x2E\x32\x35\x30\x2E\x30\x30\x30\x24")
        end
    elseif roleIdx == 2 then
        if vip and axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x34\x2E\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x32\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x31\x20\xF7\xE0\xF1\x20\x33\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x2E\x32\x32\x39\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x33\x2E\x36\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x32\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x31\x20\xF7\xE0\xF1\x20\x33\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x2E\x30\x35\x39\x2E\x32\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x34\x2E\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x34\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x20\xF7\xE0\xF1\xE0\x20\x31\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x36\x2E\x34\x35\x36\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x33\x2E\x36\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x34\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x20\xF7\xE0\xF1\xE0\x20\x31\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x2E\x31\x31\x38\x2E\x34\x30\x30\x24")
        end
    elseif roleIdx == 3 then
        if vip and axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x33\x37\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x38\x2E\x33\x37\x32\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x38\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x32\x2E\x38\x30\x30\x2E\x30\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x33\x37\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x38\x2E\x33\x37\x32\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x38\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x32\x2E\x38\x30\x30\x2E\x30\x30\x30\x24")
        end
    end
    scenarioText = result
end
-------------------------------Neobhodimie potoki pispis-------------------------------------------
huy222 = true
lua_thread.create(function()
    while true do
        wait(0)
        if ww == true then
            wait(2000)
            ww = false
        end
        if not huy228 then
            wait(5000)
            huy228 = true
        end
    end
end)

lua_thread.create(function()
    while true do
        wait(0)
        if ww then
            lua_thread.create(function()
            while ww do
                wait(0)
                setGameKeyState(0,255)
                setGameKeyState(14, 255)
            end setGameKeyState(0,0) setGameKeyState(14, 0)end)
        end
    end
end)
-------------------------------Govnokod na 1000%-------------------------------------------
function rideTo(x, y, z, speed, radius, workType)
    radius = radius or 1.2
    workType = workType or 1

    while true do
        wait(0)
        if (workType == 1 and not work1) or (workType == 2 and not work2) then break end
        local veh = getCarCharIsUsing(PLAYER_PED)
        if not isCharInCar(PLAYER_PED, veh) then break end

        local posX, posY, posZ = GetCoordinates()
        local dista = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)

        if dista < radius then
            setGameKeyState(6, 0)
            setGameKeyState(16, 0)
            break
        end
        local pX, pY = x - posX, y - posY
        local targetHeading = getHeadingFromVector2d(pX, pY)
        local carHeading = getCarHeading(veh)
        local angsum = (360 - carHeading + targetHeading) % 360
        local diff = angsum < 180 and angsum or (360 - angsum)
        local steer = 0

        if diff > 15 then
            steer = angsum < 180 and -255 or 255
        elseif diff > 5 then
            steer = angsum < 180 and -120 or 120
        elseif diff > 1 then
            steer = angsum < 180 and -40 or 40
        end

        setGameKeyState(0, steer)
        turnLeft  = steer < 0
        turnRight = steer > 0
        local targetSpeed = speed
        if workType == 1 then
            if dista < 15 then targetSpeed = speed * 0.15 end
        else
            if dista < 35 then targetSpeed = speed * 0.15 end
            if dista < 10 then targetSpeed = speed * 0.07 end
        end

        local speedNow = getCarSpeed(veh)
        if not ww then
            if speedNow < targetSpeed then
                setGameKeyState(6, 0)
                setGameKeyState(16, 255)
            elseif speedNow > targetSpeed then
                setGameKeyState(16, 0)
                setGameKeyState(6, 255)
            end
        end
    end

    turnLeft, turnRight = false, false
end

local function startRoute(routeName)
    vars.route.state = true
    vars.route.name = routeName
    vars.route.packets = 0
    vars.route.currentPos = { x = -1, y = -1, z = -1 }
    var_0_10.v = true
    local filePath = farm_route_path(routeName)
    if filePath then
        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20") .. routeName .. ("\x20\xE7\xE0\xEF\xF3\xF9\xE5\xED"))
        while vars.route.state and work3 do
            wait(100)
        end
    else
        msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..filePath)
        work3 = false
    end
end

function toggleNoCollisionObjects(enableCollision)
    for _, handle in ipairs(getAllObjects()) do
        if doesObjectExist(handle) then
            local model = getObjectModel(handle)
            for _, objId in ipairs(noCollisionObjects) do
                if model == objId then
                    setObjectCollision(handle, enableCollision)
                end
            end
        end
    end
end

function GetCoordinates()
    if isCharInAnyCar(PLAYER_PED) then
        local car = storeCarCharIsInNoSave(PLAYER_PED)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(PLAYER_PED)
    end
end

function getNearestVehicle(radius)
    if not sampIsLocalPlayerSpawned() then return end
    local pVehicle = getLocalVehicle()
    local pCoords = {getCharCoordinates(PLAYER_PED)}
    local vehicles = getAllVehicles()
    table.sort(vehicles, function(a, b)
        local aX, aY, aZ = getCarCoordinates(a)
        local bX, bY, bZ = getCarCoordinates(b)
        return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
    end)
    for i = #vehicles, 1, -1 do
        if vehicles[i] == pVehicle then
            table.remove(vehicles, i)
        elseif radius ~= nil then
            local x, y, z = getCarCoordinates(vehicles[i])
            if getDistanceBetweenCoords3d(x, y, z, unpack(pCoords)) > radius then
                table.remove(vehicles, i)
            end
        end
    end
    return vehicles[1]
end

function getLocalVehicle()
    return isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
end

function WorkInBackground(work)
    local memory = require 'memory'
    if work then
        memory.setuint8(7634870, 1)
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
    else
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
    end
end

function onScriptTerminate(LuaScript, quitGame)
    if LuaScript == thisScript() and not quitGame and not ini.settings.reload and not ini.settings.reloadR then
        sampShowDialog(6405, ("\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xCF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0\x21"), ("\x7B\x46\x46\x46\x46\x46\x46\x7D\xDD\xF2\xEE\xF2\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xEC\xEE\xE6\xE5\xF2\x20\xE1\xFB\xF2\xFC\x20\xEB\xEE\xE6\xED\xFB\xEC\x2C\x20\xE5\xF1\xEB\xE8\x20\xE2\xFB\x20\n\xE8\xF1\xEF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xEB\xE8\x20\xF1\xEA\xF0\xE8\xEF\xF2\x20\x41\x75\x74\x6F\x52\x65\x62\x6F\x6F\x74\x20\n\xCA\x20\xF1\xEE\xE6\xE0\xEB\xE5\xED\xE8\xFE\x20\xF1\xEA\xF0\xE8\xEF\xF2\x20\x7B\x46\x31\x43\x42\x30\x39\x7D\x46\x61\x72\x6D\x2D\x42\x6F\x74\x7B\x46\x46\x46\x46\x46\x46\x7D\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\xF1\xFF\x20\xED\xE5\xF3\xE4\xE0\xF7\xED\xEE\n\xC5\xF1\xEB\xE8\x20\xE2\xFB\x20\xF5\xEE\xF2\xE8\xF2\xE5\x20\xEF\xEE\xEC\xEE\xF7\xFC\x20\xF0\xE0\xE7\xF0\xE0\xE1\xEE\xF2\xF7\xE8\xEA\xF3\n\xD2\xEE\x20\xEC\xEE\xE6\xE5\xF2\xE5\x20\xEE\xEF\xE8\xF1\xE0\xF2\xFC\x20\xEF\xF0\xE8\x20\xEA\xE0\xEA\xEE\xEC\x20\xE4\xE5\xE9\xF1\xF2\xE2\xE8\xE8\x20\xEF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0\n\xD2\xE5\xEC\xE0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20\x7B\x30\x30\x39\x39\x43\x43\x7D\x68\x74\x74\x70\x73\x3A\x2F\x2F\x77\x77\x77\x2E\x62\x6C\x61\x73\x74\x2E\x68\x6B\x2F\x74\x68\x72\x65\x61\x64\x73\x2F\x32\x33\x37\x32\x31\x39"), ("\xCE\xCA"), "", DIALOG_STYLE_MSGBOX)
        SCM(("\xCF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0"))
        showCursor(false, false)
    end
end

function SCM(arg1)
    if invisible.v then
        print(arg1)
    else
        sampAddChatMessage("[Farm-bot]: {FFFFFF}"..arg1, 0xF1CB09)
    end
end

--------------------------------------------------------TELEGRAM----------------------------------------------------

---------------------------------------------https://youtu.be/XZF91nSs7wA-------------------------------------------

--------------------------------------------------------------------------------------------------------------------
function threadHandle(runner, url, args, resolve, reject)
    local t = runner(url, args)
    local r = t:get(0)
    while not r do
        r = t:get(0)
        wait(0)
    end

    local status = t:status()

    if status == 'completed' then
        local ok, result = r[1], r[2]
        if ok then resolve(result) else reject(result) end
    elseif status == 'canceled' then
        reject(status)
    else
        reject('unknown error')
    end

    t:cancel(0)
end

function requestRunner()
    return effil.thread(function(u, a)
        local https = require 'ssl.https'
        local ok, result = pcall(https.request, u, a)
        if ok then
            return {true, result}
        else
            return {false, result}
        end
    end)
end

function async_http_request(url, args, resolve, reject)
    local runner = requestRunner()
    if not reject then reject = function() end end
    lua_thread.create(function()
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. msg, '', function(result)
    end)
end

function get_telegram_updates()
    while not updateid do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

function processing_telegram_messages(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user) .. ' '
                            if text:match('^!stats') then
                                waitingForStatsTelegram = true
                                sampSendChat("/stats")

                            elseif text:match('^!send') then
                                local sendMessageTelegram = text:match('^!send (.+)')
                                sampSendChat(sendMessageTelegram)
                                sendTelegramNotification(("\xD1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xEE\xF2\xEF\xF0\xE0\xE2\xEB\xE5\xED\xEE\x20\xE2\x20\xF7\xE0\xF2\x20\xE8\xE3\xF0\xFB\x3A\x20") .. sendMessageTelegram)

                            elseif text:match('^!exit') then
                                sampProcessChatInput('/q')
                                sendTelegramNotification(("\xC2\xFB\xF8\xE5\xEB\x21"))
                            elseif text:match('^!hp') then
                                local health = getCharHealth(PLAYER_PED)
                                sendTelegramNotification(("\xC2\xE0\xF8\xE5\x20\xF5\xEF\x3A\x20")..health)
                            elseif text:match('^!start') then
                                local job = text:match('^!start (%a+)')
                                if job then
                                    if job == "ferma" then
                                        if not state then
                                            state = true
                                            state_taked = false
                                            farmStats.earned = 0
                                            sendTelegramNotification(("\xC1\xEE\xF2\x20\xED\xE0\xF7\xE0\xEB\xFC\xED\xEE\xE9\x20\xF4\xE5\xF0\xEC\xFB\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                        else
                                            sendTelegramNotification(("\xC1\xEE\xF2\x20\xF3\xE6\xE5\x20\xF0\xE0\xE1\xEE\xF2\xE0\xE5\xF2\x21"))
                                        end

                                    elseif job == "traktorist" then
                                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                work1 = true
                                                gopay = false
                                                value1 = 0
                                                num = 0
                                                ensureVehicleEngine()
                                                sendTelegramNotification(("\xC1\xEE\xF2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\xE0\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))

                                                lua_thread.create(function()
                                                    rideTo(-118.1747, 97.4916, 3.0650, 60, nil, 1)
                                                end)
                                            else
                                                sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E"))
                                            end
                                        else
                                            sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E"))
                                        end
                                    elseif job == "kombainer" then
                                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                work2 = true
                                                value1 = 0
                                                num = 0
                                                ensureVehicleEngine()
                                                sendTelegramNotification(("\xC1\xEE\xF2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))

                                                lua_thread.create(function()
                                                    rideTo(-185.1780, -84.2181, 4.0672, 45, nil, 2)
                                                end)
                                            else
                                                sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E"))
                                            end
                                        else
                                            sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E"))
                                        end
                                    elseif job == "kukuruznik" then
                                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                            if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                work3 = true
                                                farmStats.earned = 0
                                                ensureVehicleEngine()
                                                lua_thread.create(function()
                                                    startRoute("leti")
                                                    while work3 do
                                                        startRoute("leti3")
                                                    end
                                                end)
                                                sendTelegramNotification(u8("\xC1\xEE\xF2 \xE2\xEE\xE4\xE8\xF2\xE5\xEB\xFF \xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0 \xE2\xEA\xEB\xFE\xF7\xE5\xED!"))
                                            else
                                                sendTelegramNotification(u8("\xC2\xFB \xED\xE5 \xE2 \xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5."))
                                            end
                                        else
                                            sendTelegramNotification(u8("\xC2\xFB \xED\xE5 \xE2 \xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5."))
                                        end
                                    else
                                        sendTelegramNotification(u8("\xCD\xE5\xE2\xE5\xF0\xED\xE0\xFF \xF0\xE0\xE1\xEE\xF2\xE0. \xC4\xEE\xF1\xF2\xF3\xEF\xED\xFB\xE5 \xF0\xE0\xE1\xEE\xF2\xFB: ferma, traktorist, kombainer, kukuruznik"))
                                    end
                                else
                                    sendTelegramNotification(u8("\xD3\xEA\xE0\xE6\xE8\xF2\xE5 \xF0\xE0\xE1\xEE\xF2\xF3: !start <\xF0\xE0\xE1\xEE\xF2\xE0>"))
                                end

                                                        elseif text:match('^!stop') then
                                if state then
                                    state = false
                                    state_taked = false
                                    walking = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xED\xE0\xF7\xE0\xEB\xFC\xED\xEE\xE9\x20\xF4\xE5\xF0\xEC\xFB\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work1 then
                                    work1 = false
                                    gopay = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work2 then
                                    work2 = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work3 then
                                    work3 = false
                                    vars.route.state = false
                                    vars.route.name = ''
                                    vars.route.packets = 0
                                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                                    var_0_10.v = false
                                    farmStats.earned = 0
                                    farmStats.skill = 0
                                    if isCharInAnyCar(PLAYER_PED) then
                                        freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                                    else
                                        freezeCharPosition(PLAYER_PED, false)
                                    end
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xE2\xEE\xE4\xE8\xF2\xE5\xEB\xFF\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                else
                                    sendTelegramNotification(("\xCD\xE5\xF2\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE3\xEE\x20\xE1\xEE\xF2\xE0\x20\xE4\xEB\xFF\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEA\xE8\x2E"))
                                end

                            elseif text:match('^!close') then
                                lua_thread.create(function()
                                    wait(math.random(control.skip1.v, control.skip2.v))
                                    setVirtualKeyDown(27, true)
                                    wait(50)
                                    setVirtualKeyDown(27, false)
                                end)
                                sendTelegramNotification(("\xC4\xE8\xE0\xEB\xEE\xE3\x20\xE7\xE0\xEA\xF0\xFB\xF2\x21"))

                            elseif text:match('^!crash') then
                                crash.v = not crash.v
                                sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x21"))
                            else
                                sendTelegramNotification(("\xCD\xE5\xE8\xE7\xE2\xE5\xF1\xF2\xED\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x21"))
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate()
    async_http_request('https://api.telegram.org/bot' .. token .. '/getUpdates?chat_id=' .. chat_id .. '&offset=-1', '', function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table and proc_table.ok then
                if #proc_table.result > 0 then
                    updateid = proc_table.result[1].update_id
                else
                    updateid = 1
                end
            end
        end
    end)
end

function decodeJson(jsonString)
    local success, result = pcall(function() return json.decode(jsonString) end)
    if success then
        return result
    else
        return nil
    end
end

function warning()
    while true do
        wait(0)
        if warn then
            for i = 1, 20 do
                renderDrawBox(0, 0, X, Y, 0x80ff0037)
                wait(10)
                renderDrawBox(0, 0, X, Y, 0x80170038)
                wait(10)
            end
            warn = false
        end
    end
end

function warning2()
    while true do
        wait(0)
        if warn2 then
            for i = 1, 20 do
                renderDrawBox(0, 0, X, Y, 0x80ff0037)
                wait(10)
                renderDrawBox(0, 0, X, Y, 0x80170038)
                wait(10)
            end
            warn2 = false
        end
    end
end

--------------------------------------------------------THEME----------------------------------------------------
local function apply_theme(t)
    local c, Im = imgui.GetStyle().Colors, imgui.ImVec4
    local Col = imgui.Col
    for k, v in pairs(t) do
        c[Col[k]] = Im(v[1], v[2], v[3], v[4] or 1)
    end
end

local themes = {
    [1] = {
        Text={0.8,0.8,0.83}, TextDisabled={0.24,0.23,0.29},WindowBg={0.06,0.05,0.07},ChildWindowBg={0.07,0.07,0.09},
        PopupBg={0.07,0.07,0.09},Border={0.8,0.8,0.83,0.88},BorderShadow={0.92,0.91,0.88,0},FrameBg={0.1,0.09,0.12},
        FrameBgHovered={0.24,0.23,0.29},FrameBgActive={0.56,0.56,0.58},TitleBg={0.1,0.09,0.12},TitleBgCollapsed={1,0.98,0.95,0.75},
        TitleBgActive={0.07,0.07,0.09},MenuBarBg={0.1,0.09,0.12},ScrollbarBg={0.1,0.09,0.12},ScrollbarGrab={0.8,0.8,0.83,0.31},
        ScrollbarGrabHovered={0.56,0.56,0.58},ScrollbarGrabActive={0.06,0.05,0.07},ComboBg={0.19,0.18,0.21},
        CheckMark={0.8,0.8,0.83,0.31},SliderGrab={0.8,0.8,0.83,0.31},SliderGrabActive={0.06,0.05,0.07},
        Button={0.1,0.09,0.12},ButtonHovered={0.24,0.23,0.29},ButtonActive={0.56,0.56,0.58},
        Header={0.1,0.09,0.12},HeaderHovered={0.56,0.56,0.58},HeaderActive={0.06,0.05,0.07},
        ResizeGrip={0,0,0,0},ResizeGripHovered={0.56,0.56,0.58},ResizeGripActive={0.06,0.05,0.07},
        CloseButton={0.4,0.39,0.38,0.16},CloseButtonHovered={0.4,0.39,0.38,0.39},CloseButtonActive={0.4,0.39,0.38},
        PlotLines={0.4,0.39,0.38,0.63},PlotLinesHovered={0.25,1,0},PlotHistogram={0.4,0.39,0.38,0.63},
        PlotHistogramHovered={0.25,1,0},TextSelectedBg={0.25,1,0,0.43},ModalWindowDarkening={1,0.98,0.95,0.73}
    },
    [2] = {
        FrameBg={0.16,0.29,0.48,0.54},FrameBgHovered={0.26,0.59,0.98,0.4},FrameBgActive={0.26,0.59,0.98,0.67},
        TitleBg={0.04,0.04,0.04},TitleBgActive={0.16,0.29,0.48},TitleBgCollapsed={0,0,0,0.51},
        CheckMark={0.26,0.59,0.98},SliderGrab={0.24,0.52,0.88},SliderGrabActive={0.26,0.59,0.98},
        Button={0.26,0.59,0.98,0.4},ButtonHovered={0.26,0.59,0.98},ButtonActive={0.06,0.53,0.98},
        Header={0.26,0.59,0.98,0.31},HeaderHovered={0.26,0.59,0.98,0.8},HeaderActive={0.26,0.59,0.98},
        SeparatorHovered={0.26,0.59,0.98,0.78},SeparatorActive={0.26,0.59,0.98},
        ResizeGrip={0.26,0.59,0.98,0.25},ResizeGripHovered={0.26,0.59,0.98,0.67},ResizeGripActive={0.26,0.59,0.98,0.95},
        TextSelectedBg={0.26,0.59,0.98,0.35},Text={1,1,1},TextDisabled={0.5,0.5,0.5},
        WindowBg={0.06,0.06,0.06,0.94},ChildWindowBg={1,1,1,0},PopupBg={0.08,0.08,0.08,0.94},
        Border={0.43,0.43,0.5,0.5},BorderShadow={0,0,0,0},MenuBarBg={0.14,0.14,0.14},
        ScrollbarBg={0.02,0.02,0.02,0.53},ScrollbarGrab={0.31,0.31,0.31},ScrollbarGrabHovered={0.41,0.41,0.41},
        ScrollbarGrabActive={0.51,0.51,0.51},CloseButton={0.41,0.41,0.41,0.5},CloseButtonHovered={0.98,0.39,0.36},
        CloseButtonActive={0.98,0.39,0.36},PlotLines={0.61,0.61,0.61},PlotLinesHovered={1,0.43,0.35},
        PlotHistogram={0.9,0.7,0},PlotHistogramHovered={1,0.6,0},ModalWindowDarkening={0.8,0.8,0.8,0.35}
    },
    [3] = {
        FrameBg={0.48,0.16,0.16,0.54},FrameBgHovered={0.98,0.26,0.26,0.4},FrameBgActive={0.98,0.26,0.26,0.67},
        TitleBg={0.04,0.04,0.04},TitleBgActive={0.48,0.16,0.16},TitleBgCollapsed={0,0,0,0.51},
        CheckMark={0.98,0.26,0.26},SliderGrab={0.88,0.26,0.24},SliderGrabActive={0.98,0.26,0.26},
        Button={0.98,0.26,0.26,0.4},ButtonHovered={0.98,0.26,0.26},ButtonActive={0.98,0.06,0.06},
        Header={0.98,0.26,0.26,0.31},HeaderHovered={0.98,0.26,0.26,0.8},HeaderActive={0.98,0.26,0.26},
        SeparatorHovered={0.75,0.1,0.1,0.78},SeparatorActive={0.75,0.1,0.1},
        ResizeGrip={0.98,0.26,0.26,0.25},ResizeGripHovered={0.98,0.26,0.26,0.67},ResizeGripActive={0.98,0.26,0.26,0.95},
        TextSelectedBg={0.98,0.26,0.26,0.35},Text={1,1,1},TextDisabled={0.5,0.5,0.5},
        WindowBg={0.06,0.06,0.06,0.94},ChildWindowBg={1,1,1,0},PopupBg={0.08,0.08,0.08,0.94},
        Border={0.43,0.43,0.5,0.5},BorderShadow={0,0,0,0},MenuBarBg={0.14,0.14,0.14},
        ScrollbarBg={0.02,0.02,0.02,0.53},ScrollbarGrab={0.31,0.31,0.31},ScrollbarGrabHovered={0.41,0.41,0.41},
        ScrollbarGrabActive={0.51,0.51,0.51},CloseButton={0.41,0.41,0.41,0.5},CloseButtonHovered={0.98,0.39,0.36},
        CloseButtonActive={0.98,0.39,0.36},PlotLines={0.61,0.61,0.61},PlotLinesHovered={1,0.43,0.35},
        PlotHistogram={0.9,0.7,0},PlotHistogramHovered={1,0.6,0},ModalWindowDarkening={0.8,0.8,0.8,0.35}
    },
    [4] = {
        FrameBg={0.16,0.48,0.42,0.54},FrameBgHovered={0.26,0.98,0.85,0.4},FrameBgActive={0.26,0.98,0.85,0.67},
        TitleBg={0.04,0.04,0.04},TitleBgActive={0.16,0.48,0.42},TitleBgCollapsed={0,0,0,0.51},
        CheckMark={0.26,0.98,0.85},SliderGrab={0.24,0.88,0.77},SliderGrabActive={0.26,0.98,0.85},
        Button={0.26,0.98,0.85,0.4},ButtonHovered={0.26,0.98,0.85},ButtonActive={0.06,0.98,0.82},
        Header={0.26,0.98,0.85,0.31},HeaderHovered={0.26,0.98,0.85,0.8},HeaderActive={0.26,0.98,0.85},
        SeparatorHovered={0.1,0.75,0.63,0.78},SeparatorActive={0.1,0.75,0.63},
        ResizeGrip={0.26,0.98,0.85,0.25},ResizeGripHovered={0.26,0.98,0.85,0.67},ResizeGripActive={0.26,0.98,0.85,0.95},
        PlotLines={0.61,0.61,0.61},PlotLinesHovered={1,0.81,0.35},TextSelectedBg={0.26,0.98,0.85,0.35},
        Text={1,1,1},TextDisabled={0.5,0.5,0.5},WindowBg={0.06,0.06,0.06,0.94},ChildWindowBg={1,1,1,0},
        PopupBg={0.08,0.08,0.08,0.94},Border={0.43,0.43,0.5,0.5},BorderShadow={0,0,0,0},MenuBarBg={0.14,0.14,0.14},
        ScrollbarBg={0.02,0.02,0.02,0.53},ScrollbarGrab={0.31,0.31,0.31},ScrollbarGrabHovered={0.41,0.41,0.41},
        ScrollbarGrabActive={0.51,0.51,0.51},CloseButton={0.41,0.41,0.41,0.5},CloseButtonHovered={0.98,0.39,0.36},
        CloseButtonActive={0.98,0.39,0.36},PlotHistogram={0.9,0.7,0},PlotHistogramHovered={1,0.6,0},
        ModalWindowDarkening={0.8,0.8,0.8,0.35}
    },
    [5] = {
        Text={1,1,1},TextDisabled={0.5,0.5,0.5},WindowBg={0,0,0,0.895},ChildWindowBg={0,0,0,0},
        PopupBg={0.07,0.07,0.09},Border={0.184,0.878,0,0.5},BorderShadow={1,1,1,0.1},
        TitleBg={0.026,0.597,0},TitleBgCollapsed={0.099,0.315,0,0},TitleBgActive={0.026,0.597,0},
        MenuBarBg={0.16,0.16,0.16},ScrollbarBg={0,0,0,0.801},ScrollbarGrab={0.238,0.238,0.238},
        ScrollbarGrabHovered={0.238,0.238,0.238},ScrollbarGrabActive={0.004,0.381,0},
        CheckMark={0.009,0.845,0},SliderGrab={0.139,0.508,0},SliderGrabActive={0.139,0.508,0},
        Button={0.026,0.597,0},ButtonHovered={0,0.8,0},ButtonActive={0,1,0},
        FrameBg={0.026,0.597,0,0.541},FrameBgHovered={0,0.8,0,0.4},FrameBgActive={0,1,0,0.671},
        Header={0.026,0.597,0,0.541},HeaderHovered={0,0.8,0,0.8},HeaderActive={0,1,0},
        ResizeGrip={0,1,0.221,0.597},ResizeGripHovered={0,0.8,0,0.67},ResizeGripActive={0,1,0,0.95},
        PlotLines={0,0.7,0},PlotLinesHovered={0,1,0},PlotHistogram={0,0.6,0},PlotHistogramHovered={0,0.8,0},
        TextSelectedBg={0,0.4,0,0.35},ModalWindowDarkening={0.2,0.2,0.2,0.35},
        CloseButton={0.4,0.39,0.38,0.16},CloseButtonHovered={0.4,0.39,0.38,0.39},CloseButtonActive={0.4,0.39,0.38}
    },
    [6] = {
        Text={0.9,0.9,0.9},TextDisabled={0.24,0.23,0.29},WindowBg={0.06,0.05,0.07},ChildWindowBg={0.07,0.07,0.09},
        PopupBg={0.07,0.07,0.09},Border={0.8,0.8,0.83,0.88},BorderShadow={0.92,0.91,0.88,0},FrameBg={0.1,0.09,0.12},
        FrameBgHovered={0.24,0.23,0.29},FrameBgActive={0.56,0.56,0.58},TitleBg={0.76,0.31,0},TitleBgCollapsed={1,0.98,0.95,0.75},
        TitleBgActive={0.8,0.33,0},MenuBarBg={0.1,0.09,0.12},ScrollbarBg={0.1,0.09,0.12},ScrollbarGrab={0.8,0.8,0.83,0.31},
        ScrollbarGrabHovered={0.56,0.56,0.58},ScrollbarGrabActive={0.06,0.05,0.07},ComboBg={0.19,0.18,0.21},
        CheckMark={1,0.42,0,0.53},SliderGrab={1,0.42,0,0.53},SliderGrabActive={1,0.42,0},
        Button={0.1,0.09,0.12},ButtonHovered={0.24,0.23,0.29},ButtonActive={0.56,0.56,0.58},
        Header={0.1,0.09,0.12},HeaderHovered={0.56,0.56,0.58},HeaderActive={0.06,0.05,0.07},
        ResizeGrip={0,0,0,0},ResizeGripHovered={0.56,0.56,0.58},ResizeGripActive={0.06,0.05,0.07},
        CloseButton={0.4,0.39,0.38,0.16},CloseButtonHovered={0.4,0.39,0.38,0.39},CloseButtonActive={0.4,0.39,0.38},
        PlotLines={0.4,0.39,0.38,0.63},PlotLinesHovered={0.25,1,0},PlotHistogram={0.4,0.39,0.38,0.63},
        PlotHistogramHovered={0.25,1,0},TextSelectedBg={0.25,1,0,0.43},ModalWindowDarkening={1,0.98,0.95,0.73}
    },
    [7] = {
        WindowBg={0.14,0.12,0.16},ChildWindowBg={0.3,0.2,0.39,0},PopupBg={0.05,0.05,0.1,0.9},
        Border={0.89,0.85,0.92,0.3},BorderShadow={0,0,0,0},FrameBg={0.3,0.2,0.39},
        FrameBgHovered={0.41,0.19,0.63,0.68},FrameBgActive={0.41,0.19,0.63},TitleBg={0.41,0.19,0.63,0.45},
        TitleBgCollapsed={0.41,0.19,0.63,0.35},TitleBgActive={0.41,0.19,0.63,0.78},MenuBarBg={0.3,0.2,0.39,0.57},
        ScrollbarBg={0.3,0.2,0.39},ScrollbarGrab={0.41,0.19,0.63,0.31},ScrollbarGrabHovered={0.41,0.19,0.63,0.78},
        ScrollbarGrabActive={0.41,0.19,0.63},ComboBg={0.3,0.2,0.39},CheckMark={0.56,0.61,1},
        SliderGrab={0.41,0.19,0.63,0.24},SliderGrabActive={0.41,0.19,0.63},Button={0.41,0.19,0.63,0.44},
        ButtonHovered={0.41,0.19,0.63,0.86},ButtonActive={0.64,0.33,0.94},Header={0.41,0.19,0.63,0.76},
        HeaderHovered={0.41,0.19,0.63,0.86},HeaderActive={0.41,0.19,0.63},ResizeGrip={0.41,0.19,0.63,0.2},
        ResizeGripHovered={0.41,0.19,0.63,0.78},ResizeGripActive={0.41,0.19,0.63},
        CloseButton={1,1,1,0.75},CloseButtonHovered={0.88,0.74,1,0.59},CloseButtonActive={0.88,0.85,0.92},
        PlotLines={0.89,0.85,0.92,0.63},PlotLinesHovered={0.41,0.19,0.63},PlotHistogram={0.89,0.85,0.92,0.63},
        PlotHistogramHovered={0.41,0.19,0.63},TextSelectedBg={0.41,0.19,0.63,0.43},ModalWindowDarkening={0.2,0.2,0.2,0.35}
    },
    [8] = {
        Text={0.9,0.9,0.9},TextDisabled={1,1,1},WindowBg={0,0,0},ChildWindowBg={0,0,0},PopupBg={0,0,0},
        Border={0.82,0.77,0.78},BorderShadow={0.35,0.35,0.35,0.66},FrameBg={1,1,1,0.28},
        FrameBgHovered={0.68,0.68,0.68,0.67},FrameBgActive={0.79,0.73,0.73,0.62},TitleBg={0,0,0},
        TitleBgActive={0.46,0.46,0.46},TitleBgCollapsed={0,0,0},MenuBarBg={0,0,0,0.8},
        ScrollbarBg={0,0,0,0.6},ScrollbarGrab={1,1,1,0.87},ScrollbarGrabHovered={1,1,1,0.79},
        ScrollbarGrabActive={0.8,0.5,0.5,0.4},ComboBg={0.24,0.24,0.24,0.99},CheckMark={0.99,0.99,0.99,0.52},
        SliderGrab={1,1,1,0.42},SliderGrabActive={0.76,0.76,0.76},Button={0.51,0.51,0.51,0.6},
        ButtonHovered={0.68,0.68,0.68},ButtonActive={0.67,0.67,0.67},Header={0.72,0.72,0.72,0.54},
        HeaderHovered={0.92,0.92,0.95,0.77},HeaderActive={0.82,0.82,0.82,0.8},Separator={0.73,0.73,0.73},
        SeparatorHovered={0.81,0.81,0.81},SeparatorActive={0.74,0.74,0.74},ResizeGrip={0.8,0.8,0.8,0.3},
        ResizeGripHovered={0.95,0.95,0.95,0.6},ResizeGripActive={1,1,1,0.9},CloseButton={0.45,0.45,0.45,0.5},
        CloseButtonHovered={0.7,0.7,0.9,0.6},CloseButtonActive={0.7,0.7,0.7},PlotLines={1,1,1},
        PlotLinesHovered={1,1,1},PlotHistogram={1,1,1},PlotHistogramHovered={1,1,1},
        TextSelectedBg={1,1,1,0.35},ModalWindowDarkening={0.88,0.88,0.88,0.35}
    }
}

function theme9()
    local t9 = ini.theme9
    apply_theme{
        WindowBg={t9.WindowBg_r or 0.96,t9.WindowBg_g or 0.84,t9.WindowBg_b or 0.89,t9.WindowBg_a or 1},
        ChildWindowBg={t9.ChildWindowBg_r or 0.98,t9.ChildWindowBg_g or 0.87,t9.ChildWindowBg_b or 0.91,t9.ChildWindowBg_a or 0.5},
        Text={t9.Text_r or 1,t9.Text_g or 1,t9.Text_b or 1,t9.Text_a or 1},
        PopupBg={t9.PopupBg_r or 0.8,t9.PopupBg_g or 0.6,t9.PopupBg_b or 0.73,t9.PopupBg_a or 0.9},
        Border={t9.Border_r or 1,t9.Border_g or 0.8,t9.Border_b or 0.88,t9.Border_a or 0.3},
        BorderShadow={t9.BorderShadow_r or 0,t9.BorderShadow_g or 0,t9.BorderShadow_b or 0,t9.BorderShadow_a or 0},
        FrameBg={t9.FrameBg_r or 0.95,t9.FrameBg_g or 0.75,t9.FrameBg_b or 0.85,t9.FrameBg_a or 1},
        FrameBgHovered={t9.FrameBgHovered_r or 1,t9.FrameBgHovered_g or 0.65,t9.FrameBgHovered_b or 0.8,t9.FrameBgHovered_a or 0.68},
        FrameBgActive={t9.FrameBgActive_r or 1,t9.FrameBgActive_g or 0.65,t9.FrameBgActive_b or 0.8,t9.FrameBgActive_a or 1},
        TitleBg={t9.TitleBg_r or 0.9,t9.TitleBg_g or 0.7,t9.TitleBg_b or 0.8,t9.TitleBg_a or 0.45},
        TitleBgCollapsed={t9.TitleBgCollapsed_r or 0.9,t9.TitleBgCollapsed_g or 0.7,t9.TitleBgCollapsed_b or 0.8,t9.TitleBgCollapsed_a or 0.35},
        TitleBgActive={t9.TitleBgActive_r or 0.9,t9.TitleBgActive_g or 0.7,t9.TitleBgActive_b or 0.8,t9.TitleBgActive_a or 0.78},
        MenuBarBg={t9.MenuBarBg_r or 0.95,t9.MenuBarBg_g or 0.75,t9.MenuBarBg_b or 0.85,t9.MenuBarBg_a or 0.57},
        ScrollbarBg={t9.ScrollbarBg_r or 0.95,t9.ScrollbarBg_g or 0.75,t9.ScrollbarBg_b or 0.85,t9.ScrollbarBg_a or 1},
        ScrollbarGrab={t9.ScrollbarGrab_r or 0.85,t9.ScrollbarGrab_g or 0.55,t9.ScrollbarGrab_b or 0.75,t9.ScrollbarGrab_a or 0.31},
        ScrollbarGrabHovered={t9.ScrollbarGrabHovered_r or 0.85,t9.ScrollbarGrabHovered_g or 0.55,t9.ScrollbarGrabHovered_b or 0.75,t9.ScrollbarGrabHovered_a or 0.78},
        ScrollbarGrabActive={t9.ScrollbarGrabActive_r or 0.85,t9.ScrollbarGrabActive_g or 0.55,t9.ScrollbarGrabActive_b or 0.75,t9.ScrollbarGrabActive_a or 1},
        ComboBg={t9.ComboBg_r or 0.95,t9.ComboBg_g or 0.75,t9.ComboBg_b or 0.85,t9.ComboBg_a or 1},
        CheckMark={t9.CheckMark_r or 1,t9.CheckMark_g or 0.6,t9.CheckMark_b or 0.8,t9.CheckMark_a or 1},
        SliderGrab={t9.SliderGrab_r or 0.9,t9.SliderGrab_g or 0.65,t9.SliderGrab_b or 0.8,t9.SliderGrab_a or 0.24},
        SliderGrabActive={t9.SliderGrabActive_r or 0.9,t9.SliderGrabActive_g or 0.65,t9.SliderGrabActive_b or 0.8,t9.SliderGrabActive_a or 1},
        Button={t9.Button_r or 0.95,t9.Button_g or 0.7,t9.Button_b or 0.85,t9.Button_a or 0.44},
        ButtonHovered={t9.ButtonHovered_r or 0.95,t9.ButtonHovered_g or 0.7,t9.ButtonHovered_b or 0.85,t9.ButtonHovered_a or 0.86},
        ButtonActive={t9.ButtonActive_r or 1,t9.ButtonActive_g or 0.6,t9.ButtonActive_b or 0.85,t9.ButtonActive_a or 1},
        Header={t9.Header_r or 0.9,t9.Header_g or 0.65,t9.Header_b or 0.8,t9.Header_a or 0.76},
        HeaderHovered={t9.HeaderHovered_r or 0.9,t9.HeaderHovered_g or 0.65,t9.HeaderHovered_b or 0.8,t9.HeaderHovered_a or 0.86},
        HeaderActive={t9.HeaderActive_r or 0.9,t9.HeaderActive_g or 0.65,t9.HeaderActive_b or 0.8,t9.HeaderActive_a or 1},
        ResizeGrip={t9.ResizeGrip_r or 0.95,t9.ResizeGrip_g or 0.75,t9.ResizeGrip_b or 0.85,t9.ResizeGrip_a or 0.2},
        ResizeGripHovered={t9.ResizeGripHovered_r or 0.95,t9.ResizeGripHovered_g or 0.75,t9.ResizeGripHovered_b or 0.85,t9.ResizeGripHovered_a or 0.78},
        ResizeGripActive={t9.ResizeGripActive_r or 0.95,t9.ResizeGripActive_g or 0.75,t9.ResizeGripActive_b or 0.85,t9.ResizeGripActive_a or 1},
        CloseButton={t9.CloseButton_r or 1,t9.CloseButton_g or 0.9,t9.CloseButton_b or 0.95,t9.CloseButton_a or 0.75},
        CloseButtonHovered={t9.CloseButtonHovered_r or 1,t9.CloseButtonHovered_g or 0.8,t9.CloseButtonHovered_b or 0.9,t9.CloseButtonHovered_a or 0.59},
        CloseButtonActive={t9.CloseButtonActive_r or 1,t9.CloseButtonActive_g or 0.8,t9.CloseButtonActive_b or 0.9,t9.CloseButtonActive_a or 1},
        PlotLines={t9.PlotLines_r or 1,t9.PlotLines_g or 0.85,t9.PlotLines_b or 0.9,t9.PlotLines_a or 0.63},
        PlotLinesHovered={t9.PlotLinesHovered_r or 1,t9.PlotLinesHovered_g or 0.65,t9.PlotLinesHovered_b or 0.8,t9.PlotLinesHovered_a or 1},
        PlotHistogram={t9.PlotHistogram_r or 1,t9.PlotHistogram_g or 0.85,t9.PlotHistogram_b or 0.9,t9.PlotHistogram_a or 0.63},
        PlotHistogramHovered={t9.PlotHistogramHovered_r or 1,t9.PlotHistogramHovered_g or 0.65,t9.PlotHistogramHovered_b or 0.8,t9.PlotHistogramHovered_a or 1},
        TextSelectedBg={t9.TextSelectedBg_r or 0.95,t9.TextSelectedBg_g or 0.7,t9.TextSelectedBg_b or 0.85,t9.TextSelectedBg_a or 0.43},
        ModalWindowDarkening={t9.ModalWindowDarkening_r or 0.8,t9.ModalWindowDarkening_g or 0.6,t9.ModalWindowDarkening_b or 0.73,t9.ModalWindowDarkening_a or 0.35}
    }
end

local function apply_style(p)
    imgui.SwitchContext()
    local s = imgui.GetStyle()
    for k, v in pairs(p) do
        s[k] = type(v) == 'table' and imgui.ImVec2(v[1], v[2]) or v
    end
end

function set_theme(id)
    if id == 4 then
        local s = imgui.GetStyle()
        s.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
        s.Alpha = 1
    end
    if id == 8 then
        theme9()
    else
        apply_theme(themes[id+1])
    end
end

function easy_style()
    apply_style{
        WindowPadding={9,14},WindowRounding=10,ChildWindowRounding=10,FramePadding={5,3},
        FrameRounding=6,ItemSpacing={9,3},ItemInnerSpacing={9,3},IndentSpacing=21,
        ScrollbarSize=6,ScrollbarRounding=13,GrabMinSize=17,GrabRounding=16,
        WindowTitleAlign={0.5,0.5},ButtonTextAlign={0.5,0.5}
    }
end

function strong_style()
    apply_style{
        WindowPadding={8,8},WindowRounding=2,ChildWindowRounding=2,FramePadding={4,3},
        FrameRounding=2,ItemSpacing={5,4},ItemInnerSpacing={4,4},IndentSpacing=21,
        ScrollbarSize=13,ScrollbarRounding=0,GrabMinSize=8,GrabRounding=1,
        WindowTitleAlign={0.5,0.5},ButtonTextAlign={0.5,0.5}
    }
end
