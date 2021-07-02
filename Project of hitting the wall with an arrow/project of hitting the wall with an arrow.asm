.model large
.data

cikis db 0
oyuncu_posizyonu dw 1760d                         

ok_pozisyonu dw 0d                            
ok_durumu db 0d                          
ok_menzili dw  22d    

duvar_pozisyonu dw 3860d       
duvar_durumu db 0d
         
                                           


skor_durumu db '00:0:0:0:0:0:00:00$'          
hit_num db 0d
isabet dw 0d
iska dw 0d  

kaybettin     dw '  ',0ah,0dh
dw ' ',0ah,0dh 
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw '                           Kaybettiniz             ',0ah,0dh
dw '            Tekrar baslamak icin enteri tuslayiniz$',0ah,0dh 


basla          dw '  ',0ah,0dh

dw '               ||--------------------------------------------------||',0ah,0dh
dw '               || Oyunun amaci asagidan yukariya dogru hareket     ||',0ah,0dh
dw '               || eden duvari vurmaktir.Ok attiginiz yay ile       ||',0ah,0dh
dw '               || Ok atmak icin mousenin sol clickine              ||',0ah,0dh          
dw '               || basili tutunuz.                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||       Baslamak icin enteri tuslayiniz            ||',0ah,0dh 
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '$',0ah,0dh


main proc
mov ax,@data
mov ds,ax

mov ax, 0B800h
mov es,ax 



jmp oyun_menusu ;;ana menuyu gosterir                             

                                                                   
main_loop:                                 
                                           
    mov ax,0 ;mouse aktif olur
    int 33h
    mov ax,3 ;mouse koordinatlarini ve hangi tusa basildigi bilgileri gelir
    int 33h
    cmp bx,2 ;mouse sag tiklandiysa 
    je mouse_sag_bas ;sag tiklanma fonksiyonuna git                         
    jmp normal_dongu ;surekli oyunun devami saglanir                       
    
    normal_dongu:                           
        
        cmp iska,9 ;hedefi 9 kere iskalarsak oyun kaybetme sahnesine yonlendir
        jge kaybetme
        
        mov dx,ok_pozisyonu 
        cmp dx, duvar_pozisyonu ;ok pozisyonu ile duvar pozisyonu ayni ise isabeti arttir ve duvari yoket
        je atis
        
        mov dx,ok_menzili                 
        cmp ok_pozisyonu, dx ;ok pozisyonu ve menzili ayni ise oku sil
        jge ok_sil
        
        cmp duvar_pozisyonu, 0d ;duvar pozisyonu silinecek kadar uzaklastiysa iska olmustur
        jle duvar_sil
        jne duvar_ciz 
    
        atis:                               
            mov ah,2
            mov dx, 7d
            int 21h 
            
            inc isabet ;atis fonksiyonuna girdiysek isabet 1 artar                       
            
            lea bx,skor_durumu               
            call skoru_goster ;skor durumu gosterilir 
            lea dx,skor_durumu
            mov ah,09h
            int 21h
            
            mov ah,2          ;yeni satir
            mov dl, 0dh
            int 21h    
            
            jmp duvar_hareket ;yeni duvar getirilir
    
        duvar_ciz: ;duvar cizilir
            mov cl, ' ' ;once eski duvar gizlenir
            mov ch, 1111b
        
            mov bx,duvar_pozisyonu 
            mov es:[bx], cx
                
            sub duvar_pozisyonu,160d ;ve yeni pozisyona sahip bir tane cizilir
            mov cl, 219d ;duvarin sekli
            mov ch, 1000b ;duvarin rengi
        
            mov bx,duvar_pozisyonu 
            mov es:[bx], cx
            
            cmp ok_durumu,1d ;ok durumu gonderilebilir ise
            je ok_ciz ;ok cizilir
            jne yay_ciz ;gonderilebilir degil ise yay tekrar cizilir 
        
        ok_ciz:                      
        
            mov cl, ' '   ;okun eski pozisyonu gizleniyor
            mov ch, 1111b
        
            mov bx,ok_pozisyonu  ;okun yeni pozisyonu cizilir
            mov es:[bx], cx
                
            add ok_pozisyonu,4d               
            mov cl, 26d  ;ok sekli
            mov ch, 1001b ;okun rengi
        
            mov bx,ok_pozisyonu ;okun yeni pozisyonu 
            mov es:[bx], cx
        
        yay_ciz:
            
            mov cl, 41d ;yayin sekli              
            mov ch, 1110b ;yayin rengi
            
            mov bx,oyuncu_posizyonu ;yayin pozisyonu
            mov es:[bx], cx       
                       
    cmp cikis,0
    je main_loop ;eger cikisa basilmadiysa devam eder
    jmp oyundan_cik ;eger cikisa basildiysa cikis yapilir
 
jmp yay_ciz ;yay tekrardan cizilir
        
mouse_sag_bas:                                 
    cmp ok_durumu,0 ;ok durumu 0 ise ok harekete gecer
    je  ok_hareketi
    jmp normal_dongu ;ok hareketi 1 ise birsey yapilmaz dongu devam eder 
    

