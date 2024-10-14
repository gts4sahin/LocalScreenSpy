/** 
 * Provides a few functions from the GDI+ section of the Win32 API that are related to capturing an image. <p></p>
 * Note: Most of the functions return a value from the GDI+ status enumeration where the value 0 implies that the function succeeded.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/_gdiplus/
 * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplustypes/ne-gdiplustypes-status
 */
class Gdiplus {
    /**
     * Creates a GDI+ bitmap from the specified GDI bitmap. <p></p>
     * Note 1: Use the function DisposeImage to dispose the GDI+ bitmap if it is no longer needed. <p></p>
     * Note 2: Only delete the GDI bitmap after the GDI+ bitmap is disposed.
     * @param {Integer} hBitmap a handle to the GDI bitmap for which a GDI+ bitmap should be created.
     * @param {VarRef<Integer>} pBitmap a variable reference to receive a pointer pointing to the created GDI+ bitmap.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-bitmap-bitmap(hbitmap_hpalette)
     */
    static CreateBitmapFromHBITMAP(hBitmap, &pBitmap) {
        pBitmap := IsSet(pBitmap) ? pBitmap : 0
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap)
    }

    /**
     * Disposes the specified image.
     * @param {Integer} pImage a pointer to the image that should be disposed.
     */
    static DisposeImage(pImage) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pImage)
    }

    /**
     * Shutdowns the initialized GDI+.
     * @param {Integer} pToken a pointer to the token of the initialized GDI+ that should be shut down.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusshutdown
     */
    static GdiplusShutdown(pToken) {
        DllCall("gdiplus\GdiplusShutdown", "UInt", pToken)
    }

    /**
     * Initializes GDI+. <p></p>
     * Note: Use the function GdiplusShutdown with the obtained token to shut down the initialized GDI+ when it is no longer needed.
     * @param {VarRef<Integer>} pToken a variable reference to receive a pointer pointing to the token of the initialized GDI+.
     * @returns {Integer} a value from the GDI+ status enumeration: zero if the function succeeds; an integer between 1 and 21 if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/nf-gdiplusinit-gdiplusstartup
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput
     */
    static GdiplusStartup(&pToken) {
        pToken := IsSet(pToken) ? pToken : 0

        StartupInput := Buffer(4 + A_PtrSize + 1 + 1) ; {UInt32, Ptr, Boolean, Boolean}
        NumPut("UInt", 1, StartupInput, 0)

        return DllCall("gdiplus\GdiplusStartup", "UInt*", &pToken, "Ptr", StartupInput.Ptr, "Ptr", 0)
    }

    /**
     * Obtains the array that contains the available ImageCodecInfo objects. <p></p>
     * Note: The number of available image encoders and the size of the array that contains the available ImageCodecInfo objects can be obtained through the function GetImageEncodersSize.
     * @param {Integer} nEncoders the number of available image encoders.
     * @param {Integer} sEncoders the size of the array that contains the available ImageCodecInfo objects.
     * @param {VarRef<Buffer>} bEncoders a variable reference to receive the array that contains the available ImageCodecInfo objects in a buffer format.
     * @returns {Integer} a value from the GDI+ status enumeration: zero if the function succeeds; an integer between 1 and 21 if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimageencoders
     */
    static GetImageEncoders(nEncoders, sEncoders, &bEncoders) {
        bEncoders := Buffer(sEncoders)
        return DllCall("gdiplus\GdipGetImageEncoders", "UInt", nEncoders, "UInt", sEncoders, "Ptr", bEncoders.Ptr)
    }

    /**
     * Obtains the number of available image encoders and the size of the array that contains the ImageCodecInfo objects.
     * @param {VarRef<Integer>} nEncoders a variable reference to receive the number of available image encoders.
     * @param {VarRef<Integer>} sEncoders a variable reference to receive the size of the array that contains the ImageCodecInfo objects.
     * @returns {Integer} a value from the GDI+ status enumeration: zero if the function succeeds; an integer between 1 and 21 if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusimagecodec/nf-gdiplusimagecodec-getimageencoderssize
     */
    static GetImageEncodersSize(&nEncoders, &sEncoders) {
        nEncoders := IsSet(nEncoders) ? nEncoders : 0
        sEncoders := IsSet(sEncoders) ? sEncoders : 0
        return DllCall("gdiplus\GdipGetImageEncodersSize", "UInt*", &nEncoders, "UInt*", &sEncoders)
    }

    /**
     * Saves the specified image at the specified file path using the specified encoder and parameter.
     * @param {Integer} pImage a pointer to the image that should be saved.
     * @param {String} FilePath the location where the image should be saved at.
     * @param {Integer} pEncoder a pointer to the image encoder that should be used to encode the specified image.
     * @param {Integer} [pParameter = 0] a pointer to the parameter the specified encoder should use to encode the specified image.
     * @returns {Integer} a value from the GDI+ status enumeration: zero if the function succeeds; an integer between 1 and 21 if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/gdiplusheaders/nf-gdiplusheaders-image-save(constwchar_constclsid_constencoderparameters)
     */
    static SaveImageToFile(pImage, FilePath, pEncoder, pParameter := 0) {
        return DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pImage, "WStr", FilePath, "Ptr", pEncoder, "Ptr", pParameter)
    }
}
