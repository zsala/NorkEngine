
 program SpriteEditorMainProgram_v1; { v1.0.0}

 uses
   Dos, Crt, Mouse,
   uConsts,
   uSEditor, uKeys;

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
    new(SpriteEditorMainProgram);
    SpriteEditorMainProgram^.Init;
    initmouse;
    showmouse;

    { - Main game loop }
    repeat
      SpriteEditorMainProgram^.Draw;
    until
      (Running = False) or (key[KeyEsc] = True);

    { - Dispose main program }
    SpriteEditorMainProgram^.Done;
    dispose(SpriteEditorMainProgram);

    { - Change back to the default keyboard handling function }
    setintvec($09,@Old);
  end.
