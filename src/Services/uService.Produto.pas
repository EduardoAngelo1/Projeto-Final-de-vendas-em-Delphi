unit uService.Produto;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, uModelo.Produto, uDataModule;

type
  TProdutoService = class
  private
    FQuery: TFDQuery;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Incluir(Produto: TProduto): Boolean;
    function Alterar(Produto: TProduto): Boolean;
    function Excluir(Id: Integer): Boolean;
    function BuscarPorID(Id: Integer): TProduto;
    function ListarTodos: TList<TProduto>;
    function BuscarPorDescricao(Descricao: string): TList<TProduto>;
    function AtualizarEstoque(ProdutoId, Quantidade: Integer; Operacao: string): Boolean;
  end;

implementation

{ TProdutoService }

constructor TProdutoService.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := DM.FDConnection;
end;

destructor TProdutoService.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TProdutoService.Incluir(Produto: TProduto): Boolean;
begin
  Result := False;
  Produto.Validar;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('INSERT INTO produtos (descricao, preco_unitario, estoque, ativo)');
  FQuery.SQL.Add('VALUES (:descricao, :preco_unitario, :estoque, :ativo)');
  FQuery.SQL.Add('RETURNING id');
  
  FQuery.ParamByName('descricao').AsString := Produto.Descricao;
  FQuery.ParamByName('preco_unitario').AsCurrency := Produto.PrecoUnitario;
  FQuery.ParamByName('estoque').AsInteger := Produto.Estoque;
  FQuery.ParamByName('ativo').AsBoolean := Produto.Ativo;
  
  try
    FQuery.Open;
    Produto.Id := FQuery.FieldByName('id').AsInteger;
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao incluir produto: ' + E.Message);
  end;
end;

function TProdutoService.Alterar(Produto: TProduto): Boolean;
begin
  Result := False;
  Produto.Validar;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('UPDATE produtos SET');
  FQuery.SQL.Add('  descricao = :descricao,');
  FQuery.SQL.Add('  preco_unitario = :preco_unitario,');
  FQuery.SQL.Add('  estoque = :estoque,');
  FQuery.SQL.Add('  ativo = :ativo');
  FQuery.SQL.Add('WHERE id = :id');
  
  FQuery.ParamByName('id').AsInteger := Produto.Id;
  FQuery.ParamByName('descricao').AsString := Produto.Descricao;
  FQuery.ParamByName('preco_unitario').AsCurrency := Produto.PrecoUnitario;
  FQuery.ParamByName('estoque').AsInteger := Produto.Estoque;
  FQuery.ParamByName('ativo').AsBoolean := Produto.Ativo;
  
  try
    FQuery.ExecSQL;
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao alterar produto: ' + E.Message);
  end;
end;

function TProdutoService.Excluir(Id: Integer): Boolean;
begin
  Result := False;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('DELETE FROM produtos WHERE id = :id');
  FQuery.ParamByName('id').AsInteger := Id;
  
  try
    FQuery.ExecSQL;
    Result := True;
  except
    on E: Exception do
    begin
      if Pos('referenced from table', LowerCase(E.Message)) > 0 then
        raise Exception.Create('Nao e possivel excluir este produto pois ele possui vendas vinculadas.')
      else
        raise Exception.Create('Erro ao excluir produto: ' + E.Message);
    end;
  end;
end;

function TProdutoService.BuscarPorID(Id: Integer): TProduto;
begin
  Result := nil;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM produtos WHERE id = :id');
  FQuery.ParamByName('id').AsInteger := Id;
  FQuery.Open;
  
  if not FQuery.IsEmpty then
  begin
    Result := TProduto.Create;
    Result.Id := FQuery.FieldByName('id').AsInteger;
    Result.Descricao := FQuery.FieldByName('descricao').AsString;
    Result.PrecoUnitario := FQuery.FieldByName('preco_unitario').AsCurrency;
    Result.Estoque := FQuery.FieldByName('estoque').AsInteger;
    Result.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Result.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
  end;
end;

function TProdutoService.ListarTodos: TList<TProduto>;
var
  Produto: TProduto;
begin
  Result := TList<TProduto>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM produtos ORDER BY descricao');
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Produto := TProduto.Create;
    Produto.Id := FQuery.FieldByName('id').AsInteger;
    Produto.Descricao := FQuery.FieldByName('descricao').AsString;
    Produto.PrecoUnitario := FQuery.FieldByName('preco_unitario').AsCurrency;
    Produto.Estoque := FQuery.FieldByName('estoque').AsInteger;
    Produto.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Produto.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
    
    Result.Add(Produto);
    FQuery.Next;
  end;
end;

function TProdutoService.BuscarPorDescricao(Descricao: string): TList<TProduto>;
var
  Produto: TProduto;
begin
  Result := TList<TProduto>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM produtos');
  FQuery.SQL.Add('WHERE UPPER(descricao) LIKE :descricao');
  FQuery.SQL.Add('ORDER BY descricao');
  FQuery.ParamByName('descricao').AsString := '%' + UpperCase(Descricao) + '%';
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Produto := TProduto.Create;
    Produto.Id := FQuery.FieldByName('id').AsInteger;
    Produto.Descricao := FQuery.FieldByName('descricao').AsString;
    Produto.PrecoUnitario := FQuery.FieldByName('preco_unitario').AsCurrency;
    Produto.Estoque := FQuery.FieldByName('estoque').AsInteger;
    Produto.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Produto.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
    
    Result.Add(Produto);
    FQuery.Next;
  end;
end;

function TProdutoService.AtualizarEstoque(ProdutoId, Quantidade: Integer; Operacao: string): Boolean;
var
  SQL: string;
begin
  Result := False;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  
  if UpperCase(Operacao) = 'BAIXAR' then
    SQL := 'UPDATE produtos SET estoque = estoque - :quantidade WHERE id = :id'
  else if UpperCase(Operacao) = 'DEVOLVER' then
    SQL := 'UPDATE produtos SET estoque = estoque + :quantidade WHERE id = :id'
  else
    raise Exception.Create('Operacao invalida. Use BAIXAR ou DEVOLVER');
    
  FQuery.SQL.Add(SQL);
  FQuery.ParamByName('id').AsInteger := ProdutoId;
  FQuery.ParamByName('quantidade').AsInteger := Quantidade;
  
  try
    FQuery.ExecSQL;
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao atualizar estoque: ' + E.Message);
  end;
end;

end.
