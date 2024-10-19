/**
 * Obtains the recommended value lock font options.
 * @returns {String} the recommended font options.
 */
GetLockFontOptions() {
    switch(A_ScreenDPI) {
        case 96 : return "S16"
        case 120: return "S14"
        case 144: return "S12"
        default : throw Error("Lock font options have not been defined for a screen dpi of " . A_ScreenDPI . ".")
    }
}
