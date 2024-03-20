object fmRtvOrderBufferUpdate: TfmRtvOrderBufferUpdate
  Left = 0
  Top = 0
  Caption = 'fmRtvOrderBufferUpdate'
  ClientHeight = 342
  ClientWidth = 942
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    942
    342)
  TextHeight = 13
  object Label3: TLabel
    Left = 762
    Top = 41
    Width = 48
    Height = 18
    Caption = 'Rtv No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 762
    Top = 73
    Width = 48
    Height = 18
    Caption = 'Row No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object btnOrderUpdate2: TSpeedButton
    Tag = 1
    Left = 867
    Top = 3
    Width = 67
    Height = 28
    Caption = 'Save'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    OnClick = btnOrderUpdate2Click
  end
  object Label110: TLabel
    Left = 510
    Top = 41
    Width = 64
    Height = 18
    Caption = 'Priority'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 510
    Top = 73
    Width = 48
    Height = 18
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 277
    Top = 41
    Width = 32
    Height = 18
    Caption = 'From'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 277
    Top = 74
    Width = 16
    Height = 18
    Caption = 'To'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label17: TLabel
    Left = 24
    Top = 74
    Width = 88
    Height = 18
    Caption = 'Order Class'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object Label9: TLabel
    Left = 25
    Top = 41
    Width = 56
    Height = 18
    Caption = 'Work No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
  end
  object asgList: TStringGrid
    AlignWithMargins = True
    Left = 8
    Top = 101
    Width = 926
    Height = 236
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 29
    RowCount = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    GradientEndColor = clWhite
    ParentFont = False
    TabOrder = 0
    OnDrawCell = asgListDrawCell
    OnSelectCell = asgListSelectCell
    ExplicitWidth = 908
  end
  object edRowNo: TEdit
    Tag = 1
    Left = 854
    Top = 69
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 1
  end
  object edRtvNo: TEdit
    Tag = 1
    Left = 854
    Top = 37
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 2
  end
  object cbPriority: TComboBox
    AlignWithMargins = True
    Left = 617
    Top = 37
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Items.Strings = (
      '1'
      '2'
      '3')
  end
  object cbStatus: TComboBox
    AlignWithMargins = True
    Left = 617
    Top = 69
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Items.Strings = (
      'NONE'
      'FRST'
      'RESV'
      'WAIT'
      'PEND'
      'COMT'
      'EXEC'
      'LOAD'
      'COMP'
      'REST'
      'EROR'
      'RTRY')
  end
  object edFromStation: TEdit
    Tag = 1
    Left = 357
    Top = 37
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 5
  end
  object edToStation: TEdit
    Tag = 1
    Left = 357
    Top = 69
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 6
  end
  object edWorkNo: TEdit
    Tag = 1
    Left = 131
    Top = 37
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 7
  end
  object cbOrderClass: TComboBox
    Left = 131
    Top = 69
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    Items.Strings = (
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
  object Autocheck: TCheckBox
    Left = 23
    Top = 10
    Width = 188
    Height = 17
    Caption = 'Auto Refresh'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 9
  end
  object TimerDisplay: TTimer
    Enabled = False
    OnTimer = TimerDisplayTimer
    Left = 792
    Top = 256
  end
end
