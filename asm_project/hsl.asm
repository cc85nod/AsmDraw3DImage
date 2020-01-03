.code

InitialConstant PROC
	local tt:dword
	;fninit
	;1/6
	mov tt, 6
	fld constant_1div6
	fidiv tt
	fstp constant_1div6
	;1/2
	mov tt, 2
	fld constant_1div2
	fidiv tt
	fstp constant_1div2
	;1/3
	mov tt, 3
	fld constant_1div3
	fidiv tt
	fstp constant_1div3
	;2/3
	mov tt, 3
	fld constant_2div3
	fidiv tt
	fstp constant_2div3
	ret
InitialConstant ENDP


Change_HSL_TO_RGB PROC,
	hsl:ptr HSL_COORD,
	rgb:ptr RGB_COORD
	local q:real4, p:real4,
		tr:real4, tg:real4, tb:real4,
		temp:dword
q_com:
	mov edi, hsl
	fld (HSL_COORD ptr [edi]).l
	fld constant_1div2
	fcomip ST(0), ST(1)
	ja less_1div2
	fmul (HSL_COORD ptr [edi]).s
	fchs
	fadd (HSL_COORD ptr [edi]).l
	fadd (HSL_COORD ptr [edi]).s
	fstp q
	jmp p_ope
	less_1div2:
		mov temp, 1
		fild temp
		fld (HSL_COORD ptr [edi]).s
		fadd
		fmul
		fstp q
p_ope:
	fld (HSL_COORD ptr [edi]).l
	mov eax, q
	mov temp, 2
	fimul temp
	fsub q
	fstp p
tr_ope:
	fld (HSL_COORD ptr [edi]).h
	fadd constant_1div3
	mov temp, 1
	fild temp
	fcomip ST(0), ST(1)
	jb tr_lar1
	fiadd temp
	fild temp
	fcomip ST(0), ST(1)
	ja tg_ope
	fisub temp
	jmp tg_ope
	tr_lar1:
		mov temp, 1
		fisub temp
tg_ope:
	fstp tr
	
	fld (HSL_COORD ptr [edi]).h
	mov temp, 1
	fild temp
	fcomip ST(0), ST(1)
	jb tg_lar1
	fiadd temp
	fild temp
	fcomip ST(0), ST(1)	
	ja tb_ope
	fisub temp
	jmp tb_ope
	tg_lar1:
		mov temp, 1
		fisub temp
tb_ope:
	fstp tg
	
	fld (HSL_COORD ptr [edi]).h
	fsub constant_1div3
	mov temp, 1
	fild temp
	fcomip ST(0), ST(1)
	jb tb_lar1
	fiadd temp
	fild temp
	fcomip ST(0), ST(1)
	ja color_com
	fisub temp
	jmp color_com
	tb_lar1:
		mov temp, 1
		fisub temp
