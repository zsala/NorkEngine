
unit uConsts;

interface

const
    KeyQ = 16;   KeyA = 30;  KeyZ = 44;  KeyW = 17;
    KeyS = 31;   KeyX = 46;  KeyE = 18;  KeyD = 32;
    KeyC = 47;   KeyR = 19;  KeyF = 33;  KeyV = 48;
    KeyT = 20;   KeyG = 34;  KeyB = 49;  KeyY = 21;
    KeyH = 35;   KeyN = 50;  KeyU = 22;  KeyJ = 36;
    KeyM = 51;   KeyI = 23;  KeyK = 37;  KeyO = 24;
    KeyL = 38;   KeyP = 25;
    KeyEsc = 1;  KeyEnter = 28;  KeySpace = 57;  Key2 = 42;
    KeyUp = 72;  KeyDown = 80;  KeyRight = 75;  KeyLeft = 77;

    SCREEN_WIDTH  = 320;
    SCREEN_HEIGHT = 200;
    SCREEN_MAX_BYTES = 64000;
    MAX_PALLETTE_COLORS = 255;

var
    IsDrawScene , IsMenuScene : Boolean;

    { - Helper functions }
    function IntToStr(i: Longint): string;
    function FileExists(FileName : string) : Boolean;

implementation

function IntToStr(i: Longint): string;
var s: string[11];
begin
    Str(i, s);
    IntToStr := s;
end;

function FileExists(FileName : string) : Boolean;
var f : file;
begin
    {$I-}
    Assign(f, FileName);
    Reset(f);
    Close(f);
    {$I+}
    FileExists := (IOResult = 0) and (FileName <> '');
end;

begin
end.
