.code
rotate PROC,xyz:DWORD, toxyz:DWORD, trans:BYTE
LOCAL SPECIAL:DWORD
LOCAL tmpx:real4
LOCAL tmpy:real4
LOCAL tmpz:real4
LOCAL one:DWORD
	mov edi, toxyz
	mov SPECIAL, 180
	mov one, 1
	mov ebx, xyz


	fld (vertinfo ptr[ebx]).x
	fstp (vertinfo ptr[edi]).x
	fld (vertinfo ptr[ebx]).z
	fstp (vertinfo ptr[edi]).z

	cmp trans, 0
	je sktans

	fild deltax 
	fld (vertinfo ptr[ebx]).x
	fadd
	fstp (vertinfo ptr[edi]).x

	fild deltaz
	fld (vertinfo ptr[ebx]).z
	fadd
	fstp (vertinfo ptr[edi]).z
	jmp starttr
sktans:
	fild qlength
	fld (vertinfo ptr[ebx]).z
	fadd
	fstp (vertinfo ptr[edi]).z
starttr:
	fldpi
	fild SPECIAL
	fdiv 
	fild thetahoriz
	fmul
	fcos
	fld (vertinfo ptr[edi]).x
	fmul 
	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fsin
	fld (vertinfo ptr[edi]).z
	fmul 
	fadd
	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fsin
	fild qlength
	fmul
	fsub
	fstp tmpx

	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fsin
	fldpi
	fild SPECIAL
	fdiv 
	fild thetavert
	fmul
	fsin
	fmul
	fld (vertinfo ptr[edi]).x
	fmul
	fldpi
	fild SPECIAL
	fdiv
	fild thetavert
	fmul
	fcos
	fld (vertinfo ptr[ebx]).y
	fmul
	fadd
	fldpi
	fild SPECIAL
	fdiv 
	fild thetavert
	fmul
	fsin
	fldpi
	fild SPECIAL
	fdiv 
	fild thetahoriz
	fmul
	fcos
	fmul
	fld (vertinfo ptr[edi]).z
	fmul
	fsub
	fldpi
	fild SPECIAL
	fdiv 
	fild thetavert
	fmul
	fsin
	fldpi
	fild SPECIAL
	fdiv 
	fild thetahoriz
	fmul
	fcos
	fmul
	fild qlength
	fmul
	fadd
	fstp tmpy

	fldpi
	fild SPECIAL
	fdiv
	fild thetavert
	fmul
	fsin
	fld (vertinfo ptr[ebx]).y
	fmul
	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fsin
	fldpi
	fild SPECIAL
	fdiv 
	fild thetavert
	fmul
	fcos
	fmul
	fld (vertinfo ptr[edi]).x
	fmul
	fsub
	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fcos
	fldpi
	fild SPECIAL
	fdiv
	fild thetavert
	fmul
	fcos
	fmul
	fld (vertinfo ptr[edi]).z
	fmul
	fadd
	fldpi
	fild SPECIAL
	fdiv
	fild thetahoriz
	fmul
	fcos
	fldpi
	fild SPECIAL
	fdiv
	fild thetavert
	fmul
	fcos
	fmul	
	fild qlength
	fmul
	fsub
	fild qlength
	fadd
	fstp tmpz

	fld tmpx
	fstp (vertinfo ptr[edi]).x
	fld tmpy
	fstp (vertinfo ptr[edi]).y
	fld tmpz
	cmp trans, 1
	je tranz
	fisub qlength
tranz:
	fstp (vertinfo ptr[edi]).z
	

	ret
rotate ENDP