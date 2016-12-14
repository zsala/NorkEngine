unit uedit;

interface

uses
  Mouse, crt,
  uConsts,
  uScreen, uKeys, uBob;

type
    { - This should be a Label! }
    TEdit = object
      TEditX , TEditY , TAktX, TAktY : Integer;

      constructor Init( IEditX, IEditY : Integer);
      destructor Done;

      procedure Draw( Index : byte; IColor : Byte);virtual; { Draw one should be }
      procedure DrawText( Text : string; IColor : Byte);virtual; { Draw should be named }
    end;

implementation

constructor TEdit.Init( IEditX , IEditY : Integer);
begin
    TEditX:=IEditX;
    TEditY:=IEditY;
    TAktX:=TEditX;
    TAktY:=TEditY;
end;

procedure TEdit.DrawText( Text : string; IColor : Byte);
var i : integer;
    index , index2: shortint;
    c : char;
begin
    for i:=1 to length(Text) do
      begin
         c:=Text[i];
         case c of
          'a' :  index:=1;
          'A' :  index:=2;
          'b' :  index:=3;
          'B' :  index:=4;
          'c' :  index:=5;
          'C' :  index:=6;
          'd' :  index:=7;
          'D' :  index:=8;
          'e' :  index:=9;
          'E' :  index:=10;
          'f' :  index:=11;
          'F' :  index:=12;
          'g' :  index:=13;
          'G' :  index:=14;
          'h' :  index:=15;
          'H' :  index:=16;
          'i' :  index:=17;
          'I' :  index:=18;
          'j' :  index:=19;
          'J' :  index:=20;
          'k' :  index:=21;
          'K' :  index:=22;
          'l' :  index:=23;
          'L' :  index:=24;
          'm' :  index:=25;
          'M' :  index:=26;
          'n' :  index:=27;
          'N' :  index:=28;
          'o' :  index:=29;
          'O' :  index:=30;
          'p' :  index:=31;
          'P' :  index:=32;
          'r' :  index:=33;
          'R' :  index:=34;
          's' :  index:=35;
          'S' :  index:=36;
          'q' :  index:=37;
          'Q' :  index:=38;
          't' :  index:=39;
          'T' :  index:=40;
          'u' :  index:=41;
          'U' :  index:=42;
          'v' :  index:=43;
          'V' :  index:=44;
          'w' :  index:=45;
          'W' :  index:=46;
          'z' :  index:=47;
          'Z' :  index:=48;
          'y' :  index:=49;
          'Y' :  index:=50;
          '1' :  index:=51;
          '2' :  index:=52;
          '3' :  index:=53;
          '4' :  index:=54;
          '5' :  index:=55;
          '6' :  index:=56;
          '7' :  index:=57;
          '8' :  index:=58;
          '9' :  index:=59;
          '0' :  index:=60;
          ' ' :  index:=100;
         else
            index:=-1;
         end;
         if index<>-1 then
           begin
             Draw( index, IColor);
           end
         else
           if index=100 then
             begin
               TAktX:=TAktx+10;
             end;
      end;
      TAktx:=TEditX;
end;

procedure TEdit.Draw( Index : byte; IColor : Byte);
var i , j  : integer;
begin
    for i:=1 to 15 do
     for j:=1 to 15 do
      if LetterContainer[Index]^.Drawing[j,i]<>0 then
       _virtualScreenByteContainer^[TAktx+i+(j+TAktY)*SCREEN_WIDTH]:=IColor+LetterContainer[Index]^.Drawing[j,i];

    TAktX:=TAktx+10;
end;

destructor TEdit.Done;
begin
end;

begin
end.
