#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, MsgBox

#Include "Component\DeviceContextCapture.ahk"
#Include "Component\IncompleteImageTool.ahk"

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

UI := Gui("+AlwaysOnTop -DPIScale -MaximizeBox -MinimizeBox +ToolWindow", "LSS - Screen Capture Tool | Note: Tool will not be visible in the image.")
UI.MarginX := 15
UI.MarginY := 10
UI.OnEvent("Close", (*) => ExitApp())
UI.SetFont("S14", "Times New Roman")

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

hScreenContext := Gdi.GetWindowDC(0)
if (hScreenContext == 0) {
    throw Error("Failed to retrieve a handle to the device context for the entire screen. See the system error with code value " . A_LastError . " for more information on the failure.")
}

ReleaseScreenContext(*) {
    Gdi.ReleaseDC(0, hScreenContext) == 0
}
OnError(ReleaseScreenContext)
OnExit(ReleaseScreenContext)

; ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ;

CaptureScreen(*) {
    if (not ValidateCaptureArea(&X1, &Y1, &X2, &Y2)) {
        return
    }

    Response := "N/A"
    UI.Hide()
    if (ContextCapture.CaptureDeviceContext(hScreenContext, X1, Y1, X2, Y2, ChosenDirectory.Text . "\" . ChosenFileName.Text)) {
        UI.Show()
        Response := MsgBox("Image has been captured. Do you want to update the image file name to current date and time?", "LSS - File Name Update Request", "4 32 4096")
    } else {
        UI.Show()
    }

    if (Response == "Yes") {
        ChosenFileName.Text := A_Year . "-" . A_MM . "-" . A_DD . "_" . A_Hour . "-" . A_Min . "-" . A_Sec . ".png"
    }
}

CaptureButton.OnEvent("Click", CaptureScreen)