ok_hareketi:                 ;ok konumunu yay pozisyonunda ayarla
    mov dx, oyuncu_posizyonu ;yani okun bulundugu pozisyondan oku firlat
    mov ok_pozisyonu, dx
    
    mov dx,oyuncu_posizyonu ;ok ateslendiginde gidecegi menzilin uzakligini belirle
    mov ok_menzili, dx                 
    add ok_menzili, 22d  ;150
    
    mov ok_durumu, 1d  ;okun durumunu ayarla birden fazla okun ayni anda firlatilmasini engeller 
    jmp normal_dongu                        
        
        
duvar_sil:
    add iska,1 ;duvar siliniyorsa iska olmustur ve iska sayisi 1 arttirilir

    lea bx,skor_durumu ;skoru goster
    call skoru_goster 
    lea dx,skor_durumu
    mov ah,09h
    int 21h
             ;yeni satir
    mov ah,2
    mov dl, 0dh
    int 21h
jmp duvar_hareket
    
duvar_hareket: ;yeni duvari harekete gecirir
    mov duvar_durumu, 1d
    mov duvar_pozisyonu, 3860d ;duvar pozisyonu belirlenir
    jmp duvar_ciz
    
ok_sil:
    mov ok_durumu, 0 ;ok durumu 0'a getirilir
    
    mov cl, ' '    ;ok gizlenir
    mov ch, 1111b
    
    mov bx,ok_pozisyonu ;ok pozisyonu ayarlanir
    mov es:[bx], cx
    
    cmp duvar_pozisyonu, 0d ;duvar pozisyonu 0 ise duvari siler degil ise duvar cizer
    jle duvar_sil
    jne duvar_ciz 
    
    jmp yay_ciz ;yayi tekrardan cizer
                  
kaybetme:
    mov ah,09h
    mov dx, offset kaybettin ;kaybetme ekraninin adresini alir
    int 21h
    
    
    
    mov cl, ' '    ;ekranin sonuna ulasan balonlari gizle
    mov ch, 1111b 
    mov bx,ok_pozisyonu                      
    
    mov cl, ' '  ;oyuncuyu gizle
    mov ch, 1111b 
    mov bx,oyuncu_posizyonu  
 
    
     ;yeniden baslamak icin degiskenleri guncelle
    mov iska, 0d
    mov isabet,0d
    
    mov oyuncu_posizyonu, 1760d ;oyuncu pozisyonu ortaya alinir

    mov ok_pozisyonu, 0d ; ok pozisyonu, durumu ve menzili baslangic durumuna alinir
    mov ok_durumu, 0d 
    mov ok_menzili, 22d      

    mov duvar_pozisyonu, 3860d ;duvar pozisyonu ve durumu baslangic durumuna alinir       
    mov duvar_durumu, 0d
         
  
                                           
    deger_girisi: ;veri girisi icin beklenir
        mov ah,1
        int 21h
        cmp al,13d ;deger girisi enter olana kadar dongu tekrar eder enter basilirsa oyun ekranina gecilir
        jne deger_girisi
        call ekrani_temizle
        jmp main_loop
    

oyun_menusu:
             ;oyun menusu ekrani
    mov ah,09h
    mov dh,0
    mov dx, offset basla ;baslama ekraninin adresi alinir
    int 21h
                                          
    deger_girisi_2: ;deger girisi icin bekleniyor
        mov ah,1
        int 21h
        cmp al,13d ;enter basilana kadar beklenir basilirsa skor durumu gosterilir ve main loopa gecilir
        jne deger_girisi_2
        call ekrani_temizle
        
        lea bx,skor_durumu                   ;skoru goster
        call skoru_goster 
        lea dx,skor_durumu
        mov ah,09h
        int 21h
    
        mov ah,2
        mov dl, 0dh
        int 21h
        
        jmp main_loop

oyundan_cik:                                  ;oyunun sonu 
mov cikis,10d

main endp
                                                                 
  ;ekran ile ayni pozisyonda skoru goster                            
  ;dogrulanabilir segmenti kullanmak icin temel isaretciyi kullandik    

proc skoru_goster
    lea bx,skor_durumu
    
    mov dx, isabet
    add dx,48d 
    
    mov [bx], 9d
    mov [bx+1], 9d
    mov [bx+2], 9d
    mov [bx+3], 9d
    mov [bx+4], 'H'    ;skor ekranindaki isabet sayisinin onundeki yazi
    mov [bx+5], 'i'                                        
    mov [bx+6], 't'
    mov [bx+7], 's'
    mov [bx+8], ':'
    mov [bx+9], dx
    
    mov dx, iska
    add dx,48d
    mov [bx+10], ' '
    mov [bx+11], 'I'
    mov [bx+12], 's'
    mov [bx+13], 'k'  ;skor ekranindaki iska sayisinin onundeki yazi
    mov [bx+14], 'a'
    mov [bx+15], ':'
    mov [bx+16], dx
ret    
skoru_goster endp 
                                                                 
;ekrani temizle                                                   
;karmasikliktan kacinmak icin yeni metin ayarlanir          

ekrani_temizle proc near
        mov ah,0
        mov al,3 ;ekran temizlenir
        int 10h        
        ret
ekrani_temizle endp

end main