
 unit uBob;

 interface

 uses
   Mouse, Crt,
   uConsts,
   uKeys, uScreen;

 type
      PBob = ^TBob;
      TBob = object
       FBobX , FBobY , FBobWidth , FBobHeight : Integer;
       FColor : Byte;

       constructor Init(IBobX , IBobY , IBobWidth , IBobHeight : integer; IColor : Byte);
       destructor Done;

       procedure SetBounds(IBobX , IBobY , IBobWidth ,IBobHeight : integer);
       procedure Draw; virtual;
       function OnClick( IMouseX , IMouseY : Integer) : Boolean;
       procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
      end;

 implementation

 constructor TBob.Init(IBobX , IBobY , IBobWidth , IBobHeight : integer; IColor : byte);
 begin
     FBobWidth:=IBobWidth;
     FBobHeight:=IBobHeight;
     FBobX:=IBobX;
     FBobY:=IBobY;
     FColor:=IColor;
 end;

 procedure TBob.SetBounds(IBobX , IBobY , IBobWidth , IBobHeight : integer);
 begin
     FBobWidth:=IBobWidth;
     FBobHeight:=IBobHeight;
     FBobX:=IBobX;
     FBobY:=IBobY;
 end;

 procedure TBob.Draw;
 var i , j : integer;
 begin
     for i:=FBobX to FBobX+FBobWidth do
       for j:=FBobY to FBobY+FBobHeight do
        if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
         _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;
 end;

 function TBob.OnClick( IMouseX , IMouseY : Integer) : Boolean;
 var i , j : integer;
 begin
     OnClick:=False;
     if (FBobX<=IMouseX) and (IMouseX<=FBobX+FBobWidth) then
       if (FBobY<=IMouseY) and (IMouseY<=FBobY+FBobHeight) then
          OnClick:=True;
 end;

 procedure TBob.OnMouseClick( MouseX , MouseY : Integer);
 begin
     if OnClick(MouseX , MouseY) = False then exit;

     { - Implement custom logic here, by inheritance!!! }
 end;

 destructor TBob.Done;
 begin
 end;

 begin
 end.
