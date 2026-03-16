unit uService.Cliente;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, uModelo.Cliente, uDataModule;

type
  TClienteService = class
  private
    FQuery: TFDQuery;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Incluir(Cliente: TCliente): Boolean;
    function Alterar(Cliente: TCliente): Boolean;
    function Excluir(Id: Integer): Boolean;
    function BuscarPorID(Id: Integer): TCliente;
    function ListarTodos: TList<TCliente>;
    function BuscarPorNome(Nome: string): TList<TCliente>;
    function PossuiVendas(ClienteId: Integer): Boolean;
  end;

implementation

{ TClienteService }

constructor TClienteService.Create;
begin
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := DM.FDConnection;
end;

destructor TClienteService.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TClienteService.Incluir(Cliente: TCliente): Boolean;
begin
  Result := False;
  Cliente.Validar;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('INSERT INTO clientes (nome, cpf, telefone, email, endereco, ativo)');
  FQuery.SQL.Add('VALUES (:nome, :cpf, :telefone, :email, :endereco, :ativo)');
  FQuery.SQL.Add('RETURNING id');
  
  FQuery.ParamByName('nome').AsString := Cliente.Nome;
  FQuery.ParamByName('cpf').AsString := Cliente.CPF;
  FQuery.ParamByName('telefone').AsString := Cliente.Telefone;
  FQuery.ParamByName('email').AsString := Cliente.Email;
  FQuery.ParamByName('endereco').AsString := Cliente.Endereco;
  FQuery.ParamByName('ativo').AsBoolean := Cliente.Ativo;
  
  try
    FQuery.Open;
    Cliente.Id := FQuery.FieldByName('id').AsInteger;
    Result := True;
  except
    on E: Exception do
    begin
      if Pos('duplicate key', LowerCase(E.Message)) > 0 then
        raise Exception.Create('CPF ja cadastrado. Informe um CPF diferente.')
      else
        raise Exception.Create('Erro ao incluir cliente: ' + E.Message);
    end;
  end;
end;

function TClienteService.Alterar(Cliente: TCliente): Boolean;
begin
  Result := False;
  Cliente.Validar;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('UPDATE clientes SET');
  FQuery.SQL.Add('  nome = :nome,');
  FQuery.SQL.Add('  cpf = :cpf,');
  FQuery.SQL.Add('  telefone = :telefone,');
  FQuery.SQL.Add('  email = :email,');
  FQuery.SQL.Add('  endereco = :endereco,');
  FQuery.SQL.Add('  ativo = :ativo');
  FQuery.SQL.Add('WHERE id = :id');
  
  FQuery.ParamByName('id').AsInteger := Cliente.Id;
  FQuery.ParamByName('nome').AsString := Cliente.Nome;
  FQuery.ParamByName('cpf').AsString := Cliente.CPF;
  FQuery.ParamByName('telefone').AsString := Cliente.Telefone;
  FQuery.ParamByName('email').AsString := Cliente.Email;
  FQuery.ParamByName('endereco').AsString := Cliente.Endereco;
  FQuery.ParamByName('ativo').AsBoolean := Cliente.Ativo;
  
  try
    FQuery.ExecSQL;
    Result := True;
  except
    on E: Exception do
    begin
      if Pos('duplicate key', LowerCase(E.Message)) > 0 then
        raise Exception.Create('CPF ja cadastrado. Informe um CPF diferente.')
      else
        raise Exception.Create('Erro ao alterar cliente: ' + E.Message);
    end;
  end;
end;

function TClienteService.Excluir(Id: Integer): Boolean;
begin
  Result := False;

  if PossuiVendas(Id) then
    raise Exception.Create('Nao e possivel excluir cliente com vendas cadastradas');
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('DELETE FROM clientes WHERE id = :id');
  FQuery.ParamByName('id').AsInteger := Id;
  
  try
    FQuery.ExecSQL;
    Result := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao excluir cliente: ' + E.Message);
  end;
end;

function TClienteService.BuscarPorID(Id: Integer): TCliente;
begin
  Result := nil;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM clientes WHERE id = :id');
  FQuery.ParamByName('id').AsInteger := Id;
  FQuery.Open;
  
  if not FQuery.IsEmpty then
  begin
    Result := TCliente.Create;
    Result.Id := FQuery.FieldByName('id').AsInteger;
    Result.Nome := FQuery.FieldByName('nome').AsString;
    Result.CPF := FQuery.FieldByName('cpf').AsString;
    Result.Telefone := FQuery.FieldByName('telefone').AsString;
    Result.Email := FQuery.FieldByName('email').AsString;
    Result.Endereco := FQuery.FieldByName('endereco').AsString;
    Result.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Result.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
  end;
end;

function TClienteService.ListarTodos: TList<TCliente>;
var
  Cliente: TCliente;
begin
  Result := TList<TCliente>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM clientes ORDER BY nome');
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Cliente := TCliente.Create;
    Cliente.Id := FQuery.FieldByName('id').AsInteger;
    Cliente.Nome := FQuery.FieldByName('nome').AsString;
    Cliente.CPF := FQuery.FieldByName('cpf').AsString;
    Cliente.Telefone := FQuery.FieldByName('telefone').AsString;
    Cliente.Email := FQuery.FieldByName('email').AsString;
    Cliente.Endereco := FQuery.FieldByName('endereco').AsString;
    Cliente.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Cliente.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
    
    Result.Add(Cliente);
    FQuery.Next;
  end;
end;

function TClienteService.BuscarPorNome(Nome: string): TList<TCliente>;
var
  Cliente: TCliente;
begin
  Result := TList<TCliente>.Create;
  
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM clientes');
  FQuery.SQL.Add('WHERE UPPER(nome) LIKE :nome');
  FQuery.SQL.Add('ORDER BY nome');
  FQuery.ParamByName('nome').AsString := '%' + UpperCase(Nome) + '%';
  FQuery.Open;
  
  while not FQuery.Eof do
  begin
    Cliente := TCliente.Create;
    Cliente.Id := FQuery.FieldByName('id').AsInteger;
    Cliente.Nome := FQuery.FieldByName('nome').AsString;
    Cliente.CPF := FQuery.FieldByName('cpf').AsString;
    Cliente.Telefone := FQuery.FieldByName('telefone').AsString;
    Cliente.Email := FQuery.FieldByName('email').AsString;
    Cliente.Endereco := FQuery.FieldByName('endereco').AsString;
    Cliente.Ativo := FQuery.FieldByName('ativo').AsBoolean;
    Cliente.DataCadastro := FQuery.FieldByName('data_cadastro').AsDateTime;
    
    Result.Add(Cliente);
    FQuery.Next;
  end;
end;

function TClienteService.PossuiVendas(ClienteId: Integer): Boolean;
begin
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT COUNT(*) as total FROM vendas WHERE cliente_id = :cliente_id');
  FQuery.ParamByName('cliente_id').AsInteger := ClienteId;
  FQuery.Open;
  
  Result := FQuery.FieldByName('total').AsInteger > 0;
end;

end.
