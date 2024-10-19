#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, MsgBox

#Include "Component\GetGuiFontOptions.ahk"
#Include "Component\GetLockFontOptions.ahk"
#Include "Component\ToolData.ahk"
SetTitleMatchMode(3)

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Provides the period in milliseconds that is used to update the csv tool. <p></p>
 * Note: Buttons and hotkeys remain responsive if the update period is kept between 10 and 100 milliseconds.
 * @type {Integer}
 */
UpdatePeriod := 50

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Provides the symbol that is placed between dimensional values.
 * @type {String}
 * @see https://www.compart.com/en/unicode/U+00D7
 */
MULTPLICATION_SIGN := Chr(215)

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Provides the data instance that contains the coord mode that is used to capture the data of the cursor.
 * @type {ToolData}
 */
ChosenCoordMode := unset

/**
 * Provides the edit instance that contains the directory in which the tool should save the captured data.
 * @type {Gui.Edit}
 */
ChosenDirectory := unset

/**
 * Provides the edit instance that contains the name of the file in which the tool should save the captured data.
 * @type {Gui.Edit}
 */
ChosenFileName := unset

/**
 * Provides the edit instance that contains the value separator the tool should use to separate the captured data values from each other within the save.
 * @type {Gui.Edit}
 */
ChosenSeparator := unset

/**
 * Provides the data instance that contains the color id of the pixel that is pointed by the cursor.
 * @type {ToolData}
 */
CursorPixelData := unset

/**
 * Provides the data instance that contains the position of the cursor.
 * @type {CSVToolData}
 */
CursorPosData := unset

/**
 * Defines whether a request was received to lock every data instance that is checked and unlocked.
 * @type {Integer}
 */
LockRequested := false

/**
 * Defines whether a request was received to save every data instance that is checked.
 * @type {Integer}
 */
SaveRequested := false

/**
 * Defines whether a request was received to unlock every data instance that is checked and locked.
 * @type {Integer}
 */
UnlockRequested := false

/**
 * Provides the data instance that contains the position of the client area of the window for which the data is captured.
 * @type {ToolData}
 */
WinClientPosData := unset

/**
 * Provides the data instance that contains the resolution of the client area of the window for which the data is captured.
 * @type {ToolData}
 */
WinClientResData := unset

/**
 * Provides the data instance that contains the position of the window for which the data is captured.
 * @type {CToolData}
 */
WinPosData := unset

/**
 * Provides the data instance that contains the resolution of the window for which the data is captured.
 * @type {ToolData}
 */
WinResData := unset

/**
 * Provides the data instance that contains the title of the window for which the data is captured.
 * @type {ToolData}
 */
WinTitleData := unset

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Requests the tool to lock all checked data instances.
 */
RequestLockChecked(*) {
    if (!LockRequested) {
        global LockRequested := true
    }
}

/**
 * Requests the tool to save all checked data instances.
 */
RequestSaveChecked(*) {
    if (!SaveRequested) {
        global SaveRequested := true
    }
}

/**
 * Requests the tool to unlock all checked data instances.
 */
