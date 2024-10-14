#Include "Win32\Gdi.ahk"
#Include "Win32\Gdiplus.ahk"
#Include "Win32\SystemServices.ahk"

/**
 * Provides functionality to captures images. <p></p>
 * Note: The tool does not come with a graphical user interface.
 * @requires Gdi.ahk : the file that contains the class Gdi which is a collection of functions from the section Windows GDI of the Win32 API that are related to capturing an image.
 * @requires Gdiplus.ahk : the file that contains the class Gdiplus which is a collection of functions from the section GDI+ of the Win32 API that are related to saving an image.
 * @requires SystemServices.ahk : the file that contains the class SystemServices which is a collection of functions from the section System Services of the Win32 API that are related to loading dynamic-link libraries.
 */
class DeviceContextCapture {
    /**
     * Copies the color data of the specified area from the bitmap of the specified device context.
     * @param {VarRef<Integer>} hBitmap a variable reference to receive a handle to the bitmap that contains the copied color data.
     * @param {Integer} hDeviceContext the device context for which the color data of its bitmap should be copied. 
     * @param {Integer} X1 the top-left x-coordinate of the bitmap of the specified device context that should be copied.
     * @param {Integer} Y1 the top-left y-coordinate of the bitmap of the specified device context that should be copied.
     * @param {Integer} X2 the bottom-right x-coordinate of the bitmap of the specified device context that should be copied.
     * @param {Integer} Y2 the bottom-right y-coordinate of the bitmap of the specified device context that should be copied.
     * @returns {String} an empty-string if the function succeeds | a non-empty string describing the failure if the function fails.
     */
    static CopyBitmap(&hBitmap, hDeviceContext, X1, Y1, X2, Y2) {
        if (X1 >= X2) {
            return "Cannot attempt to copy color data due to the top-left x-coordinate being greater than or equal to the bottom-right x-coordinate."
        } else if (Y1 >= Y2) {
            return "Cannot attempt to copy color data due to the top-left y-coordinate being greater than or equal to the bottom-right y-coordinate."
        }

        BitmapWidth := X2 - X1
        BitmapHeight := Y2 - Y1
        hCompatibleBitmap := Gdi.CreateCompatibleBitmap(hDeviceContext, BitmapWidth, BitmapHeight)
        if (hCompatibleBitmap == 0) {
            return "Failed to create a compatible bitmap. For more information on the failure see the system error that has the code value " . A_LastError . "." 
        }

        hMemoryContext := Gdi.CreateCompatibleDC(hDeviceContext)
        if (hMemoryContext == 0) {
            Gdi.DeleteObject(hCompatibleBitmap)
            return "Failed to create a compatible memory device context. For more information on the failure see the system error that has the code value " . A_LastError . "."
        }

        hEjectedBitmap := Gdi.SelectObject(hMemoryContext, hCompatibleBitmap)
        if (hEjectedBitmap == 0) {
            Gdi.DeleteObject(hCompatibleBitmap)
            Gdi.DeleteDC(hMemoryContext)
            return "Failed to selected the bitmap into the memory device context. For more information on the failure see the system error that has the code value " . A_LastError . "."
        }

        CopyResult := Gdi.BitBlt(hMemoryContext, 0, 0, BitmapWidth, BitmapHeight, hDeviceContext, X1, Y1, 0x01CC0020)
        if (Gdi.SelectObject(hMemoryContext, hEjectedBitmap) != hCompatibleBitmap) {
            Gdi.DeleteDC(hMemoryContext)
            return "Failed to retrieve the selected bitmap. For more information on the failure see the system error that has the code value " . A_LastError . "."
        } else if (CopyResult == 0) {
            Gdi.DeleteObject(hCompatibleBitmap)
            Gdi.DeleteDC(hMemoryContext)
           return "Failed to copy color data. For more information on the failure see the system error that has the code value " . A_LastError . "."
        }

        hBitmap := hCompatibleBitmap
        return ""
    }

    /**
     * Obtains a pointer to the image encoder that is associated with the specified file name extension.
     * @param {VarRef<Integer} pEncoder a variable reference to receive a pointer pointing to the image encoder that is associated with teh specified file name extension.
     * @param {Integer} nEncoders the number of available image encoders on the device.
     * @param {Integer} sEncoders the size of the array that contains the ImageCodecInfo objects on the device.
     * @param {Buffer} bEncoders a buffer that contains the ImageCodecInfo object array.
     * @param {String} FileNameExtension the file name extension (without the dot) for which a pointer to its associated image encoder should be obtained.
     * @returns {String} an empty-string if the function succeeds | a non-empty string describing the failure if the function fails.
     */
    static GetImageEncoder(&pEncoder, nEncoders, sEncoders, bEncoders, FileNameExtension) {
        StructSize := 48 + 7 * A_PtrSize
        Offset := 32 + 3 * A_PtrSize
        Pointer := bEncoders.Ptr
        Identifier := "*." . FileNameExtension
        loop (nEncoders) {
            Address := NumGet(Offset + Pointer, "UPtr")
            SearchString := StrGet(Address, "UTF-16")
            if (InStr(SearchString, Identifier)) {
                pEncoder := Pointer
                return ""
            }
            Pointer += StructSize
        }
        return "Could not find the image encoder that is associated with the specified file name extension."
    }

