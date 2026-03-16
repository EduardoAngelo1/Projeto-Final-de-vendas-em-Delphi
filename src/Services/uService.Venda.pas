unit uService.Venda;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, uModelo.Venda, uModelo.Produto,
  uService.Produto, uDataModule;

type
  TVendaService = class
  private
    FQuery: TFDQuery;
    FProdutoService: TProdutoService;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Incluir(Venda: TVenda): Boolean;
    function Excluir(Id: Integer): Boolean;
    function BuscarPorID(Id: Integer): TVenda;
    function ListarTodos: TList<TVenda>;
    function ListarPorCliente(ClienteId: Integer): TList<TVenda>;
  end;

implementation

{ TVendaService }

constructor TVendaService.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := DM.FDConnection;
  FProdutoService := TProdutoService.Create;
end;

destructor TVendaService.Destroy;
begin
  FProdutoService.Free;
  FQuery.Free;
  inherited;
end;

function TVendaService.Incluir(Venda: TVenda): Boolean;
var
  Produto: TProduto;
begin
  Result := False;
  Venda.Validar;
  
  Produto := FProdutoService.BuscarPorID(Venda.ProdutoId);
  try
    if not Assigned(Produto) then
      raise Exception.Create('Produto nao encontrado');
      
    if not Produto.TemEstoqueDisponivel(Venda.Quantidade) then
      raise Exception.Create('Estoque insuficiente. Disponível: ' + IntToStr(Produto.Estoque));
    
    Venda.CalcularTotal;
    
    DM.FDConnection.StartTransaction;
    try
      FQuery.Close;
      FQuery.SQL.Clear;
      FQuery.SQL.Add('INSERT INTO vendas (cliente_id, produto_id, quantidade, valor_unitario, valor_total, data_venda)');
      FQuery.SQL.Add('VALUES (:cliente_id, :produto_id, :quantidade, :valor_unitario, :valor_total, :data_venda)');
      FQuery.SQL.Add('RETURNING id');
      
      FQuery.ParamByName('cliente_id').AsInteger := Venda.ClienteId;
      FQuery.ParamByName('produto_id').AsInteger := Venda.ProdutoId;
      FQuery.ParamByName('quantidade').AsInteger := Venda.Quantidade;
      FQuery.ParamByName('valor_unitario').AsCurrency := Venda.ValorUnitario;
      FQuery.ParamByName('valor_total').AsCurrency := Venda.ValorTotal;
      FQuery.ParamByName('data_venda').AsDateTime := Venda.DataVenda;
      
      FQuery.Open;
      Venda.Id := FQuery.FieldByName('id').AsInteger;
      
      FProdutoService.AtualizarEstoque(Venda.ProdutoId, Venda.Quantidade, 'BAIXAR');
      
      DM.FDConnection.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        DM.FDConnection.Rollback;
        raise Exception.Create('Erro ao incluir venda: ' + E.Message);
      end;
    end;
  finally
    Produto.Free;
  end;
end;

function TVendaService.Excluir(Id: Integer): Boolean;
var
  Venda: TVenda;
begin
  Result := False;
  
  Venda := BuscarPorID(Id);
  if not Assigned(Venda) then
    raise Exception.Create('Venda nao encontrada');
    
  try
    DM.FDConnection.StartTransaction;
    try
      FQuery.Close;
      FQuery.SQL.Clear;
      FQuery.SQL.Add('DELETE FROM vendas WHERE id = :id');
      FQuery.ParamByName('id').AsInteger := Id;
      FQuery.ExecSQL;
      
      FProdutoService.AtualizarEstoque(Venda.ProdutoId, Venda.Quantidade, 'DEVOLVER');
      
      DM.FDConnection.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        DM.FDConnection.Rollback;
        raise Exception.Create('Erro ao excluir venda: ' + E.Message);
      end;
    end;
  finally
    Venda.Free;
  end;
end;

