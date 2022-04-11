unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.OleCtrls, Vcl.ExtCtrls,
  DateUtils, StrUtils, System.IniFiles,
  MSHTML, SHDocVw;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    dtpDate: TDateTimePicker;
    btnDownload: TButton;
    wb1: TWebBrowser;
    pnlTop: TPanel;
    procedure btnDownloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

Uses untIECompat, untDownloadCommon;

{$R *.dfm}

var
  C_Echo_Block: TStringList;

procedure ProcessNodes(ANode: MSHTML.IHTMLElement; var AIgnoreSubNodes: Boolean);
var
  href, destfolder, CurrDate, FileDate, FileName: string;
  tmpfname, programname, tmstr: string;
  I: Integer;
  year, mon, day: Word;
begin
  if not SameText(ANode.tagName, 'a') then
    Exit;
  href := ANode.getAttribute('href', 0);

  if href.StartsWith('https://cdn', True) and href.EndsWith('.mp3', True) then
  begin
    for I := 0 to C_Echo_Block.Count - 1 do
    begin
      if AnsiContainsText(href, C_Echo_Block.Names[I]) then
        Exit;
    end;
    // https://cdn.echo.msk.ru/snd/2018-12-10-razbor_poleta-2105.mp3
    DecodeDate(Form1.dtpDate.Date, year, mon, day);
    CurrDate := Format('%4d-%.2d-%.2d', [year, mon, day]);
    destfolder := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + CurrDate + '\';
    FileName := href.Substring(href.LastDelimiter('/') + 1);
    FileDate := Copy(FileName, 1, Length('2018-12-10'));

    tmpfname := ReplaceText(FileName, '.mp3', '');
    tmstr := Copy(tmpfname, Length(tmpfname) - 4 + 1, 4);
    programname := Copy(tmpfname, 12, Length(tmpfname) - 4 - 12);

    FileName := Format('%s-%s-%s.mp3', [FileDate, tmstr, programname]);

    if AnsiStartsText(FileDate, FileName) then // чтобы не скачивать повторы с предыдущих дней
      DownloadFile(href, FileName, destfolder);
  end;
end;

procedure TForm1.btnDownloadClick(Sender: TObject);
var
  year, mon, day: Word;
  url: string;
  content: IHTMLElement;
  bodyHTML: IHTMLElement;
begin
  DecodeDate(dtpDate.Date, year, mon, day);
  url := Format('https://echo.msk.ru/schedule/%4d-%.2d-%.2d.html', [year, mon, day]);
  try
    Screen.Cursor := crHourGlass;
    NavigateAndWait(wb1, url);
    bodyHTML := (wb1.Document as IHTMLDocument2).body;
    content := FindNodeByAttrExStarts(bodyHTML, 'section', 'class', 'content');
    if content <> nil then
      TraverseNodeTree(content, ProcessNodes);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  setts: TIniFile;
  I: Integer;
begin
  setts := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    setts.WriteDate('Main', 'Date', dtpDate.Date);
    C_Echo_Block.Sort;
    for I := 0 to C_Echo_Block.Count - 1 do
      setts.WriteString('Blocks', C_Echo_Block.Names[I], '1');
  finally
    setts.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  setts: TIniFile;
begin
  PutIECompatible(11, cmrCurrentUser);
  C_Echo_Block := TStringList.Create;
  setts := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    dtpDate.Date := setts.ReadDate('Main', 'Date', Trunc(Now));
    setts.ReadSectionValues('Blocks', C_Echo_Block);
  finally
    setts.Free;
  end;
end;

end.
