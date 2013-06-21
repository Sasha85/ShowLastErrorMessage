;Test the ShowLastErrorMessage DLL

format  PE GUI 4.0

entry   Start

include 'win32a.inc'

section '.data' data readable writeable

Caption db 'Hello World',0

section '.code' code readable executable

  Start:
        invoke  ShowLastErrorMessage,\
                HWND_DESKTOP,\          ;_In_opt_  HWND hWnd
                Caption                 ;_In_opt_  LPCTSTR lpCaption    ;NULL means "Error"

  Finish:
        invoke  ExitProcess,\
                0               ;_In_  UINT uExitCode

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        user32,'USER32.DLL',\
        shell32,'SHELL32.DLL',\
        gdi32,'GDI32.DLL',\
        showlasterrormessage,'SHOWLASTERRORMESSAGE.DLL'

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\shell32.inc'
include 'api\gdi32.inc'

import  showlasterrormessage,\
        ShowLastErrorMessage,'ShowLastErrorMessage'
