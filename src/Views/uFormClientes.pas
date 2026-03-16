unit uFormClientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  System.Generics.Collections, uModelo.Cliente, uService.Cliente;

type
  TFormClientes = class(TForm)
    pnlTop: TPanel;
    pnlGrid: TPanel;
    pnlCadastro: TPanel;
    DBGrid: TDBGrid;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;
    btnFechar: TButton;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnFiltrar: TButton;
    lblId: TLabel;
    edtId: TEdit;
    lblNome: TLabel;
    edtNome: TEdit;
    lblCPF: TLabel;
    edtCPF: TEdit;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblEndereco: TLabel;
    edtEndereco: TEdit;
    chkAtivo: TCheckBox;
    btnSalvar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure DBGridDblClick(Sender: TObject);
    procedure edtCPFKeyPress(Sender: TObject; var Key: Char);
  private
    FClienteService: TClienteService;
    FClienteAtual: TCliente;
    FModoEdicao: Boolean;
    procedure CarregarGrid;
    procedure LimparCampos;
    procedure HabilitarCampos(Habilitar: Boolean);
    procedure CarregarCliente(Cliente: TCliente);
  public
  end;

var
  FormClientes: TFormClientes;

implementation

uses
  uDataModule;

{$R *.dfm}

procedure TFormClientes.FormCreate(Sender: TObject);
begin
  FClienteService := TClienteService.Create;
  FClienteAtual := nil;
  FModoEdicao := False;
  edtCPF.MaxLength := 14;
  edtCPF.OnKeyPress := edtCPFKeyPress;
  HabilitarCampos(False);
  CarregarGrid;
end;

procedure TFormClientes.FormDestroy(Sender: TObject);
begin
  if Assigned(FClienteAtual) then
    FClienteAtual.Free;
  FClienteService.Free;
end;

procedure TFormClientes.CarregarGrid;
begin
  DM.qryClientes.Close;
  DM.qryClientes.SQL.Clear;
  DM.qryClientes.SQL.Add('SELECT id, nome, cpf, telefone, email, ativo FROM clientes ORDER BY nome');
  DM.qryClientes.Open;
end;

procedure TFormClientes.LimparCampos;
begin
  edtId.Clear;
  edtNome.Clear;
  edtCPF.Clear;
  edtTelefone.Clear;
  edtEmail.Clear;
  edtEndereco.Clear;
  chkAtivo.Checked := True;
end;

procedure TFormClientes.HabilitarCampos(Habilitar: Boolean);
begin
  edtNome.Enabled := Habilitar;
  edtCPF.Enabled := Habilitar;
  edtTelefone.Enabled := Habilitar;
  edtEmail.Enabled := Habilitar;
  edtEndereco.Enabled := Habilitar;
  chkAtivo.Enabled := Habilitar;
  btnSalvar.Enabled := Habilitar;
  btnCancelar.Enabled := Habilitar;
  
  btnNovo.Enabled := not Habilitar;
  btnEditar.Enabled := not Habilitar;
  btnExcluir.Enabled := not Habilitar;
  DBGrid.Enabled := not Habilitar;
end;

procedure TFormClientes.CarregarCliente(Cliente: TCliente);
begin
  edtId.Text := IntToStr(Cliente.Id);
  edtNome.Text := Cliente.Nome;
  edtCPF.Text := Cliente.CPF;
  edtTelefone.Text := Cliente.Telefone;
  edtEmail.Text := Cliente.Email;
  edtEndereco.Text := Cliente.Endereco;
  chkAtivo.Checked := Cliente.Ativo;
end;

procedure TFormClientes.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarCampos(True);
  FModoEdicao := False;
  edtNome.SetFocus;
end;

procedure TFormClientes.btnEditarClick(Sender: TObject);
begin
  if DM.qryClientes.IsEmpty then
  begin
    ShowMessage('Selecione um cliente para editar');
    Exit;
  end;
  
  if Assigned(FClienteAtual) then
    FClienteAtual.Free;
    
  FClienteAtual := FClienteService.BuscarPorID(DM.qryClientes.FieldByName('id').AsInteger);
  
  if Assigned(FClienteAtual) then
  begin
    CarregarCliente(FClienteAtual);
    HabilitarCampos(True);
    FModoEdicao := True;
    edtNome.SetFocus;
  end;
end;

procedure TFormClientes.btnExcluirClick(Sender: TObject);
begin
  if DM.qryClientes.IsEmpty then
  begin
    ShowMessage('Selecione um cliente para excluir');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir este cliente?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FClienteService.Excluir(DM.qryClientes.FieldByName('id').AsInteger);
      ShowMessage('Cliente excluido com sucesso!');
      CarregarGrid;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TFormClientes.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormClientes.btnFiltrarClick(Sender: TObject);
begin
  if Trim(edtFiltro.Text) = '' then
    CarregarGrid
  else
  begin
    DM.qryClientes.Close;
    DM.qryClientes.SQL.Clear;
    DM.qryClientes.SQL.Add('SELECT id, nome, cpf, telefone, email, ativo FROM clientes');
    DM.qryClientes.SQL.Add('WHERE UPPER(nome) LIKE :nome ORDER BY nome');
    DM.qryClientes.ParamByName('nome').AsString := '%' + UpperCase(edtFiltro.Text) + '%';
    DM.qryClientes.Open;
  end;
end;

procedure TFormClientes.btnSalvarClick(Sender: TObject);
var
  Cliente: TCliente;
  Salvo: Boolean;
begin
  Salvo := False;

  if FModoEdicao then
    Cliente := FClienteAtual
  else
    Cliente := TCliente.Create;

  try
    Cliente.Nome := edtNome.Text;
    Cliente.CPF := edtCPF.Text;
    Cliente.Telefone := edtTelefone.Text;
    Cliente.Email := edtEmail.Text;
    Cliente.Endereco := edtEndereco.Text;
    Cliente.Ativo := chkAtivo.Checked;

    if FModoEdicao then
      FClienteService.Alterar(Cliente)
    else
      FClienteService.Incluir(Cliente);

    Salvo := True;
  except
    on E: Exception do
    begin
      if Pos('duplicate key', LowerCase(E.Message)) > 0 then
        ShowMessage('CPF ja cadastrado. Informe um CPF diferente.')
      else
        ShowMessage('Erro ao salvar: ' + E.Message);
    end;
  end;

  if not FModoEdicao and not Salvo then
    Cliente.Free;

  if Salvo then
  begin
    if FModoEdicao then
    begin
      FClienteAtual.Free;
      FClienteAtual := nil;
    end;
    ShowMessage('Cliente salvo com sucesso!');
    LimparCampos;
    HabilitarCampos(False);
    CarregarGrid;
  end;
end;

procedure TFormClientes.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarCampos(False);
  
  if Assigned(FClienteAtual) then
  begin
    FClienteAtual.Free;
    FClienteAtual := nil;
  end;
end;

procedure TFormClientes.DBGridDblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFormClientes.edtCPFKeyPress(Sender: TObject; var Key: Char);
begin
  if not (CharInSet(Key, ['0'..'9', '.', '-', #8])) then
    Key := #0;
end;

end.
