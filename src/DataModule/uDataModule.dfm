object DM: TDM
  OnCreate = DataModuleCreate
  Height = 500
  Width = 750
  PixelsPerInch = 120
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=loja_nexus'
      'User_Name=postgres'
      'Password=1234'
      'Server=localhost'
      'Port=5433'
      'DriverID=PG')
    LoginPrompt = False
    Left = 60
    Top = 30
  end
  object FDPhysPgDriverLink: TFDPhysPgDriverLink
    VendorLib = 'C:\Program Files (x86)\PostgreSQL\psqlODBC\bin\libpq.dll'
    Left = 60
    Top = 110
  end
  object qryClientes: TFDQuery
    Connection = FDConnection
    Left = 210
    Top = 30
  end
  object qryProdutos: TFDQuery
    Connection = FDConnection
    Left = 210
    Top = 110
  end
  object qryVendas: TFDQuery
    Connection = FDConnection
    Left = 210
    Top = 190
  end
  object qryAux: TFDQuery
    Connection = FDConnection
    Left = 210
    Top = 270
  end
  object dsClientes: TDataSource
    DataSet = qryClientes
    Left = 350
    Top = 30
  end
  object dsProdutos: TDataSource
    DataSet = qryProdutos
    Left = 350
    Top = 110
  end
  object dsVendas: TDataSource
    DataSet = qryVendas
    Left = 350
    Top = 190
  end
end
