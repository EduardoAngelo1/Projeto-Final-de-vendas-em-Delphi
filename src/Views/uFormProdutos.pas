unit uFormProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.DBCtrls,
  System.Generics.Collections, uModelo.Produto, uService.Produto;

type
  TFormProdutos = class(TForm)
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
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    lblEstoque: TLabel;
    edtEstoque: TEdit;
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
  private
    FProdutoService: TProdutoService;
    FProdutoAtual: TProduto;
    FModoEdicao: Boolean;
    procedure CarregarGrid;
    procedure LimparCampos;
    procedure HabilitarCampos(Habilitar: Boolean);
    procedure CarregarProduto(Produto: TProduto);
  public
  end;

var
  FormProdutos: TFormProdutos;

implementation

uses
  uDataModule;

{$R *.dfm}

procedure TFormProdutos.FormCreate(Sender: TObject);
begin
  FProdutoService := TProdutoService.Create;
  FProdutoAtual := nil;
  FModoEdicao := False;
  HabilitarCampos(False);
  CarregarGrid;
end;

procedure TFormProdutos.FormDestroy(Sender: TObject);
begin
  if Assigned(FProdutoAtual) then
    FProdutoAtual.Free;
  FProdutoService.Free;
end;

procedure TFormProdutos.CarregarGrid;
begin
  DM.qryProdutos.Close;
  DM.qryProdutos.SQL.Clear;
  DM.qryProdutos.SQL.Add('SELECT id, descricao, preco_unitario, estoque, ativo FROM produtos ORDER BY descricao');
  DM.qryProdutos.Open;
end;

procedure TFormProdutos.LimparCampos;
begin
  edtId.Clear;
  edtDescricao.Clear;
  edtPreco.Text := '0,00';
  edtEstoque.Text := '0';
  chkAtivo.Checked := True;
end;

procedure TFormProdutos.HabilitarCampos(Habilitar: Boolean);
begin
  edtDescricao.Enabled := Habilitar;
  edtPreco.Enabled := Habilitar;
  edtEstoque.Enabled := Habilitar;
  chkAtivo.Enabled := Habilitar;
  btnSalvar.Enabled := Habilitar;
  btnCancelar.Enabled := Habilitar;
  
  btnNovo.Enabled := not Habilitar;
  btnEditar.Enabled := not Habilitar;
  btnExcluir.Enabled := not Habilitar;
  DBGrid.Enabled := not Habilitar;
end;

procedure TFormProdutos.CarregarProduto(Produto: TProduto);
begin
  edtId.Text := IntToStr(Produto.Id);
  edtDescricao.Text := Produto.Descricao;
  edtPreco.Text := FormatFloat('0.00', Produto.PrecoUnitario);
  edtEstoque.Text := IntToStr(Produto.Estoque);
  chkAtivo.Checked := Produto.Ativo;
end;

procedure TFormProdutos.btnNovoClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarCampos(True);
  FModoEdicao := False;
  edtDescricao.SetFocus;
end;

procedure TFormProdutos.btnEditarClick(Sender: TObject);
begin
  if DM.qryProdutos.IsEmpty then
  begin
    ShowMessage('Selecione um produto para editar');
    Exit;
  end;
  
  if Assigned(FProdutoAtual) then
    FProdutoAtual.Free;
    
  FProdutoAtual := FProdutoService.BuscarPorID(DM.qryProdutos.FieldByName('id').AsInteger);
  
  if Assigned(FProdutoAtual) then
  begin
    CarregarProduto(FProdutoAtual);
    HabilitarCampos(True);
    FModoEdicao := True;
    edtDescricao.SetFocus;
  end;
end;

procedure TFormProdutos.btnExcluirClick(Sender: TObject);
begin
  if DM.qryProdutos.IsEmpty then
  begin
    ShowMessage('Selecione um produto para excluir');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir este produto?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FProdutoService.Excluir(DM.qryProdutos.FieldByName('id').AsInteger);
      ShowMessage('Produto excluido com sucesso!');
      CarregarGrid;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TFormProdutos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormProdutos.btnFiltrarClick(Sender: TObject);
begin
  if Trim(edtFiltro.Text) = '' then
    CarregarGrid
  else
  begin
    DM.qryProdutos.Close;
    DM.qryProdutos.SQL.Clear;
    DM.qryProdutos.SQL.Add('SELECT id, descricao, preco_unitario, estoque, ativo FROM produtos');
    DM.qryProdutos.SQL.Add('WHERE UPPER(descricao) LIKE :descricao ORDER BY descricao');
    DM.qryProdutos.ParamByName('descricao').AsString := '%' + UpperCase(edtFiltro.Text) + '%';
    DM.qryProdutos.Open;
  end;
end;

procedure TFormProdutos.btnSalvarClick(Sender: TObject);
var
  Produto: TProduto;
begin
  try
    if FModoEdicao then
      Produto := FProdutoAtual
    else
      Produto := TProduto.Create;
      
    try
      Produto.Descricao := edtDescricao.Text;
      Produto.PrecoUnitario := StrToCurrDef(edtPreco.Text, 0);
      Produto.Estoque := StrToIntDef(edtEstoque.Text, 0);
      Produto.Ativo := chkAtivo.Checked;
      
      if FModoEdicao then
        FProdutoService.Alterar(Produto)
      else
        FProdutoService.Incluir(Produto);
        
      ShowMessage('Produto salvo com sucesso!');
      LimparCampos;
      HabilitarCampos(False);
      CarregarGrid;
    except
      on E: Exception do
      begin
        ShowMessage('Erro ao salvar: ' + E.Message);
        if not FModoEdicao then
          Produto.Free;
      end;
    end;
  finally
    if FModoEdicao and Assigned(FProdutoAtual) then
    begin
      FProdutoAtual.Free;
      FProdutoAtual := nil;
    end;
  end;
end;

procedure TFormProdutos.btnCancelarClick(Sender: TObject);
begin
  LimparCampos;
  HabilitarCampos(False);
  
  if Assigned(FProdutoAtual) then
  begin
    FProdutoAtual.Free;
    FProdutoAtual := nil;
  end;
end;

procedure TFormProdutos.DBGridDblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

end.
