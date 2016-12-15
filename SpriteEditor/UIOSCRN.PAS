
 unit uIOScrn;

 interface

 uses
   Mouse,
   uConsts,
   uScreen;

 type
      TMouse = record
        Image : array [1..20,1..20] of Integer;
        Background : array [1..20,1..20] of Integer;
        Heigth , Width : integer;
      End;

      {************************************************************}
      {*                     TIOScreen class                      *}
      {*                    --------------                        *}
      {*    Main objective of the class is to overwrite the main  *}
      {*    functionalities of the TScreen class and provide      *}
      {*    mouse handling functions/procedures. Furthermore the  *}
      {*    class implements some basic save/load/create file     *}
      {*    handling operations.                                  *}
      {*                                                          *}
      {************************************************************}
      PIOScreen = ^TIOScreen;
      TIOScreen = object(TScreen)
        _mouse : TMouse;
        constructor Init;
        destructor Done; virtual;

        procedure BeforeDraw; virtual;
        procedure DrawBackground; virtual;
        procedure Draw; virtual;

        procedure PressedMouseXY(var Point : TPoint);

        procedure SaveFile;
        procedure LoadFile;
        procedure NewFile;
      End;

 var  MousePoint : TPoint;
      PressedKey : Char;

 implementation

 constructor TIOScreen.Init;
 var i , j : integer;
     f : Text;
 begin
     inherited Init;

     ClearScreen(0);

     Randomize;
     for i:=0 to SCREEN_WIDTH do
      for j:=0 to SCREEN_HEIGHT do
         SetPixel(i,j,0);

     Assign(f, 'cursor.ico');
     Reset(f);

     readln( f , _mouse.Width , _mouse.Heigth);
     for i:=1 to _mouse.Width do
      begin
       for j:=1 to _mouse.Heigth do
         Read( f, _mouse.Image[j,i]);
       readln(f);
      end;
     Close(f);

     { - Loads RGB Palette from Turbo Pascal }
     for i:=0 to MAX_PALLETTE_COLORS do
      GetRGB(i,Palette^[i].R,Palette^[i].G,Palette^[i].B);
 end;

 destructor TIOScreen.Done;
 begin
     inherited done;
 end;

 procedure TIOScreen.DrawBackground;
 var i , j , k , l : integer;
 begin
   { - TODO: do we need this !? }
   for i:=1 to _mouse.Width do
   begin
     for j:=1 to _mouse.Heigth do
       begin
         if _mouse.Background[i,j]<>-1 then
           SetPixel(i+GetMx(MouseX),j+GetMy(MouseY),_mouse.Background[i,j]);
       end
   end
 end;

 procedure TIOScreen.Draw;
 begin
   inherited Draw;
 end;

 procedure TIOScreen.PressedMouseXY(var Point : TPoint);
 begin
      if (GetMx(MouseX)>=0) and (GetMX(MouseY)>=0) then
       begin
        Point.X:=GetMx(MouseX);
        Point.Y:=GetMy(MouseY);
       end
      else
       begin
        Point.X:=-1;
        Point.Y:=-1;
       end;
 end;

 procedure TIOScreen.SaveFile;
 begin
 end;

 procedure TIOScreen.LoadFile;
 begin
 end;

 procedure TIOScreen.NewFile;
 begin
 end;

 procedure TIOScreen.BeforeDraw;
 var i , j : integer;
 begin
   inherited BeforeDraw;

   for i:=1 to _mouse.Width do
   begin
     for j:=1 to _mouse.Heigth do
     begin
       if _mouse.Image[i,j]<>-1 then
         SetPixel(i+GetMx(MouseX),j+GetMy(MouseY),_mouse.Image[i,j]);
     end
   end
 end;

 begin

 end.
