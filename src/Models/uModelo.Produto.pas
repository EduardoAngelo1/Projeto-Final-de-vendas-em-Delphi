unit uModelo.Produto;

interface

uses
  System.SysUtils;

type
  TProduto = class
  private
    FId: Integer;
    FDescricao: string;
    FPrecoUnitario: Currency;
    FEstoque: Integer;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Validar: Boolean;
    function TemEstoqueDisponivel(Quantidade: Integer): Boolean;
    procedure BaixarEstoque(Quantidade: Integer);
    procedure DevolverEstoque(Quantidade: Integer);
    
    property Id: Integer read FId write FId;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoUnitario: Currency read FPrecoUnitario write FPrecoUnitario;
    property Estoque: Integer read FEstoque write FEstoque;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
  end;

implementation

{ TProduto }

constructor TProduto.Create;
begin
  FId := 0;
  FAtivo := True;
  FEstoque := 0;
  FPrecoUnitario := 0;
  FDataCadastro := Now;
end;

destructor TProduto.Destroy;
begin
  inherited;
end;

function TProduto.Validar: Boolean;
begin
  Result := False;
  
  if Trim(FDescricao) = '' then
    raise Exception.Create('Descricao do produto e obrigatoria');

  if FPrecoUnitario <= 0 then
    raise Exception.Create('Preco unitario deve ser maior que zero');

  if FEstoque < 0 then
    raise Exception.Create('Estoque nao pode ser negativo');
    
  Result := True;
end;

function TProduto.TemEstoqueDisponivel(Quantidade: Integer): Boolean;
begin
  Result := FEstoque >= Quantidade;
end;

procedure TProduto.BaixarEstoque(Quantidade: Integer);
begin
  if not TemEstoqueDisponivel(Quantidade) then
    raise Exception.Create('Estoque insuficiente');
    
  FEstoque := FEstoque - Quantidade;
end;

procedure TProduto.DevolverEstoque(Quantidade: Integer);
begin
  FEstoque := FEstoque + Quantidade;
end;

end.