RequestUnlockChecked(*) {
    if (!UnlockRequested) {
        global UnlockRequested := true
    }
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

 /**
     * Captures the data of the active window if the window title data section of the tool is unlocked or the title of the active window matches the title that is specified in the (locked) window title data section of the tool.
     * @returns {Integer} true if the data of the active window has been captured | false otherwise.
     */
 CaptureActiveWindowData() {
    try {
        ActiveWindow := WinGetTitle("A")
        if (WinTitleData.IsLocked() && ActiveWindow != WinTitleData.GetDisplayedText()) {
            return false
        }
        WinGetPos(&WindowX, &WindowY, &WindowWidth, &WindowHeight, ActiveWindow)
        WinGetClientPos(&WindowClientX, &WindowClientY, &WindowClientWidth, &WindowClientHeight, ActiveWindow)
    } catch (Error as E) {
        if (E.Message != "Target window not found.") {
            MsgBox("Failed to capture the data of the active window due to error: " . E.Message, "LSS - CSV Tool Error", "0 16 4096")
        }
        return false
    }

    if (WinTitleData.IsUnlocked()) {
        WinTitleData.SetIfNotSet(ActiveWindow)
    }
    if (WinPosData.IsUnlocked()) {
        WinPosData.SetIfNotSet(WindowX, WindowY)
    }
    if (WinResData.IsUnlocked()) {
        WinResData.SetIfNotSet(WindowWidth, WindowHeight)
    }
    if (WinClientPosData.IsUnlocked()) {
        WinClientPosData.SetIfNotSet(WindowClientX, WindowClientY)
    }
    if (WinClientResData.IsUnlocked()) {
        WinClientResData.SetIfNotSet(WindowClientWidth, WindowClientHeight)
    }
    return true
}

/**
 * Captures the data of the cursor.
 * @returns {Integer} true if the data of the cursor has been captured | false, otherwise.
 */
CaptureCursorData() {
    try {
        ChosenMode := ChosenCoordMode.GetDisplayedText()
        if (A_CoordModeMouse != ChosenMode) {
            CoordMode("Mouse", ChosenMode)
            CoordMode("Pixel", ChosenMode)
        }
        MouseGetPos(&X, &Y)
        ColorID := PixelGetColor(X, Y)
    } catch (Error as E) {
        MsgBox("Failed to capture the data of the cursor due to error: " . E.Message, "LSS - CSV Tool Error", "0 16 4096")
        return false
    }

    if (CursorPixelData.IsUnlocked()) {
        CursorPixelData.SetIfNotSet(ColorID)
    }
    if (CursorPosData.IsUnlocked()) {
        CursorPosData.SetIfNotSet(X, Y)
    }
    return true
}

/**
 * Updates the tool.
 */
UpdateTool(*) {
    if (SaveRequested) {
        ToolData.SaveIfChecked(ChosenDirectory.Text, ChosenFileName.Text, ChosenSeparator.Text, WinTitleData, WinPosData, WinResData, WinClientPosData, WinClientResData, ChosenCoordMode, CursorPixelData, CursorPosData)
        global SaveRequested := false
        return
    }

    if (LockRequested) {
        ToolData.LockIfChecked(WinTitleData, WinPosData, WinResData, WinClientPosData, WinClientResData, ChosenCoordMode, CursorPixelData, CursorPosData)
        global LockRequested := false
        return
    }

    if (UnlockRequested) {
        ToolData.UnlockIfChecked(WinTitleData, WinPosData, WinResData, WinClientPosData, WinClientResData, ChosenCoordMode, CursorPixelData, CursorPosData)
        global UnlockRequested := false
        return
    }

    if (CaptureActiveWindowData()) {
        CaptureCursorData()
    }
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Adds a button that displays the specified text.
 * @param {String} Text the text the button should display.
 * @returns {Gui.Button} the button that has been added to the tool.
 */
AddButton(Text) => UI.AddButton("XM Y+M W438 H45", Text)

/**
 * Adds a text instance that displays the specified character on the user interface.
 * @param {String} Character the character that should be displayed.
 * @returns {Gui.Text} the text instance that has been added to the user interface.
 */
AddCharacter(Character) => UI.AddText("X+5 YP W10 H30 0x1 0x200", Character)

/**
 * Adds a check box that displays the specified text on the user interface.
 * @param {String} Text the text the check box should display.
 * @returns {Gui.CheckBox} the check box that has been added to the user interface.
 */
AddCheckBox(Text) => UI.AddCheckbox("XS+" . UI.MarginX . " Y+M W150 H30 0x200 0xC00", Text)

/**
 * Adds a text instance that displays the specified label on the user interface.
 * @param {String} Label the label that should be displayed.
 * @returns {Gui.Text} the text instance that has been added to the user interface.
 */
AddLabel(Label) => UI.AddText("XS+" . UI.MarginX . " Y+M W150 H30 0x2 0x200", Label)

/**
 * Adds a tab that has the specified title on the user interface.
 * @param {String} Title the title the tab should have.
 * @returns {Gui.Tab} the tab that has been added to the user interface.
 */
AddTab(Title) => UI.AddTab3("XM Y+M 0x400 Section", Array(Title))

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Adds a drop down list that displays the specified items on the user interface.
 * @param {Array<String>} Items the items the drop down list should display.
 * @returns {Gui.DDL} the drop down list that has been added to the user interface.
 */
AddDropDownList(Items) {
    DDL := UI.AddDropDownList("X+5 YP W200", Items)
    DDL.Choose(Items.Length ? 1 : 0)
    PostMessage(0x153, -1, 25, DDL)
    return DDL
}

/**
 * Creates a text instance that displays the lock state of one or more values on the user interface.
 * @returns {Gui.Text} the text instance that has been added to the user interface.
 */
AddLockStateControl() {
    Control := UI.AddText("X+5 YP W30 H30 0x1 0x200 0x1000 Border")
    Control.SetFont(GetLockFontOptions())
    return Control
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Creates a hotkey and displays a section that consists of a description, a colon, a hotkey field and a lock.
 * @param {String} Description the description that should be displayed.
 * @param {String} Combination the key combination that should be enabled as a hotkey for the specified callback.
 * @param {Func} Callback the function that should be executed whenever the specified key combination is pressed.
 */
CreateHotkey(Description, Combination, Callback) {
    AddLabel(Description)
    AddCharacter(":")
    HotkeyControl := UI.AddHotkey("X+5 YP W200 H30", Combination)
    HotkeyLock := ValueLock(AddLockStateControl())
    HotkeyLock.OnLockStateChanged.Push((*) => HotkeyControl.Enabled := HotkeyLock.IsUnlocked())
    HotkeyLock.SetLockState(true)

    DisableHotkey(*) {
        if (Combination != "") {
            Hotkey(Combination, "Off")
        }
    }

    EnableHotkey(*) {
        if (Combination != "") {
            Hotkey(Combination, Callback, "On")
        }
    }

    SwapCombination(HotkeyControl, *) {
        Combination := HotkeyControl.value
    }

    HotkeyControl.OnEvent("Change", DisableHotkey)
    HotkeyControl.OnEvent("Change", SwapCombination)
    HotkeyControl.OnEvent("Change", EnableHotkey)

    OnError(DisableHotkey)
    OnExit(DisableHotkey)
    EnableHotkey()
}

/**
 * Displays a section that consists of a checkable description, a colon, a drop down list and a lock.
 * @param Description the description that should be displayed.
 * @param Items  the items the drop down list should display.
 * @param DataLabel the data label of the choice.
 * @returns {ToolData} a data instance that tracks the chosen option.
 */
DisplayChoice(Description, Items, DataLabel) {
    CheckBox := AddCheckBox(Description)
    AddCharacter(":")
    Data := ToolData(Array(DataLabel), "", AddDropDownList(Items), AddLockStateControl(), CheckBox)
    Data.OnLockStateChanged.Push((*) => Data.SetEnabled(Data.IsUnlocked()))
    Data.SetLockState(false)
    return Data
}

/**
 * Displays a section that consists of a checkable description, a colon, a color sample, a color id and a lock.
 * @param Description the description that should be displayed.
 * @param DataLabel the data label of the color.
 * @returns {ToolData} a data instance that defines the displayed color.
 */
DisplayColor(Description, DataLabel) {
    CheckBox := AddCheckBox(Description)
    AddCharacter(":")
    SampleControl := UI.AddText("X+5 YP W30 H30 0x1 0x200", Chr(11035))
    ValueControl := UI.AddEdit("X+5 YP W165 H30 0x1 0x800")
    Data := ToolData(Array(DataLabel), "", ValueControl, AddLockStateControl(), CheckBox)
    Data.OnLockStateChanged.Push((*) => Data.SetEnabled(Data.IsUnlocked()))
    Data.SetLockState(false)
    Data.OnValuesChanged.Push((*) => SampleControl.Opt("C" . ValueControl.Text))
    Data.SetIfNotSet("0x41582F")
    return Data
}


/**
 * Displays a section that consists of a description, a colon, an edit field and a lock.
 * @param {String} Description the description that should be displayed.
 * @param {String} Text the text that should be displayed.
 * @returns {Gui.Edit} the edit instance that displays the specified text.
 */
DisplayEditField(Description, Text) {
    AddLabel(Description)
    AddCharacter(":")
    EditField := UI.AddEdit("X+5 YP W200 H30 0x1", Text)
    FieldLock := ValueLock(AddLockStateControl())
    FieldLock.OnLockStateChanged.Push((*) => EditField.Enabled := FieldLock.IsUnlocked())
    FieldLock.SetLockState(true)
    return EditField
}

/**
 * Displays a section that consists of a description, a colon, an read-only edit field and a lock.
 * @param {String} Description the description that should be displayed.
 * @param {Array<String>} ValueLabels the labels of the values that form the data.
 * @param {String} ValueSeparator one or more symbols that should be used to separate the values that form the data.
 * @returns {ToolData} a data instance that defines the displayed values.
 */
DisplaySeparatedValues(Description, ValueLabels, ValueSeparator) {
    CheckBox := AddCheckBox(Description)
    AddCharacter(":")
    Data := ToolData(ValueLabels, ValueSeparator, UI.AddEdit("X+5 YP W200 H30 0x1 0x800"), AddLockStateControl(), CheckBox)
    Data.OnLockStateChanged.Push((*) => Data.SetEnabled(Data.IsUnlocked()))
    Data.SetLockState(false)
    Data.SetIfNotSet("XXXX", "YYYY")
    return Data
}

/**
 * Displays the window title section.
 * @returns {ToolData} a data instance that defines the displayed window title.
 */
DisplayWindowTitleSection() {
    CheckBox := AddCheckBox("")
    AddCharacter(":")
    Data := ToolData(Array("Window"), "", UI.AddEdit("X+5 YP W200 H30 0x1"), AddLockStateControl(), CheckBox)
    Data.OnLockStateChanged.Push((*) => CheckBox.Text := Data.IsLocked() ? "Target window" : "Active window")
    Data.SetLockState(true)
    return Data
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;
MsgBox(A_ScreenDPI)
UI := Gui("+AlwaysOnTop -DPIScale -MaximizeBox -MinimizeBox", "LSS - CSV Tool")
UI.MarginX := 15
UI.MarginY := 10
UI.OnEvent("Close", (*) => ExitApp())
UI.SetFont(GetGuiFontOptions(), "Times New Roman")

AddTab("Process")
WinTitleData := DisplayWindowTitleSection()

AddTab("Window")
WinPosData := DisplaySeparatedValues("Position", Array("Window X", "Window Y"), ",")
WinResData := DisplaySeparatedValues("Resolution", Array("Window Width", "Window Height"), MULTPLICATION_SIGN)

AddTab("Client")
WinClientPosData := DisplaySeparatedValues("Position", Array("Window Client X", "Window Client Y"), ",")
WinClientResData := DisplaySeparatedValues("Resolution", Array("Window Client Width", "Window Client Height"), MULTPLICATION_SIGN)

AddTab("Cursor")
CursorPosData   := DisplaySeparatedValues("Position", Array("Cursor X", "Cursor Y"), ",")
CursorPixelData := DisplayColor("Pixel color", "Pixel Color ID")
ChosenCoordMode := DisplayChoice("Coord mode", Array("Client", "Screen", "Window"), "Cursor Coord Mode")

AddTab("Data")
ChosenDirectory := DisplayEditField("Directory", A_ScriptDir . "\CSV")
ChosenFileName  := DisplayEditField("File name", A_Year . "-" . A_MM . "-" . A_DD . "_" . A_Hour . "-" . A_Min . ".csv")
ChosenSeparator := DisplayEditField("Value separator", ",")

LastTab := AddTab("Hotkey")
CreateHotkey("Save checked", "+w", RequestSaveChecked)
CreateHotkey("Lock checked", "+d", RequestLockChecked)
CreateHotkey("Unlock checked", "+a", RequestUnlockChecked)

LastTab.UseTab(0)
SaveButton := AddButton("SAVE CHECKED DATA")
SaveButton.OnEvent("Click", RequestSaveChecked)

UI.Show()

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

DisableUpdate(*) => SetTimer(UpdateTool, 0)
OnError(DisableUpdate)
OnExit(DisableUpdate)
SetTimer(UpdateTool, UpdatePeriod)
