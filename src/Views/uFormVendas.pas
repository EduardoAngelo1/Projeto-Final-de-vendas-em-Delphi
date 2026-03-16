unit uFormVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Comp.Client,
  System.Generics.Collections, uModelo.Venda, uService.Venda;

type
  TFormVendas = class(TForm)
    pnlTop: TPanel;
    pnlMaster: TPanel;
    pnlDetail: TPanel;
    lblMaster: TLabel;
    DBGridClientes: TDBGrid;
    lblDetail: TLabel;
    DBGridVendas: TDBGrid;
    btnNovaVenda: TButton;
    btnExcluirVenda: TButton;
    btnFechar: TButton;
    btnAtualizar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBGridClientesCellClick(Column: TColumn);
    procedure btnNovaVendaClick(Sender: TObject);
    procedure btnExcluirVendaClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
  private
    FVendaService: TVendaService;
    FClienteIdSelecionado: Integer;
    procedure CarregarClientes;
    procedure CarregarVendasCliente(ClienteId: Integer);
  public
  end;

var
  FormVendas: TFormVendas;

implementation

uses
  uDataModule, uFormNovaVenda;

{$R *.dfm}

procedure TFormVendas.FormCreate(Sender: TObject);
begin
  FVendaService := TVendaService.Create;
  FClienteIdSelecionado := 0;
  CarregarClientes;
end;

procedure TFormVendas.FormDestroy(Sender: TObject);
begin
  FVendaService.Free;
end;

procedure TFormVendas.CarregarClientes;
begin
  DM.qryClientes.Close;
  DM.qryClientes.SQL.Clear;
  DM.qryClientes.SQL.Add('SELECT id, nome, cpf, telefone FROM clientes WHERE ativo = true ORDER BY nome');
  DM.qryClientes.Open;
end;

procedure TFormVendas.CarregarVendasCliente(ClienteId: Integer);
begin
  DM.qryVendas.Close;
  DM.qryVendas.SQL.Clear;
  DM.qryVendas.SQL.Add('SELECT v.id, p.descricao as produto, v.quantidade,');
  DM.qryVendas.SQL.Add('       v.valor_unitario, v.valor_total, v.data_venda');
  DM.qryVendas.SQL.Add('FROM vendas v');
  DM.qryVendas.SQL.Add('INNER JOIN produtos p ON p.id = v.produto_id');
  DM.qryVendas.SQL.Add('WHERE v.cliente_id = :cliente_id');
  DM.qryVendas.SQL.Add('ORDER BY v.data_venda DESC');
  DM.qryVendas.ParamByName('cliente_id').AsInteger := ClienteId;
  DM.qryVendas.Open;
end;

procedure TFormVendas.DBGridClientesCellClick(Column: TColumn);
begin
  if not DM.qryClientes.IsEmpty then
  begin
    FClienteIdSelecionado := DM.qryClientes.FieldByName('id').AsInteger;
    CarregarVendasCliente(FClienteIdSelecionado);
  end;
end;

procedure TFormVendas.btnNovaVendaClick(Sender: TObject);
var
  Form: TFormNovaVenda;
begin
  if FClienteIdSelecionado = 0 then
  begin
    ShowMessage('Selecione um cliente primeiro');
    Exit;
  end;
  
  Form := TFormNovaVenda.Create(Self);
  try
    Form.ClienteId := FClienteIdSelecionado;
    Form.ClienteNome := DM.qryClientes.FieldByName('nome').AsString;
    
    if Form.ShowModal = mrOk then
    begin
      CarregarVendasCliente(FClienteIdSelecionado);
      ShowMessage('Venda realizada com sucesso!');
    end;
  finally
    Form.Free;
  end;
end;

procedure TFormVendas.btnExcluirVendaClick(Sender: TObject);
begin
  if DM.qryVendas.IsEmpty then
  begin
    ShowMessage('Selecione uma venda para excluir');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente excluir esta venda? O estoque sera devolvido.',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FVendaService.Excluir(DM.qryVendas.FieldByName('id').AsInteger);
      ShowMessage('Venda excluida com sucesso!');
      CarregarVendasCliente(FClienteIdSelecionado);
    except
      on E: Exception do
        ShowMessage('Erro ao excluir venda: ' + E.Message);
    end;
  end;
end;

procedure TFormVendas.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormVendas.btnAtualizarClick(Sender: TObject);
begin
  CarregarClientes;
  if FClienteIdSelecionado > 0 then
    CarregarVendasCliente(FClienteIdSelecionado);
end;

end.
