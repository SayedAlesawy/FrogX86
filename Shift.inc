
;base_addr => offset address of an array
;sflag => 0 => shift left , 1=> shift right


Shift MACRO base_addr,start,sflag,froggy
    
    LOCAL ShiftRight
    LOCAL ShiftLeft
    LOCAL shift_loopL
    LOCAL shift_loopR
    LOCAL Done
    LOCAL Frog_outL
    LOCAL Frog_outR

    pusha   
     mov ax,0
     mov bx,0
     mov cx,0
     mov dx,0

     mov cx,15
     add cx,base_addr
     add cx,start

     mov al,sflag
     cmp al,1
     jnz ShiftRight
     
     
     
     ShiftLeft:
     cmp cx,froggy
     jb Frog_outL
     sub cx,15
     cmp cx,froggy
     ja Frog_outL
     dec froggy
     Frog_outL:
	   mov bx,base_addr 
		add bx, start 
       mov cx,15

       mov dh,[bx]
       shift_loopL:
         mov dl,[bx+1]
         mov [bx],dl
         inc bx
         ;cmp bx,15
         ;jne Shift_loopL 
		 loop shift_LoopL

       mov [bx],dh;put the first element in the last element
     
     jmp Done
     
     ShiftRight:
     cmp cx,froggy
     jb Frog_outR
     sub cx,15
     cmp cx,froggy
     ja Frog_outL
     inc froggy
     Frog_outR:
       mov bx,base_addr 
		add bx,start
       add bx,15
       mov dh,[bx]
	   mov cx,15
       shift_loopR:
         mov dl,[bx-1]
         mov [bx],dl
         dec bx
         ;cmp bx,base_addr
         ;jne Shift_loopR
		 loop shift_loopR 
       mov [bx],dh;put the last element in the first element
         
         
     
     Done:
    popa

ENDM Shift