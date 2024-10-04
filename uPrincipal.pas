unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  System.ImageList, Vcl.ImgList, Vcl.WinXPanels, Vcl.Buttons, MMSystem,
  Vcl.Imaging.pngimage, IniFiles, System.StrUtils, System.NetEncoding;

type
  TfmPrincipal = class(TForm)
    pnlBackground: TPanel;
    btnIniciarParar: TButton;
    tmTimer: TTimer;
    btnReiniciar: TButton;
    pnlTimer: TPanel;
    cpPrincipal: TCardPanel;
    cTimer: TCard;
    cConfiguração: TCard;
    pnlConfiguracao: TPanel;
    Label1: TLabel;
    edTempoPeriodo: TEdit;
    Label2: TLabel;
    edTempoIntervalo: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    btnVoltar: TButton;
    btnSalvar: TButton;
    btnimgConfiguracoes: TImage;
    chkTelaCheia: TCheckBox;
    btnFechar: TButton;
    mmNotificacaoEncoded: TMemo;
    chkNotificar: TCheckBox;
    procedure btnIniciarPararClick(Sender: TObject);
    procedure tmTimerTimer(Sender: TObject);
    procedure btnReiniciarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure btnVoltarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnimgConfiguracoesClick(Sender: TObject);
    procedure chkTelaCheiaClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FTempoCorrido: integer;
    procedure CalculaTempo;
    procedure CalculaIntervalo;
    function GetTempoPeriodo: integer;
    function GetTempoIntervalo: integer;
    procedure GravarIni(ASecao, AIdent, AValor: string);
    function LerIni(ASecao, AIdent, AValorDefault: string): string;
    function EncodeFileBase64(AFile: string): string;
    function DecodeFileBase64(ABase64: string): string;
    procedure TocarNotificacao;
  public
    { Public declarations }
  end;

var
  fmPrincipal: TfmPrincipal;


implementation

{$R *.dfm}

procedure TfmPrincipal.btnIniciarPararClick(Sender: TObject);
begin
  case btnIniciarParar.Tag of
    0: begin
      tmTimer.Enabled := True;
      btnIniciarParar.Tag := 1;
      btnIniciarParar.Caption := 'Parar';
    end;
    1: begin
      btnIniciarParar.Tag := 0;
      btnIniciarParar.Caption := 'Iniciar';
      tmTimer.Enabled := False;
    end;
  end;
end;

procedure TfmPrincipal.btnReiniciarClick(Sender: TObject);
begin
  FTempoCorrido := 0;
  CalculaTempo;
end;

procedure TfmPrincipal.btnVoltarClick(Sender: TObject);
begin
  if not (tmTimer.Enabled) then
    CalculaTempo;
  cpPrincipal.PreviousCard;
end;

procedure TfmPrincipal.btnSalvarClick(Sender: TObject);
begin
  GravarIni('GERAL', 'PERIODO', edTempoPeriodo.Text);
  GravarIni('GERAL', 'INTERVALO', edTempoIntervalo.Text);
  GravarIni('GERAL', 'TELACHEIA', IfThen(chkTelaCheia.Checked, 'S', 'N'));
  GravarIni('GERAL', 'NOTIFICAR', IfThen(chkNotificar.Checked, 'S', 'N'));
  CalculaTempo;
  cpPrincipal.PreviousCard;
end;

procedure TfmPrincipal.CalculaIntervalo;
var
  lTempoAtual: integer;
  Minutes: Integer;
  RemainingSeconds: Integer;
begin
  lTempoAtual := GetTempoPeriodo + GetTempoIntervalo - FTempoCorrido;
  Minutes := lTempoAtual div 60; // Calcula os minutos
  RemainingSeconds := lTempoAtual mod 60; // Calcula os segundos restantes
  pnlTimer.Caption := Format('%.2d:%.2d', [Minutes, RemainingSeconds]); // Formata como mm:ss
  pnlTimer.Font.Color := clRed;
  if lTempoAtual = 0 then
    TocarNotificacao;
end;

procedure TfmPrincipal.CalculaTempo;
var
  lTempoAtual: integer;
  Minutes: Integer;
  RemainingSeconds: Integer;
begin
  lTempoAtual := GetTempoPeriodo - FTempoCorrido;
  Minutes := lTempoAtual div 60; // Calcula os minutos
  RemainingSeconds := lTempoAtual mod 60; // Calcula os segundos restantes
  pnlTimer.Caption := Format('%.2d:%.2d', [Minutes, RemainingSeconds]); // Formata como mm:ss
  pnlTimer.Font.Color := clWhite;
  if lTempoAtual = 0 then
    TocarNotificacao;
end;

