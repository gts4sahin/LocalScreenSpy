#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, MsgBox

#Include "Component\DeviceContextCapture.ahk"
#Include "Component\IncompleteImageTool.ahk"
SendMode("Event")
SetTitleMatchMode(3)

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

UI := Gui("+AlwaysOnTop -DPIScale -MaximizeBox -MinimizeBox +ToolWindow", "LSS - Window Capture Tool")
UI.MarginX := 15
UI.MarginY := 10
UI.OnEvent("Close", (*) => ExitApp())
UI.SetFont(GetGuiFontOptions(), "Times New Roman")

AddTab("Target")
DisplayEditField(&ChosenWindow, "Window", "", false)
DisplayChoice(&ChosenMode, "Area Mode", Array("Client", "Window"))

AddTab("Area")
DisplayCoordinate(&TopLeftX, &TopLeftY, "Top-left")
DisplayCoordinate(&BottomRightX, &BottomRightY, "Bottom-right")

LastTab := AddTab("Image")
DisplayEditField(&ChosenDirectory, "Directory", A_ScriptDir . "\Image", true)
DisplayEditField(&ChosenFileName, "File name", A_Year . "-" . A_MM . "-" . A_DD . "_" . A_Hour . "-" . A_Min . "-" . A_Sec . ".png", true)
LastTab.UseTab(0)

CaptureButton := AddButton("CAPTURE SPECIFIED AREA")

UI.Show()

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

ContextCapture := DeviceContextCapture()

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

CaptureWindow(*) {
    if (not ValidateCaptureArea(&X1, &Y1, &X2, &Y2)) {
        return
    }
    hWindow := 0
    WindowTitle := ChosenWindow.Text
    try {
        if (!WinExist(WindowTitle)) {
            MsgBox("Cannot capture an image of the specified area due to the specified window not existing.", "LSS - Image Tool Error", "0 16 4096")
            return
        }
        
        WinActivate(WindowTitle)
        WinWaitActive(WindowTitle,, 2)

        hWindow := WinGetID(WindowTitle)
        WinGetPos(&WindowX, &WindowY, &WindowWidth, &WindowHeight, WindowTitle)
        WinGetClientPos(&ClientX, &ClientY, &ClientWidth, &ClientHeight, WindowTitle)
    } catch (Error as E) {
        MsgBox("Cannot capture an image of the specified area due to having encountered the error: " E.Message, "LSS - Image Tool Error", "0 16 4096")
        return
    }

    switch (ChosenMode.Text) {
        case "Window":
            if (X2 > WindowWidth) {
                MsgBox("Cannot capture an image of the specified area due to its bottom-right x-coordinate being located outside the specified window.", "LSS - Coordinate Error", "0 16 4096")
                return
            } else if (Y2 > WindowHeight) {
                MsgBox("Cannot capture an image of the specified area due to its bottom-right y-coordinate being located outside the specified window.", "LSS - Coordinate Error", "0 16 4096")
                return
            }
            hDeviceContext := Gdi.GetWindowDC(hWindow)
        default:
            if (X2 > ClientWidth) {
                MsgBox("Cannot capture an image of the specified area due to its bottom-right x-coordinate being located outside the client area of the specified window.", "LSS - Coordinate Error", "0 16 4096")
                return
            } else if (Y2 > ClientHeight) {
                MsgBox("Cannot capture an image of the specified area due to its bottom-right y-coordinate being located outside the client area of the specified window.", "LSS - Coordinate Error", "0 16 4096")
                return
            }
            hDeviceContext := Gdi.GetDC(hWindow)
    }

    Response := "N/A"
    UI.Hide()
    if (ContextCapture.CaptureDeviceContext(hDeviceContext, X1, Y1, X2, Y2, ChosenDirectory.Text . "\" . ChosenFileName.Text)) {
        UI.Show()
        Response := MsgBox("Image has been captured. Do you want to update the image file name to current date and time?", "LSS - File Name Update Request", "4 32 4096")
    } else {
        UI.Show()
    }

    if (Response == "Yes") {
        ChosenFileName.Text := A_Year . "-" . A_MM . "-" . A_DD . "_" . A_Hour . "-" . A_Min . "-" . A_Sec . ".png"
    }

    if (Gdi.ReleaseDC(hWindow, hDeviceContext) == 0) {
        Message := ChosenMode.Text == "Window" ? "Failed to release the retrieved handle to the device context of the specified window." : "Failed to release the retrieved handle to the device context of the client area of the specified window."
        MsgBox(Message, "LSS - Image Tool Error", "0 16 4096")
        return
    }
}

CaptureButton.OnEvent("Click", CaptureWindow)
