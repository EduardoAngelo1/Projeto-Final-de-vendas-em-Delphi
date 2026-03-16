unit uDataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    qryClientes: TFDQuery;
    qryProdutos: TFDQuery;
    qryVendas: TFDQuery;
    qryAux: TFDQuery;
    dsClientes: TDataSource;
    dsProdutos: TDataSource;
    dsVendas: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure ConfigurarConexao;
  public
    function TestarConexao: Boolean;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  ConfigurarConexao;
end;

procedure TDM.ConfigurarConexao;
begin
  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=PG');
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('Port=5433');
  FDConnection.Params.Add('Database=loja_nexus');
  FDConnection.Params.Add('User_Name=postgres');
  FDConnection.Params.Add('Password=1234');
  FDConnection.LoginPrompt := False;
  
  try
    FDConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Erro ao conectar ao banco de dados: ' + E.Message);
  end;
end;

function TDM.TestarConexao: Boolean;
begin
  Result := FDConnection.Connected;
end;

end.
