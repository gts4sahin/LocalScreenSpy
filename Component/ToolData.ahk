#Include "ValueLock.ahk"

/**
 * Provides a structure that uses graphical user interface control instances to store values that form data.
 * @extends ValueLock : a class that uses a graphical user interface text instance to display the lock state of one or more values.
 * @requires ValueLock.ahk : the file containing the class ValueLock.
 */
class ToolData extends ValueLock {
    /**
     * Concatenates the specified values together with the specified separator.
     * @param {Array} Values the values that should be concatenated together with the specified separator.
     * @param {String} ValueSeparator zero or more symbols that should be placed between the specified values.
     * @returns {String} a non-empty string if at least one value is specified | an empty string otherwise.
     */
    static Concatenate(Values, ValueSeparator) {
        Result := Values.Length ? Values[1] : ""

        Index := 2
        while (Index <= Values.Length) {
            Result := Result . ValueSeparator . Values[Index++]
        }

        return Result
    }

    /**
     * Locks every data instance that is checked and unlocked.
     * @param {... ToolData} Data one or more data instances.
     */
    static LockIfChecked(Data*) {
        for (Instance in Data) {
            if (Instance.IsChecked() && Instance.IsUnlocked()) {
                Instance.SetLockState(true)
            }
        }
    }
    /**
     * Saves every data instance that is checked.
     * @param {String} Directory the name of the directory in which the checked data should be saved.
     * @param {String} FileName the name of the file in which the checked data should be saved.
     * @param {String} ValueSeparator one or more symbols that should be used to separated the checked data in the specified file.
     * @param {... ToolData} Data one or more data instances.
     */
    static SaveIfChecked(Directory, FileName, ValueSeparator, Data*) {
        CheckedLabels := ""
        CheckedValues := ""

        Index := 1
        while (Index <= Data.Length) {
            Instance := Data[Index++]
            if (Instance.IsChecked()) {
                CheckedLabels := Instance.GetLabels(ValueSeparator)
                CheckedValues := Instance.GetValues(ValueSeparator)
                break
            }
        }

        if (CheckedLabels == "") {
            MsgBox("Cannot save checked data due to nothing being checked.", "LSS - Save Checked Error", "0 16 4096")
            return
        }

        while (Index <= Data.Length) {
            Instance := Data[Index++]
            if (Instance.IsChecked()) {
                CheckedLabels := CheckedLabels . ValueSeparator . Instance.GetLabels(ValueSeparator)
                CheckedValues := CheckedValues . ValueSeparator . Instance.GetValues(ValueSeparator)
            }
        }

        CreateDirectory := "N/A"
        if (!DirExist(Directory)) {
            CreateDirectory := MsgBox(Directory . " does not exist. Do you want to create it?", "LSS - Directory Request", "4 32 4096")
        }

        if (!(CreateDirectory == "N/A" || CreateDirectory == "Yes")) {
            MsgBox("Cannot save checked data due to not having permission to create the data directory.", "LSS - Directory Error", "0 16 4096")
            return
        }

        try {
            if (CreateDirectory == "Yes") {
                DirCreate(Directory)
            }

            FilePath := Directory . "\" . FileName
            if ( not FileExist(FilePath)) {
                FileWriter := FileOpen(FilePath, "w")
                FileWriter.WriteLine(CheckedLabels)
                FileWriter.WriteLine(CheckedValues)
                FileWriter.Close()
                return
            }

            FileReader := FileOpen(FilePath, "r")
            SavedLabels := FileReader.ReadLine()
            FileReader.Close()
            if (StrCompare(SavedLabels, CheckedLabels) == 0) {
                FileWriter := FileOpen(FilePath, "a")
                FileWriter.WriteLine(CheckedValues)
                FileWriter.Close()
                return
            }

            FileWriter := FileOpen(FilePath, "w")
            FileWriter.WriteLine(CheckedLabels)
            FileWriter.WriteLine(CheckedValues)
            FileWriter.Close()
        } catch (Error as E) {
            MsgBox("Failed to save checked data due to error: " E.Message, "LSS - Save Checked Error", "0 16 4096")
        }
    }

    /**
     * Unlocks every data instance that is checked and locked.
     * @param {... ToolData} Data one or more data instances.
     */
    static UnlockIfChecked(Data*) {
        for (Instance in Data) {
            if (Instance.IsChecked() && Instance.IsLocked()) {
                Instance.SetLockState(false)
            }
        }
    }

