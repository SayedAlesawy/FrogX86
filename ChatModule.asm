include mymacros.inc
;Author:Sayed Kotb
;Date:10-10-2017
;This program calcultes grades curving
;---------------------------
        .MODEL SMALL
        .STACK 64
        .DATA
        
        ToBeSent db ?,'$'
        ToBeReceived db '$','$'
        Divider db '--------------------------------------------------------------------------------$'
        row1 db 0
        col1 db 0
        row2 db 13
        col2 db 0
        from1 dw 0
        to1 dw 0B4fh
        from2 dw 0D00h 
        to2 dw 184Fh 
        ApplyNewLine db 0Dh  
        GoodByeMessage db 'Goodbye, we wish that you have enjoyed your time!$'

        .code
MAIN    PROC FAR               
        MOV AX,@DATA
        MOV DS,AX 
        
        portinitialization  
        CLEAR_SCREEN_UP
        MOVECURSOR 0,0
        
        MOVECURSOR 12,0
        ShowMessage Divider

        MOVECURSOR 0,0
        
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
                 
                mov ToBeSent,al
                
                MOVECURSOR row1,col1
                ShowMessage ToBeSent 
            
                send ToBeSent
                
                inc col1 
                cmp col1,80
                je ResetCol1
                BackCol1:
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
                receive ToBeReceived
                 
                cmp ToBeReceived,'$'
                je chat 

                cmp ToBeReceived, 0Dh 
                je Enter2

                MOVECURSOR row2,col2
                ShowMessage ToBeReceived
                inc col2
                cmp col2,80
                je ResetCol2
                BackCol2: 
        
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
            hlt

MAIN    ENDP
        END MAIN