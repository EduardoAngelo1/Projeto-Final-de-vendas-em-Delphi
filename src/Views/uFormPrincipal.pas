unit uFormPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons;

type
  TFormPrincipal = class(TForm)
    MainMenu: TMainMenu;
    mnuCadastros: TMenuItem;
    mnuClientes: TMenuItem;
    mnuProdutos: TMenuItem;
    mnuVendas: TMenuItem;
    pnlPrincipal: TPanel;
    btnClientes: TBitBtn;
    btnProdutos: TBitBtn;
    btnVendas: TBitBtn;
    lblTitulo: TLabel;
    pnlTopo: TPanel;
    lblUsuario: TLabel;
    lblData: TLabel;
    btnSair: TBitBtn;
    procedure mnuClientesClick(Sender: TObject);
    procedure mnuProdutosClick(Sender: TObject);
    procedure mnuVendasClick(Sender: TObject);
    procedure mnuSairClick(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnVendasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSairCLick(Sender: Tobject);
  private
  public
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

uses
  uFormClientes, uFormProdutos, uFormVendas, uDataModule;

{$R *.dfm}

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  try
    if not DM.TestarConexao then
      ShowMessage('Erro ao conectar ao banco de dados');

    lblData.Caption := 'Data: ' + FormatDateTime('dd/mm/yyyy', Date);
    lblUsuario.Caption := 'Usuario: Admin';
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

procedure TFormPrincipal.mnuClientesClick(Sender: TObject);
var
  Form: TFormClientes;
begin
  Form := TFormClientes.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFormPrincipal.mnuProdutosClick(Sender: TObject);
var
  Form: TFormProdutos;
begin
  Form := TFormProdutos.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TFormPrincipal.mnuVendasClick(Sender: TObject);
var
  Form: TFormVendas;
begin
  Form := TFormVendas.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;


procedure TFormPrincipal.mnuSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.btnClientesClick(Sender: TObject);
begin
  mnuClientesClick(Sender);
end;

procedure TFormPrincipal.btnProdutosClick(Sender: TObject);
begin
  mnuProdutosClick(Sender);
end;

procedure TFormPrincipal.btnVendasClick(Sender: TObject);
begin
  mnuVendasClick(Sender);
end;

procedure TFormPrincipal.btnSairClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja realmente sair do sistema?',
     'Confirmacao', MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin
    Application.Terminate;
  end;
end;

end.
