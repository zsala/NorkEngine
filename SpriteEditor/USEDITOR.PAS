
 unit uSEditor;

 interface

 uses
   Dos, Crt, Mouse,
   uConsts,
   uIOScrn , uScreen, uKeys , USprite, UButton, ULabel;

 var
   OMouseX,OMouseY:integer;
   X , Y  : Integer;
   ColorSelectedY : Integer;
   SelectedColorMouseButtonLeft , SelectedColorMouseButtonRight : byte;

 type
   PSpritePixel2DBob = ^TSpritePixel2DBob;
   TSpritePixel2DBob = object(TSprite)
     procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;

   {************************************************************}
   {*                     TColorSprite class                   *}
   {*                     ---------------                      *}
   {*    Main objective of the class is to draw colors in      *}
   {*    the Editor.                                           *}
   {*                                                          *}
   {************************************************************}
   PColorSprite = ^TColorSprite;
   TColorSprite = object(TSprite)
     MyIndex: Integer;
     FSelectedRight,  FSelectedLeft : Boolean;

     procedure SetMyIndex( _MyIndex: Integer);
     procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
     procedure Draw; virtual;
   end;

   PMinimapSprite = ^TMinimapSprite;
   TMinimapSprite = object(TSprite)
     procedure Draw; virtual;
   end;

   TDrawButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;
   TExitButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;
   TMenuButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;
   TSaveButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;
   TLoadButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;
   TNewButton = object(TButton)
      procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;

   {************************************************************}
   {*                     TSpriteEditor class                  *}
   {*                     ---------------                      *}
   {*    Main objective of the class is to implement and use   *}
   {*    set of custom classes that make up the logic of the   *}
   {*    Sprite editor                                         *}
   {*                                                          *}
   {************************************************************}
   PSpriteEditor = ^TSpriteEditor;
   TSpriteEditor = object(TIOScreen)

        {---------------------------------------------------------}
        {                 SceneDraw variables                     }
        {---------------------------------------------------------}
        Sprite_MAX_LENGTH , Sprite_MAX_WIDTH , COLOR_PALLETTE_MAX_COLUM , COLOR_PALLETTE_MAX_ROW: integer;
        Sprite_LENGTH, Sprite_HALF_LENGTH : Integer;

        SpriteMenu : ^TMenuButton;
        SpriteButton2 : PButton;
        MinimapSprite : ^TMinimapSprite;
        SpriteSidePanel : PButton;
        SpritePixel2DContainer : array [1..120,1..120] of PSpritePixel2DBob;
        ColorPalletteSpriteArray : array [0..MAX_PALLETTE_COLORS] of PColorSprite;
        MenuLabel : ^TLabel;

        {---------------------------------------------------------}
        {                 SceneMenu variables                     }
        {---------------------------------------------------------}
        BtMReturn : ^TDrawButton;
        BtMSave : ^TSaveButton;
        BtMLoad : ^TLoadButton;
        BtMExit : ^TExitButton;
        BtMNew : ^TNewButton;
        DrawButtonLabel, SaveButtonLabel, LoadButtonLabel, ExitButtonLabel , NewButtonLabel: ^TLabel;

        {---------------------------------------------------------}
        {                       Main functions                    }
        {---------------------------------------------------------}
        constructor Init;
        procedure BeforeDraw; virtual;
        procedure Draw; virtual;

        procedure SceneMenu;
        procedure SceneDraw;

        procedure OnMouseButtonPressed( MouseX , MouseY : Integer); virtual;
        procedure OnKeyPressed;  virtual;
        procedure DoneKey;
        procedure ClearColorPalleteSpritesExceptIndex(MyIndex: Integer);

        procedure SaveFile;
        procedure LoadFile;
        procedure NewFile;
        destructor Done; virtual;
      End;

 var  SpriteEditorMainProgram : PSpriteEditor;

 implementation

 procedure TSpriteEditor.ClearColorPalleteSpritesExceptIndex(MyIndex: Integer);
 var counter , i , j : integer;
 begin
     { - Clear all pallette members and skip the one that are currently used}
     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        if counter <> MyIndex then
          begin
            ColorPalletteSpriteArray[counter]^.FSelectedRight:=False;
            ColorPalletteSpriteArray[counter]^.FSelectedLeft:=False;
            Inc(counter);
          end;
       end;
 end;

 constructor TSpriteEditor.Init;
 var I , J: integer;
     counter : Integer;
 begin
     inherited Init;

     IsDrawScene:=False;
     IsMenuScene:=True;

     {---------------------------------------------------------}
     {                       SceneMenu                         }
     {---------------------------------------------------------}
     new(BtMReturn);
     new(BtMSave);
     new(BtMLoad);
     new(BtMExit);
     new(BtMNew);
     new(NewButtonLabel);
     new(DrawButtonLabel);
     new(SaveButtonLabel);
     new(LoadButtonLabel);
     new(ExitButtonLabel);

     BtMNew^.Init(    20,  25, 75, 15, 24, 30, 40);
     BtMreturn^.Init( 20,  50, 75, 15, 24, 30, 40);
     BtMSave^.Init(   20,  75, 75, 15, 26, 30, 40);
     BtMLoad^.Init(   20, 100, 75, 15, 26, 30, 40);
     BtMExit^.Init(   20, 125, 75, 15, 26, 30, 40);

     NewButtonLabel^.Init(  25,  25-1);
     DrawButtonLabel^.Init( 25,  50-1);
     SaveButtonLabel^.Init( 25,  75-1);
     LoadButtonLabel^.Init( 25, 100-1);
     ExitButtonLabel^.Init( 25, 125-1);


     {---------------------------------------------------------}
     {                       SceneDraw                         }
     {---------------------------------------------------------}
     Sprite_MAX_LENGTH:=  24;
     Sprite_MAX_WIDTH :=  24;
     Sprite_LENGTH    :=  24;
     Sprite_HALF_LENGTH:=  16;
     COLOR_PALLETTE_MAX_COLUM :=   1;
     COLOR_PALLETTE_MAX_ROW := 127;
     ColorSelectedY :=   0;

     { - Assign middle of the picture }
      X:=-((Sprite_MAX_LENGTH+1) div 2)*Sprite_LENGTH;
      Y:=-((Sprite_MAX_WIDTH+1) div 2)*Sprite_LENGTH;

     for i:=1 to 120 do
      for j:=1 to 120 do
       begin
         new(SpritePixel2DContainer[i,j]);
         SpritePixel2DContainer[i,j]^.Init( i*Sprite_LENGTH, j*Sprite_LENGTH, Sprite_LENGTH, Sprite_LENGTH,i+j*2);
       end;

     counter:=0;
     for i:=0  to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       Begin

        new(ColorPalletteSpriteArray[counter]);

        ColorPalletteSpriteArray[counter]^.Init(
           8 + i*Sprite_HALF_LENGTH,
          21 + j*Sprite_HALF_LENGTH,
          Sprite_HALF_LENGTH,
          Sprite_HALF_LENGTH,counter
        );
        ColorPalletteSpriteArray[counter]^.FSelectedRight:=False;
        ColorPalletteSpriteArray[counter]^.FSelectedLeft:=False;
        ColorPalletteSpriteArray[counter]^.SetMyIndex( counter);
        Inc(counter);
       End;

     new(SpriteMenu);
     new(SpriteButton2);
     new(SpriteSidePanel);
     new(MinimapSprite);

     SpriteMenu^.Init(    1,   0,  60,  15, 24, 30, 6);
     SpriteButton2^.Init(315-Sprite_MAX_LENGTH-2, 0, Sprite_MAX_LENGTH+2+2,  Sprite_MAX_WIDTH+4, 26, 26, 6);
     SpriteSidePanel^.Init(    1, 16,  60, 200, 26, 26, 6);
     MinimapSprite^.Init(315-Sprite_MAX_LENGTH, 2, Sprite_MAX_LENGTH,  Sprite_MAX_WIDTH, 0);

     New(MenuLabel);
     MenuLabel^.Init( 10, -2);
 end;


 destructor TSpriteEditor.Done;
 var i , j , counter : integer;
 begin
     inherited Done;

     for i:=1 to Sprite_MAX_LENGTH do
      for j:=1 to Sprite_MAX_WIDTH do
       dispose(SpritePixel2DContainer[i,j]);

     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        dispose(ColorPalletteSpriteArray[counter]);
        Inc(counter);
       end;

     dispose(MenuLabel);
     dispose(SpriteMenu);
     dispose(SpriteButton2);
     dispose(SpriteSidePanel);

     dispose(BtMReturn);
     dispose(BtMSave);
     dispose(BtMLoad);
     dispose(BtMExit);
     dispose(DrawButtonLabel);
     dispose(SaveButtonLabel);
     dispose(LoadButtonLabel);
     dispose(ExitButtonLabel);
 end;

 procedure TSpriteEditor.OnKeyPressed;
 begin
     if key[KeyS] = true then begin donekey;inc(Y, 2*Sprite_LENGTH); end;
     if key[KeyW] = true then begin donekey;dec(Y, 2*Sprite_LENGTH); end;

     if key[KeyR] = true then
      if (ColorSelectedY<>-116*16) then
       begin
        donekey;
        dec(ColorSelectedY, 16);
       end;

     if key[KeyF] = true then
      if (ColorSelectedY<>0) then
       begin
        donekey;
        inc(ColorSelectedY, 16);
       end;

     if key[KeyA] = true then
      begin
       donekey;
       dec(X, 2*Sprite_LENGTH);
      end;

     if key[KeyD] = true then
      begin
       donekey;
       inc(X, 2*Sprite_LENGTH);
      end;

     { - Zoom                 }
     if (key[KeyX] = true) then
      begin
       inc(Sprite_LENGTH , 1);
       X:=160-((Sprite_MAX_LENGTH+1) div 2)*Sprite_LENGTH;
       Y:=100-((Sprite_MAX_WIDTH+1) div 2)*Sprite_LENGTH;
       Donekey;
      end;

     if (key[KeyZ] = true) and (Sprite_LENGTH>1) then
      begin
       dec(Sprite_LENGTH , 1);
       X:=160-((Sprite_MAX_LENGTH+1) div 2)*Sprite_LENGTH;
       Y:=100-((Sprite_MAX_WIDTH+1) div 2)*Sprite_LENGTH;
       DoneKey;
      end;
 end;

 procedure TSpriteEditor.OnMouseButtonPressed( MouseX , MouseY : Integer);
 var i , j : integer;
 begin
 end;

 procedure TSpriteEditor.SceneDraw;
 var i , j , counter : integer;
     CONDITION_Sprite_OUT_OF_SCREEN : Boolean;
 begin
     ClearScreen(0);

     CONDITION_Sprite_OUT_OF_SCREEN:=True;
     i:=1;
     j:=1;
     While (j<=Sprite_MAX_WIDTH) and (CONDITION_Sprite_OUT_OF_SCREEN = True) do
     begin
      i:=1;
      While (i<=Sprite_MAX_LENGTH) and (CONDITION_Sprite_OUT_OF_SCREEN = True) do
      begin  {-}                           { + }
          if (X+i*Sprite_LENGTH>=-Sprite_LENGTH) and (X+(i+1)*Sprite_LENGTH<=319+Sprite_LENGTH) then
            begin
              if (Y+j*Sprite_LENGTH>=-Sprite_LENGTH) and ((Y+(j+1)*Sprite_LENGTH<=199+Sprite_LENGTH)) then
                begin
                  SpritePixel2DContainer[i,j]^.Draw;
                end;
            end;

          if (X+(i+2)*Sprite_LENGTH=319+Sprite_LENGTH) and (Y+(j+2)*Sprite_LENGTH=199+Sprite_LENGTH) then
            CONDITION_Sprite_OUT_OF_SCREEN:=False;
       Inc(i);
      end;
      Inc(j)
     end;


     SpriteMenu^.Draw;
     SpriteButton2^.Draw;
     MenuLabel^.DrawText( 'Menu',0);
     SpriteSidePanel^.Draw;

     MinimapSprite^.Draw;


     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        ColorPalletteSpriteArray[counter]^.SetBounds(5+i*Sprite_HALF_LENGTH,
                                   ColorSelectedY+21+j*Sprite_HALF_LENGTH,
                                   Sprite_HALF_LENGTH,
                                   Sprite_HALF_LENGTH);
        if (ColorSelectedY+21+j*Sprite_HALF_LENGTH>8) and
           (ColorSelectedY+21+j*Sprite_HALF_LENGTH<21+16*11) then
          ColorPalletteSpriteArray[counter]^.Draw;
        Inc(counter);
       end;


     if not(MouseHooked) then
        begin
         ReadMouse;

         SpriteMenu^.OnMouseClick( MousePoint.X , MousePoint.Y );
         SpriteButton2^.OnMouseClick( MousePoint.X , MousePoint.Y );

         for i:=0 to MAX_PALLETTE_COLORS do
           ColorPalletteSpriteArray[i]^.OnMouseClick( MousePoint.X , MousePoint.Y );;

         SpriteSidePanel^.OnMouseClick( MousePoint.X , MousePoint.Y );

         for i:=1 to Sprite_MAX_LENGTH do
          for j:=1 to Sprite_MAX_WIDTH do
            SpritePixel2DContainer[i,j]^.OnMouseClick( MousePoint.X , MousePoint.Y );
     end;

     OnKeyPressed;
     PressedMouseXY( MousePoint );

     if (MousePoint.X>0) and (MousePoint.Y> 0) then
      OnMouseButtonPressed( MousePoint.X, MousePoint.Y );

     { - Check if a key was pressed! }
     if (OldClk <> SysClk) and
        ((MouseX <> OMouseX) or (MouseY <> OMouseY)) then
          begin
            OMouseX := MouseX;
            OMouseY := MouseY;

            OldClk := SysClk;
            Hidemouse;
          end;

     for i:=1 to Sprite_MAX_LENGTH do
      for j:=1 to Sprite_MAX_WIDTH do
       if Sprite_LENGTH>8 then
        SpritePixel2DContainer[i,j]^.SetBounds( X+i*Sprite_LENGTH-2, Y+j*Sprite_LENGTH-2,
                                  Sprite_LENGTH-2,     Sprite_LENGTH-2)
       else
        SpritePixel2DContainer[i,j]^.SetBounds( X+i*Sprite_LENGTH, Y+j*Sprite_LENGTH,
                                  Sprite_LENGTH,     Sprite_LENGTH);

     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
     begin
       for j:=0 to COLOR_PALLETTE_MAX_ROW do
         begin
           ColorPalletteSpriteArray[counter]^.SetBounds(
              8 + i*Sprite_HALF_LENGTH - 2,
             21 + j*Sprite_HALF_LENGTH - 2,
             Sprite_HALF_LENGTH-2,
             Sprite_HALF_LENGTH-2
           );
           Inc(counter);
         end;
     end;

     {*********************************************************************}
     {*                            Set timers                             *}
     {*********************************************************************}
     Inc(SpriteMenu^.FClock, 1);
     Inc(SpriteButton2^.FClock, 1);
     Inc( SpriteSidePanel^.FClock, 1);
     SpriteMenu^.SetButtonClock(SpriteMenu^.FClock);
     SpriteButton2^.SetButtonClock(SpriteButton2^.FClock);
     SpriteSidePanel^.SetButtonClock( SpriteSidePanel^.FClock);
 end;

 procedure TSpriteEditor.SceneMenu;
 begin
     ClearScreen(21);

     BtMReturn^.Draw;
     BtMSave^.Draw;
     BtMLoad^.Draw;
     BtMExit^.Draw;
     BtMNew^.Draw;

     DrawButtonLabel^.DrawText('Draw',0);
     SaveButtonLabel^.DrawText('Save',0);
     LoadButtonLabel^.DrawText('Load',0);
     ExitButtonLabel^.DrawText('Exit',0);
     NewButtonLabel^.DrawText('New',0);

     if not(MouseHooked) then
        begin
         ReadMouse;

         BtMReturn^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BtMSave^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BtMLoad^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BtMExit^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BtMNew^.OnMouseClick( MousePoint.X , MousePoint.Y );
        end;

     OnKeyPressed;
     PressedMouseXY( MousePoint );

     if (MousePoint.X>0) and (MousePoint.Y> 0) then
      OnMouseButtonPressed( MousePoint.X, MousePoint.Y );

     { - Check if a key was pressed! }
     if (OldClk <> SysClk) and
        ((MouseX <> OMouseX) or (MouseY <> OMouseY)) then
          begin
            OMouseX := MouseX;
            OMouseY := MouseY;
            OldClk := SysClk;
            Hidemouse;
          end;

     Inc(BtMReturn^.FClock, 1);
     Inc(BtMSave^.FClock, 1);
     Inc(BtMLoad^.FClock, 1);
     Inc(BtMExit^.FClock, 1);
     Inc(BtMNew^.FClock, 1);

     BtMReturn^.SetButtonClock(BtmReturn^.FClock);
     BtMSave^.SetButtonClock(BtMSave^.FClock);
     BtMLoad^.SetButtonClock(BtMLoad^.FClock);
     BtMExit^.SetButtonClock(BtMExit^.FClock);
     BtMNew^.SetButtonClock(BtMNew^.FClock);
 end;

 procedure TSpriteEditor.Draw;
 begin
    inherited Draw;
 end;

 procedure TSpriteEditor.BeforeDraw;
 begin
    if IsDrawScene then
     SceneDraw
    else if IsMenuScene then
     SceneMenu;

    inherited BeforeDraw;
 end;

 procedure TSpriteEditor.DoneKey;
 var I : Byte;
 begin
     For I:=1 to 255 do
      Key[I]:=False;
 end;

 procedure TSpriteEditor.SaveFile;
 var i , j , CollorId: Integer;
     f : Text;
     nev : string;
 begin
     inherited SaveFile;

     setintvec($09,@Old);
     EndMCGA;

     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {                            Save Sprite to a file                          }');
     writeln(' {                           -----------------------                         }');
     writeln(' {---------------------------------------------------------------------------}');
     writeln('    |                                                                        ');
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {  Enter file name >>                                                       }');
     write(' {  ');
     readln(nev);
     writeln(' {---------------------------------------------------------------------------}');

     assign(f, nev);
     if FileExists(nev) then
      begin
       Clrscr;
       writeln('                                                                       |     ');
       writeln(' {---------------------------------------------------------------------------}');
       writeln(' {  ATENTION!!! File already exists.                                         }');
       writeln(' {  Overwrite file >>  0.Yes 1.No                                            }');
       write(' {  Answer:');
       writeln(' {---------------------------------------------------------------------------}');
       if CollorId = 1 then
         reset(f)
       else rewrite(f);
      end
     else
      rewrite(f);

     writeln(f,Sprite_MAX_LENGTH,' ',Sprite_MAX_WIDTH);
     J:=1;
     while j<=Sprite_MAX_WIDTH do
      begin
       I:=1;
       while I<=Sprite_MAX_LENGTH do
       begin
        write(f, SpritePixel2DContainer[i,j]^.FColor,' ');
        inc(I);
       end;
       inc(J);
       writeln(f);
      end;
     close(f);
     setintvec($09,@NewIRQ);
     fillchar(key, sizeof(key), 0);
     SetMCGA;
 end;

 procedure TSpriteEditor.LoadFile;
 var i , j , CollorId: Integer;
     f : Text;
     nev : string;
 begin
     inherited LoadFile;

     setintvec($09,@Old);
     EndMCGA;
     Clrscr;
     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {                        Load Sprite from a file                            }');
     writeln(' {                       -------------------------                           }');
     writeln(' {---------------------------------------------------------------------------}');
     writeln('    |                                                                        ');
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {  Enter file name >>                                                       }');
     write(' {  ');
     readln(nev);
     writeln(' {---------------------------------------------------------------------------}');
     writeln;
     writeln('                             - PRESS ENTER -                                  ');
     readln;

     if FileExists(nev) then
      begin
       assign(f, nev);
       reset(f);
       readln(f,Sprite_MAX_LENGTH,Sprite_MAX_WIDTH);
       J:=1;
       while J<=Sprite_MAX_LENGTH do
        begin
         i:=1;
         while I<=Sprite_MAX_WIDTH do
          begin
           read(f,CollorId);
           SpritePixel2DContainer[i,j]^.FColor:=CollorId;
           inc(I);
          end;
         readln(f);
         inc(J);
        end;
       close(f);
       MinimapSprite^.Init(315-Sprite_MAX_LENGTH, 2, Sprite_MAX_LENGTH,  Sprite_MAX_WIDTH, 0);
       SpriteButton2^.Init(315-Sprite_MAX_LENGTH-2, 0, Sprite_MAX_LENGTH+2+2,  Sprite_MAX_WIDTH+4, 26, 26, 6);
       X:=160-((Sprite_MAX_LENGTH+1) div 2)*Sprite_LENGTH;
       Y:=100-((Sprite_MAX_WIDTH+1) div 2)*Sprite_LENGTH;
      end
     else
      begin
        writeln('                                                                       |     ');
        writeln(' {---------------------------------------------------------------------------}');
        writeln(' {  ATENTION!!! File does not exists.                                        }');
        writeln(' {  Try again with another file name. PRESS Enter to continue!!!             }');
        writeln(' {---------------------------------------------------------------------------}');
        writeln;
        writeln('                             - PRESS ENTER -                                  ');
        readln;
      end;
     setintvec($09,@NewIRQ);
     fillchar(key, sizeof(key), 0);
     SetMCGA;
 end;

 procedure TSpriteEditor.NewFile;
 var i , j : integer;
     Color : Byte;
 begin
     inherited NewFile;

     setintvec($09,@Old);
     EndMCGA;
     Clrscr;
     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {                               Create new Sprite                           }');
     writeln(' {                              ----------------                             }');
     writeln(' {---------------------------------------------------------------------------}');
     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {  Enter Sprite sizes >>                                                    }');
     write(' {  Width:');
     readln(I);
     write(' {  Height:');
     readln(J);
     writeln(' {---------------------------------------------------------------------------}');
     writeln;

     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {  Choose fill collor >>                                                    }');
     write(' {  Color:');
     readln(Color);
     writeln(' {---------------------------------------------------------------------------}');
     writeln;
     writeln('                             - PRESS ENTER -                                  ');
     readln;

     Sprite_MAX_LENGTH:=I;
     Sprite_MAX_WIDTH:=J;

     for i:=1 to Sprite_MAX_LENGTH do
      for j:=1 to Sprite_MAX_WIDTH do
       SpritePixel2DContainer[i,j]^.FColor:=Color;

     setintvec($09,@NewIRQ);
     fillchar(key, sizeof(key), 0);
     SetMCGA;
     MinimapSprite^.Init(315-Sprite_MAX_LENGTH, 2, Sprite_MAX_LENGTH,  Sprite_MAX_WIDTH, 0);
     SpriteButton2^.Init(315-Sprite_MAX_LENGTH-2, 0, Sprite_MAX_LENGTH+2+2,  Sprite_MAX_WIDTH+4, 26, 26, 6);
     X:=160-((Sprite_MAX_LENGTH+1) div 2)*Sprite_LENGTH;
     Y:=100-((Sprite_MAX_WIDTH+1) div 2)*Sprite_LENGTH;
 end;



 procedure TDrawButton.OnMouseClick( MouseX , MouseY : Integer);
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
               IsMenuScene:=False;
               IsDrawScene:=True;
              end;
        end;
 end;

 procedure TExitButton.OnMouseClick( MouseX , MouseY : Integer);
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
               Running:=False;
               {Halt; }
              end;
        end;
 end;

 procedure TMenuButton.OnMouseClick( MouseX , MouseY : Integer);
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
               IsMenuScene:=True;
               IsDrawScene:=False;
              end;
        end;
 end;

 procedure TSaveButton.OnMouseClick( MouseX , MouseY : Integer);
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
               SpriteEditorMainProgram^.SaveFile;
              end;
        end;
 end;




 procedure TLoadButton.OnMouseClick( MouseX , MouseY : Integer);
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
               SpriteEditorMainProgram^.LoadFile;
              end;
        end;
 end;

 procedure TNewButton.OnMouseClick( MouseX , MouseY : Integer);
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
               SpriteEditorMainProgram^.NewFile;
              end;
        end;
 end;

 procedure TSpritePixel2DBob.OnMouseClick( MouseX , MouseY : Integer);
 begin
     if OnClick(MouseX , MouseY) = False then exit;

     if MouseClick then
      if MouseClickButton = MouseLeftButton then
        begin
          FColor:=SelectedColorMouseButtonLeft
        end
      else
        begin
          if MouseClickButton = MouseRightButton then
          begin
            FColor:=SelectedColorMouseButtonRight;
          end
        end;

     if (key[keyE] = true) then
        FColor:=SelectedColorMouseButtonRight;

     if (key[keyQ] = true) then
        FColor:=SelectedColorMouseButtonLeft;
 end;

 procedure TMinimapSprite.Draw;
 var i , j : Integer;
 begin
     for i:=1 to  SpriteEditorMainProgram^.Sprite_MAX_LENGTH do
       for j:=1 to SpriteEditorMainProgram^.Sprite_MAX_WIDTH do
        if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
          _virtualScreenByteContainer^[i+FSpritex+SCREEN_WIDTH*(j+FSpriteY)]:=SpriteEditorMainProgram^.SpritePixel2DContainer[i,j]^.FColor;
 end;

 procedure TColorSprite.SetMyIndex( _MyIndex: Integer);
 begin
   MyIndex := _MyIndex;
 end;

 procedure TColorSprite.Draw;
 var i , j : integer;
 begin
     for i:=FSpriteX to FSpriteX+FSpriteWidth do
       for j:=FSpriteY to FSpriteY+FSpriteHeight do
        if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
         begin
          if FSelectedLeft = True then
           _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=1;
          if FSelectedRight = True then
           _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=2;
          if (FSelectedRight = False) and (FSelectedLeft = False) then
           _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=30;
         end;

     { - Padding !? }
     for i:=FSpriteX+2 to FSpriteX+FSpriteWidth-3 do
       for j:=FSpriteY+2 to FSpriteY+FSpriteHeight-3 do
        if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
         _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor

 end;

 procedure TColorSprite.OnMouseClick( MouseX , MouseY : Integer);
 var R,G,B : Byte;
 begin
     if OnClick(MouseX , MouseY) = False then exit;

     if MouseClick then
       begin
         if MouseClickButton = MouseLeftButton then
         begin
            SelectedColorMouseButtonLeft:=FColor;
            SpriteEditorMainProgram^.ClearColorPalleteSpritesExceptIndex(MyIndex);
            FSelectedLeft:=True;
            FSelectedRight:=False;
         end
         else
         if MouseClickButton = MouseRightButton then
           begin
             SelectedColorMouseButtonRight:=FColor;
             SpriteEditorMainProgram^.ClearColorPalleteSpritesExceptIndex(MyIndex);
             FSelectedRight:=True;
             FSelectedLeft:=False;
           end
        end
 end;

 begin
 end.
