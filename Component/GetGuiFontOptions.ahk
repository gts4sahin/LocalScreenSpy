/**
 * Obtains the recommended graphical user interface font options.
 * @returns {String} the recommended font options.
 */
GetGuiFontOptions() {
    switch(A_ScreenDPI) {
        case 96 : return "S14"
        case 120: return "S12"
        case 144: return "S10"
        default : throw Error("Font options have not been defined for a screen dpi of " . A_ScreenDPI . ".")
    }
}
