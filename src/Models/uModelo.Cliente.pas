unit uModelo.Cliente;

interface

uses
  System.SysUtils;

type
  TCliente = class
  private
    FId: Integer;
    FNome: string;
    FCPF: string;
    FTelefone: string;
    FEmail: string;
    FEndereco: string;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Validar: Boolean;
    function ValidarCPF: Boolean;
    
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property CPF: string read FCPF write FCPF;
    property Telefone: string read FTelefone write FTelefone;
    property Email: string read FEmail write FEmail;
    property Endereco: string read FEndereco write FEndereco;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
  end;

implementation

{ TCliente }

constructor TCliente.Create;
begin
  FId := 0;
  FAtivo := True;
  FDataCadastro := Now;
end;

destructor TCliente.Destroy;
begin
  inherited;
end;

function TCliente.Validar: Boolean;
begin
  Result := False;
  
  if Trim(FNome) = '' then
    raise Exception.Create('Nome do cliente e obrigatorio');
    
  if Trim(FCPF) = '' then
    raise Exception.Create('CPF do cliente e obrigatorio');

  if not ValidarCPF then
    raise Exception.Create('CPF invalido (deve conter 11 digitos)');
    
  Result := True;
end;

function TCliente.ValidarCPF: Boolean;
var
  CPFLimpo: string;
  i: Integer;
begin
  CPFLimpo := '';
  for i := 1 to Length(FCPF) do
    if CharInSet(FCPF[i], ['0'..'9']) then
      CPFLimpo := CPFLimpo + FCPF[i];

  Result := Length(CPFLimpo) = 11;
end;

end.
