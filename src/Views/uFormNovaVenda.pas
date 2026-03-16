unit uFormNovaVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.DBCtrls, System.Generics.Collections,
  uModelo.Venda, uModelo.Produto, uService.Venda, uService.Produto;

type
  TFormNovaVenda = class(TForm)
    pnlPrincipal: TPanel;
    lblCliente: TLabel;
    edtCliente: TEdit;
    lblProduto: TLabel;
    cmbProduto: TComboBox;
    lblQuantidade: TLabel;
    edtQuantidade: TEdit;
    lblValorUnitario: TLabel;
    edtValorUnitario: TEdit;
    lblValorTotal: TLabel;
    edtValorTotal: TEdit;
    lblEstoqueDisponivel: TLabel;
    edtEstoqueDisponivel: TEdit;
    btnConfirmar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbProdutoChange(Sender: TObject);
    procedure edtQuantidadeChange(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FVendaService: TVendaService;
    FProdutoService: TProdutoService;
    FClienteId: Integer;
    FClienteNome: string;
    FProdutos: TList<TProduto>;
    procedure CarregarProdutos;
    procedure CalcularTotal;
    function GetProdutoSelecionado: TProduto;
  public
    property ClienteId: Integer read FClienteId write FClienteId;
    property ClienteNome: string read FClienteNome write FClienteNome;
  end;

var
  FormNovaVenda: TFormNovaVenda;

implementation

{$R *.dfm}

procedure TFormNovaVenda.FormCreate(Sender: TObject);
begin
  FVendaService := TVendaService.Create;
  FProdutoService := TProdutoService.Create;
  FProdutos := TList<TProduto>.Create;
  CarregarProdutos;
end;

procedure TFormNovaVenda.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(FProdutos) then
  begin
    for I := 0 to FProdutos.Count - 1 do
      FProdutos[I].Free;
    FProdutos.Free;
  end;
  FProdutoService.Free;
  FVendaService.Free;
end;

procedure TFormNovaVenda.CarregarProdutos;
var
  Produto: TProduto;
  I: Integer;
begin
  FProdutos := FProdutoService.ListarTodos;
  
  cmbProduto.Clear;
  cmbProduto.Items.Add('Selecione um produto...');
  
  if Assigned(FProdutos) then
  begin
    for I := 0 to FProdutos.Count - 1 do
    begin
      Produto := FProdutos[I];
      if Produto.Ativo and (Produto.Estoque > 0) then
        cmbProduto.Items.AddObject(
          Format('%s - R$ %.2f (Estoque: %d)', 
                 [Produto.Descricao, Produto.PrecoUnitario, Produto.Estoque]),
          TObject(Produto.Id)
        );
    end;
  end;
  
  cmbProduto.ItemIndex := 0;
  edtQuantidade.Text := '1';
end;

procedure TFormNovaVenda.FormShow(Sender: TObject);
begin
  edtCliente.Text := FClienteNome;
end;

function TFormNovaVenda.GetProdutoSelecionado: TProduto;
var
  ProdutoId: Integer;
  I: Integer;
begin
  Result := nil;
  
  if (cmbProduto.ItemIndex <= 0) or (cmbProduto.Items.Objects[cmbProduto.ItemIndex] = nil) then
    Exit;
    
  ProdutoId := Integer(cmbProduto.Items.Objects[cmbProduto.ItemIndex]);
  
  if Assigned(FProdutos) then
  begin
    for I := 0 to FProdutos.Count - 1 do
    begin
      if FProdutos[I].Id = ProdutoId then
      begin
        Result := FProdutos[I];
        Break;
      end;
    end;
  end;
end;

procedure TFormNovaVenda.cmbProdutoChange(Sender: TObject);
var
  Produto: TProduto;
begin
  Produto := GetProdutoSelecionado;
  
  if Assigned(Produto) then
  begin
    edtValorUnitario.Text := FormatFloat('0.00', Produto.PrecoUnitario);
    edtEstoqueDisponivel.Text := IntToStr(Produto.Estoque);
    CalcularTotal;
  end
  else
  begin
    edtValorUnitario.Clear;
    edtEstoqueDisponivel.Clear;
    edtValorTotal.Clear;
  end;
end;

procedure TFormNovaVenda.edtQuantidadeChange(Sender: TObject);
begin
  CalcularTotal;
end;

procedure TFormNovaVenda.CalcularTotal;
var
  Quantidade: Integer;
  ValorUnitario, ValorTotal: Currency;
begin
  Quantidade := StrToIntDef(edtQuantidade.Text, 0);
  ValorUnitario := StrToCurrDef(edtValorUnitario.Text, 0);
  ValorTotal := Quantidade * ValorUnitario;
  
  edtValorTotal.Text := FormatFloat('0.00', ValorTotal);
end;

procedure TFormNovaVenda.btnConfirmarClick(Sender: TObject);
var
  Venda: TVenda;
  Produto: TProduto;
  Quantidade: Integer;
begin
  Produto := GetProdutoSelecionado;
  
  if not Assigned(Produto) then
  begin
    ShowMessage('Selecione um produto');
    Exit;
  end;
  
  Quantidade := StrToIntDef(edtQuantidade.Text, 0);
  
  if Quantidade <= 0 then
  begin
    ShowMessage('Quantidade deve ser maior que zero');
    Exit;
  end;
  
  if Quantidade > Produto.Estoque then
  begin
    ShowMessage(Format('Estoque insuficiente. Disponível: %d', [Produto.Estoque]));
    Exit;
  end;
  
  Venda := TVenda.Create;
  try
    Venda.ClienteId := FClienteId;
    Venda.ProdutoId := Produto.Id;
    Venda.Quantidade := Quantidade;
    Venda.ValorUnitario := Produto.PrecoUnitario;
    Venda.DataVenda := Now;
    
    try
      FVendaService.Incluir(Venda);
      ModalResult := mrOk;
    except
      on E: Exception do
        ShowMessage('Erro ao realizar venda: ' + E.Message);
    end;
  finally
    Venda.Free;
  end;
end;

procedure TFormNovaVenda.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
