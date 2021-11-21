object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'EchoSave'
  ClientHeight = 376
  ClientWidth = 631
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object wb1: TWebBrowser
    Left = 0
    Top = 41
    Width = 631
    Height = 335
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 472
    ExplicitHeight = 202
    ControlData = {
      4C00000037410000A02200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 631
    Height = 41
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 7
      Top = 13
      Width = 26
      Height = 13
      Caption = #1044#1072#1090#1072
    end
    object dtpDate: TDateTimePicker
      Left = 49
      Top = 9
      Width = 102
      Height = 21
      Date = 43466.000000000000000000
      Time = 0.449967013890272900
      TabOrder = 0
    end
    object btnDownload: TButton
      Left = 164
      Top = 7
      Width = 75
      Height = 25
      Caption = 'Download'
      TabOrder = 1
      OnClick = btnDownloadClick
    end
  end
end