color_com:
	fstp tb
	mov edi, rgb
	r_condition:
		fld tr
		
		fld constant_2div3
		fcomip ST(0), ST(1)
		jb tr_large_2div3
		
		fld constant_1div2
		fcomip ST(0), ST(1)
		jb tr_between_1div2_2div3
		
		fld constant_1div6
		fcomip ST(0), ST(1)
		jb tr_between_1div6_1div2
		; less than 1/6
		fld q
		fsub p
		mov temp, 6
		fimul temp
		fmul tr
		fadd p
		jmp g_condition
		
		tr_between_1div6_1div2:
			fld q
			jmp g_condition
		tr_between_1div2_2div3:
			fld q
			fsub p
			mov temp, 6
			fimul temp
			fld constant_2div3
			fsub tr
			fmul
			fadd p
			jmp g_condition
		tr_large_2div3:
			fld p
	g_condition:
		fstp (RGB_COORD ptr [edi]).r
		
		fld tg
		
		fld constant_2div3
		fcomip ST(0), ST(1)
		jb tg_large_2div3
		
		fld constant_1div2
		fcomip ST(0), ST(1)
		jb tg_between_1div2_2div3
		
		fld constant_1div6
		fcomip ST(0), ST(1)
		jb tg_between_1div6_1div2
		;less than 1/6
		fld q
		fsub p
		mov temp, 6
		fimul temp
		fmul tg
		fadd p
		jmp b_condition
		tg_between_1div6_1div2:
			fld q
			jmp b_condition
		tg_between_1div2_2div3:
			fld q
			fsub p
			mov temp, 6
			fimul temp
			fld constant_2div3
			fsub tg
			fmul
			fadd p
			jmp b_condition
		tg_large_2div3:
			fld p
		
	b_condition:
		fstp (RGB_COORD ptr [edi]).g
		
		fld tb
		
		fld constant_2div3
		fcomip ST(0), ST(1)
		jb tb_large_2div3
		
		fld constant_1div2
		fcomip ST(0), ST(1)
		jb tb_between_1div2_2div3
		
		fld constant_1div6
		fcomip ST(0), ST(1)
		jb tb_between_1div6_1div2
		;less than 1/6
		fld q
		fsub p
		mov temp, 6
		fimul temp
		fmul tb
		fadd p
		jmp ex_Change_HSL_TO_RGB
		tb_between_1div6_1div2:
			fld q
			jmp ex_Change_HSL_TO_RGB
		tb_between_1div2_2div3:
			fld q
			fsub p
			mov temp, 6
			fimul temp
			fld constant_2div3
			fsub tb
			fmul
			fadd p
			jmp ex_Change_HSL_TO_RGB
		tb_large_2div3:
			fld p
	ex_Change_HSL_TO_RGB:
		fstp (RGB_COORD ptr [edi]).b
		ret
Change_HSL_TO_RGB ENDP



Change_RGB_TO_HSL PROC,
	hsl:ptr HSL_COORD,
	rgb:ptr RGB_COORD
	local max:real4, min:real4,
		temp_r:real4, temp_dw:dword
	mov edi, rgb
	mov esi, hsl
find_max:
	r_lar:
		fld (RGB_COORD ptr [edi]).r
		fld (RGB_COORD ptr [edi]).g
		fcomip ST(0), ST(1)
		jb r_lar_g
		je r_lar_g
		jmp g_lar
		r_lar_g:
			fld (RGB_COORD ptr [edi]).b
			fcomip ST(0), ST(1)
			je find_min
			jb find_min
			fstp temp_r
	g_lar:
		fld (RGB_COORD ptr [edi]).g
		fld (RGB_COORD ptr [edi]).r
		fcomip ST(0), ST(1)
		jb g_lar_r
		je g_lar_r
		jmp b_lar
		g_lar_r:
			fld (RGB_COORD ptr [edi]).b
			fcomip ST(0), ST(1)
			je find_min
			jb find_min
			fstp temp_r
	b_lar:
		fld (RGB_COORD ptr [edi]).b
		fld (RGB_COORD ptr [edi]).r
		fcomip ST(0), ST(1)
		jb b_lar_r
		je b_lar_r
		jmp s_ope
		b_lar_r:
			fld (RGB_COORD ptr [edi]).g
			fcomip ST(0), ST(1)
			je find_min
			jb find_min
			fstp temp_r
find_min:
	fstp max
	
	r_les:
		fld (RGB_COORD ptr [edi]).r
		fld (RGB_COORD ptr [edi]).g
		fcomip ST(0), ST(1)
		ja r_les_g
		je r_les_g
		jmp g_les
		r_les_g:
			fld (RGB_COORD ptr [edi]).b
			fcomip ST(0), ST(1)
			ja h_ope
			je h_ope
			fstp temp_r
	g_les:
		fld (RGB_COORD ptr [edi]).g
		fld (RGB_COORD ptr [edi]).r
		fcomip ST(0), ST(1)
		ja g_les_r
		je g_les_r
		jmp b_les
		g_les_r:
			fld (RGB_COORD ptr [edi]).b
			fcomip ST(0), ST(1)
			ja h_ope
			je h_ope
			fstp temp_r
	b_les:
		fld (RGB_COORD ptr [edi]).b
		fld (RGB_COORD ptr [edi]).r
		fcomip ST(0), ST(1)
		ja b_les_r
		je b_les_r
		jmp h_ope
		b_les_r:
			fld (RGB_COORD ptr [edi]).g
			fcomip ST(0), ST(1)
			ja h_ope
			je h_ope
			fstp temp_r
