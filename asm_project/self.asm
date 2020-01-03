include masm32\include\masm32rt.inc
.686
WaitMsg PROTO
ReadChar PROTO
includelib masm32\lib\Irvine32.lib

include struct.inc

.DATA
    cursor_info CONSOLE_CURSOR_INFO <?>
    winhwnd HWND ?
    windc HDC ?
    writeHandle HANDLE ?
    read_handle HANDLE ?
    isread byte ?
;;
    rec  RECT <?>
    wheight DWORD ?
    wwidth  DWORD ?
    cheight DWORD ?
    cwidth  DWORD ?
    qlength DWORD 100
    redraw BYTE 1
;;
    deltax DWORD 0
    deltaz DWORD 100
    thetavert DWORD 0
    thetahoriz DWORD 0
    vision real4 ?
;;
    file_name BYTE 150 dup(?)
    sterromsg BYTE 'Cannot open output file!',10,0
;;

    file_length dd ?
    file_buff_ptr dd ?
;;
    polys DWORD ?
    tmpsort sortinfo <?>
    minptr DWORD ?
    printp POINT <?>,<?>,<?>
    pen DWORD 200 dup(?)
    brush DWORD 200 dup(?)
    gtmpn DWORD ?
;; vector info
    gptr   DD   ?
    gcap   WORD 10
    gsize  WORD -1
;;
    coord_hsl HSL_COORD <0.0,0.0,0.0>
    coord_rgb RGB_COORD <1.0, 1.0, 0.0>
    constant_1div2 real4 1.0
    constant_1div3 real4 1.0
    constant_2div3 real4 2.0
    constant_1div6 real4 1.0
;; for test
    
;;;


include rotate.asm
include theta.asm
include show.asm
include read_obj_file.asm
include hsl.asm

.CODE
;;;;;;;

main PROC

;; color
    mov ecx, 181

loopcolor:
    push ecx
    dec ecx
    mov gtmpn, ecx
    mov eax, ecx
    mov ecx, 4
    mul ecx
    mov ebx, eax

    fild gtmpn
    mov gtmpn, 180
    fidiv gtmpn
    mov gtmpn, 1
    fisubr gtmpn
    fstp coord_hsl.l
    INVOKE Change_HSL_TO_RGB, addr coord_hsl, addr coord_rgb

    fld coord_rgb.r
    mov gtmpn, 255
    fimul  gtmpn
    fistp gtmpn
    mov eax, gtmpn
    sal eax, 8

    fld coord_rgb.g
    mov gtmpn, 255
    fimul  gtmpn
    fistp gtmpn
    add eax, gtmpn
    sal eax, 8

    fld coord_rgb.b
    mov gtmpn, 255
    fimul  gtmpn
    fistp gtmpn
    add eax, gtmpn
    mov gtmpn, eax

    mov ecx, offset pen
    add ecx, ebx
    push ecx
    INVOKE CreatePen, PS_SOLID, 1, eax
    pop ecx
    mov [ecx], eax

    mov eax, gtmpn
    push ecx
    INVOKE CreateSolidBrush, eax
    pop ecx
    mov ecx, offset brush
    add ecx, ebx
    mov [ecx], eax

    pop ecx
    dec ecx
    jne loopcolor

;;
    INVOKE GetConsoleWindow
    mov winhwnd, eax
    
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov read_handle,eax


    INVOKE ReadConsole, read_handle, addr file_name, 150, addr isread, 0
    movzx eax, isread
    dec eax
    dec eax
    mov file_name[eax], 0

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE 
    MOV writeHandle, eax
    INVOKE GetConsoleCursorInfo, writeHandle, addr cursor_info
    mov cursor_info.bVisible, 0
    INVOKE SetConsoleCursorInfo, writeHandle,addr cursor_info

    INVOKE  CreateFile,ADDR file_name,GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    MOV     read_handle,eax
    cmp read_handle, INVALID_HANDLE_VALUE
    je erroro


    INVOKE  GetFileSize, read_handle, NULL
    MOV     file_length, eax
    INVOKE  GlobalAlloc, GMEM_FIXED, file_length
    MOV     file_buff_ptr, eax
    INVOKE  ReadFile, read_handle, file_buff_ptr, file_length, NULL, NULL

    INVOKE Proccess_raw_obj_file

    push eax
    INVOKE GlobalFree, file_buff_ptr
    pop eax

    mov ecx, sizeof sortinfo
    mul ecx
    mov ecx, 3
    mul ecx
    INVOKE  GlobalAlloc, GMEM_FIXED, eax
    mov polys, eax

;;
game:
    INVOKE GetAsyncKeyState, 1Bh
    cmp al, 1
    je exitg
