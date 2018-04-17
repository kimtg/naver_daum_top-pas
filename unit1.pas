unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, RegExpr, fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonRefresh: TButton;
    EditInterval: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure ButtonRefreshClick(Sender: TObject);
    procedure EditIntervalChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  result: TStrings;

implementation

{$R *.lfm}

var
  re_naver, re_daum: tregexpr;

function re_groups(re: tregexpr; text: string; group: integer): TStrings;
begin
  re_groups := TStringList.Create;
  if re.Exec(text) then
  begin
    repeat
      re_groups.Add(re.match[group]);
    until not re.ExecNext;
  end;
end;

function list_naver: TStrings;
begin
  list_naver := re_groups(re_naver, TFPHTTPClient.SimpleGet('https://www.naver.com'), 1);
  list_naver.Capacity := 20;
end;

function list_daum: TStrings;
begin
  list_daum := re_groups(re_daum, TFPHTTPClient.SimpleGet('https://www.daum.net'), 1);
end;

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  x, item: string;
  ln, ld: TStrings;
begin
  try
    item := item + DateTimeToStr(Now);
    item := item + #13#10'Naver: ';
    ln := list_naver;
    for x in ln do
      item := item + x + '; ';

    item := item + #13#10'Daum: ';
    ld := list_daum;
    for x in ld do
      item := item + x + '; ';

    item := item + #13#10;
  except
    on e: Exception do
      item := item + e.ToString;
  end;
  ln.Free;
  ld.Free;
  result.Add(item);
  while result.Count > 10000 do
    result.Delete(0);

  memo1.Text := result.Text;
  memo1.Append('');
end;

procedure TForm1.EditIntervalChange(Sender: TObject);
begin
  Timer1.Interval := StrToInt(EditInterval.Text) * 1000;
end;

procedure TForm1.ButtonRefreshClick(Sender: TObject);
begin
  Timer1Timer(Nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  EditIntervalChange(Nil);
  Timer1Timer(Nil);
end;

begin
  re_naver := tregexpr.Create('<span class="ah_k">(.+?)</span>');
  re_daum := tregexpr.Create('class=\"link_issue\" tabindex.*?>(.+?)</a>');
  result := TStringList.Create;
end.

