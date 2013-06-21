;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                                       ;
;       This is "one-function" DLL wich can help you to display the error messages to user              ;
;       Copyright (c) 2012,2013, Alexander Yefremov                                                     ;
;                                                                                                       ;
;       This program is free software: you can redistribute it and/or modify                            ;
;       it under the terms of the GNU Affero General Public License as published by                     ;
;       the Free Software Foundation, either version 3 of the License, or                               ;
;       (at your option) any later version.                                                             ;
;                                                                                                       ;
;       This program is distributed in the hope that it will be useful,                                 ;
;       but WITHOUT ANY WARRANTY; without even the implied warranty of                                  ;
;       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                                   ;
;       GNU Affero General Public License for more details.                                             ;
;                                                                                                       ;
;       You should have received a copy of the GNU Affero General Public License                        ;
;       along with this program.  If not, see <http://www.gnu.org/licenses/>.                           ;
;                                                                                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

format  PE GUI 4.0 DLL

entry   DllEntryPoint

include 'win32a.inc'

section '.code' code readable executable

proc    DllEntryPoint\  ;DllMain entry point
        hinstDLL,\      ;_In_  HINSTANCE hinstDLL       ;Library instance handle
        fdwReason,\     ;_In_  DWORD fdwReason          ;Reason this function is being called
        lpvReserved     ;_In_  LPVOID lpvReserved       ;Not used

        mov     eax,TRUE

        ret

endp

;This function will show the MessageBox with the last error message retrieved by the GetLastError function
;The function beeps if there was an internal unknown error or you have specified the invalid parameter
;If you want, it is posible to copy-paste this proc directly to your source file

proc    ShowLastErrorMessage\
        hWnd,\                  ;_In_opt_  HWND hWnd
        lpCaption               ;_In_opt_  LPCTSTR lpCaption    ;NULL means "Error"

local   Buffer: DWORD

        invoke  GetLastError
        lea     edx,[Buffer]
        invoke  FormatMessage,\
                FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM,\     ;_In_      DWORD dwFlags
                NULL,\                                                          ;_In_opt_  LPCVOID lpSource
                eax,\                                                           ;_In_      DWORD dwMessageId
                LANG_NEUTRAL,\                                                  ;_In_      DWORD dwLanguageId
                edx,\                                                           ;_Out_     LPTSTR lpBuffer
                NULL,\                                                          ;_In_      DWORD nSize
                NULL                                                            ;_In_opt_  va_list *Arguments
        or      eax,eax
        je      .Beep

        invoke  MessageBox,\
                [hWnd],\                ;_In_opt_  HWND hWnd
                [Buffer],\              ;_In_opt_  LPCTSTR lpText
                [lpCaption],\           ;_In_opt_  LPCTSTR lpCaption    ;NULL means "Error"
                MB_ICONERROR+MB_OK      ;_In_      UINT uType
        or      eax,eax
        je      .MessageBoxError

        invoke  LocalFree,\     ;This function returns NULL when succeeds
                [Buffer]        ;_In_  HLOCAL hMem
        or      eax,eax
        jne     .Beep

  .Finish:
        ret


  .MessageBoxError:
        invoke  LocalFree,\     ;This function returns NULL when succeeds
                [Buffer]        ;_In_  HLOCAL hMem

  .Beep:
        invoke  Beep,\
                440,\   ;_In_  DWORD dwFreq
                125     ;_In_  DWORD dwDuration

        jmp     .Finish

endp

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        user32,'USER32.DLL',\
        shell32,'SHELL32.DLL',\
        gdi32,'GDI32'

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\shell32.inc'
include 'api\gdi32.inc'

section '.edata' export data readable

export 'SHOWLASTERRORMESSAGE.DLL',\
       ShowLastErrorMessage,'ShowLastErrorMessage'

section '.reloc' fixups data readable discardable

section '.rsrc' resource data readable

directory       RT_VERSION,versions

resource        versions,\
                1,LANG_NEUTRAL,version

versioninfo     version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,0,\
                'FileDescription','Shows the last error message',\
                'LegalCopyright','Copyright (c) 2012,2013, Alexander Yefremov',\
                'FileVersion','0.1',\
                'OriginalFilename','SHOWLASTERRORMESSAGE.DLL'
