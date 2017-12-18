include Drawing.inc
include UI.inc 
include InputMotion.inc
include Shift.inc
include port.inc

.model small

.stack 64

.data

tiles db 640 dup(3)    ;Code byte for the content of each tile 0:Status | 1:Frog | 2:Log main | 3:Water | 4:Pavement | 5:Road | 6: log beg. | 7: log end | 8: Car rear | 9: Car front | 10: endPoint

frogPos dw 620
frogPos2 dw 620
fakePos dw 620
BoundsFlag db ? 
BoundsFlag2 db ?
direction db ?
chatFlag db ?
readyflag db 0
readyflag2 db 0
levelflag db ?
;---------------------------------------------------------------
        ToBeSent db ?,'$'
        ToBeReceived db '$','$'
        Divider db '--------------------------------------------------------------------------------$'
        row1 db 1
        col1 db 0
        row2 db 14
        col2 db 0
        from1 dw 0100h
        to1 dw 0B4fh
        from2 dw 0E00h 
        to2 dw 184Fh 
        ApplyNewLine db 0Dh  
        NUllChar db ' $'
        GoodByeMessage db 'Goodbye, we wish that you have enjoyed your time!$'
;---------------------------------------------------------------
        ToBeSentGame db ?,'$'
        ToBeReceivedGame db '$','$'
        row1Game db 1
        col1Game db 0
        row2Game db 2
        col2Game db 0
        from1Game dw 0100h
        to1Game dw 0127h
        from2Game dw 0200h 
        to2Game dw 0227h 
        scrollRow dw ?
;---------------------------------------------------------------

;---------------------------------------------------------------

;------MainMenu\IntroScreen\StatusBar----------------
mes1 db '*To start Frogx86 press ENTER','$'
mes2 db '*To end the program press ESC','$'
mes3 db 'Please enter your name:',10,13 ,'$'
mes4 db 'Press Enter key to continue','$'
mes5 db 'Enter a valid name','$'
mes6 db 'Please enter player2 name:',10,13 ,'$'
mes7 db ' won','$'
mes8 db '*To enter chat press SPACE','$'
mes9 db '*To exit chat press ESC','$'
mes10 db 'To Play level 1 press 1','$'
mes11 db 'To Play level 2 press 2','$'
mes12 db 'You won','$'
    MyBuffer1 LABEL BYTE
	    BufferSize1 DB 15
	    ActualSize1 DB ?
	    PlayerName1 DB 15 DUP ('$')
	MyBuffer2 LABEL BYTE
	    BufferSize2 DB 15
	    ActualSize2 DB ?
	    PlayerName2 DB 15 DUP ('$')
PlayerScore1 db '0$'
PlayerScore2 db '0$'
PlayerScore1Num db 0
PlayerScore2Num db 0 
fakevalue db ? ,'$'
sep db 'Press Esc to exit$'
;-----------------------------------------------------

xpos dw 0
ypos dw 0

color db 0

delayLoops db 4

.code

mov ax,@data
mov ds,ax

portinitialization
mov ah,0
mov al,13h
int 10h

IntroScreen mes3,mes4,mes5,MyBuffer1,PlayerName1,ActualSize1
        MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
        MOV BH,00H     
        MOV CX,0000H    ;STARTING COORDINATES
        MOV DX,184FH    ;ENDING COORDINATES
        INT 10H
	lea si,playerName1
	lea di,playerName2 
	mov cl,6
	mov ch,0

NameLoop:
	send [si] 
	receive3ady fakevalue
	mov al,fakevalue
	mov [di],al
	inc si
	inc di
	inc ActualSize2
	loop NameLoop

MainMenu:

mov ah,0
mov al,13h
int 10h
;MainMenu\IntroScreen------------
MainMenu mes1,mes2,mes8,mes9,chatFlag
        MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
        MOV BH,00H      
        MOV CX,0000H    ;STARTING COORDINATES
        MOV DX,184FH    ;ENDING COORDINATES
        INT 10H
;-----Level-------------------------

	cmp chatFlag,1
	je BeginChat 
	
	;CALL CHAT MACRO
    ;jmp BeginChat
	
LevelMenu mes10,mes11,levelflag
;-----------------------------------
		MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
        MOV BH,00H     
        MOV CX,0000H    ;STARTING COORDINATES
        MOV DX,184FH    ;ENDING COORDINATES
        INT 10H

gamebegin:	

