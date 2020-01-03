.code

expend_g PROC
	mov eax, 2
	inc gcap
	mul gcap
	mov gcap, ax
	movzx eax, gcap
	dec gcap
	mov ecx, sizeof ginfo
	mul ecx
	INVOKE GlobalReAlloc, gptr, eax , GMEM_MOVEABLE 
    mov	gptr, eax
    mov edi, eax
    movzx eax, gsize
    mov ecx, sizeof ginfo
    mul ecx
    add edi, eax
    ret

expend_g ENDP

expend_v PROC
	mov eax, 2
	inc (ginfo ptr [edi]).vcap
	mul (ginfo ptr [edi]).vcap
	mov (ginfo ptr [edi]).vcap, eax
	mov eax, (ginfo ptr [edi]).vcap
	dec (ginfo ptr [edi]).vcap
	mov ecx, sizeof vertinfo
	mul ecx
	INVOKE GlobalReAlloc, (ginfo ptr [edi]).v, eax, GMEM_MOVEABLE 
    mov	(ginfo ptr [edi]).v, eax
    mov (ginfo ptr [edi]).curv_ptr, eax
    mov eax, (ginfo ptr [edi]).vsize
    mov ecx, sizeof vertinfo
    mul ecx
    add (ginfo ptr [edi]).curv_ptr, eax
    ret

expend_v ENDP

expend_vn PROC
	mov eax, 2
	inc (ginfo ptr [edi]).vncap
	mul (ginfo ptr [edi]).vncap
	mov (ginfo ptr [edi]).vncap, eax
	mov eax, (ginfo ptr [edi]).vncap
	dec (ginfo ptr [edi]).vncap
	mov ecx, sizeof vertinfo
	mul ecx
	INVOKE GlobalReAlloc, (ginfo ptr [edi]).vn, eax, GMEM_MOVEABLE 
    mov	(ginfo ptr [edi]).vn, eax
    mov (ginfo ptr [edi]).curvn_ptr, eax
    mov eax, (ginfo ptr [edi]).vnsize
    mov ecx, sizeof vertinfo
    mul ecx
    add (ginfo ptr [edi]).curvn_ptr, eax
    ret

expend_vn ENDP

expend_vt PROC
	mov eax, 2
	inc (ginfo ptr [edi]).vtcap
	mul (ginfo ptr [edi]).vtcap
	mov (ginfo ptr [edi]).vtcap, eax
	mov eax, (ginfo ptr [edi]).vtcap
	dec (ginfo ptr [edi]).vtcap
	mov ecx, sizeof vertinfo
	mul ecx
	INVOKE GlobalReAlloc, (ginfo ptr [edi]).vt, eax, GMEM_MOVEABLE 
    mov	(ginfo ptr [edi]).vt, eax
    mov (ginfo ptr [edi]).curvt_ptr, eax
    mov eax, (ginfo ptr [edi]).vtsize
    mov ecx, sizeof vertinfo
    mul ecx
    add (ginfo ptr [edi]).curvt_ptr, eax
    ret

expend_vt ENDP

expend_f PROC
	mov eax, 2
	inc (ginfo ptr [edi]).fcap
	mul (ginfo ptr [edi]).fcap
	mov (ginfo ptr [edi]).fcap, eax
	mov eax, (ginfo ptr [edi]).fcap
	dec (ginfo ptr [edi]).fcap
	mov ecx, sizeof finfo
	mul ecx
	INVOKE GlobalReAlloc, (ginfo ptr [edi]).f, eax, GMEM_MOVEABLE 
    mov	(ginfo ptr [edi]).f, eax
    mov (ginfo ptr [edi]).curf_ptr, eax
    mov eax, (ginfo ptr [edi]).fsize
    mov ecx, sizeof finfo
    mul ecx
    add (ginfo ptr [edi]).curf_ptr, eax
    ret

expend_f ENDP



init_g PROC
	
	inc gsize
	add edi, sizeof ginfo
	mov ax, gcap
	cmp ax, gsize
	jg 	skexpg
	call expend_g

skexpg:
	mov (ginfo PTR [edi]).ginit , 1
    mov (ginfo PTR [edi]).vcap , 99
    mov (ginfo PTR [edi]).vncap, 99
    mov (ginfo PTR [edi]).vtcap, 99
    mov (ginfo PTR [edi]).fcap, 99

    mov (ginfo PTR [edi]).vsize , -1
    mov (ginfo PTR [edi]).vnsize, -1
    mov (ginfo PTR [edi]).vtsize, -1
    mov (ginfo PTR [edi]).fsize, -1

    INVOKE GlobalAlloc, GMEM_FIXED, 100 * sizeof vertinfo
    mov (ginfo PTR [edi]).v, eax
    mov (ginfo PTR [edi]).curv_ptr, eax
    sub (ginfo PTR [edi]).curv_ptr, sizeof vertinfo
    INVOKE GlobalAlloc, GMEM_FIXED, 100 * sizeof vertinfo
    mov (ginfo PTR [edi]).vn, eax
    mov (ginfo PTR [edi]).curvn_ptr, eax
    sub (ginfo PTR [edi]).curvn_ptr, sizeof vertinfo
    INVOKE GlobalAlloc, GMEM_FIXED, 100 * sizeof vertinfo
    mov (ginfo PTR [edi]).vt, eax
    mov (ginfo PTR [edi]).curvt_ptr, eax
    sub (ginfo PTR [edi]).curvt_ptr, sizeof vertinfo
    INVOKE GlobalAlloc, GMEM_FIXED, 100 * sizeof finfo
    mov (ginfo PTR [edi]).f, eax
    mov (ginfo PTR [edi]).curf_ptr, eax
    sub (ginfo PTR [edi]).curf_ptr, sizeof finfo

    ret
