/** 
 * Provides a structure that uses a text instance to display the lock state of one or more data values.
 */
class ValueLock {
    /**
     * Provides the color that is used to indicate a closed lock.
     * @private
     * @readonly
     * @type {String}
     */
    static CLOSED_LOCK_COLOR => "0xAE0F00"

    /**
     * Provides the symbol that is used to indicate a closed lock.
     * @private
     * @readonly
     * @type {String}
     * @see https://www.compart.com/en/unicode/U+1F512
     */
    static CLOSED_LOCK_SYMBOL => Chr(128274)

    /**
     * Provides the color that is used to indicate an open lock.
     * @private
     * @readonly
     * @type {String}
     */
    static OPEN_LOCK_COLOR => "0x0FAE00"

    /**
     * Provides the symbol that is used to indicate an open lock.
     * @private
     * @readonly
     * @type {String}
     * @see https://www.compart.com/en/unicode/U+1F513
     */
    static OPEN_LOCK_SYMBOL => Chr(128275)

    /**
     * Provides the text instance that displays the lock state of the data values.
     * @private
     * @type {Gui.Text}
     */
    LockStateControl := unset

    /**
     * Provides the functions that get executed after the lock state has been set.
     * Note: This property is optional and may therefore not have been assigned a value other than an empty array.
     * @public
     * @type {Array<Func>}
     */
    OnLockStateChanged := []

    /**
     * Creates a new value lock instance that uses the specified text instance to display the lock state of one or more data values.
     * @param {Gui.Text} LockStateControl the text instance that should be used to display the lock state of one or more data values.
     */
    __New(LockStateControl) {
        this.LockStateControl := LockStateControl
        this.LockStateControl.OnEvent("Click", (*) => this.SetLockState(this.IsUnlocked() ? true : false))
    }

    /**
     * Determines whether the data values are locked.
     * @returns {Integer} true if the data values are locked | false otherwise.
     */
    IsLocked() => this.LockStateControl.Text == ValueLock.CLOSED_LOCK_SYMBOL

    /**
     * Determines whether the data values are unlocked.
     * @returns {Integer} true if the data values are unlocked | false otherwise.
     */
    IsUnlocked() => this.LockStateControl.Text == ValueLock.OPEN_LOCK_SYMBOL

    /**
     * Sets the lock state of the data values.
     * @param {Integer} LockState true if the data values should be locked | false if the data values should be unlocked.
     */
    SetLockState(LockState) {
        if (LockState) {
            this.LockStateControl.Text := ValueLock.CLOSED_LOCK_SYMBOL
            this.LockStateControl.Opt("C" . ValueLock.CLOSED_LOCK_COLOR)
        } else {
            this.LockStateControl.Text := ValueLock.OPEN_LOCK_SYMBOL
            this.LockStateControl.Opt("C" . ValueLock.OPEN_LOCK_COLOR)
        }
        for (Callback in this.OnLockStateChanged) {
            Callback()
        }
    }
}
