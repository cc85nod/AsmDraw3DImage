.code

anglewithz PROC,xyz1:DWORD, xyz2:DWORD, angle:DWORD
LOCAL t1length:real4
LOCAL t2length:real4
LOCAL sin:real4
LOCAL cos:real4
LOCAL incos:real4
LOCAL i:real4
LOCAL t2side:real4
LOCAL SPECIAL:DWORD
        fld1
        fstp i
        mov SPECIAL, 180

	mov ebx, xyz1
        mov edx, xyz2
        
        fld (vertinfo ptr[ebx]).x
        fld (vertinfo ptr[ebx]).x
        fmul
        fld (vertinfo ptr[ebx]).y
        fld (vertinfo ptr[ebx]).y
        fmul
        fadd
        fld (vertinfo ptr[ebx]).z
        fld (vertinfo ptr[ebx]).z
        fmul
        fadd
	fsqrt
        fstp t1length

        fld (vertinfo ptr[edx]).x
        fld (vertinfo ptr[edx]).x
        fmul
        fld (vertinfo ptr[edx]).y
        fld (vertinfo ptr[edx]).y
        fmul
        fadd
        fld (vertinfo ptr[edx]).z
        fld (vertinfo ptr[edx]).z
        fmul
        fadd
	fsqrt
        fstp t2length  
        
        fld t1length
        fld t2length
        fmul

        fld (vertinfo ptr[ebx]).x 
	fld (vertinfo ptr[edx]).x 
	fmul                      
	fld (vertinfo ptr[ebx]).y 
	fld (vertinfo ptr[edx]).y 
	fmul  
        fadd                   
        fld (vertinfo ptr[ebx]).z 
	fld (vertinfo ptr[edx]).z 
	fmul
        fadd
        fdiv
        fstp incos
        fld  i        
        fld  incos
        fdiv
        fstp cos

        fld t2length
        fld t2length
        fmul
        fld t2length
        fld t2length
        fmul
        fld cos
        fld cos
        fmul
        fmul
        fsub
        fsqrt
        fstp t2side
        
        fld t2side
        fld t2length 
        fdiv
        fstp sin
       
        fld incos
        fld sin
        fmul
        fld i
        fpatan
      
	fild SPECIAL
	fmul
	fldpi
	fdiv
	mov ebx, angle
	fstp real4 ptr [ebx]
	ret
anglewithz ENDP