init_g ENDP

read_string PROC uses edi, dest: DWORD, maxlength:DWORD
	mov edi, dest
	mov ecx, maxlength

rnext:
	mov al, [ebx + esi]
	cmp al, 13
	je exitRsnP
	mov [edi], al
	inc edi
	inc esi
	cmp esi, file_length
	je exitRsP
	loop rnext

exitRsnP:
	inc esi
exitRsP:
	ret

read_string ENDP

Proccess_raw_obj_file PROC
LOCAL tmpfor8:REAL8
LOCAL tmpdig:DWORD
;; init g vector
    INVOKE GlobalAlloc, GMEM_FIXED, 100 * sizeof ginfo
    mov	gcap, 10
    mov	gptr, eax
    mov edi, eax
    sub edi, sizeof ginfo

    mov gsize, -1
    INVOKE init_g

    mov ebx, file_buff_ptr
    mov esi, 0

;; start cmp
nextch:
	cmp esi, file_length
	je exitRfP
	mov al, [ebx + esi]

; comment
    cmp al, '#'
    je read_to_nextline
; emptyline
    cmp al, 13
    je to_nextline
; emptyline
    cmp al, 10
    je endch
; g
    cmp al, 'g'
    je g
; mtllib
    cmp al, 'm'
    je mtllib
; usemtl
    cmp al, 'u'
    je usemtl
; v*
    cmp al, 'v'
    je vstar
; f
    cmp al, 'f'
    je f

jmp read_to_nextline

vstar:
    inc esi 
    mov al, [ebx + esi]
    cmp al, ' '
    je v
    cmp al, 'n'
    je vn
    cmp al, 't'
    je vt

v:

	inc (ginfo ptr [edi]).vsize
	add (ginfo ptr [edi]).curv_ptr, sizeof vertinfo
	mov eax, (ginfo ptr [edi]).vcap
	cmp eax, (ginfo ptr [edi]).vsize
	jg 	skexpv
	call expend_v
skexpv:
	mov ecx, 3
	dec esi

loopv:

    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne loopv

looptonsp:
    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    je looptonsp

	
	push esi
	push ebx
	push ecx
	push edi

	mov ecx, esi
	add ecx, ebx
	
    INVOKE  StrToFloat, ecx, addr tmpfor8
    fld tmpfor8

    pop edi
    pop eax
    push eax
    push edi

    dec eax
    mov ecx, 4
    mul ecx
    add eax, (ginfo ptr [edi]).curv_ptr
    fstp real4 ptr [eax]


    pop edi
    pop ecx
    pop ebx
    pop esi

    loop loopv
    jmp read_to_nextline
    
vn:

	inc (ginfo ptr [edi]).vnsize
	add (ginfo ptr [edi]).curvn_ptr, sizeof vertinfo
	mov eax, (ginfo ptr [edi]).vncap
	cmp eax, (ginfo ptr [edi]).vnsize
	jg 	skexpvn
	call expend_vn
skexpvn:
	mov ecx, 3
loopvn:

    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne loopvn
    inc esi

	
	push esi
	push ebx
	push ecx
	push edi

	mov ecx, esi
	add ecx, ebx
	
    INVOKE  StrToFloat, ecx, addr tmpfor8
    fld tmpfor8

    pop edi
    pop eax
    push eax
    push edi

    dec eax
    mov ecx, 4
    mul ecx
    add eax, (ginfo ptr [edi]).curvn_ptr
    fstp real4 ptr [eax]

    pop edi
    pop ecx
    pop ebx
    pop esi

    loop loopvn
    jmp read_to_nextline

vt:


	inc (ginfo ptr [edi]).vtsize
	add (ginfo ptr [edi]).curvt_ptr, sizeof vertinfo
	mov eax, (ginfo ptr [edi]).vtcap
	cmp eax, (ginfo ptr [edi]).vtsize
	jg 	skexpvt
	call expend_vt
skexpvt:
	mov ecx, 2
