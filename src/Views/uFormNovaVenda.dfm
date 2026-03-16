object FormNovaVenda: TFormNovaVenda
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Nova Venda'
  ClientHeight = 350
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  OnDestroy = FormDestroy
  TextHeight = 13
  object pnlPrincipal: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 350
    Align = alClient
    TabOrder = 0
    object lblCliente: TLabel
      Left = 24
      Top = 24
      Width = 37
      Height = 13
      Caption = 'Cliente:'
    end
    object lblProduto: TLabel
      Left = 24
      Top = 72
      Width = 42
      Height = 13
      Caption = 'Produto:'
    end
    object lblQuantidade: TLabel
      Left = 24
      Top = 120
      Width = 60
      Height = 13
      Caption = 'Quantidade:'
    end
    object lblValorUnitario: TLabel
      Left = 24
      Top = 168
      Width = 68
      Height = 13
      Caption = 'Valor Unit'#225'rio:'
    end
    object lblValorTotal: TLabel
      Left = 24
      Top = 216
      Width = 55
      Height = 13
      Caption = 'Valor Total:'
    end
    object lblEstoqueDisponivel: TLabel
      Left = 280
      Top = 120
      Width = 94
      Height = 13
      Caption = 'Estoque Dispon'#237'vel:'
    end
    object edtCliente: TEdit
      Left = 24
      Top = 40
      Width = 450
      Height = 21
      Enabled = False
      TabOrder = 0
    end
    object cmbProduto: TComboBox
      Left = 24
      Top = 88
      Width = 450
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = cmbProdutoChange
    end
    object edtQuantidade: TEdit
      Left = 24
      Top = 136
      Width = 105
      Height = 21
      TabOrder = 2
      OnChange = edtQuantidadeChange
    end
    object edtValorUnitario: TEdit
      Left = 24
      Top = 184
      Width = 200
      Height = 21
      Enabled = False
      TabOrder = 3
    end
    object edtValorTotal: TEdit
      Left = 24
      Top = 232
      Width = 200
      Height = 21
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
    end
    object edtEstoqueDisponivel: TEdit
      Left = 280
      Top = 139
      Width = 105
      Height = 21
      Enabled = False
      TabOrder = 5
    end
    object btnConfirmar: TButton
      Left = 24
      Top = 280
      Width = 120
      Height = 35
      Caption = 'Confirmar'
      TabOrder = 6
      OnClick = btnConfirmarClick
    end
    object btnCancelar: TButton
      Left = 150
      Top = 280
      Width = 120
      Height = 35
      Caption = 'Cancelar'
      TabOrder = 7
      OnClick = btnCancelarClick
    end
  end
end
