
unit uDrwObj;

interface

uses
  Mouse,
  uConsts, uLabel;

type
  TMousePosition = object(TLabel)
     procedure DrawText( Text : string; IColor : Byte); virtual;
  end;

implementation

procedure TMousePosition.DrawText( Text : string; IColor : Byte);
var MouseX, MouseY: integer;
begin
  { - Get the current Mouse and write the position }

  inherited DrawText;
end;

begin
end.