    /**
     * Saves the specified bitmap at the specified location using the specified image encoder.
     * @param {Integer} hBitmap a handle to the bitmap that should be saved.
     * @param {String} FilePath the path of the file in which the bitmap should be saved.
     * @param {Integer} pEncoder the image encoder that should be used to save the specified bitmap.
     * @returns {String} an empty-string if the function succeeds | a non-empty string describing the failure if the function fails.
     */
    static SaveBitmap(hBitmap, FilePath, pEncoder) {
        Gdiplus.CreateBitmapFromHBITMAP(hBitmap, &pBitmap)
        if (pBitmap == 0) {
            Gdi.DeleteObject(hBitmap)
            return "Failed to create a GDI+ bitmap from the specified bitmap."
        }

        StatusCode := Gdiplus.SaveImageToFile(pBitmap, FilePath, pEncoder)
        Gdiplus.DisposeImage(pBitmap)
        Gdi.DeleteObject(hBitmap)
        if (StatusCode) {
            return "Failed to save the specified bitmap. For more information on the failure see status code " . StatusCode . " from the GDI+ status enumeration."
        }
    }

    /**
     * Provides the buffer that contains the ImageCodecInfo object array.
     * @private
     * @readonly
     * @type {Buffer}
     */
    bEncoders := unset

    /**
     * Provides the number of available image encoders.
     * @private
     * @readonly
     * @type {Integer}
     */
    nEncoders := unset

    /**
     * Provides the size of the array that contains the ImageCodecInfo objects.
     * @private
     * @readonly
     * @type {Integer}
     */
    sEncoders := unset

    /**
     * Loads pre-loadable resources that are required to capture images.
     * @throws {Error} if the GDI+ library module could not be loaded | if GDI+ could not be initialized | if the number of available image encoders could not be obtained | 
     *                 if the array that contains information about the available image encoders could not be obtained.
     */
    __New() {
        hGdiplusModule := SystemServices.LoadLibraryW("gdiplus")
        if (hGdiplusModule == 0) {
            throw Error("Failed to load the GDI+ library module. For more information on the failure see the system error that has the code value " . A_LastError . ".")
        }
        FreeGdiplusModule(*) => SystemServices.FreeLibrary(hGdiplusModule)
        OnError(FreeGdiplusModule)
        OnExit(FreeGdiplusModule)

        StatusCode := Gdiplus.GdiplusStartup(&pToken)
        if (StatusCode) {
            throw Error("Failed to start GDI+ up. For more information on the failure see status code " . StatusCode . " from the GDI+ status enumeration.")
        }
        ShutGdiplusDown(*) => Gdiplus.GdiplusShutdown(pToken)
        OnError(ShutGdiplusDown)
        OnExit(ShutGdiplusDown)

        StatusCode := Gdiplus.GetImageEncodersSize(&nEncoders, &sEncoders)
        if (StatusCode) {
            throw Error("Failed to obtain the number of available image encoders on the device. For more information on the failure see status code " . StatusCode . " from the GDI+ status enumeration.")
        }

        StatusCode := Gdiplus.GetImageEncoders(nEncoders, sEncoders, &bEncocders)
        if (StatusCode) {
            throw Error("Failed to obtain the array that contains information about the available image encoders. For more information on the failure see status code " . StatusCode . " from the GDI+ status enumeration.")
        }

        this.bEncoders := bEncocders
        this.nEncoders := nEncoders
        this.sEncoders := sEncoders
    }

    /**
     * Captures an image of the bitmap of the specified device context.
     * @param {Integer} hDeviceContext the device context for which an image of its bitmap should be captured.
     * @param {Integer} X1 the top-left x-coordinate of the bitmap of the specified device context that should be captured.
     * @param {Integer} Y1 the top-left y-coordinate of the bitmap of the specified device context that should be captured.
     * @param {Integer} X2 the bottom-right x-coordinate of the bitmap of the specified device context that should be captured.
     * @param {Integer} Y2 the bottom-right y-coordinate of the bitmap of the specified device context that should be captured.
     * @param {String} FilePath the path of the file in which the captured image should be saved.
     * @returns {Integer} true if the function succeeds | false if the function fails.
     */
    CaptureDeviceContext(hDeviceContext, X1, Y1, X2, Y2, FilePath) {
        SplitPath(FilePath, , &Directory, &Extension)
        ErrorMessage := DeviceContextCapture.GetImageEncoder(&pEncoder, this.nEncoders, this.sEncoders, this.bEncoders, Extension)
        if (ErrorMessage != "") {
            MsgBox(ErrorMessage, "LSS - File Name Error", "0 16 4096")
            return false
        }

        CreateDirectory := "N/A"
        if (!DirExist(Directory)) {
            CreateDirectory := MsgBox(Directory . " does not exist. Do you want to create it?", "LSS - Directory Request", "4 32 4096")
        }

        if (!(CreateDirectory == "N/A" || CreateDirectory == "Yes")) {
            MsgBox("Cannot attempt to capture an image due to not having permission to create the image directory.", "LSS - Directory Error", "0 16 4096")
            return false
        }

        try {
            if (CreateDirectory == "Yes") {
                DirCreate(Directory)
            }
        } catch (Error as E) {
            MsgBox("Failed to create the image directory. For more information on the failure see the system error that has the code value " . A_LastError ".", "LSS - Directory Error", "0 16 4096")
            return false
        }
 
        ErrorMessage := DeviceContextCapture.CopyBitmap(&hBitmap, hDeviceContext, X1, Y1, X2, Y2)
        if (ErrorMessage != "") {
            MsgBox(ErrorMessage, "LSS - Image Capture Error", "0 16 4096")
            return false
        }

        ErrorMessage := DeviceContextCapture.SaveBitmap(hBitmap, FilePath, pEncoder)
        if (ErrorMessage != "") {
            MsgBox(ErrorMessage, "LSS - Image Capture Error", "0 16 4096")
            return false
        }

        return true
    }
}
