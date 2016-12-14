
 program BobDrawerMainProgram_v1; { v1.0.0}

 uses
   Dos, Crt, Mouse,
   uConsts,
   uIOScrn , uScreen, uKeys , UBob, UButton, UEdit;

 var  OmouseX,OmouseY:integer;
      OldClk : word;
      SysClk : word absolute $40:$6C;
      X , Y  : Integer;
      ColorSelectedY : Integer;
      SelectedColorMouseButtonLeft , SelectedColorMouseButtonRight : byte;
      Running : Boolean;

 type
   PExBob = ^TExBob;
   TExBob = object(TBob)
     procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
   end;

   {************************************************************}
   {*                     TColorBob class                      *}
   {*                     ---------------                      *}
   {*    Main objective of the class is to draw colors in      *}
   {*    the editor.                                           *}
   {*                                                          *}
   {************************************************************}
   PColorBob = ^TColorBob;
   TColorBob = object(TBob)
     FSelectedRight,  FSelectedLeft : Boolean;
     procedure OnMouseClick( MouseX , MouseY : Integer); virtual;
     procedure Draw; virtual;
   end;

   PMinimapBob = ^TMinimapBob;
   TMinimapBob = object(TBob)
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


   PBobDrawer = ^TBobDrawer;
   TBobDrawer = object(TIOScreen)

        {---------------------------------------------------------}
        {                 SceneDraw variables                     }
        {---------------------------------------------------------}
        BOB_MAX_LENGTH , BOB_MAX_WIDTH , COLOR_PALLETTE_MAX_COLUM , COLOR_PALLETTE_MAX_ROW: integer;
        BOB_LENGTH, BOB_HALF_LENGTH : Integer;

        BobMenu : ^TMenuButton;
        BobButton2 : PButton;
        MinimapBob : ^TMinimapBob;
        BobSidePanel : PButton;
        BobPixel2DContainer : array [1..120,1..120] of PExBob;
        ColorPalletteBobArray : array [0..MAX_PALLETTE_COLORS] of PColorBob;
        MenuLabel : ^TEdit;

        {---------------------------------------------------------}
        {                 SceneMenu variables                     }
        {---------------------------------------------------------}
        BtMReturn : ^TDrawButton;
        BtMSave : ^TSaveButton;
        BtMLoad : ^TLoadButton;
        BtMExit : ^TExitButton;
        BtMNew : ^TNewButton;
        DrawButtonLabel, SaveButtonLabel, LoadButtonLabel, ExitButtonLabel , NewButtonLabel: ^TEdit;

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
        procedure SetWhichMouseButtonPaints(Left,Right :Boolean);

        procedure SaveFile;
        procedure LoadFile;
        procedure NewFile;
        destructor Done; virtual;
      End;

 var  BobDrawerMainProgram : PBobDrawer;

 procedure TBobDrawer.SetWhichMouseButtonPaints(Left,Right :Boolean);
 var counter , i , j : integer;
 begin
     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        if Right = True then
          begin
            ColorPalletteBobArray[counter]^.FSelectedRight:=False;
          end
        else
          begin
            ColorPalletteBobArray[counter]^.FSelectedLeft:=False;
            Inc(counter);
          end;
       end;
 end;

 constructor TBobDrawer.Init;
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
     BOB_MAX_LENGTH:=  24;
     BOB_MAX_WIDTH :=  24;
     BOB_LENGTH    :=  24;
     BOB_HALF_LENGTH:=  16;
     COLOR_PALLETTE_MAX_COLUM :=   1;
     COLOR_PALLETTE_MAX_ROW := 127;
     ColorSelectedY :=   0;

     { - Assign middle of the picture }
      X:=-((BOB_MAX_LENGTH+1) div 2)*BOB_LENGTH;
      Y:=-((BOB_MAX_WIDTH+1) div 2)*BOB_LENGTH;

     for i:=1 to 120 do
      for j:=1 to 120 do
       begin
         new(BobPixel2DContainer[i,j]);
         BobPixel2DContainer[i,j]^.Init( i*BOB_LENGTH, j*BOB_LENGTH, BOB_LENGTH, BOB_LENGTH,i+j*2);
       end;

     counter:=0;
     for i:=0  to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       Begin

        new(ColorPalletteBobArray[counter]);

        ColorPalletteBobArray[counter]^.Init(
           8 + i*BOB_HALF_LENGTH,
          21 + j*BOB_HALF_LENGTH,
          BOB_HALF_LENGTH,
          BOB_HALF_LENGTH,counter
        );
        ColorPalletteBobArray[counter]^.FSelectedRight:=False;
        ColorPalletteBobArray[counter]^.FSelectedLeft:=False;

        Inc(counter);
       End;

     new(BobMenu);
     new(BobButton2);
     new(BobSidePanel);
     new(MinimapBob);

     BobMenu^.Init(    1,   0,  40,  15, 24, 30, 6);
     BobButton2^.Init(315-BOB_MAX_LENGTH-2, 0, BOB_MAX_LENGTH+2+2,  BOB_MAX_WIDTH+4, 26, 26, 6);
     BobSidePanel^.Init(    1, 16,  40, 200, 26, 26, 6);
     MinimapBob^.Init(315-BOB_MAX_LENGTH, 2, BOB_MAX_LENGTH,  BOB_MAX_WIDTH, 0);

     New(MenuLabel);
     MenuLabel^.Init( -2, -2);
 end;


 destructor TBobDrawer.Done;
 var i , j , counter : integer;
 begin
     inherited Done;

     for i:=1 to BOB_MAX_LENGTH do
      for j:=1 to BOB_MAX_WIDTH do
       dispose(BobPixel2DContainer[i,j]);

     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        dispose(ColorPalletteBobArray[counter]);
        Inc(counter);
       end;

     dispose(MenuLabel);
     dispose(BobMenu);
     dispose(BobButton2);
     dispose(BobSidePanel);

     dispose(BtMReturn);
     dispose(BtMSave);
     dispose(BtMLoad);
     dispose(BtMExit);
     dispose(DrawButtonLabel);
     dispose(SaveButtonLabel);
     dispose(LoadButtonLabel);
     dispose(ExitButtonLabel);
 end;

 procedure TBobDrawer.OnKeyPressed;
 begin
     if key[KeyS] = true then begin donekey;inc(Y, 2*BOB_LENGTH); end;
     if key[KeyW] = true then begin donekey;dec(Y, 2*BOB_LENGTH); end;

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
       dec(X, 2*BOB_LENGTH);
      end;

     if key[KeyD] = true then
      begin
       donekey;
       inc(X, 2*BOB_LENGTH);
      end;

     { - Zoom                 }
     if (key[KeyX] = true) then
      begin
       inc(BOB_LENGTH , 1);
       X:=160-((BOB_MAX_LENGTH+1) div 2)*BOB_LENGTH;
       Y:=100-((BOB_MAX_WIDTH+1) div 2)*BOB_LENGTH;
       Donekey;
      end;

     if (key[KeyZ] = true) and (BOB_LENGTH>1) then
      begin
       dec(BOB_LENGTH , 1);
       X:=160-((BOB_MAX_LENGTH+1) div 2)*BOB_LENGTH;
       Y:=100-((BOB_MAX_WIDTH+1) div 2)*BOB_LENGTH;
       DoneKey;
      end;
 end;

 procedure TBobDrawer.OnMouseButtonPressed( MouseX , MouseY : Integer);
 var i , j : integer;
 begin
 end;

 procedure TBobDrawer.SceneDraw;
 var i , j , counter : integer;
     CONDITION_BOB_OUT_OF_SCREEN : Boolean;
 begin
     ClearScreen(0);

     CONDITION_BOB_OUT_OF_SCREEN:=True;
     i:=1;
     j:=1;
     While (j<=BOB_MAX_WIDTH) and (CONDITION_BOB_OUT_OF_SCREEN = True) do
     begin
      i:=1;
      While (i<=BOB_MAX_LENGTH) and (CONDITION_BOB_OUT_OF_SCREEN = True) do
      begin  {-}                           { + }
          if (X+i*BOB_LENGTH>=-BOB_LENGTH) and (X+(i+1)*BOB_LENGTH<=319+BOB_LENGTH) then
            begin
              if (Y+j*BOB_LENGTH>=-BOB_LENGTH) and ((Y+(j+1)*BOB_LENGTH<=199+BOB_LENGTH)) then
                begin
                  BobPixel2DContainer[i,j]^.Draw;
                end;
            end;

          if (X+(i+2)*BOB_LENGTH=319+BOB_LENGTH) and (Y+(j+2)*BOB_LENGTH=199+BOB_LENGTH) then
            CONDITION_BOB_OUT_OF_SCREEN:=False;
       Inc(i);
      end;
      Inc(j)
     end;


     BobMenu^.Draw;
     BobButton2^.Draw;
     MenuLabel^.DrawText( 'Menu',0);
     BobSidePanel^.Draw;

     MinimapBob^.Draw;


     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
      for j:=0 to COLOR_PALLETTE_MAX_ROW do
       begin
        ColorPalletteBobArray[counter]^.SetBounds(5+i*BOB_HALF_LENGTH,
                                   ColorSelectedY+21+j*BOB_HALF_LENGTH,
                                   BOB_HALF_LENGTH,
                                   BOB_HALF_LENGTH);
        if (ColorSelectedY+21+j*BOB_HALF_LENGTH>8) and
           (ColorSelectedY+21+j*BOB_HALF_LENGTH<21+16*11) then
          ColorPalletteBobArray[counter]^.Draw;
        Inc(counter);
       end;


     if not(MouseHooked) then
        begin
         ReadMouse;

         BobMenu^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BobButton2^.OnMouseClick( MousePoint.X , MousePoint.Y );
         BobSidePanel^.OnMouseClick( MousePoint.X , MousePoint.Y );

         for i:=0 to 255 do
           ColorPalletteBobArray[i]^.OnMouseClick( MousePoint.X , MousePoint.Y );;

         for i:=1 to BOB_MAX_LENGTH do
          for j:=1 to BOB_MAX_WIDTH do
            BobPixel2DContainer[i,j]^.OnMouseClick( MousePoint.X , MousePoint.Y );
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

     for i:=1 to BOB_MAX_LENGTH do
      for j:=1 to BOB_MAX_WIDTH do
       if BOB_LENGTH>8 then
        BobPixel2DContainer[i,j]^.SetBounds( X+i*BOB_LENGTH-2, Y+j*BOB_LENGTH-2,
                                  BOB_LENGTH-2,     BOB_LENGTH-2)
       else
        BobPixel2DContainer[i,j]^.SetBounds( X+i*BOB_LENGTH, Y+j*BOB_LENGTH,
                                  BOB_LENGTH,     BOB_LENGTH);

     counter:=0;
     for i:=0 to COLOR_PALLETTE_MAX_COLUM do
     begin
       for j:=0 to COLOR_PALLETTE_MAX_ROW do
         begin
           ColorPalletteBobArray[counter]^.SetBounds(
              8 + i*BOB_HALF_LENGTH - 2,
             21 + j*BOB_HALF_LENGTH - 2,
             BOB_HALF_LENGTH-2,
             BOB_HALF_LENGTH-2
           );
           Inc(counter);
         end;
     end;

     {*********************************************************************}
     {*                            Set timers                             *}
     {*********************************************************************}
     Inc(BobMenu^.FClock, 1);
     Inc(BobButton2^.FClock, 1);
     Inc( BobSidePanel^.FClock, 1);
     BobMenu^.SetButtonClock(BobMenu^.FClock);
     BobButton2^.SetButtonClock(BobButton2^.FClock);
     BobSidePanel^.SetButtonClock( BobSidePanel^.FClock);
 end;

 procedure TBobDrawer.SceneMenu;
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

 procedure TBobDrawer.Draw;
 begin
    inherited Draw;
 end;

 procedure TBobDrawer.BeforeDraw;
 begin
    if IsDrawScene then
     SceneDraw
    else if IsMenuScene then
     SceneMenu;

    inherited BeforeDraw;
 end;

 procedure TBobDrawer.DoneKey;
 var I : Byte;
 begin
     For I:=1 to 255 do
      Key[I]:=False;
 end;

 procedure TBobDrawer.SaveFile;
 var i , j , CollorId: Integer;
     f : Text;
     nev : string;
 begin
     inherited SaveFile;

     setintvec($09,@Old);
     EndMCGA;

     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {                            Save Bob to a file                             }');
     writeln(' {                           --------------------                            }');
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

     writeln(f,BOB_MAX_LENGTH,' ',BOB_MAX_WIDTH);
     J:=1;
     while j<=BOB_MAX_WIDTH do
      begin
       I:=1;
       while I<=BOB_MAX_LENGTH do
       begin
        write(f, BobPixel2DContainer[i,j]^.FColor,' ');
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

 procedure TBobDrawer.LoadFile;
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
     writeln(' {                          Load Bob from a file                             }');
     writeln(' {                         ----------------------                            }');
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
       readln(f,BOB_MAX_LENGTH,BOB_MAX_WIDTH);
       J:=1;
       while J<=BOB_MAX_LENGTH do
        begin
         i:=1;
         while I<=BOB_MAX_WIDTH do
          begin
           read(f,CollorId);
           BobPixel2DContainer[i,j]^.FColor:=CollorId;
           inc(I);
          end;
         readln(f);
         inc(J);
        end;
       close(f);
       MinimapBob^.Init(315-BOB_MAX_LENGTH, 2, BOB_MAX_LENGTH,  BOB_MAX_WIDTH, 0);
       BobButton2^.Init(315-BOB_MAX_LENGTH-2, 0, BOB_MAX_LENGTH+2+2,  BOB_MAX_WIDTH+4, 26, 26, 6);
       X:=160-((BOB_MAX_LENGTH+1) div 2)*BOB_LENGTH;
       Y:=100-((BOB_MAX_WIDTH+1) div 2)*BOB_LENGTH;
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

 procedure TBobDrawer.NewFile;
 var i , j : integer;
     Color : Byte;
 begin
     inherited NewFile;

     setintvec($09,@Old);
     EndMCGA;
     Clrscr;
     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {                               Create new Bob                              }');
     writeln(' {                              ----------------                             }');
     writeln(' {---------------------------------------------------------------------------}');
     writeln;
     writeln(' {---------------------------------------------------------------------------}');
     writeln(' {  Enter Bob sizes >>                                                       }');
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

     BOB_MAX_LENGTH:=I;
     BOB_MAX_WIDTH:=J;

     for i:=1 to BOB_MAX_LENGTH do
      for j:=1 to BOB_MAX_WIDTH do
       BobPixel2DContainer[i,j]^.FColor:=Color;

     setintvec($09,@NewIRQ);
     fillchar(key, sizeof(key), 0);
     SetMCGA;
     MinimapBob^.Init(315-BOB_MAX_LENGTH, 2, BOB_MAX_LENGTH,  BOB_MAX_WIDTH, 0);
     BobButton2^.Init(315-BOB_MAX_LENGTH-2, 0, BOB_MAX_LENGTH+2+2,  BOB_MAX_WIDTH+4, 26, 26, 6);
     X:=160-((BOB_MAX_LENGTH+1) div 2)*BOB_LENGTH;
     Y:=100-((BOB_MAX_WIDTH+1) div 2)*BOB_LENGTH;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
               BobDrawerMainProgram^.SaveFile;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
               BobDrawerMainProgram^.LoadFile;
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
               FDrawBob:=False;
               FDrawPushedBob:=True;
               BobDrawerMainProgram^.NewFile;
              end;
        end;
 end;

 procedure TExBob.OnMouseClick( MouseX , MouseY : Integer);
 begin
     if OnClick(MouseX , MouseY) = False then exit;
     if MouseClick then
      if MouseClickButton = MouseLeftButton then
        FColor:=SelectedColorMouseButtonLeft
      else if MouseClickButton = MouseRightButton then
        FColor:=SelectedColorMouseButtonRight;

     if (key[keyE] = true) then
        FColor:=SelectedColorMouseButtonRight;

     if (key[keyQ] = true) then
        FColor:=SelectedColorMouseButtonLeft;
 end;

 procedure TMinimapBob.Draw;
 var i , j : Integer;
 begin
     for i:=1 to  BobDrawerMainProgram^.BOB_MAX_LENGTH do
       for j:=1 to BobDrawerMainProgram^.BOB_MAX_WIDTH do
        if ((i>=0) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
          _virtualScreenByteContainer^[i+FBobx+SCREEN_WIDTH*(j+FBobY)]:=BobDrawerMainProgram^.BobPixel2DContainer[i,j]^.FColor;
 end;


 procedure TColorBob.Draw;
 var i , j : integer;
 begin
     for i:=FBobX to FBobX+FBobWidth do
       for j:=FBobY to FBobY+FBobHeight do
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
     for i:=FBobX+2 to FBobX+FBobWidth-3 do
       for j:=FBobY+2 to FBobY+FBobHeight-3 do
        if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
         _virtualScreenByteContainer^[i+SCREEN_WIDTH*j]:=FColor

 end;

 procedure TColorBob.OnMouseClick( MouseX , MouseY : Integer);
 var R,G,B : Byte;
 begin
     if OnClick(MouseX , MouseY) = False then exit;

     if MouseClick then
       begin
         if MouseClickButton = MouseLeftButton then
         begin
            SelectedColorMouseButtonLeft:=FColor;
            BobDrawerMainProgram^.SetWhichMouseButtonPaints(False,True);
            FSelectedLeft:=True;
            FSelectedRight:=False;
         end
         else
         if MouseClickButton = MouseRightButton then
           begin
             SelectedColorMouseButtonRight:=FColor;
             BobDrawerMainProgram^.SetWhichMouseButtonPaints(True,False);
             FSelectedRight:=True;
             FSelectedLeft:=False;
           end
        end
 end;


 {************************************************************}
 {*                     Main program                         *}
 {*                                                          *}
 {*      Contains the initializations, the main game loop    *}
 {*      and the disposal functions of the objects.          *}
 {*                                                          *}
 {************************************************************}
 begin
     { - Change keyboard handling with new assembler function }
     getintvec($09,@Old);
     setintvec($09,@NewIRQ);
     fillchar(key, sizeof(key), 0);
     InitGraphText;

     randomize;
     Running:=True;

     { - Init main program }
     new(BobDrawerMainProgram);
     BobDrawerMainProgram^.Init;
     initmouse;
     showmouse;
     repeat
       PressedKey:=#0;
       BobDrawerMainProgram^.Draw;
     until
       (Running = False) or (key[KeyEsc] = True);

     { - Dispose main program }
     BobDrawerMainProgram^.Done;
     dispose(BobDrawerMainProgram);

     { - Change back to the default keyboard handling function }
     setintvec($09,@Old);
 end.
