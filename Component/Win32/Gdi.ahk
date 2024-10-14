/** 
 * Provides a handful of functions from the section Windows GDI of the Win32 API that are related to capturing an image. <p></p>
 * Note: Whenever a function fails, the code value of the error that caused the failure can be found in the built-in variable A_LastError.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/_gdi/ 
 * @see https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes
 */
class Gdi {
    /**
     * Performs a bit-block transfer of color data from one device context to the other.
     * @param {Integer} hDesintationContext a handle to the device context for which its bitmap should receive the color data.
     * @param {Integer} DestinationBitmapX the first x-coordinate of the destination bitmap that should receive the color data.
     * @param {Integer} DestinationBitmapY the first y-coordinate of the destination bitmap that should receive the color data.
     * @param {Integer} BitmapWidth the number of pixels in the x-axis for which the color data from the source bitmap should be transferred to the destination bitmap.
     * @param {Integer} BitmapHeight the number of pixels in the y-axis for which the color data from the source bitmap should be transferred to the destination bitmap.
     * @param {Integer} hSourceContext a handle to the device context for which its bitmap should send the color data.
     * @param {Integer} SourceBitmapX the first x-coordinate of the source bitmap that should send the color data.
     * @param {Integer} SourceBitmapY the first y-coordinate of the source bitmap that should send the color data.
     * @param {Integer} RasterOperationCode a raster operation that defines how the color data from the source bitmap should be transferred to the destination bitmap.
     * @returns {Integer} a non-zero integer if the function succeeds. | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-bitblt
     */
    static BitBlt(hDestinationContext, DestinationBitmapX, DestinationBitmapY, BitmapWidth, BitmapHeight, hSourceContext, SourceBitmapX, SourceBitmapY, RasterOperationCode) {
        return DllCall("gdi32\BitBlt", "UPtr", hDestinationContext, "Int", DestinationBitmapX, "Int", DestinationBitmapY, "Int", BitmapWidth, "Int", BitmapHeight, "UPtr", hSourceContext, "Int", SourceBitmapX, "Int", SourceBitmapY, "UInt", RasterOperationCode)
    }

    /**
     * Creates a bitmap that is compatible with the specified device context. <p></p>
     * Note: Use the function DeleteObject to delete the bitmap if it is no longer needed.
     * @param {Integer} hDeviceContext a handle to the device context for which a compatible bitmap should be created.
     * @param {Integer} BitmapWidth the width the compatible bitmap should have.
     * @param {Integer} BitmapHeight the height the compatible bitmap should have.
     * @returns {Integer} a handle to the created bitmap if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatiblebitmap
     */
    static CreateCompatibleBitmap(hDeviceContext, BitmapWidth, BitmapHeight) {
        return DllCall("CreateCompatibleBitmap", "UPtr", hDeviceContext, "Int", BitmapWidth, "Int", BitmapHeight, "UPtr")
    }

    /**
     * Creates a memory device context that is compatible with the specified device context. <p></p>
     * Note: Use the function DeleteDC to delete the memory device context if it is no longer needed.
     * @param {Integer} hDeviceContext a handle to the device context for which a compatible memory device context should be created.
     * @returns {Integer} a handle to the created memory device context if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createcompatibledc
     */
    static CreateCompatibleDC(hDeviceContext) {
        return DllCall("CreateCompatibleDC", "UPtr", hDeviceContext, "UPtr")
    }

    /**
     * Deletes the specified device context.
     * @param {Integer} hDeviceContext a handle to the device context that should be deleted.
     * @returns {Integer} a non-zero integer if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-deletedc
     */
    static DeleteDC(hDeviceContext) {
        return DllCall("DeleteDC", "UPtr", hDeviceContext)
    }

    /**
     * Deletes the specified object.
     * @param {Integer} hGDIObject a handle to either the bitmap, the brush, the font, the pen or the region that should be deleted.
     * @returns {Integer} a non-zero integer if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-deleteobject
     */
    static DeleteObject(hGDIObject) {
        return DllCall("DeleteObject", "UPtr", hGDIObject)
    }

    /**
     * Retrieves a handle to the device context for the client area of the specified window. <p></p>
     * Note: Use the function ReleaseDC to return the retrieved handle if it is no longer needed.
     * @param {Integer} hWindow a handle to the window for which a handle to its device context should be retrieved | zero if a handle should be retrieved for the device context for the entire screen.
     * @returns {Integer} the retrieved handle to the device context for the client area of the specified window if the function succeeds | zero if the function fails. 
     * @see https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdc
     */
    static GetDC(hWindow) {
        return DllCall("GetDC", "UPtr", hWindow, "UPtr")
    }

    /**
     * Retrieves a handle to the device context for the entirety of the specified window. <p></p>
     * Note: Use the function ReleaseDC to return the retrieved handle if it is no longer needed.
     * @param {Integer} hWindow a handle to the window for which a handle to its device context should be retrieved | zero if a handle should be retrieved for the device context for the entire screen.
     * @returns {Integer} the retrieved handle to the device context of the specified window if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowdc
     */
    static GetWindowDC(hWindow) {
        return DllCall("GetWindowDC", "UPtr", hWindow, "UPtr")
    }

    /**
     * Releases the specified device context (for the client area or the entirety) of the specified window.
     * @param {Integer} hWindow a handle to the window for which its device context or the device context for its client area should be released | zero, if the device context for the entire screen is going to be released.
     * @param {Integer} hDeviceContext a handle to the device context of the specified window that should be released | a handle to the device context for the client area of the specified window that should be released.
     * @returns {Integer} a non-zero integer if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-releasedc
     */
    static ReleaseDC(hWindow, hDeviceContext) {
        return DllCall("ReleaseDC", "UPtr", hWindow, "UPtr", hDeviceContext)
    }

    /**
     * Inserts the specified object into the specified device context. <p></p>
     * Note: This operation will cause the existing object of the same type as the specified object inside the specified device context to be ejected.
     * @param {Integer} hDeviceContext a handle to the device context for which the specified object should be inserted into.
     * @param {Integer} hGDIObject a handle to either a bitmap, a brush, a font, a pen or a region that should be inserted into the specified device context.
     * @returns {Integer} a handle to the ejected object if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-selectobject
     */
    static SelectObject(hDeviceContext, hGDIObject) {
        return DllCall("SelectObject", "UPtr", hDeviceContext, "UPtr", hGDIObject, "UPtr")
    }
}
