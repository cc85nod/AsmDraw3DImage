.code

to_2D PROC, convptr:DWORD, convtoptr:DWORD
LOCAL tmpq:real4
LOCAL checkq:real4
    mov ebx, convptr
    mov edi, convtoptr

    INVOKE rotate, ebx, edi, 1


    fld (vertinfo ptr [edi]).z
    fisubr qlength
    fst tmpq
    fld (vertinfo ptr [edi]).x
    fimul qlength
    fdivr
    fst checkq
    fiadd cwidth
    fisubr wwidth
    fst checkq
    fstp (vertinfo ptr [edi]).x

    fld tmpq
    fld (vertinfo ptr [edi]).y
    fimul qlength
    fdivr
    fst checkq
    fiadd cheight
    fst checkq
    fstp (vertinfo ptr [edi]).y

    ret
to_2D ENDP


Show_2D PROC, polyptr:DWORD
LOCAL gsptr:DWORD
LOCAL fsptr:DWORD

LOCAL vaptr:vertinfo
LOCAL vbptr:vertinfo
LOCAL vcptr:vertinfo
LOCAL tmpn:DWORD
LOCAL tmpna:DWORD
LOCAL tmpr:real4
LOCAL pta:POINT
LOCAL ptb:POINT
LOCAL ptc:POINT
LOCAL validc:DWORD
LOCAL rgbid:DWORD

    mov validc, 0
    INVOKE GetWindowRect, winhwnd, offset rec
    mov eax, rec.right
    sub eax, rec.left
    add eax, 200
    mov wwidth, eax
    mov ecx, 2
    mov edx, 0
    div ecx
    mov cwidth, eax

    mov eax, rec.bottom
    sub eax, rec.top
    mov wheight, eax
    mov ecx, 2
    mov edx, 0
    div ecx
    mov cheight, eax

    fild cwidth
    fild qlength
    fpatan
    
    mov tmpn, 180
    fild tmpn
    fmul
    fldpi
    fdiv
    fstp vision

    movzx ecx, gsize
    inc ecx
gshlp:
    push ecx
    mov eax, ecx
    dec eax
    mov ecx, sizeof ginfo
    mul ecx
    add eax, gptr
    mov gsptr, eax

    mov ecx, (ginfo ptr [eax]).fsize
    inc ecx
    cmp ecx, 0
    je finish
fshlp:
    push ecx
    mov eax, ecx
    dec eax
    mov ecx, sizeof finfo
    mul ecx
    mov ecx, gsptr
    add eax, (ginfo ptr [ecx]).f
    mov fsptr, eax
;;
    mov eax, (finfo ptr [eax]).va.vn
    mov tmpn, eax
    dec tmpn
    mov eax, gsptr
    mov ebx, (ginfo ptr [eax]).vn
    mov eax, sizeof vertinfo
    mul tmpn
    add ebx, eax

    fld (vertinfo ptr [ebx]).x
    fchs
    fstp vbptr.x
    fld (vertinfo ptr [ebx]).y
    fchs
    fstp vbptr.y
    fld (vertinfo ptr [ebx]).z
    fisubr qlength
    fstp vbptr.z

    INVOKE rotate, ebx, addr vaptr, 0
    INVOKE anglewithz, addr vaptr, addr vbptr, addr tmpr

    fld tmpr
    fistp tmpn
    mov eax, 90
    cmp tmpn, eax
    jg skdraw
;;
    mov tmpn, 0
    fild tmpn
    fst vbptr.x
    fstp vbptr.y
    mov tmpn, -1
    fild tmpn
    fstp vbptr.z

    
    INVOKE anglewithz, addr vaptr, addr vbptr, addr tmpr

    fld tmpr
    fistp rgbid
    mov eax, rgbid
    add eax, 360
    mov edx, 0
    mov ecx, 360
    div ecx
    mov rgbid, edx

;;

