import QtQuick 2.0

Item {

    signal focusToMainList()

    function focusToChild() {
        focusToMainList()
    }

}