;--------------------------------------------------------------   
    
    InitializeArena ;Gives every tile in grid main code with no logs or car then draw    
    
    ;Drawing Background Once
    mov cx,0
    mov xpos,0
    mov ypos,0
    drawBackGround:       
        mov bx, offset tiles
        add bx,cx
        DrawTileCode xpos ypos [bx]    
        
        add xpos, 10
        cmp xpos, 320
        jnz BGrowCompleted
        mov xpos,0
        add ypos,10
        BGrowCompleted:    
    
    inc cx
    cmp cx,640
    jnz drawBackGround
    
    InitializeBlocks levelflag;Puts the logs and car codes in places  
    
    send readyflag
GameLoop:  ;This loop gets Called every loop till player wins

    ScoreBar PlayerName1,PlayerScore1,PlayerName2,PlayerScore2,sep  ;Writing the score of each player

    mov cx,0
    mov xpos,0
    mov ypos,0
   
	;cmp delayLoops,0
	;jnz DelayedLoop
	;Shifting the rows
	 mov bh,0
	 mov bl,tiles
    
	;Shift bx 96 0 frogPos,frogPos2    
    Shift bx 128 1 frogPos,frogPos2     ;---------This block shifts the rows of water and cars
	Shift bx 160 0 frogPos,frogPos2
	Shift bx 192 1 frogPos,frogPos2
    Shift bx 224 0 frogPos,frogPos2
	Shift bx 256 1 frogPos,frogPos2
	;Shift bx 288 0 frogPos,frogPos2
	Shift bx 320 0 fakePos,fakePos
    Shift bx 352 1 fakePos,fakePos
    Shift bx 384 0 fakePos,fakePos
    Shift bx 416 1 fakePos,fakePos
    Shift bx 448 0 fakePos,fakePos
    Shift bx 480 1 fakePos,fakePos
    Shift bx 512 0 fakePos,fakePos
    Shift bx 544 1 fakePos,fakePos
    Shift bx 576 0 fakePos,fakePos

	
	; mov delayLoops,4    ;------This block makes sure that shifting doens't happen every frame so the game is easier
	; DelayedLoop:
	; dec delayLoops
    ;mov direction,0
	
	receive3ady direction
	TakeGameInput frogPos,BoundsFlag  ;Take the input from users
    cmp BoundsFlag,5
    jbe normal

    mov al,BoundsFlag
    mov ToBeSentGame, al 
    MOVECURSOR row1Game,col1Game
    ShowMessage ToBeSentGame
    inc col1Game 
    cmp col1Game,40
    jne normal 
    mov col1Game,0
    mov scrollRow,8
    scrollVideo scrollRow

    normal:
    send BoundsFlag 

    cmp direction,1
    je up 
    cmp direction,2
    je down 
    cmp direction,3
    je right 
    cmp direction,4
    je left 
    cmp direction,5
    je mafshoo5
    cmp direction,6
    ja character
    jmp beed 

    up:
        sub frogPos2,32
        jmp beed 
    
    down:
        add frogPos2,32
        jmp beed 
    
    right:
        inc frogPos2
        jmp beed 

    left:
        dec frogPos2
        jmp beed 

    mafshoo5:
        mov frogPos2,620 
        jmp beed 

    character:
        mov al, direction
        mov ToBeReceivedGame, al 
        MOVECURSOR row2Game,col2Game
        ShowMessage ToBeReceivedGame
        inc col2Game
        cmp col2Game,40
        jne beed 
        mov col2Game,0
        mov scrollRow,16
        scrollVideo scrollRow

    beed:    
        mov BoundsFlag,0

    lea bx,tiles        ;Check foreach Frog new Position and check if dead
	add bx , frogPos
	mov al,tiles[bx]
    cmp al,3  ;water     
    je Dead 
    cmp al,8  ;Car front 
    je Dead 
    cmp al,9  ;Car end
    je Dead 
    jmp Alive 

    Dead:
        mov frogPos,620
		mov BoundsFlag,5
    
    Alive:
	lea bx,tiles
	add bx,frogPos
	mov al,[bx]
	cmp al,10
	jne Alive2
	mov [bx],3
	mov frogPos,620
	inc playerScore1
	inc PlayerScore1Num
	
	Alive2: 
	lea bx,tiles
	add bx,frogPos2
	mov al,[bx]
	cmp al,10
	jne CheckWon
	mov [bx],3
	mov frogPos2,620
	inc playerScore2
	inc PlayerScore2Num
	
	CheckWon:               ;--Check the winner
	mov al,PlayerScore1Num
	mov ah,PlayerScore2Num
	
	cmp al,3d
	jge Player1Won
	cmp ah,3d
	jl Continue
	
	Playes2Won:
	mov ah,2
	mov bh,0
    mov dh,10
	mov dl,10
    int 10h
	PrintMessage PlayerName2
	mov ah,2
	mov bh,0
    mov dh,10
	add dl,ActualSize2
    int 10h
	PrintMessage mes7
	mov ah, 4ch
	int 21h
	hlt
	
	Player1Won:
	mov ah,2
	mov bh,0
    mov dh,10
	mov dl,10
    int 10h
	PrintMessage mes12
	; PrintMessage PlayerName1
	; mov ah,2
	; mov bh,0
    ; mov dh,10
	; add dl,ActualSize1
    ; int 10h
	; PrintMessage mes7
	mov ah, 4ch
	int 21h
	hlt
	
	Continue:	
		
    drawCubes:          ;-----All the following is responsible for drawing the whole current frame       
    mov bx, offset tiles
    add bx,cx
    
    mov dl,[bx]
    
    cmp [bx],6
    jnz logBeg:
    
    ;Draw log beg------------------------
    push cx 
    push dx 
    mov cx, xpos
    mov dx, ypos
	
	add dx,2
	DrawHorizontalLine cx, dx, 6, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 7, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 8, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 9, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 8, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 7, 06h
	
	inc dx
	DrawHorizontalLine cx, dx, 6, 06h
	
	;water filling
	mov dx,ypos
	DrawHorizontalLine cx, dx, 10, 001b
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	inc dx
	add cx,6
	DrawHorizontalLine cx, dx, 4, 001b
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 3, 001b
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 2, 001b
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 1, 001b
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 2, 001b
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 3, 001b
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 4, 001b

    pop dx 
    pop cx 
    ;------------------------------------
    jmp DoneDrawing
    logBeg:
    
    cmp [bx],7
    jnz logEnd:
    
    ;Draw log End------------------------
    push cx
    push dx
    mov cx, xpos
    mov dx, ypos 
	
	add cx,4
	add dx,2
	DrawHorizontalLine cx, dx, 6, 06h
	
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 7, 06h
	
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 8, 06h
	
	inc dx
	dec cx
	DrawHorizontalLine cx, dx, 9, 06h
	
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 8, 06h
	
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 7, 06h
	
	inc dx
	inc cx
	DrawHorizontalLine cx, dx, 6, 06h
	;water filling
	mov cx,xpos
	mov dx,ypos
	DrawHorizontalLine cx, dx, 10, 001b
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	inc dx
	DrawHorizontalLine cx, dx, 4, 001b
	inc dx
	DrawHorizontalLine cx, dx, 3, 001b
	inc dx
	DrawHorizontalLine cx, dx, 2, 001b
	inc dx
	DrawHorizontalLine cx, dx, 1, 001b
	inc dx
	DrawHorizontalLine cx, dx, 2, 001b
	inc dx
	DrawHorizontalLine cx, dx, 3, 001b
	inc dx
	DrawHorizontalLine cx, dx, 4, 001b
	
    pop dx
    pop cx 
    ;------------------------------------
    
    jmp DoneDrawing
    logEnd:
    
    
    cmp [bx],8
    jnz carBeg:
    
    ;Draw car Beg-----------------------
    push cx 
    push dx 
 	mov cx, xpos
    mov dx, ypos
	
		add dx,2
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	mov dx,ypos
	
	inc cx
	add dx,3
	DrawHorizontalLine cx, dx, 8, 11D
	
	inc dx
	DrawHorizontalLine cx, dx, 8, 11D
	
	inc dx
	DrawHorizontalLine cx, dx, 8, 11D
	
	inc dx
	DrawHorizontalLine cx, dx, 8, 11D
   pop dx 
    pop cx 
    ;--------------------------------------
    
    jmp DoneDrawing
    carBeg:
    
    cmp [bx],9
    jnz carEnd:
    
    ;Draw car end--------------------------
    push cx 
    push dx 
    mov cx, xpos
    mov dx, ypos
	
	;first wheel
	add cx,2
	DrawHorizontalLine cx, dx, 6, 14D
	
	inc dx
	DrawHorizontalLine cx, dx, 6, 14D
	
	;car body between the two wheels
	mov cx,xpos 
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	inc dx
	DrawHorizontalLine cx, dx, 10, 001b
	
	;second wheel
	inc dx
	add cx,2
	DrawHorizontalLine cx, dx, 6, 14D
	
	inc dx
	DrawHorizontalLine cx, dx, 6, 14D
    pop dx 
    pop cx 
    ;--------------------------------------
    
    jmp DoneDrawing
    carEnd:    
        
    cmp [bx],2
    jnz logMain:
    
    ;Draw logMain--------------------------
    push cx 
    push dx 
    mov cx, xpos
    mov dx, ypos
	
	add dx,2
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	
	inc dx
	DrawHorizontalLine cx,dx,10,06h
	;water filling
	mov dx,ypos
	DrawHorizontalLine cx,dx,10,001b
	inc dx
	DrawHorizontalLine cx,dx,10,001b
	
    pop dx 
    pop cx 
    ;--------------------------------------
    
    jmp DoneDrawing
    logMain:
    
    
    DrawTileCode xpos ypos [bx]
    
    DoneDrawing:
    
    cmp cx,frogPos                          ;---Drawing the frogs comes at last so it gets drawn after all other objects
    jnz Frog:
    
    ;Draw Frog----------------------------
    ;Draw the frog's 4 legs
      push cx 
      push dx 
      mov cx, xpos 
      mov dx, ypos 
      inc cx 
      DrawVerticalLine cx,dx,4,1110b
      add dx,5
      DrawVerticalLine cx,dx,4,1110b
      mov cx, xpos 
      mov dx, ypos
      add cx,8
      DrawVerticalLine cx,dx,4,1110b
      add dx,5
      DrawVerticalLine cx,dx,4,1110b

      ;Draw 4 feet
      mov cx, xpos 
      mov dx, ypos
      inc dx
      DrawPixel cx,dx,1110b
      add cx,9 
      DrawPixel cx,dx,1110b 
      mov cx, xpos 
      mov dx, ypos
      add dx,7
      DrawPixel cx,dx,1110b
      add cx,9
      DrawPixel cx,dx,1110b 

      ;Draw the connections between legs and body
      mov cx, xpos 
      mov dx, ypos
      add cx,2
      add dx,3
      DrawPixel cx,dx,1110b 
      add cx,5
      DrawPixel cx,dx,1110b
      mov cx, xpos 
      mov dx, ypos
      add dx,5
      add cx,2
      DrawPixel cx,dx,1110b 
      add cx,5
      DrawPixel cx,dx,1110b 
      
      ;Draw the frog body
      mov cx, xpos 
      mov dx, ypos
      add cx,3
      add dx,2
      DrawVerticalLine cx,dx,6,0100b
      add cx,3
      DrawVerticalLine cx,dx,6,0100b
      mov cx, xpos 
      mov dx, ypos
      add cx,4
      DrawVerticalLine cx,dx,9,0100b
      inc cx
      DrawVerticalLine cx,dx,9,0100b

      ;Draw the frog's eyes
      mov cx, xpos 
      mov dx, ypos
      add cx,3
      inc dx
      DrawPixel cx,dx,100b
      add cx,3
      DrawPixel cx,dx,100b
      pop dx 
      pop cx 
      ;--------------------------------
    
    Frog:
	
	cmp cx,frogPos2
    jnz Frog2:
    
    ;Draw Frog----------------------------
    ;Draw the frog's 4 legs
      push cx 
      push dx 
      mov cx, xpos 
      mov dx, ypos 
      inc cx 
      DrawVerticalLine cx,dx,4,1100b
      add dx,5
      DrawVerticalLine cx,dx,4,1100b
      mov cx, xpos 
      mov dx, ypos
      add cx,8
      DrawVerticalLine cx,dx,4,1100b
      add dx,5
      DrawVerticalLine cx,dx,4,1100b

      ;Draw 4 feet
      mov cx, xpos 
      mov dx, ypos
      inc dx
      DrawPixel cx,dx,1100b
      add cx,9 
      DrawPixel cx,dx,1100b 
      mov cx, xpos 
      mov dx, ypos
      add dx,7
      DrawPixel cx,dx,1100b
      add cx,9
      DrawPixel cx,dx,1100b 

      ;Draw the connections between legs and body
      mov cx, xpos 
      mov dx, ypos
      add cx,2
      add dx,3
      DrawPixel cx,dx,1100b 
      add cx,5
      DrawPixel cx,dx,1100b
      mov cx, xpos 
      mov dx, ypos
      add dx,5
      add cx,2
      DrawPixel cx,dx,1100b 
      add cx,5
      DrawPixel cx,dx,1100b 
      
      ;Draw the frog body
      mov cx, xpos 
      mov dx, ypos
      add cx,3
      add dx,2
      DrawVerticalLine cx,dx,6,1010b
      add cx,3
      DrawVerticalLine cx,dx,6,1010b
      mov cx, xpos 
      mov dx, ypos
      add cx,4
      DrawVerticalLine cx,dx,9,1010b
      inc cx
      DrawVerticalLine cx,dx,9,1010b

      ;Draw the frog's eyes
      mov cx, xpos 
      mov dx, ypos
      add cx,3
      inc dx
      DrawPixel cx,dx,100b
      add cx,3
      DrawPixel cx,dx,100b
      pop dx 
      pop cx 
      ;--------------------------------
    
    Frog2:
    
    add xpos, 10
    cmp xpos, 320
    jnz rowCompleted
    mov xpos,0
    add ypos,10
    rowCompleted:    
    
    inc cx
    cmp cx,640
    jnz drawCubes
     
