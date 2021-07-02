
   
   
org 100h

mov al,0h  ;ekran modu
mov ah,0   ;fonksyion numarasi
int 10h    ;ekran 40(sutun)x25(satir) ayarlandi

mov si,9

tekrar:               
    mov al,1   
    mov bh,08ch
    mov cl,0    
    mov ch,0    
                
    mov dl,7   
    mov dh,7  
    mov ah,06   
    int 10h     
    
    dec si
    jnz tekrar 

    
    
    mov ax,1
    int 33h

    mov ax,0
    mov dh,10
    mov dl,10
    mov cl,0
    mov ch,0 
    int 33h

    cmp bx,2
         
    
            
    mov dx, offset yazi; 
    mov ah,09
    int 21h    
    yazi db "Emir Muhammet Aydemir 171419008" , "$"   


             
                    

         
ret