function TVendaService.BuscarPorID(Id: Integer): TVenda;
begin
  Result := nil;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT v.*, c.nome as cliente_nome, p.descricao as produto_descricao');
  FQuery.SQL.Add('FROM vendas v');
  FQuery.SQL.Add('INNER JOIN clientes c ON c.id = v.cliente_id');
  FQuery.SQL.Add('INNER JOIN produtos p ON p.id = v.produto_id');
  FQuery.SQL.Add('WHERE v.id = :id');
  FQuery.ParamByName('id').AsInteger := Id;
  FQuery.Open;
  
  if not FQuery.IsEmpty then
  begin
    Result := TVenda.Create;
    Result.Id := FQuery.FieldByName('id').AsInteger;
    Result.ClienteId := FQuery.FieldByName('cliente_id').AsInteger;
    Result.ProdutoId := FQuery.FieldByName('produto_id').AsInteger;
    Result.Quantidade := FQuery.FieldByName('quantidade').AsInteger;
    Result.ValorUnitario := FQuery.FieldByName('valor_unitario').AsCurrency;
    Result.ValorTotal := FQuery.FieldByName('valor_total').AsCurrency;
    Result.DataVenda := FQuery.FieldByName('data_venda').AsDateTime;
    Result.ClienteNome := FQuery.FieldByName('cliente_nome').AsString;
    Result.ProdutoDescricao := FQuery.FieldByName('produto_descricao').AsString;
  end;
end;

function TVendaService.ListarTodos: TList<TVenda>;
var
  Venda: TVenda;
begin
  Result := TList<TVenda>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT v.*, c.nome as cliente_nome, p.descricao as produto_descricao');
  FQuery.SQL.Add('FROM vendas v');
  FQuery.SQL.Add('INNER JOIN clientes c ON c.id = v.cliente_id');
  FQuery.SQL.Add('INNER JOIN produtos p ON p.id = v.produto_id');
  FQuery.SQL.Add('ORDER BY v.data_venda DESC');
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Venda := TVenda.Create;
    Venda.Id := FQuery.FieldByName('id').AsInteger;
    Venda.ClienteId := FQuery.FieldByName('cliente_id').AsInteger;
    Venda.ProdutoId := FQuery.FieldByName('produto_id').AsInteger;
    Venda.Quantidade := FQuery.FieldByName('quantidade').AsInteger;
    Venda.ValorUnitario := FQuery.FieldByName('valor_unitario').AsCurrency;
    Venda.ValorTotal := FQuery.FieldByName('valor_total').AsCurrency;
    Venda.DataVenda := FQuery.FieldByName('data_venda').AsDateTime;
    Venda.ClienteNome := FQuery.FieldByName('cliente_nome').AsString;
    Venda.ProdutoDescricao := FQuery.FieldByName('produto_descricao').AsString;
    
    Result.Add(Venda);
    FQuery.Next;
  end;
end;

function TVendaService.ListarPorCliente(ClienteId: Integer): TList<TVenda>;
var
  Venda: TVenda;
begin
  Result := TList<TVenda>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT v.*, c.nome as cliente_nome, p.descricao as produto_descricao');
  FQuery.SQL.Add('FROM vendas v');
  FQuery.SQL.Add('INNER JOIN clientes c ON c.id = v.cliente_id');
  FQuery.SQL.Add('INNER JOIN produtos p ON p.id = v.produto_id');
  FQuery.SQL.Add('WHERE v.cliente_id = :cliente_id');
  FQuery.SQL.Add('ORDER BY v.data_venda DESC');
  FQuery.ParamByName('cliente_id').AsInteger := ClienteId;
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Venda := TVenda.Create;
    Venda.Id := FQuery.FieldByName('id').AsInteger;
    Venda.ClienteId := FQuery.FieldByName('cliente_id').AsInteger;
    Venda.ProdutoId := FQuery.FieldByName('produto_id').AsInteger;
    Venda.Quantidade := FQuery.FieldByName('quantidade').AsInteger;
    Venda.ValorUnitario := FQuery.FieldByName('valor_unitario').AsCurrency;
    Venda.ValorTotal := FQuery.FieldByName('valor_total').AsCurrency;
    Venda.DataVenda := FQuery.FieldByName('data_venda').AsDateTime;
    Venda.ClienteNome := FQuery.FieldByName('cliente_nome').AsString;
    Venda.ProdutoDescricao := FQuery.FieldByName('produto_descricao').AsString;
    
    Result.Add(Venda);
    FQuery.Next;
  end;
end;

end.