procedure TfmPrincipal.chkTelaCheiaClick(Sender: TObject);
begin
  if chkTelaCheia.Checked then
  begin
    Self.BorderStyle := bsNone;
    btnFechar.Visible := True;
  end
  else
  begin
    Self.BorderStyle := bsSizeable;
    btnFechar.Visible := False;
  end;
  Self.WindowState := wsNormal;
  Self.WindowState := wsMaximized;
end;

function TfmPrincipal.DecodeFileBase64(ABase64: string): string;
var
  StreamFile: TBytesStream;
  lArquivo: string;
begin
  lArquivo := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'notificacao.wav';
  if not (FileExists(lArquivo)) then
  begin
    try
      StreamFile := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(aBase64));
      try
        StreamFile.SaveToFile(lArquivo);
      finally
        StreamFile.Free;
      end;
      Result := lArquivo;
    except
      Result := '';
    end;
  end
  else
    Result := lArquivo;
end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin
  cpPrincipal.ActiveCard := cTimer;
  edTempoPeriodo.Text := LerIni('GERAL', 'PERIODO', '25');
  edTempoIntervalo.Text := LerIni('GERAL', 'INTERVALO', '5');
  chkTelaCheia.Checked := LerIni('GERAL', 'TELACHEIA', 'N') = 'S';
  chkNotificar.Checked := LerIni('GERAL', 'NOTIFICAR', 'S') = 'S';
  CalculaTempo;
end;

procedure TfmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_F1: begin
      var lFonteAtual: integer := pnlTimer.Font.Size;
      Inc(lFonteAtual);
      pnlTimer.Font.Size := lFonteAtual;
    end;
    VK_F2: begin
      var lFonteAtual: integer := pnlTimer.Font.Size;
      Dec(lFonteAtual);
      pnlTimer.Font.Size := lFonteAtual;
    end;
  end;
end;

procedure TfmPrincipal.FormResize(Sender: TObject);
begin
  // Centraliza o TPanel horizontalmente e verticalmente
  pnlBackground.Left := (ClientWidth - pnlBackground.Width) div 2;
  pnlBackground.Top := (ClientHeight - pnlBackground.Height) div 2;
  pnlConfiguracao.Left := (ClientWidth - pnlConfiguracao.Width) div 2;
  pnlConfiguracao.Top := (ClientHeight - pnlConfiguracao.Height) div 2;
end;

function TfmPrincipal.GetTempoIntervalo: integer;
begin
  Result := StrToIntDef(edTempoIntervalo.Text, 5) * 60;
end;

function TfmPrincipal.GetTempoPeriodo: integer;
begin
  Result := StrToIntDef(edTempoPeriodo.Text, 25) * 60;
end;

procedure TfmPrincipal.GravarIni(ASecao, AIdent, AValor: string);
var
  vIni: TIniFile;
begin
  vIni := TIniFile.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'config.ini');
  try
    vIni.WriteString(ASecao, AIdent, AValor);
  finally
    vIni.Free;
  end;
end;

function TfmPrincipal.LerIni(ASecao, AIdent, AValorDefault: string): string;
var
  vIni: TIniFile;
begin
  vIni := TIniFile.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'config.ini');
  try
    Result := vIni.ReadString(ASecao, AIdent, AValorDefault);
  finally
    vIni.Free;
  end;
end;

procedure TfmPrincipal.btnFecharClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfmPrincipal.btnimgConfiguracoesClick(Sender: TObject);
begin
  cpPrincipal.NextCard;
end;

procedure TfmPrincipal.tmTimerTimer(Sender: TObject);
begin
  inc(FTempoCorrido);
  if GetTempoPeriodo < FTempoCorrido then
  begin
    if GetTempoIntervalo + GetTempoPeriodo < FTempoCorrido then //Reinicia
    begin
      FTempoCorrido := 0;
    end
    else
    begin
      CalculaIntervalo;
    end;
  end
  else
    CalculaTempo;
end;

procedure TfmPrincipal.TocarNotificacao;
begin
  if chkNotificar.Checked then
    SndPlaySound(PWideChar(DecodeFileBase64(mmNotificacaoEncoded.Lines.Text)), SND_ASYNC);
end;

function TfmPrincipal.EncodeFileBase64(aFile: string): string;
var
  StreamFile: TBytesStream;
begin
  if aFile.IsEmpty then
  begin
    Result := '';
    Exit;
  end;
  if FileExists(aFile) then
  begin
    try
      StreamFile := TBytesStream.Create;
      StreamFile.LoadFromFile(aFile);
      Result := TNetEncoding.Base64.EncodeBytesToString(StreamFile.Bytes);
    except
      Result := '';
    end;
  end;
end;

end.
