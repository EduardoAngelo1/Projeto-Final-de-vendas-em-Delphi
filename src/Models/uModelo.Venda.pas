unit uModelo.Venda;

interface

uses
  System.SysUtils;

type
  TVenda = class
  private
    FId: Integer;
    FClienteId: Integer;
    FProdutoId: Integer;
    FQuantidade: Integer;
    FValorUnitario: Currency;
    FValorTotal: Currency;
    FDataVenda: TDateTime;
    FClienteNome: string;
    FProdutoDescricao: string;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Validar: Boolean;
    procedure CalcularTotal;
    
    property Id: Integer read FId write FId;
    property ClienteId: Integer read FClienteId write FClienteId;
    property ProdutoId: Integer read FProdutoId write FProdutoId;
    property Quantidade: Integer read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property DataVenda: TDateTime read FDataVenda write FDataVenda;
    property ClienteNome: string read FClienteNome write FClienteNome;
    property ProdutoDescricao: string read FProdutoDescricao write FProdutoDescricao;
  end;

implementation

{ TVenda }

constructor TVenda.Create;
begin
  FId := 0;
  FClienteId := 0;
  FProdutoId := 0;
  FQuantidade := 1;
  FValorUnitario := 0;
  FValorTotal := 0;
  FDataVenda := Now;
end;

destructor TVenda.Destroy;
begin
  inherited;
end;

function TVenda.Validar: Boolean;
begin
  Result := False;
  
  if FClienteId <= 0 then
    raise Exception.Create('Cliente deve ser selecionado');
    
  if FProdutoId <= 0 then
    raise Exception.Create('Produto deve ser selecionado');
    
  if FQuantidade <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero');
    
  if FValorUnitario <= 0 then
    raise Exception.Create('Valor unitario deve ser maior que zero');
    
  Result := True;
end;

procedure TVenda.CalcularTotal;
begin
  FValorTotal := FQuantidade * FValorUnitario;
end;

end.
