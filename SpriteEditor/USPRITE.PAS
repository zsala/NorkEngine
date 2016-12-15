
 unit uSprite;

 interface

 uses
   Mouse, Crt,
   uConsts,
   uKeys, uScreen;

 type
      PSprite = ^TSprite;
      TSprite = object
       FSpriteX , FSpriteY , FSpriteWidth , FSpriteHeight : Integer;
       FColor : Byte;

       constructor Init(ISpriteX , ISpriteY , ISpriteWidth , ISpriteHeight : integer; IColor : Byte);
       destructor Done;

       procedure SetBounds(ISpriteX , ISpriteY , ISpriteWidth ,ISpriteHeight : integer);
       procedure Draw; virtual;
       function OnClick( IMouseX , IMouseY : Integer) : Boolean;
       procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
      end;

 implementation

 constructor TSprite.Init(ISpriteX , ISpriteY , ISpriteWidth , ISpriteHeight : integer; IColor : byte);
 begin
     FSpriteWidth:=ISpriteWidth;
     FSpriteHeight:=ISpriteHeight;
     FSpriteX:=ISpriteX;
     FSpriteY:=ISpriteY;
     FColor:=IColor;
 end;

 procedure TSprite.SetBounds(ISpriteX , ISpriteY , ISpriteWidth , ISpriteHeight : integer);
 begin
     FSpriteWidth:=ISpriteWidth;
     FSpriteHeight:=ISpriteHeight;
     FSpriteX:=ISpriteX;
     FSpriteY:=ISpriteY;
 end;

 procedure TSprite.Draw;
 var i , j : integer;
 begin
     for i:=FSpriteX to FSpriteX+FSpriteWidth do
       for j:=FSpriteY to FSpriteY+FSpriteHeight do
        if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
         _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;
 end;

 function TSprite.OnClick( IMouseX , IMouseY : Integer) : Boolean;
 var i , j : integer;
 begin
     OnClick:=False;
     if (FSpriteX<=IMouseX) and (IMouseX<=FSpriteX+FSpriteWidth) then
       if (FSpriteY<=IMouseY) and (IMouseY<=FSpriteY+FSpriteHeight) then
          OnClick:=True;
 end;

 procedure TSprite.OnMouseClick( MouseX , MouseY : Integer);
 begin
     if OnClick(MouseX , MouseY) = False then exit;

     { - Implement custom logic here, by inheritance!!! }
 end;

 destructor TSprite.Done;
 begin
 end;

 begin
 end.
