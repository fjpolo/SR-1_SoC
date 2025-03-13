#HotIf WinActive("IP Customization")
^l::{
    Send "{Tab 3}"
    SendText "DP_BSRAM8"
    Send "{Tab}"
    SendText "dp_bsram8"
    Send "{Tab 2}"
    SendText "Placeholder\CPU\Memory" ;EDIT ME!
    Sleep 100
    Send "{Tab 6}"
    SendText "32768"
    Send "{Tab}"
    SendText "8"
    Send "{Tab 3}"
    SendText "32768"
    Send "{Tab}"
    SendText "8"
    Send "{Tab 5}"
    Send "{Right}"
    Send "{Tab}"
    MsgBox "Successfully filled data fields"
}