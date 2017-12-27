unit uButton;

interface

uses
    Mouse, crt,
    uConsts,
    uKeys, uSprite, uScreen;

type
    {************************************************************}
    {*                     TButton class                        *}
    {*                    --------------                        *}
    {*    Main objective of the class is to draw a button.      *}
    {*    Furthermore the class handles user interaction and    *}
    {*    visualy responds accordingly to the different events. *}
    {*                                                          *}
    {************************************************************}
    PButton = ^TButton;
    TButton = object(TSprite)
       FClicked , FDrawPushedSprite, FDrawSprite: Boolean;
       FColor2 : Byte;
       FClock , FInterval : Integer;

       constructor Init(ISpriteX , ISpriteY , ISpriteWidth , ISpriteHeight : integer;
                   IColorClicked , IColorNotClicked: Byte; IInterval: Integer);
       destructor done;

       procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
       procedure Draw; virtual;
       procedure DrawSprite; virtual;        { - Should be private }
       procedure DrawPushedSprite; virtual;  { - Shoule be private }
       procedure SetButtonClock(var IClock : Integer); virtual;
    end;

implementation

constructor TButton.Init(ISpriteX , ISpriteY , ISpriteWidth , ISpriteHeight : integer;
            IColorClicked , IColorNotClicked: Byte; IInterval : Integer);
begin
    FSpriteX:=ISpriteX;
    FSpriteY:=ISpriteY;
    FSpriteWidth:=ISpriteWidth;
    FSpriteHeight:=ISpriteHeight;
    FColor:=IColorClicked;
    FColor2:=IColorNotClicked;
    FDrawSprite:=True;
    FDrawPushedSprite:=False;
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
              FDrawSprite:=False;
              FDrawPushedSprite:=True;
             end;
       end;
end;

procedure TButton.Draw;
begin
    if FDrawSprite then
      DrawSprite
    else
      DrawPushedSprite;
end;

  procedure TButton.SetButtonClock(var IClock : Integer);
begin
   if IClock = FInterval then
    begin
     FDrawSprite:=True;
     FDrawPushedSprite:=False;
     IClock:=0;
    end;
end;

procedure TButton.DrawSprite;
var i , j  : integer;
begin
     for i:=FSpriteX to FSpriteX+FSpriteWidth do
      for j:=FSpriteY to FSpriteY+FSpriteHeight do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;
end;

procedure TButton.DrawPushedSprite;
var i , j : integer;
begin
     for i:=FSpriteX to FSpriteX+FSpriteWidth do
      for j:=FSpriteY to FSpriteY+FSpriteHeight do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor;

     for i:=FSpriteX+1 to FSpriteX+FSpriteWidth-1 do
      for j:=FSpriteY+1 to FSpriteY+FSpriteHeight-1 do
       if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
        _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor2;
end;

destructor TButton.done;
begin
end;

begin
end.
