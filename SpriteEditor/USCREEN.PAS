unit uScreen;

interface

uses
    uConsts;

type
     TRGB = record
       R , G , B : byte;
     end;

     TPoint = record
       X , Y : Integer;
     end;

     PPalett = ^TPalett;
     TPalett = array [0..MAX_PALLETTE_COLORS] of TRGB;

     PScreenByteContainer = ^TScreenByteContainer;
     TScreenByteContainer = array [1..SCREEN_MAX_BYTES] of byte;

     {************************************************************}
     {*                     TScreen class                        *}
     {*                    --------------                        *}
     {*    Main objective of the class is to implement low-      *}
     {*    level screen draw handle functionalities. In order to *}
     {*    achieve maximum speed some functions are written in   *}
     {*    asssembly.                                            *}
     {*                                                          *}
     {************************************************************}
     PScreen = ^TScreen;
     TScreen = object
       Palette : PPalett;
       procedure SetMCGA;
       procedure EndMCGA;
       procedure GetRGB( N: byte; var R, G, B: byte);
       procedure SetRGB( N, R, G, B: byte);
      public
       constructor Init;
       destructor Done; virtual;

       procedure SetPixel( i, j : integer;Color : Byte);
       function GetPixel( i , j : integer) : Byte;
       procedure GetPaletteRGB( N: byte; var R, G, B: byte);
       procedure SetPaletteRGB( N, R, G, B: byte);
       procedure LoadPalette( _palette : PPalett);
       procedure ClearScreen( Color : byte);
       procedure BeforeDraw; virtual;
       procedure Draw; virtual;
     end;

var  _virtualScreenByteContainer : PScreenByteContainer;

implementation

procedure TScreen.SetMCGA; assembler;
asm
  mov   ax,13h
  int   10h           { - Init MCGA graphics mode }
end;

procedure TScreen.EndMCGA; assembler;
asm
  mov ax,3
  int 10h             { - Close MCGA graphics mode }
end;

constructor TScreen.Init;
begin
  setmcga;          { - Init MCGA grpahics mode. }
  new(_virtualScreenByteContainer);  { - Initialize corresponding memory on the heap. }
  new(Palette);     { - 256*3 byte memory init for the Palette. }
end;

procedure TScreen.GetPaletteRGB( N: byte; var R, G, B: byte);
begin
  R:=Palette^[N].R;
  G:=Palette^[N].G;
  B:=Palette^[N].B;
end;

procedure TScreen.SetPaletteRGB( N, R, G, B: byte);
begin
  Palette^[N].R:=R;
  Palette^[N].G:=G;
  Palette^[N].B:=B;
end;

procedure TScreen.GetRGB( N: byte; var R, G, B: byte); assembler;
asm
  mov    dx,03c7h      { Read RGB data to register               }
  mov    al,N          { Set output variable as N                }
  out    dx,al
  mov    dx,03c9h      { RGB register setup                      }
  in     al,dx         { Read R parameter                        }
  les    di,R
  stosb
  in     al,dx         { Read G parameter                        }
  les    di,G
  stosb
  in     al,dx         { Read B parameter                        }
  les    di,B
  stosb
end;

procedure TScreen.SetRGB( N, R, G, B: byte); assembler;
asm
  mov    dx,03c8h      { RGB write register setup                }
  mov    al,N
  out    dx,al         { N. szin modositasa                      }
  mov    dx,03c9h      { RGB adatregiszter                       }
  mov    al,R
  out    dx,al         { Write R parameter                       }
  mov    al,G
  out    dx,al         { Write G parameter                       }
  mov    al,B
  out    dx,al         { Write B parameter                       }
end;


procedure TScreen.SetPixel( i, j : integer;Color : Byte);
begin
  if ((i>=1) and (i<=SCREEN_WIDTH)) and ((j>=0) and (j<=SCREEN_HEIGHT)) then
    _virtualScreenByteContainer^[j*SCREEN_WIDTH+i]:=Color;
end;

function TScreen.GetPixel( i , j : integer) : Byte;
begin
  GetPixel:=_virtualScreenByteContainer^[j*SCREEN_WIDTH+i];
end;

procedure TScreen.LoadPalette( _palette : PPalett);
var i : integer;
begin
  _palette^[0].R:=0;
  _palette^[0].G:=0;
  _palette^[0].B:=0;
  for i:=1 to MAX_PALLETTE_COLORS do
    SetRGB( i, _palette^[i].R, _palette^[i].G, _palette^[i].B);
end;

procedure TScreen.BeforeDraw;
begin
  {
    - Code that needs to run before the _virtualScreenByteContainer is
      push to the physical screen
  }
end;

procedure TScreen.ClearScreen( Color : byte);
var i , j : integer;
begin
    for i:=0 to SCREEN_WIDTH do
      for j:=0 to SCREEN_HEIGHT do
        _virtualScreenByteContainer^[j*SCREEN_WIDTH+i]:=Color;
end;

procedure TScreen.Draw;
var  _mainScreenByteContainerPointer : TScreenByteContainer absolute $A000:0000;
begin
  { - Draw logic (INFO: this only modifies the pixels in the container!!!)  }
  BeforeDraw;

  { - Draw virtual screen to the real physical one }
  _mainScreenByteContainerPointer := _virtualScreenByteContainer^;
end;

destructor TScreen.Done;
begin
  endmcga;                              { - back to text mode     }
  dispose(_virtualScreenByteContainer); { - free virtual screen   }
  dispose(Palette);                     { - free palette pointer  }
end;

begin
end.
