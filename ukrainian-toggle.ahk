#Requires AutoHotkey v2.0
Persistent

; ---------- Настройки ----------
TOGGLE_KEY                := "RAlt"
FLAG_WIDTH                := 46
FLAG_HEIGHT               := 30
MARGIN_RIGHT              := 6
MARGIN_BOTTOM             := 4
MONITOR_NUMBER            := 1
COLOR_BLUE                := "0057B7"
COLOR_YELLOW              := "FFD700"
SPLIT_OFFSET              := 0
OPACITY                   := 235
AUTO_DPI_SCALE            := false
STANDARD_UA_LAYOUT        := false
AUTO_OFF_ON_LAYOUT_CHANGE := true

; ---------- Раскладка ----------
LAYOUT := Map(
    "SC010", ["й","Й"], "SC011", ["ц","Ц"], "SC012", ["у","У"], "SC013", ["к","К"],
    "SC014", ["е","Е"], "SC015", ["н","Н"], "SC016", ["г","Г"], "SC017", ["ш","Ш"],
    "SC018", ["щ","Щ"], "SC019", ["з","З"], "SC01A", ["х","Х"], "SC01B", ["ї","Ї"],
    "SC01E", ["ф","Ф"], "SC01F", ["и","И"], "SC020", ["в","В"], "SC021", ["а","А"],
    "SC022", ["п","П"], "SC023", ["р","Р"], "SC024", ["о","О"], "SC025", ["л","Л"],
    "SC026", ["д","Д"], "SC027", ["ж","Ж"], "SC028", ["є","Є"],
    "SC02C", ["я","Я"], "SC02D", ["ч","Ч"], "SC02E", ["с","С"], "SC02F", ["м","М"],
    "SC030", ["і","І"], "SC031", ["т","Т"], "SC032", ["ь","Ь"], "SC033", ["б","Б"],
    "SC034", ["ю","Ю"], "SC02B", ["ґ","Ґ"], "SC029", ["ʼ","ʼ"]
)

; ---------- Логика ----------
if STANDARD_UA_LAYOUT {
    tmp := LAYOUT["SC01F"]
    LAYOUT["SC01F"] := LAYOUT["SC030"]
    LAYOUT["SC030"] := tmp
}

ua := false
lastToggle := 0
lastHwnd := 0
lastLayout := 0

scale := AUTO_DPI_SCALE ? A_ScreenDPI / 96 : 1
flagW := Round(FLAG_WIDTH * scale)
flagH := Round(FLAG_HEIGHT * scale)
blueH := flagH // 2 + SPLIT_OFFSET

flag := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
flag.MarginX := 0
flag.MarginY := 0
flag.Add("Text", "x0 y0 w" flagW " h" blueH " Background" COLOR_BLUE)
flag.Add("Text", "x0 y" blueH " w" flagW " h" (flagH - blueH) " Background" COLOR_YELLOW)

MonitorGetWorkArea(MONITOR_NUMBER, &aL, &aT, &aR, &aB)
flagX := aR - flagW - Round(MARGIN_RIGHT * scale)
flagY := aB - flagH - Round(MARGIN_BOTTOM * scale)

A_IconTip := "Украинский режим: выкл"

SetMode(on) {
    global ua
    ua := on
    if ua {
        flag.Show("NoActivate x" flagX " y" flagY " w" flagW " h" flagH)
        WinSetTransparent(OPACITY, flag.Hwnd)
        A_IconTip := "Украинский режим: ВКЛ"
    } else {
        flag.Hide()
        A_IconTip := "Украинский режим: выкл"
    }
}

Toggle(*) {
    global lastToggle
    if (A_TickCount - lastToggle < 250)
        return
    lastToggle := A_TickCount
    SetMode(!ua)
    Send "{Blind}{vkE8}"
}

GetLayout(hwnd) {
    tid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")
    return DllCall("GetKeyboardLayout", "UInt", tid, "Ptr") & 0xFFFF
}

CheckLayout() {
    global lastHwnd, lastLayout
    hwnd := WinExist("A")
    layout := GetLayout(hwnd)
    if (ua && hwnd = lastHwnd && layout != lastLayout)
        SetMode(false)
    lastHwnd := hwnd
    lastLayout := layout
}

Hotkey("*" TOGGLE_KEY, Toggle)

if AUTO_OFF_ON_LAYOUT_CHANGE
    SetTimer(CheckLayout, 200)

HotIf((*) => ua)
for sc, letters in LAYOUT {
    Hotkey(sc, TypeLetter.Bind(letters[1]))
    Hotkey("+" sc, TypeLetter.Bind(letters[2]))
}
HotIf()

TypeLetter(letter, *) => SendText(letter)
