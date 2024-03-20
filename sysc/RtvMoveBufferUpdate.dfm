object fmRtvMoveBufferUpdate: TfmRtvMoveBufferUpdate
  Left = 0
  Top = 0
  Caption = 'fmRtvMoveBufferUpdate'
  ClientHeight = 204
  ClientWidth = 942
  Color = clBtnFace
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
    204)
  TextHeight = 13
  object tabType: TTabControl
    Left = 0
    Top = 0
    Width = 942
    Height = 204
    Align = alClient
    TabOrder = 0
    Tabs.Strings = (
      'RTV #1'
      'RTV #2')
    TabIndex = 0
    OnChange = tabTypeChange
    ExplicitWidth = 830
    ExplicitHeight = 203
    object Panel3: TPanel
      Left = 4
      Top = 24
      Width = 934
      Height = 176
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 822
      ExplicitHeight = 175
      object Label17: TLabel
        Left = 14
        Top = 69
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
        Left = 15
        Top = 36
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
      object Label110: TLabel
        Left = 510
        Top = 36
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
        Top = 68
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
      object Label3: TLabel
        Left = 762
        Top = 36
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
      object btnOrderUpdate2: TSpeedButton
        Tag = 1
        Left = 863
        Top = 1
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
      object Label2: TLabel
        Left = 277
        Top = 36
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
        Top = 69
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
      object Label5: TLabel
        Left = 762
        Top = 68
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
      object Autocheck: TCheckBox
        Left = 13
        Top = 5
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
        TabOrder = 0
      end
    end
  end
  object edWorkNo: TEdit
    Tag = 1
    Left = 131
    Top = 56
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
  object cbOrderClass: TComboBox
    Left = 131
    Top = 88
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
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
  object edFromStation: TEdit
    Tag = 1
    Left = 357
    Top = 56
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 3
  end
  object edToStation: TEdit
    Tag = 1
    Left = 357
    Top = 88
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 4
  end
  object cbPriority: TComboBox
    AlignWithMargins = True
    Left = 617
    Top = 56
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Items.Strings = (
      '1'
      '2'
      '3')
  end
  object cbStatus: TComboBox
    AlignWithMargins = True
    Left = 617
    Top = 88
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
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
  object edRtvNo: TEdit
    Tag = 1
    Left = 854
    Top = 56
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
  object edRowNo: TEdit
    Tag = 1
    Left = 854
    Top = 88
    Width = 80
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    ImeName = 'Microsoft IME 2003'
    ParentFont = False
    TabOrder = 8
  end
  object asgList: TStringGrid
    AlignWithMargins = True
    Left = 10
    Top = 121
    Width = 924
    Height = 74
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    ColCount = 29
    RowCount = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'D2Coding'
    Font.Style = []
    GradientEndColor = clWhite
    ParentFont = False
    TabOrder = 9
    OnSelectCell = asgListSelectCell
  end
  object TimerDisplay: TTimer
    Enabled = False
    OnTimer = TimerDisplayTimer
    Left = 712
    Top = 240
  end
end
