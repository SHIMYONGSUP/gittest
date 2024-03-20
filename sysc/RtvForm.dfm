object fmRTV: TfmRTV
  Left = 244
  Top = 131
  Caption = 'RTV Info'
  ClientHeight = 313
  ClientWidth = 475
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #46027#50880#52404
  Font.Style = []
  FormStyle = fsMDIChild
  Scaled = False
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    475
    313)
  TextHeight = 13
  object Label4: TLabel
    Left = 246
    Top = 177
    Width = 42
    Height = 13
    Caption = 'Status'
  end
  object tcRtvNo: TTabControl
    Left = 0
    Top = 0
    Width = 475
    Height = 313
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'D2Coding'
    Font.Style = []
    OwnerDraw = True
    ParentFont = False
    TabOrder = 0
    Tabs.Strings = (
      'RTV #1'
      'RTV #2')
    TabIndex = 0
    OnChange = tcRtvNoChange
    OnDrawTab = tcRtvNoDrawTab
    ExplicitWidth = 471
    ExplicitHeight = 312
    DesignSize = (
      475
      313)
    object Label9: TLabel
      Left = 18
      Top = 177
      Width = 112
      Height = 15
      Caption = 'Current Position'
    end
    object Label96: TLabel
      Left = 249
      Top = 74
      Width = 28
      Height = 15
      Caption = 'Mode'
    end
    object Label97: TLabel
      Left = 18
      Top = 211
      Width = 35
      Height = 15
      Alignment = taRightJustify
      Caption = 'Error'
    end
    object Label98: TLabel
      Left = 249
      Top = 140
      Width = 35
      Height = 15
      Alignment = taRightJustify
      Caption = 'Exist'
    end
    object Label111: TLabel
      Left = 249
      Top = 106
      Width = 70
      Height = 15
      Caption = 'CommStatus'
    end
    object Label2: TLabel
      Left = 18
      Top = 74
      Width = 42
      Height = 15
      Caption = 'Enable'
    end
    object Label40: TLabel
      Left = 18
      Top = 281
      Width = 98
      Height = 15
      Caption = 'Error Sub Code'
    end
    object Label110: TLabel
      Left = 18
      Top = 106
      Width = 42
      Height = 15
      Caption = 'Status'
    end
    object Label1: TLabel
      Left = 18
      Top = 246
      Width = 70
      Height = 15
      Caption = 'Error Code'
    end
    object Label3: TLabel
      Left = 19
      Top = 140
      Width = 63
      Height = 15
      Alignment = taRightJustify
      Caption = 'Work Type'
    end
    object Label5: TLabel
      Left = 249
      Top = 177
      Width = 91
      Height = 15
      Alignment = taRightJustify
      Caption = 'Complete Flag'
    end
    object CheckBox1: TCheckBox
      Left = 18
      Top = 40
      Width = 128
      Height = 17
      Caption = 'Auto Refresh'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 0
    end
    object btnReset: TButton
      Tag = 1
      Left = 387
      Top = 265
      Width = 66
      Height = 35
      Caption = 'Reset'
      TabOrder = 1
      OnClick = btnUpdateClick
    end
    object btnUpdate: TButton
      Tag = 1
      Left = 249
      Top = 265
      Width = 66
      Height = 35
      Caption = 'Update'
      TabOrder = 2
      OnClick = btnUpdateClick
    end
    object edCurPos: TEdit
      Tag = 1
      Left = 158
      Top = 173
      Width = 67
      Height = 23
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentFont = False
      TabOrder = 3
    end
    object cbMode: TComboBox
      Left = 385
      Top = 68
      Width = 67
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Items.Strings = (
        'FALSE'
        'TRUE')
    end
    object cbCommStatus: TComboBox
      AlignWithMargins = True
      Left = 385
      Top = 102
      Width = 67
      Height = 23
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      Items.Strings = (
        'FALSE'
        'TRUE')
    end
    object cbError: TComboBox
      Left = 158
      Top = 207
      Width = 67
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      Items.Strings = (
        'FALSE'
        'TRUE')
    end
    object cbExist: TComboBox
      Left = 385
      Top = 137
      Width = 67
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      Items.Strings = (
        'FALSE'
        'TRUE')
    end
    object edSubErrcd: TEdit
      Tag = 7
      Left = 158
      Top = 277
      Width = 67
      Height = 23
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentFont = False
      TabOrder = 8
    end
    object edErrcd: TEdit
      Left = 158
      Top = 242
      Width = 67
      Height = 23
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentFont = False
      TabOrder = 9
    end
    object cbStatus: TComboBox
      AlignWithMargins = True
      Left = 158
      Top = 102
      Width = 67
      Height = 23
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
      Text = 'TRUE'
      Items.Strings = (
        'READY'
        'WORK')
    end
    object cbWorkType: TComboBox
      Left = 158
      Top = 137
      Width = 67
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 11
      Items.Strings = (
        'NONE'
        'MOVE'
        'LOAD'
        'UNLD'
        'TRAN'
        'HOME'
        'ONLI'
        'RSET'
        'STOP'
        'CLAR'
        'MNDR'
        'EMRY'
        'CPRS')
    end
    object cbEnable: TComboBox
      AlignWithMargins = True
      Left = 158
      Top = 67
      Width = 67
      Height = 23
      Anchors = [akLeft, akTop, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'D2Coding'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
      Text = 'READY'
      Items.Strings = (
        'TRUE'
        'FALSE')
    end
  end
  object cbCompleteFlag: TComboBox
    AlignWithMargins = True
    Left = 386
    Top = 173
    Width = 67
    Height = 23
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'TRUE'
    Items.Strings = (
      'TRUE'
      'FALSE')
  end
  object TimerDisplay: TTimer
    OnTimer = TimerDisplayTimer
    Left = 344
    Top = 8
  end
end
