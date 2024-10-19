# Local Screen Spy (LSS)

Provides means to locally capture cursor, image and window data from the screen of Windows operating systems that have the second version of [AutoHotKey](https://autohotkey.com) installed.

## Remarks

The project has ended with providing three tools: the csv tool which captures cursor and window data, the screen capture tool that captures images of the screen, and the window capture tool that captures images of the specified window.

### CSV Tool

The following information could be useful to keep in mind when working with the csv tool.

* The tool updates the displayed data values if and only if the (specified) window title in the process tab matches the title of the active window.

* It tracks the active window if the data value in the process tab is unlocked.

* It does not update locked data values.

* It only saves checked data values and their respective data labels.

* It saves position data as two separate values in the data file (e.g., if the captured cursor position is (1, 2), then the value 1 is saved underneath the label "Cursor X" and the value 2 is saved underneath the label "Cursor Y").

* It saves resolution data as two separate values in the data file (e.g., if the captured window resolution is (480, 720), then the value 480 is saved underneath the label "Window Width" and the value 720 is saved underneath the label "Window Height").

* Previously stored data is lost if and only if the stored data labels do not match the data labels of the checked data values (e.g., if the very first line of the data file equals "Window X,Window Y,Cursor X,Cursor Y" and the concatenation of the data labels of the checked data values equals "Cursor X,Cursor Y,Pixel Color ID", then the all previously stored data is lost when performing the save operation).

### Capture Tool

The tool that captures the image does not capture itself during the image capture (and is therefore not visible in the saved image).

## Resources

A small amount of functions have been used from the Win32 API in order to "develop" the screen and window capture functionaly. These functions can be found below where they have been ordered alphabetically in their corresponding section.

Furthermore, a few scripts from the AutoHotKey forum have been used as a baseline for the screen capture and window capture functionality. These can also be found below.

### Win32 API

Functions of the section [GDI](https://learn.microsoft.com/en-us/windows/win32/api/_gdi/) that have been used:

* [BitBlt](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt) : a function that performs a bit-block transfer of color data from one device context to another.

* [CreateCompatibleBitmap](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatiblebitmap) : a function that creates a bitmap that is compatible with the specified device context.

* [CreateCompatibleDC](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatibledc) : a function that creates a memory device context that is compatible with the specified device context.

* [DeleteDC](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-deletedc) : a function that deletes the specified (memory) device context.

* [DeleteObject](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-deleteobject) : a function that deletes the specified bitmap, brush, font, pen or region.

* [GetDC](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc) : a function that retrieves a handle to the device context for the client area of the specified window.

* [GetWindowDC](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdc) : a function that retrieves a handle to the device context for the entirety of the specified window.

* [ReleaseDC](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-releasedc) : a function that returns the retrieved handles that have been obtained from the functions GetDC and GetWindowDC.

* [SelectObject](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject) : a function that inserts the specified bitmap, brush, font, pen or region into the specified device context.

Functions of the section [GDI+](https://learn.microsoft.com/en-us/windows/win32/api/_gdiplus/) that have been used:

* [CreateBitmapFromHBITMAP](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(hbitmap_hpalette)) : a function that creates a GDI+ bitmap from the specified GDI bitmap.

* [GdiplusShutdown](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusshutdown) : a function that shuts the initialized GDI+ down.

* [GdiplusStartup](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup) : a function that initializes GDI+.

* [GetImageEncoders](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimageencoders) : a function that obtains the array that contains the available ImageCodecInfo objects.

* [GetImageEncodersSize](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimageencoderssize) : a function that obtains [i] the number of available image encoders and [ii] the size of the array that contains the available ImageCodecInfo objects.

* [SaveImageToFile](https://learn.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-save(constwchar_constclsid_constencoderparameters)) : a function that saves the specified GDI+ bitmap to the specified file path with the specified image encoder.

Functions of the section [System Services](https://learn.microsoft.com/en-us/windows/win32/api/_base/) have been used:

* [FreeLibrary](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-freelibrary) : a function that frees the specified loaded library module.

* [LoadLibraryW](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryw) : a function that loads the specified dyanimic-link library module.

### AutoHotKey Forum

* Linear Spoon's CaptureScreen [function](https://www.autohotkey.com/board/topic/121619-screencaptureahk-broken-capturescreen-function-win-81-x64) that has been [ported]((https://www.autohotkey.com/boards/viewtopic.php?t=123212)) to the second version of AutoHotkey.

* The Gdip.ahk file written by Tariq Porter that has been [edited](https://www.autohotkey.com/board/topic/91585-screen-capture-using-only-ahk-no-3rd-party-software-required/) by Cruncher1.
