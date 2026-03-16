program SistemaVendas;

uses
  Vcl.Forms,
  uFormPrincipal in 'src\Views\uFormPrincipal.pas' {FormPrincipal},
  uFormClientes in 'src\Views\uFormClientes.pas' {FormClientes},
  uFormProdutos in 'src\Views\uFormProdutos.pas' {FormProdutos},
  uFormVendas in 'src\Views\uFormVendas.pas' {FormVendas},
  uFormNovaVenda in 'src\Views\uFormNovaVenda.pas' {FormNovaVenda},
  uDataModule in 'src\DataModule\uDataModule.pas' {DM: TDataModule},
  uModelo.Cliente in 'src\Models\uModelo.Cliente.pas',
  uModelo.Produto in 'src\Models\uModelo.Produto.pas',
  uModelo.Venda in 'src\Models\uModelo.Venda.pas',
  uService.Cliente in 'src\Services\uService.Cliente.pas',
  uService.Produto in 'src\Services\uService.Produto.pas',
  uService.Venda in 'src\Services\uService.Venda.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
