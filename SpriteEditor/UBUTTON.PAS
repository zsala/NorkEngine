unit uButton;

interface

uses
    Mouse, crt,
    uConsts,
    uKeys, uBob, uScreen;

type
    PButton = ^TButton;
    TButton = object(TBob)
       FClicked , FDrawPushedBob, FDrawBob: Boolean;
       FColor2 : Byte;
       FClock , FInterval : Integer;

       constructor Init(IBobX , IBobY , IBobWidth , IBobHeight : integer;
                   IColorClicked , IColorNotClicked: Byte; IInterval: Integer);
       destructor done;

       procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
       procedure Draw; virtual;
       procedure DrawBob; virtual;        { - Should be private }
       procedure DrawPushedBob; virtual;  { - Shoule be private }
       procedure SetButtonClock(var IClock : Integer); virtual;
    end;

implementation

constructor TButton.Init(IBobX , IBobY , IBobWidth , IBobHeight : integer;
            IColorClicked , IColorNotClicked: Byte; IInterval : Integer);
begin
    FBobX:=IBobX;
    FBobY:=IBobY;
    FBobWidth:=IBobWidth;
    FBobHeight:=IBobHeight;
    FColor:=IColorClicked;
    FColor2:=IColorNotClicked;
    FDrawBob:=True;
    FDrawPushedBob:=False;
    FInterval:=IInterval;
    FClock:=0;
end;

procedure TButton.OnMouseClick( MouseX , MouseY : Integer);
begin
   if OnClick(MouseX , MouseY) = False then
     begin
       exit;
     end;
   if (MouseClick) then
      if MouseClickButton = MouseLeftButton then
       begin
           if (OnClick(MouseX , MouseY) = True) then
             begin
              FDrawBob:=False;
              FDrawPushedBob:=True;
             end;
       end;
end;

procedure TButton.Draw;
begin
    if FDrawBob then
      DrawBob
    else
      DrawPushedBob;
end;

  procedure TButton.SetButtonClock(var IClock : Integer);
begin
   if IClock = FInterval then
    begin
     FDrawBob:=True;
     FDrawPushedBob:=False;
     IClock:=0;
    end;
end;

procedure TButton.DrawBob;
var i , j  : integer;
begin
     for i:=FBobX to FBobX+FBobWidth do
      for j:=FBobY to FBobY+FBobHeight do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;
end;

procedure TButton.DrawPushedBob;
var i , j : integer;
begin
     for i:=FBobX to FBobX+FBobWidth do
      for j:=FBobY to FBobY+FBobHeight do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;

     for i:=FBobX+1 to FBobX+FBobWidth-1 do
      for j:=FBobY+1 to FBobY+FBobHeight-1 do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor2;
end;

destructor TButton.done;
begin
end;

begin
end.