    /**
     * Provides the check box that displays the check state of the data.
     * @private
     * @readonly
     * @type {Gui.CheckBox}
     */
    CheckBox := unset

    /**
     * Provides the functions that get executed whenever the values that form the data change. <p></p>
     * Note: This property is optional and may therefore not have been assigned a value other than an empty array.
     * @public
     * @type {Array<Func>}
     */
    OnValuesChanged := []

    /**
     * Provides the control instance that displays the value of the data.
     * @private
     * @readonly
     * @type {Gui.DDL | Gui.Edit | Gui.Text}
     */
    ValueControl := unset

    /**
     * Provides the labels of the values that form the data. <p></p>
     * Note: This property is optional and may therefore be assigend an empty array to indicate that it is not used.
     * @private
     * @readonly
     * @type {Array<String>}
     */
    ValueLabels := unset

    /**
     * Provides one or more symbols to separate the values that form the data in a displayed string representation of the data. <p></p>
     * Note: This property is optional and may therefore be assigend an empty string to indicate that it is not used.
     * @private
     * @readonly
     * @type {String}
     */
    ValueSeparator := unset

    /**
     * Creates a new data instance that contains the specified value labels, value separator, value control, lock state control and check box.
     * @param {String} ValueLabels the labels of the values that will form the data.
     * @param {String} ValueSeparator a non-empty string if the data will consist of more than one value | an empty string otherwise.
     * @param {Gui.DDL | Gui.Edit | Gui.Text} ValueControl the control instance that display the values that form the data.
     * @param {Gui.Text} LockStateControl the text instance that should display the lock state of the values that form the data.
     * @param {Gui.CheckBox} CheckBox the check box that should display the check state of the values that form the data.
     */
    __New(ValueLabels, ValueSeparator, ValueControl, LockStateControl, CheckBox) {
        super.__Init()
        super.__New(LockStateControl)
        this.CheckBox := CheckBox
        this.ValueControl := ValueControl
        this.ValueLabels := ValueLabels
        this.ValueSeparator := ValueSeparator
    }

    /**
     * Obtains the displayed text that contains the values that form the data.
     * @returns {String} the displayed text that contains the values that form the data.
     */
    GetDisplayedText() {
        return this.ValueControl.Text
    }

    /**
     * Converts the labels of the values that form the data to a string.
     * @param {String} ValueSeparator one or more symbols that should be used to separate the labels of the values that form the data from each other in the string.
     * @returns {String} a non-empty string if at least one value label is stored | an empty string otherwise.
     */
    GetLabels(ValueSeparator) {
        return ToolData.Concatenate(this.ValueLabels, ValueSeparator)
    }

    /**
     * Converts the values that form the data to a string.
     * @param {String} ValueSeparator one or more symbols that should be used to separate the values that form the data from each other in the string.
     * @returns {String} a non-empty string if at least one value is displayed | an empty string otherwise.
     */
    GetValues(ValueSeparator) {
        Values := this.ValueSeparator == "" ? Array(this.ValueControl.Text) : StrSplit(this.ValueControl.Text, this.ValueSeparator, A_Space)
        return ToolData.Concatenate(Values, ValueSeparator)
    }

    /**
     * Determines whether the data is checked.
     * @returns {Integer} true if the data is checked. | false otherwise.
     */
    IsChecked() => this.CheckBox.Value == 1

    /**
     * Sets the enabled property of the control instance that displays the values that form the data.
     * @param {Integer} Enabled true if the control instance should be enabled | false if the control instance should be disabled.
     */
    SetEnabled(Enabled) {
        if (this.ValueControl.Enabled != Enabled) {
            this.ValueControl.Enabled := Enabled
        }
    }

    /**
     * Sets the values that form the data if it is not already set.
     * @param {... String | ... Integer | ... Float} Values the values that should form the data.
     * @throws {Error} if more than one value is specified and the data instance does not contain a value separator.
     */
    SetIfNotSet(Values*) {
        if (Values.Length > 1 && this.ValueSeparator == "") {
            throw Error("Cannot set the specified values due to the data instance not containing a value separator.")
        }

        Text := Values.Length == 1 ? String(Values[1]) : ToolData.Concatenate(Values, this.ValueSeparator)
        if (this.ValueControl.Text != Text) {
            this.ValueControl.Text := Text
            for (Callback in this.OnValuesChanged) {
                Callback()
            }
        }
    }
}