jmp GameLoop 

BeginChat:
        mov ah,00h
		mov al,02h
		int 10h
        portinitialization  
        CLEAR_SCREEN_UP
        MOVECURSOR 0,0
        
        MOVECURSOR 12,0
        ShowMessage Divider

        MOVECURSOR 0,0
        ShowMessage PlayerName1
        
        MOVECURSOR 13,0
        ShowMessage PlayerName2
        
        MOVECURSOR 1,0
        
        chat:
            mov ToBeReceived,'$'

            mov ah,1
            int 16h
            jnz Se 
            jmp Re   
            
            Se: 
                mov ah,00   
                int 16h

                cmp ah,1ch
                je enter

                cmp al,27
                je escape

                cmp ah,0Eh
                je BackSpace1
                 
                mov ToBeSent,al
                
                MOVECURSOR row1,col1
                ShowMessage ToBeSent 
            
                send ToBeSent
                
                inc col1 
                cmp col1,80
                je ResetCol1
                BackCol1:
                jmp Re 
             
             BackSpace1: 
                cmp col1,0
                je Re  
                send ah 
                dec col1 
                MOVECURSOR row1,col1
                ShowMessage NUllChar
                MOVECURSOR row1,col1
                jmp Re

             enter:
                mov col1,0
                inc row1
                cmp row1,12
                je ResetRow1Enter
                BackRow1Enter:
                MOVECURSOR row1,col1
                send ApplyNewLine 
                
             Re:
                receiveChat ToBeReceived
                 
                cmp ToBeReceived,'$'
                je chat 

                cmp ToBeReceived, 0Eh
                je Backspace2

                cmp ToBeReceived, 0Dh 
                je Enter2

                MOVECURSOR row2,col2
                ShowMessage ToBeReceived
                inc col2
                cmp col2,80
                je ResetCol2
                BackCol2: 
        
          jmp chat
          
          Backspace2:
            dec col2
            MOVECURSOR row2,col2
            ShowMessage NUllChar
            MOVECURSOR row2,col2
            jmp chat  

          Enter2:
            mov col2,0
            inc row2 
            cmp row2,24
            je ResetEnter2
            BackEnter2:
            MOVECURSOR row2,col2 
            jmp chat 

          ResetEnter2:
            scroll from2,to2 
            MOVECURSOR 12,0
            ShowMessage Divider
            mov row2,23
            jmp BackEnter2

          ResetCol1:
            mov col1,0
            inc row1
            cmp row1,12
            je ResetRow1
            BackRow1:
            jmp BackCol1
          
          ResetCol2:
            mov col2,0
            inc row2
            cmp row2,24
            je ResetRow2
            BackRow2:
            jmp BackCol2
          
          ResetRow1:
            scroll from1,to1
            mov row1,11
            jmp BackRow1
          
          ResetRow2:
            scroll from2,to2 
            MOVECURSOR 12,0
            ShowMessage Divider
            mov row2,23
            jmp BackRow2
            
          ResetRow1Enter:
            scroll from1,to1
            mov row1,11
            jmp BackRow1Enter
            
          escape:
            CLEAR_SCREEN_UP
            MOVECURSOR 0,0
            ShowMessage GoodByeMessage
			jmp MainMenu:

hlt               