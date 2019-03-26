program EchoSave;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  untIECompat in 'untIECompat.pas',
  untDownloadCommon in 'untDownloadCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