loopvt:

    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne loopvt
    inc esi

	
	push esi
	push ebx
	push ecx
	push edi

	mov ecx, esi
	add ecx, ebx
	
    INVOKE  StrToFloat, ecx, addr tmpfor8
    fld tmpfor8

    pop edi
    pop eax
    push eax
    push edi

    dec eax
    mov ecx, 4
    mul ecx
    add eax, (ginfo ptr [edi]).curvt_ptr
    fstp real4 ptr [eax]


    pop edi
    pop ecx
    pop ebx
    pop esi

    loop loopvt
    jmp read_to_nextline



;; ebx esi edi
f:

	inc (ginfo ptr [edi]).fsize
	add (ginfo ptr [edi]).curf_ptr, sizeof finfo
	mov eax, (ginfo ptr [edi]).fcap
	cmp eax, (ginfo ptr [edi]).fsize
	jg 	skexpf
	call expend_f
skexpf:	
	inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne f
    inc esi

    mov eax, (ginfo ptr [edi]).curf_ptr
	mov (finfo ptr [eax]).va.v, 0
	mov (finfo ptr [eax]).va.vt, 0
	mov (finfo ptr [eax]).va.vn, 0
	mov (finfo ptr [eax]).vb.v, 0
	mov (finfo ptr [eax]).vb.vt, 0
	mov (finfo ptr [eax]).vb.vn, 0
	mov (finfo ptr [eax]).vc.v, 0
	mov (finfo ptr [eax]).vc.vt, 0
	mov (finfo ptr [eax]).vc.vn, 0

    mov ecx, 3
lpf:

scanfslf:
	mov eax, [ebx + esi]
	cmp al, '/'
	je scanfsls
	sub al, 48
	push edi
	movzx edx, al
	mov tmpdig, edx

	mov eax, ecx
	dec eax
    mov edi, sizeof fmap
    mul edi
    pop edi
    push edi
	mov edi, (ginfo ptr [edi]).curf_ptr
	add edi, eax

	mov eax, 10
	mul (fmap ptr [edi]).v
	add eax, tmpdig
	mov (fmap ptr [edi]).v, eax

	pop edi

	inc esi
	jmp scanfslf

scanfsls:
	inc esi

	mov eax, [ebx + esi]
	cmp al, '/'
	je scanfslt
	sub al, 48
	push edi
	movzx edx, al
	mov tmpdig, edx
	mov eax, ecx
	dec eax
    mov edi, sizeof fmap
    mul edi
    pop edi
    push edi
	mov edi, (ginfo ptr [edi]).curf_ptr
	add edi, eax

	mov eax, 10
	mul (fmap ptr [edi]).vt
	add eax, tmpdig
	mov (fmap ptr [edi]).vt, eax

	pop edi

	jmp scanfsls


scanfslt:
	inc esi

	mov eax, [ebx + esi]
	cmp al, ' '
	je exitscanfsl
	cmp al, 13
	je to_nextline
	cmp esi, file_length
	je exitRfP
	sub al, 48
	push edi
	movzx edx, al
	mov tmpdig, edx

	mov eax, ecx
	dec eax
    mov edi, sizeof fmap
    mul edi
    pop edi
    push edi
	mov edi, (ginfo ptr [edi]).curf_ptr
	add edi, eax

	mov eax, 10
	mul (fmap ptr [edi]).vn
	add eax, tmpdig
	mov (fmap ptr [edi]).vn, eax

	pop edi

	jmp scanfslt

exitscanfsl:
	inc esi
	cmp esi, file_length
	je exitRfP
	mov al, [ebx + esi]
	cmp al, ' '
	je exitscanfsl

	dec ecx
	jne  lpf

to_nextline:
    inc esi
    jmp endch

read_to_nextline:
    
    inc esi
    cmp esi, file_length
    je exitRfP
    mov al, [ebx + esi]
    cmp al , 10
    je endch
    cmp al , 13
    jne read_to_nextline
    jmp to_nextline
    
g:
    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne g
    inc esi

	;INVOKE init_g

    INVOKE read_string, addr (ginfo ptr [edi]).gname, lengthof (ginfo ptr [edi]).gname
    cmp esi, file_length
    je exitRfP
    jmp endch

mtllib:
	inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne mtllib
    inc esi

    INVOKE read_string, addr (ginfo ptr [edi]).mtlsource, lengthof (ginfo ptr [edi]).mtlsource
    cmp esi, file_length
    je exitRfP
    jmp endch

usemtl:
    inc esi
    mov al, [ebx + esi]
    cmp al, ' '
    jne usemtl
    inc esi

    INVOKE read_string, addr (ginfo ptr [edi]).mtlname, lengthof (ginfo ptr [edi]).mtlname
    cmp esi, file_length
    je exitRfP
    jmp endch

endch:

    inc esi 
    cmp esi, file_length
    je exitRfP
	jmp nextch

exitRfP:
    mov eax, (ginfo ptr [edi]).fsize
    inc eax
    ret
Proccess_raw_obj_file endp