;;
    INVOKE GetAsyncKeyState, 25h
    cmp al, 1
    jne noleft
    add deltax, 5
    inc redraw
noleft:
    INVOKE GetAsyncKeyState, 27h
    cmp al, 1
    jne noright
    sub deltax, 5
    inc redraw
noright:
    INVOKE GetAsyncKeyState, 26h
    cmp al, 1
    jne noup
    sub deltaz, 5
    inc redraw
noup:
    INVOKE GetAsyncKeyState, 28h
    cmp al, 1
    jne nodown
    add deltaz, 5
    inc redraw
nodown:

;;
    INVOKE GetAsyncKeyState, 57h
    cmp al, 1
    jne nokup
    sub thetavert, 3
    inc redraw
nokup:
    INVOKE GetAsyncKeyState, 53h
    cmp al, 1
    jne nokdown
    add thetavert, 3
    inc redraw
nokdown:
    INVOKE GetAsyncKeyState, 41h
    cmp al, 1
    jne nokleft
    add thetahoriz, 3
    inc redraw
nokleft:
   INVOKE GetAsyncKeyState, 44h
    cmp al, 1
    jne nokright
    sub thetahoriz, 3
    inc redraw
nokright:
INVOKE GetAsyncKeyState, 20h
    cmp al, 1
    jne nosp
    sub thetahoriz, 3
    INVOKE InvalidateRect, winhwnd, NULL, FALSE
nosp:
    mov al, redraw
    cmp al, 0
    je game
    mov redraw,0
    INVOKE GetDC, winhwnd
    mov windc, eax

    INVOKE InvalidateRect, winhwnd, NULL, FALSE
    
    INVOKE Show_2D, polys
    cmp eax, 0
    je game
    mov ecx, eax
    mov esi, polys
drawloop:
    mov minptr, esi
    push ecx

inner:
    push ecx
    dec ecx
    mov eax, ecx
    mov ecx, sizeof sortinfo
    mul ecx
    mov ecx, 3
    mul ecx
    mov edi, esi
    add edi, eax

    mov eax, minptr
    mov eax, (sortinfo ptr [eax]).z
    mov ecx, [edi]
    cmp eax, ecx
    jg nolarger
    mov minptr, edi
nolarger:

    pop ecx
    loop inner

    mov eax, minptr
    mov ebx, offset printp

    mov ecx, (sortinfo ptr [eax]).x
    mov [ebx], ecx
    mov ecx, (sortinfo ptr [eax]).y
    add ebx, 4
    mov [ebx], ecx

    add eax, sizeof sortinfo
    mov ecx, (sortinfo ptr [eax]).x
    add ebx, 4
    mov [ebx], ecx
    mov ecx, (sortinfo ptr [eax]).y
    add ebx, 4
    mov [ebx], ecx

    add eax, sizeof sortinfo
    mov ecx, (sortinfo ptr [eax]).x
    add ebx, 4
    mov [ebx], ecx
    mov ecx, (sortinfo ptr [eax]).y
    add ebx, 4
    mov [ebx], ecx

    push esi
    mov eax, minptr
;;????
    mov eax, (sortinfo ptr [eax]).rgb
    mov ecx, 4
    mul ecx
    mov ebx, offset pen
    add eax, ebx
    INVOKE SelectObject, windc, [eax]

    mov eax, minptr
    mov eax, (sortinfo ptr [eax]).rgb
    mov ecx, 4
    mul ecx
    mov ebx, offset brush
    add eax, ebx
    INVOKE SelectObject, windc, [eax]



    INVOKE Polygon, windc, addr printp, 3
    pop esi

    mov ecx, 3
    mov eax, minptr

loopins:
    push ecx
    mov ecx, (sortinfo ptr [esi]).x
    mov (sortinfo ptr [eax]).x, ecx
    mov ecx, (sortinfo ptr [esi]).y
    mov (sortinfo ptr [eax]).y, ecx
    mov ecx, (sortinfo ptr [esi]).z
    mov (sortinfo ptr [eax]).z, ecx
    mov ecx, (sortinfo ptr [esi]).rgb
    mov (sortinfo ptr [eax]).rgb, ecx
    add esi, sizeof sortinfo
    add eax, sizeof sortinfo

    pop ecx
    loop loopins

    pop ecx
    dec ecx
    jne drawloop
    dec ecx
    jne game

erroro:
    INVOKE WriteConsole, writeHandle, addr sterromsg, lengthof sterromsg, NULL, NULL
exitg:
    INVOKE InvalidateRect, winhwnd, NULL, FALSE
    call ReadChar
    call WaitMsg
    RET

main ENDP

END main