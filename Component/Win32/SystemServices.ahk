/**
 * Provides a few functions from the section System Services of the Win32 API that are related to loading dynamic-link libraries. <p></p>
 * Note: Whenever a function fails, the code value of the error that caused the failure can be found in the built-in variable A_LastError.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/_base/
 * @see https://learn.microsoft.com/en-us/windows/win32/debug/system-error-codes
 */
class SystemServices {
    /**
     * Frees the specified loaded library module.
     * @param {Integer} hLibraryModule a handle to the loaded library module that should be freed.
     * @returns {Integer} a non-zero integer if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-freelibrary
     */
    static FreeLibrary(hLibraryModule) {
        return DllCall("FreeLibrary", "UPtr", hLibraryModule)
    }

    /**
     * Loads the specified dynamic-link library module.
     * @param {String} LibaryModuleName the name or location of the library module that should be loaded.
     * @returns {Integer} a handle to the loaded library module if the function succeeds | zero if the function fails.
     * @see https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryw
     */
    static LoadLibraryW(LibaryModuleName) {
        return DllCall("LoadLibraryW", "WStr", LibaryModuleName, "UPtr")
    }
}