h_ope:
	fstp min
	
	fld max
	fld min
	fcomip ST(0), ST(1)
	je max_equal_min
	fld (RGB_COORD ptr [edi]).r
	fcomip ST(0), ST(1)
	je max_equal_r
	fld (RGB_COORD ptr [edi]).g
	fcomip ST(0), ST(1)
	je max_equal_g
	fld (RGB_COORD ptr [edi]).b
	fcomip ST(0), ST(1)
	je max_equal_b
	max_equal_min:
		mov temp_dw, 0
		fimul temp_dw
		fstp (HSL_COORD ptr [esi]).h
		jmp l_ope
	max_equal_r:
		fstp temp_r
		fld (RGB_COORD ptr [edi]).g
		fld (RGB_COORD ptr [edi]).b
		fcomip ST(0), ST(1)
		je g_jae_b
		jb g_jae_b
		fsub (RGB_COORD ptr [edi]).b
		fld max
		fsub min
		fdiv
		fmul constant_1div6
		mov temp_dw, 1
		fiadd temp_dw
		fstp (HSL_COORD ptr [esi]).h
		jmp l_ope
		g_jae_b:
			fsub (RGB_COORD ptr [edi]).b
			fld max
			fsub min
			fdiv
			fmul constant_1div6
			fstp (HSL_COORD ptr [esi]).h
			jmp l_ope
	max_equal_g:
		fstp temp_r
		fld (RGB_COORD ptr [edi]).b
		fsub (RGB_COORD ptr [edi]).r
		fld max
		fsub min
		fdiv
		fmul constant_1div6
		fadd constant_1div3
		fstp (HSL_COORD ptr [esi]).h
		jmp l_ope
	max_equal_b:
		fstp temp_r
		fld (RGB_COORD ptr [edi]).r
		fsub (RGB_COORD ptr [edi]).g
		fld max
		fsub min
		fdiv
		fmul constant_1div6
		fadd constant_2div3
		fstp (HSL_COORD ptr [esi]).h
l_ope:
	fld max
	fadd min
	fmul constant_1div2
	fstp (HSL_COORD ptr [esi]).l
s_ope:
	fld (HSL_COORD ptr [esi]).l
	fldz
	fcomip ST(0), ST(1)
	je l_e_0ormax_e_min
	fstp temp_r
	fld max
	fld min
	fcomip ST(0), ST(1)
	je l_e_0ormax_e_min
	fstp temp_r
	fld (HSL_COORD ptr [esi]).l
	fld constant_1div2
	fcomip ST(0), ST(1)
	ja l_be_1div2
	je l_be_1div2
	fstp temp_r
	fld max
	fsub min
	mov temp_dw, 2
	fild temp_dw
	fld (HSL_COORD ptr [esi]).l
	fimul temp_dw
	fsub
	fdiv
	fstp (HSL_COORD ptr [esi]).s
	jmp ex_Change_RGB_TO_HSL
	l_be_1div2:
		fstp temp_r
		fld max
		fsub min
		fld max
		fadd min
		fdiv
		fstp (HSL_COORD ptr [esi]).s
		jmp ex_Change_RGB_TO_HSL
	l_e_0ormax_e_min:
		fstp temp_r
		fldz
		fstp (HSL_COORD ptr [esi]).s
ex_Change_RGB_TO_HSL:
	ret
Change_RGB_TO_HSL ENDP	
