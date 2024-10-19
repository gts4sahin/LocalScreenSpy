#Include "GetGuiFontOptions.ahk"
#Include "GetLockFontOptions.ahk"
#Include "ValueLock.ahk"

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Provides the edit instance that displays the bottom-right x-coordinate of the capture area.
 * @type {Gui.Edit}
 */
BottomRightX := unset

/**
 * Provides the edit instance that displays the bottom-right y-coordinate of the capture area.
 * @type {Gui.Edit}
 */
BottomRightY := unset

/**
 * Provides the placeholder text for the displayed x-coordinates.
 * @type {String}
 */
PlaceholderX := "XXXX"

/**
 * Provides the placeholder text for the displayed y-coordinate.
 * @type {String}
 */
PlaceholderY := "YYYY"

/**
 * Provides the edit instance that displays the top-left x-coordinate of the capture area.
 * @type {Gui.Edit}
 */
TopLeftX := unset

/**
 * Provides the edit instance that displays the top-left y-coordinate of the capture area.
 * @type {Gui.Edit}
 */
TopLeftY := unset

/**
 * Provides the user interface of the screen capture tool.
 * @type {Gui}
 */
UI := unset

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Adds a button that displays the specified text on the user interface.
 * @param {String} Text the text that should be displayed.
 * @returns {Gui.Button} the button that has been added to the user interface.
 */
AddButton(Text) => UI.AddButton("XM Y+M W408 H45", Text)

/**
 * Adds a text instance that displays the specified character on the user interface.
 * @param {String} Character the character that should be displayed.
 * @returns {Gui.Text} the text instance that has been added to the user interface.
 */
AddCharacter(Character) => UI.AddText("X+5 YP W10 H30 0x1 0x200", Character)

/**
 * Adds a text instance that displays the specified label on the user interface.
 * @param {String} Label the label that should be displayed.
 * @returns {Gui.Text} the text instance that has been added to the user interface.
 */
AddLabel(Label) => UI.AddText("XS+" . UI.MarginX . " Y+M W100 H30 0x2 0x200", Label)

/**
 * Adds a tab that has the specified title on the user interface.
 * @param {String} Title the title the tab should have.
 * @returns {Gui.Tab} the tab that has been added to the user interface.
 */
AddTab(Title) => UI.AddTab3("XM Y+M 0x400 Section", Array(Title))

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Clears the text property of the specified control instance if the specified control instance displays the specified placeholder text.
 * @param {Gui.Control} Control the control instance for which the placeholder text should be removed.
 * @param {String} Placeholder the placeholder text the control is expected to have.
 */
RemovePlacholderText(Control, Placeholder) {
    if (Control.Text == Placeholder) {
        Control.Text := ""
    }
}

/**
 * Sets the text property of the specified control instance to be equal to the specified placeholder text if the specified control instance displays an empty string.
 * @param {Gui.Control} Control the control instance for which the placeholder text should be removed.
 * @param {String} Placeholder the placeholder text the control is expected to have.
 */
