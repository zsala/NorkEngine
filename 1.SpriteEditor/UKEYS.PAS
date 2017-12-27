
 {
  i eleme   [0..127] : then     i:3
  i eleme [128..255] : then i-128:3
 }

 unit ukeys;

 interface

 uses
   dos;

 type Letter = record
        Drawing : array [1..15,1..15] of Byte;
      end;

 var
   key : array [0..255] of Boolean;
   Old : procedure;
   LetterContainer : array [1..100] of ^Letter;

     procedure Newirq;
     procedure InitGraphText;
     procedure FalseKeyArray;

 implementation

 procedure FalseKeyArray;
 begin
     fillchar(key, sizeof(key), 0);
 end;

 procedure InitGraphText;
 var i , i2, j2 , x : integer;
     f : Text;
 begin
     for i:=1 to 100 do
       new(LetterContainer[i]);
     assign( f, 'abc.tex');
     reset(f);
     for i:=1 to 60 do
      begin
         for i2:=1 to 15 do
          begin
           for j2:=1 to 15 do
            begin
              read(f,x);
              LetterContainer[i]^.Drawing[i2,j2]:=x;
            end;
           readln(f);
          end;
      end;
      close(f);
 end;

 procedure Newirq; assembler;
 asm
     push ds
     push ax
     push bx
     push cx
     xor cl, cl
     mov bh, cl
     mov ax, seg key
     mov ds, ax
     in al, 60h
     cmp al, 0e0h
     jnz @1
     mov byte [offset key], 0
     jnz @end
    @1:
     cmp byte [offset key], 1
     jnz @2
     mov cl, 128
     mov byte [offset key], 0
    @2:
     mov bl, al
     and bl, 127
     add bl, cl
     xor cl, cl
     shl al, 1
     cmc
     adc cl, 00
     mov [offset key+bx], cl
    @end:
     in  al, 61h
     mov ah, al
     or  al, 80h
     out 61h, al
     mov al, ah
     nop
     nop
     nop
     out 61h, al
     cli
     mov al, 20h
     out 20h, al
     sti
     pop cx
     pop bx
     pop ax
     pop ds
     iret
 end;

 begin
 end.