;;
    mov eax, fsptr
    mov eax, (finfo ptr [eax]).va.v
    mov tmpn, eax
    dec tmpn
    mov eax, gsptr
    mov ebx, (ginfo ptr [eax]).v
    mov eax, sizeof vertinfo
    mul tmpn
    add ebx, eax
    INVOKE to_2D, ebx, addr vaptr
    fld vaptr.z
    fistp tmpn
    mov eax, qlength
    cmp tmpn, eax
    jle skdraw

    mov eax, fsptr
    mov eax, (finfo ptr [eax]).vb.v
    mov tmpn, eax
    dec tmpn
    mov eax, gsptr
    mov ebx, (ginfo ptr [eax]).v
    mov eax, sizeof vertinfo
    mul tmpn
    add ebx, eax
    INVOKE to_2D, ebx , addr vbptr
    fld vbptr.z
    fistp tmpn
    mov eax, qlength
    cmp tmpn, eax
    jle skdraw

    mov eax, fsptr
    mov eax, (finfo ptr [eax]).vc.v
    mov tmpn,eax
    dec tmpn
    mov eax, gsptr
    mov ebx, (ginfo ptr [eax]).v
    mov eax, sizeof vertinfo
    mul tmpn
    add ebx, eax
    INVOKE to_2D, ebx, addr vcptr
    fld vcptr.z
    fistp tmpn
    mov eax, qlength
    cmp tmpn, eax
    jle skdraw

    fld vaptr.x
    fistp pta.x
    fld vaptr.y
    fistp pta.y

    fld vbptr.x
    fistp ptb.x
    fld vbptr.y
    fistp ptb.y

    fld vcptr.x
    fistp ptc.x
    fld vcptr.y
    fistp ptc.y

    mov eax, pta.x
    cmp eax, 0
    jl outc
    cmp eax, wwidth
    jg outc
    mov eax, pta.y
    cmp eax, 0
    jl outc
    cmp eax, wheight
    jg outc
    jmp draw
outc:
    mov eax, ptb.x
    cmp eax, 0
    jl outa
    cmp eax, wwidth
    jg outa
    mov eax, ptb.y
    cmp eax, 0
    jl outa
    cmp eax, wheight
    jg outa
    jmp draw
outa:
    mov eax, ptc.x
    cmp eax, 0
    jl skdraw
    cmp eax, wwidth
    jg skdraw
    mov eax, ptc.y
    cmp eax, 0
    jl skdraw
    cmp eax, wheight
    jg skdraw

draw:
    inc validc
    mov eax, polyptr
    fld vaptr.z
    fld vbptr.z
    fadd
    fld vcptr.z
    fadd
    mov tmpn, 3
    fidiv tmpn

    mov ecx, pta.x
    mov (sortinfo ptr [eax]).x, ecx
    mov ecx, pta.y
    mov (sortinfo ptr [eax]).y, ecx
    fist (sortinfo ptr [eax]).z
    mov ecx, rgbid
    mov (sortinfo ptr [eax]).rgb, ecx
    add eax, sizeof sortinfo

    mov ecx, ptb.x
    mov (sortinfo ptr [eax]).x, ecx
    mov ecx, ptb.y
    mov (sortinfo ptr [eax]).y, ecx
    fist (sortinfo ptr [eax]).z
    mov ecx, rgbid
    mov (sortinfo ptr [eax]).rgb, ecx
    add eax, sizeof sortinfo

    mov ecx, ptc.x
    mov (sortinfo ptr [eax]).x, ecx
    mov ecx, ptc.y
    mov (sortinfo ptr [eax]).y, ecx
    fistp (sortinfo ptr [eax]).z
    mov ecx, rgbid
    mov (sortinfo ptr [eax]).rgb, ecx
    add eax, sizeof sortinfo

    mov polyptr, eax
skdraw:
    pop ecx
    dec ecx
    jne fshlp

    pop ecx
    dec ecx
    jne gshlp
finish:
    mov eax, validc
    ret
Show_2D ENDP