unit untIECompat;

interface

uses System.SysUtils, System.StrUtils, VCL.Forms, DateUtils,
  SHDocVw,
  MSHTML;

type
  TCompatibleModeRegistry = (cmrCurrentUser, cmrLocalMachine, cmrBoth);

const
  IECOMPATIBLEMODEKEY = 'Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION\';

procedure PutIECompatible(MajorVer: Integer; CMR: TCompatibleModeRegistry);

function FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName, AttrValue: string): IHTMLElement;

procedure NavigateAndWait(AEWB: TWebBrowser; AUrl: string; ATimeout: Cardinal = 15000);

type
  TNodeTraverseProc = procedure(ANode: IHTMLElement; var AIgnoreSubNodes: Boolean);

procedure TraverseNodeTree(ANode: IHTMLElement; AProc: TNodeTraverseProc);

implementation

uses Winapi.Windows, System.Win.Registry;

type
  TIsWow64Process = function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;

function IsWindows64: Boolean;
var
  IsWow64Process: TIsWow64Process;
  IsW64: LongBool;
begin
  IsW64 := False;
  @IsWow64Process := GetProcAddress(GetModuleHandle(kernel32), 'IsWow64Process');
  if Assigned(@IsWow64Process) then
    IsWow64Process(GetCurrentProcess, IsW64);
  Result := Boolean(IsW64);
end;

Procedure SetReg64Access(R: TRegistry);
begin
  if IsWindows64 and Assigned(R) then
    R.Access := R.Access or KEY_WOW64_64KEY;
end;

procedure PutIECompatible(MajorVer: Integer; CMR: TCompatibleModeRegistry);
var
  Reg: TRegistry;
  HK: array of Cardinal;
  i: Integer;
begin
  case CMR of
    cmrCurrentUser:
      begin
        SetLength(HK, 1);
        HK[0] := HKEY_CURRENT_USER;
      end;
    cmrLocalMachine:
      begin
        SetLength(HK, 1);
        HK[0] := HKEY_LOCAL_MACHINE;
      end;
    cmrBoth:
      begin
        SetLength(HK, 2);
        HK[0] := HKEY_CURRENT_USER;
        HK[1] := HKEY_LOCAL_MACHINE;
      end;
  end;
  for i := 0 to Length(HK) - 1 do
  begin
    Reg := TRegistry.Create;
    try
      SetReg64Access(Reg); // если программа x32, а система x64
      Reg.RootKey := HK[i];
      Reg.OpenKey(IECOMPATIBLEMODEKEY, True);
      Reg.WriteInteger(ExtractFileName(Application.ExeName), MajorVer * 1000);
      // MajorVer IE
    finally
      Reg.Free;
    end;
  end;
end;

function FindNodeByAttrExStarts(ANode: IHTMLElement; NodeName, AttrName, AttrValue: string): IHTMLElement;
var
  i: Integer;
  child: IHTMLElement;
  Str: string;
begin
  if ANode = nil then
  begin
    Result := nil;
    Exit;
  end;
  Result := nil;
  // OutputDebugString(PChar(
  // Format('FindNodeByAttrEx: %s _ %s _ %s in  %s id = %s, class = %s ',
  // [NodeName,  AttrName,  AttrValue,
  // ANode.tagName, ANode.id,  ANode.classname])));
  if Sametext(ANode.tagName, NodeName) then
  begin
    if AttrName.IsEmpty then
      Result := ANode
    else if SameText(AttrName, 'class') then
    begin
      if SameText(AttrValue, ANode._classname) then
        Result := ANode;
    end
    else // для иных атрибутов
    begin
      Str := ANode.getAttribute(AttrName, 0);
      if AttrValue.IsEmpty or StartsText(AttrValue, Str) then
        Result := ANode
    end
  end;
  if not Assigned(Result) then
    for i := 0 to (ANode.children as IHTMLElementCollection).Length - 1 do
    begin
      child := (ANode.children as IHTMLElementCollection).item(i, 0) as IHTMLElement;
      Result := FindNodeByAttrExStarts(child, NodeName, AttrName, AttrValue);
      if Result <> nil then
        Exit;
    end;
end;

procedure TraverseNodeTree(ANode: IHTMLElement; AProc: TNodeTraverseProc);
var
  i: Integer;
  child: IHTMLElement;
  NeedToStop: Boolean;
begin
  if (ANode = nil) or not Assigned(AProc) then
    Exit;
  NeedToStop := False;
  AProc(ANode, NeedToStop);
  if NeedToStop then
    Exit;

  for i := 0 to (ANode.children as IHTMLElementCollection).Length - 1 do
  begin
    child := (ANode.children as IHTMLElementCollection).item(i, 0) as IHTMLElement;
    TraverseNodeTree(child, AProc);
  end;
end;

procedure NavigateAndWait(AEWB: TWebBrowser; AUrl: string; ATimeout: Cardinal = 15000);
var
  StartTm: TDate;
begin
  StartTm := GetTime;
  AEWB.Navigate(AUrl);
  try
    AEWB.Enabled := False;
    while (not(AEWB.ReadyState in [READYSTATE_COMPLETE { , READYSTATE_INTERACTIVE } ])) and
      (MilliSecondsBetween(StartTm, GetTime) < ATimeout) do
    begin
      Sleep(50);
      Application.ProcessMessages;
    end;
  finally
    AEWB.Enabled := True;
  end;
end;

end.