SetPlaceholderText(Control, Placeholder) {
    if (Control.Text == "") {
        Control.Text := Placeholder
    }
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Creates a value lock.
 * @returns {ValueLock} the value lock that has been created. 
 */
CreateValueLock() {
    Control := UI.AddText("X+5 YP W30 H30 0x1 0x200 0x1000 Border")
    Control.SetFont(GetLockFontOptions())
    return ValueLock(Control)
}

/**
 * Displays a section that consists of a description, a colon, a drop down list and a lock.
 * @param {VarRef<Gui.DDL>} DDL a variable reference to receive the drop down list that displays the specified items.
 * @param {String} Description the description that should be displayed.
 * @param {Array<String>} Items the items the drop down list should display.
 */
DisplayChoice(&DDL, Description, Items) {
    AddLabel(Description)
    AddCharacter(":")
    DDL := UI.AddDropDownList("X+5 YP W220", Items)
    DDL.Choose(Items.Length ? 1 : 0)
    PostMessage(0x153, -1, 25, DDL)
    ListLock := CreateValueLock()
    ListLock.OnLockStateChanged.Push((*) => DDL.Enabled := ListLock.IsUnlocked())
    ListLock.SetLockState(false)
}

/**
 * Displays a section that consists of a description, a colon, a x-coordinate, a y-coordinate and a lock.
 * @param {VarRef<Gui.Edit>} X a variable reference to receive the edit instance that displays the x-coordinate.
 * @param {VarRef<Gui.Edit>} Y a variable reference to receive the edit instance that displays the y-coordinate.
 * @param {String} Description the description that should be displayed.
 */
DisplayCoordinate(&X, &Y, Description) {
    AddLabel(Description)
    AddCharacter(":")
    X := UI.AddEdit("X+5 YP W100 H30 0x1 Number", PlaceholderX)
    X.OnEvent("Focus", (*) => RemovePlacholderText(X, PlaceholderX))
    X.OnEvent("LoseFocus", (*) => SetPlaceholderText(X, PlaceholderX))
    AddCharacter(",")
    Y := UI.AddEdit("X+5 YP W100 H30 0x1 Number", PlaceholderY)
    Y.OnEvent("Focus", (*) => RemovePlacholderText(Y, PlaceholderY))
    Y.OnEvent("LoseFocus", (*) => SetPlaceholderText(Y, PlaceholderY))
    CoordinateLock := CreateValueLock()
    CoordinateLock.OnLockStateChanged.Push((*) => X.Enabled := CoordinateLock.IsUnlocked())
    CoordinateLock.OnLockStateChanged.Push((*) => Y.Enabled := CoordinateLock.IsUnlocked())
    CoordinateLock.SetLockState(false)
}

/**
 * Displays a section that consists of a description, a colon, an edit field and a lock.
 * @param {VarRef<Gui.Edit>} EditField a variable reference to receive the edit instance that displays the specified text.
 * @param {String} Description the description that should be displayed.
 * @param {String} Text the text that should be displayed.
 * @param {Integer} LockState true if the edit field should be locked | false if th edit field should be unlocked.
 */
DisplayEditField(&EditField, Description, Text, LockState) {
    AddLabel(Description)
    AddCharacter(":")
    EditField := UI.AddEdit("X+5 YP W220 H30 0x1", Text)
    FieldLock := CreateValueLock()
    FieldLock.OnLockStateChanged.Push((*) => EditField.Enabled := FieldLock.IsUnlocked())
    FieldLock.SetLockState(LockState)
}

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

/**
 * Validates the coordinates that form the capture area.
 * @param {VarRef<Integer>} X1 a variable reference to receive the top-left x-coordinate of the capture area.
 * @param {VarRef<Integer>} Y1 a variable reference to receive the top-left y-coordinate of the capture area.
 * @param {VarRef<Integer>} X2 a variable reference to receive the bottom-right x-coordinate of the capture area.
 * @param {VarRef<Integer>} Y2 a variable reference to receive the bottom-right y-coordinate of the capture area.
 * @returns {Integer} true if there are no issues | false if at least one issue is detected.
 */
ValidateCaptureArea(&X1?, &Y1?, &X2?, &Y2?) {
    if (TopLeftX.Text == PlaceholderX) {
        MsgBox("Cannot capture an image of the specified area due to the top-left x-coordinate being undefined.", "LSS - Coordinate Error", "0 16 4096")
        return false
    } else if (TopLeftY.Text == PlaceholderY) {
        MsgBox("Cannot capture an image of the specified area due to the top-left y-coordinate being undefined.", "LSS - Coordinate Error", "0 16 4096")
        return false
    } else if (BottomRightX.Text == PlaceholderX) {
        MsgBox("Cannot capture an image of the specified area due to the top-left x-coordinate being undefined.", "LSS - Coordinate Error", "0 16 4096")
        return false
    } else if (BottomRightY.Text == PlaceholderY) {
        MsgBox("Cannot capture an image of the specified area due to the bottom-right y-coordinate being undefined.", "LSS - Coordinate Error", "0 16 4096")
        return false
    }

    X1 := Integer(TopLeftX.Text)
    Y1 := Integer(TopLeftY.Text)
    X2 := Integer(BottomRightX.Text)
    Y2 := Integer(BottomRightY.Text)
    
    if (X1 >= X2) {
        MsgBox("Cannot capture an image of the specified area due to the top-left x-coordinate being greater than or equal to the bottom-right x-coordinate.", "LSS - Coordinate Error", "0 16 4096")
        return false
    } else if (Y1 >= Y2) {
        MsgBox("Cannot capture an image of the specified area due to the top-left y-coordinate being greater than or equal to the bottom-right y-coordinate.", "LSS - Coordinate Error", "0 16 4096")
        return false
    }
    return true
}
