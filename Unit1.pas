unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.OleCtrls, Vcl.ExtCtrls,
  DateUtils, StrUtils,
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

const
  C_Echo_Block: array [1..60] of string = (
    'bigecho', 'classicrock', 'odna', 'risk',
    'vinil', 'peskov', 'unpast', 'farm',
    'apriscatole', 'moscowtravel', 'speakrus', 'orders',
    'kazino', 'autorsong', 'redrquare', 'museum',
    'voensovet', 'parking', 'graniweek', 'gorodovoy',
    'proehali', 'skaner', 'doehali', 'zoloto', 'glam', 'babnik', 'blues', 'znamenatel',
    'arsenal', 'football', 'galopom', 'autorsong', 'tabel', 'buntman-kid', 'keys', 'blogout1',
    'beatles', 'bombard', 'radiodetaly', 'garage', 'dream', 'blokadagolosa', 'victory', 'help',
    'dalvostok', '-0805.mp3', 'cenapobedy', 'aqua', 'agent_provocateur', 'gulko-kid',
    'speaktatar', 'tv_person', 'vsetakplus', 'vottak'
    , 'kurspotapenko', 'club_parina', 'ganapolskoe_itogi', 'knigivokrug', 'sho_tam', '-tv-'
    );

procedure ProcessNodes(ANode: MSHTML.IHTMLElement; var AIgnoreSubNodes: Boolean);
var
  href, destfolder, DayStr, FileName: string;
  tmpfname, programname, tmstr: string;
  I: Integer;
  year, mon, day: Word;
begin
  if not SameText(ANode.tagName, 'a') then Exit;
//  OutputDebugString(PChar(
//    Format('ProcessNodes: %s id = %s, class = %s [%s]',
//    [ANode.tagName, ANode.id,  ANode._classname, ANode.outerHTML])));
  href := ANode.getAttribute('href', 0);

  if href.StartsWith('https://cdn', True) and  href.EndsWith('.mp3', True) then
  begin
  OutputDebugString(PChar('href = ' + href));
    for I := Low(C_Echo_Block) to High(C_Echo_Block) do
    begin
      if AnsiContainsText(href, C_Echo_Block[I]) then
        Exit;
    end;
    //https://cdn.echo.msk.ru/snd/2018-12-10-razbor_poleta-2105.mp3
    DecodeDate(Form1.dtpDate.Date, year, mon, day);
    DayStr := Format('%4d-%.2d-%.2d', [year, mon, day]);
    destfolder := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + DayStr + '\';
    FileName := href.Substring(href.LastDelimiter('/') + 1);

    tmpfname := ReplaceText(FileName, '.mp3', '');
    tmstr := Copy(tmpfname, Length(tmpfname) - 4 + 1, 4);
    programname := Copy(tmpfname, 12, Length(tmpfname) - 4 - 12);


    FileName := Format('%s-%s-%s.mp3', [DayStr, tmstr, programname]);

    if AnsiStartsText(DayStr,  FileName) then // чтобы не скачивать повторы с предыдущих дней
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
  NavigateAndWait(wb1, url);
  bodyHTML := (wb1.Document as IHTMLDocument2).body;
  content := FindNodeByAttrExStarts(bodyHTML, 'section', 'class', 'content');
  if content <> nil then
    TraverseNodeTree(content, ProcessNodes);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  PutIECompatible(11, cmrCurrentUser);
end;

end.
