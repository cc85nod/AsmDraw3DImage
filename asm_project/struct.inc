;;
vertinfo STRUCT
	z real4 ?
    y real4 ?
    x real4 ?
    
vertinfo ENDS

fmap STRUCT
	v  DWORD 0
    vt DWORD 0
    vn DWORD 0
fmap ENDS

finfo STRUCT
	vc fmap <?>
	vb fmap <?>
    va fmap <?>
finfo ENDS

;;
ginfo STRUCT

ginit		BYTE 0

gname 		BYTE 10 dup(?)
mtlsource  	BYTE 50 dup(?)
mtlname  	BYTE 50 dup(?)

v 	DD ?
vn  DD ?
vt  DD ?
f   DD ?

curv_ptr  DD ?
curvn_ptr DD ?
curvt_ptr DD ?
curf_ptr DD ?

;; vector info
vcap   	DWORD 0
vncap  	DWORD 0
vtcap  	DWORD 0
fcap	DWORD 0

vsize  	DWORD 0
vnsize 	DWORD 0
vtsize 	DWORD 0
fsize 	DWORD 0

ginfo ENDS
