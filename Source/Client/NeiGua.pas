unit NeiGua;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,  StdCtrls, MShare, ExtCtrls, Spin, Grobal2, Actor;
type
  TfrmNeiGua=class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    PageControl2: TPageControl;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    Timer1: TTimer;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    grp1: TGroupBox;
    mmo1: TMemo;
    PageControl4: TPageControl;
    TabSheet17: TTabSheet;
    TabSheet18: TTabSheet;
    TabSheet19: TTabSheet;
    PageControl5: TPageControl;
    TabSheet20: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    TabSheet21: TTabSheet;
    CheckBox31: TCheckBox;
    CheckBox33: TCheckBox;
    CheckBox32: TCheckBox;
    chk12: TCheckBox;
    chk11: TCheckBox;
    CheckBox39: TCheckBox;
    CheckBox38: TCheckBox;
    CheckBox37: TCheckBox;
    CheckBox36: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    DuraAlert: TCheckBox;
    EntironmentList: TListView;
    EntironmentClass: TComboBox;
    ShowEntironment: TCheckBox;
    EntironmentTimer: TTimer;
    ItemList: TListView;
    CropsItemShow: TCheckBox;
    EditRedMsgFColor: TSpinEdit;
    DelItem: TButton;
    AddItem: TButton;
    ItemName: TEdit;
    ShowCropsColor: TLabel;
    GroupBox2: TGroupBox;
    CropsMonList: TListBox;
    EditCrops: TEdit;
    AddCropsMon: TButton;
    DelCropsMon: TButton;
    CropsMonHit: TCheckBox;
    CropsChangeColor: TCheckBox;
    CropsAutoLock: TCheckBox;
    CropsColorEff: TComboBox;
    GroupBox3: TGroupBox;
    Label8: TLabel;
    Label11: TLabel;
    CheckBoxOpenMsg: TCheckBox;
    EditSysMsg: TEdit;
    ComboBox1: TComboBox;
    Button1: TButton;
    Label7: TLabel;
    AutoHpOrotectTick: TSpinEdit;
    AutoCropsMpTick: TSpinEdit;
    AutoMpTick: TSpinEdit;
    AutoCropsHpTick: TSpinEdit;
    AutoHpTick: TSpinEdit;
    AutoHpProtectName: TComboBox;
    AutoHpProtectCount: TEdit;
    AutoHpProtect: TCheckBox;
    AutoCropsMpName: TComboBox;
    AutoCropsMpCount: TEdit;
    AutoCropsMp: TCheckBox;
    AutoMp: TCheckBox;
    AutoMpCount: TEdit;
    AutoMpName: TComboBox;
    AutoCropsHp: TCheckBox;
    AutoCropsHpCount: TEdit;
    AutoCropsHpName: TComboBox;
    AutoHpName: TComboBox;
    AutoHpCount: TEdit;
    AutoHp: TCheckBox;
    GroupBox4: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LabelMoveTime: TLabel;
    LabelHitTime: TLabel;
    LabelSpellTime: TLabel;
    MoveTime: TTrackBar;
    HitTime: TTrackBar;
    SpellTime: TTrackBar;
    CheckBox15: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CanLongHit: TCheckBox;
    CanWideHit: TCheckBox;
    CanAutoFireHit: TCheckBox;
    CanLongHit2: TCheckBox;
    CanFireSide: TCheckBox;
    CanShield: TCheckBox;
    CanShieldClsF: TRadioButton;
    CanShieldClsT: TRadioButton;
    CanFirewind: TCheckBox;
    CanAutoAddHp: TCheckBox;
    CanAutoAmyounsul: TCheckBox;
    CanCrossingOver: TCheckBox;
    CanAutoAddHpTick: TSpinEdit;
    Label10: TLabel;
    CanAutoAddHpCount: TEdit;
    CanAmyounsulCls: TComboBox;
    TabSheet9: TTabSheet;
    GroupBox5: TGroupBox;
    ListBoxBossHintList: TListBox;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure ShowEntironmentClick(Sender: TObject);
    procedure EntironmentTimerTimer(Sender: TObject);
    procedure ItemListMouseDown(Sender: TObject;
        Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AddItemClick(Sender: TObject);
    procedure EditRedMsgFColorChange(Sender: TObject);
    procedure AddCropsMonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure AutoHpClick(Sender: TObject);
    procedure CheckBoxOpenMsgClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CanLongHitClick(Sender: TObject);
    procedure CanAutoAddHpClick(Sender: TObject);




  private
    { Private declarations }
  public

    procedure RefWgBut();
    procedure Open;
    { Public declarations }
  end ;

var
  frmNeiGua: TfrmNeiGua;
  g_WgItemArr: array[0..5] of TClientItem;
  g_dwFireHitTick: LongWord;
  g_dwLongSwordTick: LongWord;
  g_dwLongFireTick: LongWord;
  g_dwHPUpUseTime:LongWord;
  g_HumList: TList;


implementation


{$R *.DFM}

uses FState, ClMain, HUtil32, PlayScn, CLFunc, Share, SoundUtil,NWGfig;
procedure TfrmNeiGua.Open;
begin
    Left := 0;
    Top := 0;
 Show();
end;


procedure TfrmNeiGua.RefWgBut();
var
  I: Integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
  Item: TListItem;
begin
  if g_MySelf = nil then
    exit;
   CheckBox1.Checked := g_boBGSound;
   CheckBox6.Checked := g_WgInfo.boShowAllItem;
   CheckBox7.Checked := g_WgInfo.boShowAllItemFil;
   CheckBox8.Checked := g_WgInfo.boCropsItemHit;
   CheckBox9.Checked := g_WgInfo.boAutoPuckUpItem;
   CheckBox10.Checked := g_WgInfo.boAutoPuckItemFil;
   CheckBox32.Checked := g_WgInfo.boAutoDownDrup;
   CheckBox33.Checked := g_WgInfo.boAutoOpenItem;
   CheckBox12.Checked := g_WgInfo.boShowName;
   CheckBox11.Enabled := g_WgInfo.boShowAllName;
   CheckBox16.Checked := g_WgInfo.boShowDura;
   CheckBox36.Checked := g_WgInfo.boCanRunHuman;
   CheckBox37.Checked := g_WgInfo.boCanRunMon;
   CheckBox38.Checked := g_WgInfo.boCanRunNpc;
   chk11.Checked := g_WgInfo.boCloseShift;
   chk12.Checked := g_wgInfo.boParalyCan;
   CheckBox3.Checked := g_WgInfo.boShowRedHPLable;
   CheckBox4.Checked := g_WgInfo.boShowHPNumber;
   CheckBox2.Checked := g_WgInfo.boShowBlueMpLable;
   DuraAlert.Checked := g_WgInfo.boDuraAlert;
   CheckBox5.Checked := g_WgInfo.boShowLevel; //显示等级
   CheckBox39.Checked := g_WgInfo.boMoveRedShow;
   ShowCropsColor.Color := GetRGB(g_WgInfo.coShowCropsColor);
   EditRedMsgFColor.Value := g_WgInfo.coShowCropsColor;
   CropsItemShow.Checked := g_WgInfo.boCropsItemShow;
   CropsMonHit.Checked := g_WgInfo.boCropsMonHit;
   CropsAutoLock.Checked := g_WgInfo.boCropsAutoLock;
   CropsChangeColor.Checked := g_WgInfo.boCropsChangeColor;
   CropsColorEff.ItemIndex := g_WgInfo.nCropsColorEff - 1;
   CheckBox13.Checked := g_WgInfo.boBossHint;

   CanLongHit.Checked := g_WgInfo.boCanLongHit;
   CanWideHit.Checked := g_WgInfo.boCanWideHit;
   CanFireSide.Checked := g_WgInfo.boCanFireSide;
   CanLongHit2.Checked := g_WgInfo.boCanLongHit2;

    CanFireSide.Checked := g_WgInfo.boCanFireSide;
    CanFirewind.Checked := g_WgInfo.boCanFirewind;
    CanShield.Checked   := g_WgInfo.boCanShield;







    CanShieldClsT.Enabled := not g_WgInfo.boCanShield;
    CanShieldClsF.Enabled := not g_WgInfo.boCanShield;


 // OpenItemList.Items.Clear;

   ItemList.Items.Clear;
  for I := 0 to g_ItemFiltrateList.Count - 1 do
  begin
    ItemFiltrate := g_ItemFiltrateList.Items[I];
    Item := ItemList.Items.Add;
    Item.Caption := ItemFiltrate.sItemName;
    if ItemFiltrate.boItemShow then
      Item.SubItems.Add('√')
    else
      Item.SubItems.Add(' ');
    if ItemFiltrate.boItemPick then
      Item.SubItems.Add('√')
    else
      Item.SubItems.Add(' ');
    if ItemFiltrate.boItemCorps then
      Item.SubItems.Add('√')
    else
      Item.SubItems.Add(' ');
    if ItemFiltrate.boItemHit then
      Item.SubItems.Add('√')
    else
      Item.SubItems.Add(' ');
  end;


      CropsMonList.Items.Clear;
    for I := 0 to g_CorpsMonList.Count - 1 do
    begin
      CropsMonList.Items.Add(g_CorpsMonList.Strings[I]);
      ChangeMonShow(g_CorpsMonList.Strings[I], True);
    end;

       ListBoxBossHintList.Items.Clear;

    for I := 0 to g_BossMonList.Count - 1 do
    begin
      ListBoxBossHintList.Items.Add(g_BossMonList.Strings[I]);
      ChangeMonShow(g_BossMonList.Strings[I], True);
    end;

    AutoHpProtectCount.Enabled := not g_WgInfo.boAutoHpProtect;
    AutoHpProtectName.Enabled := not g_WgInfo.boAutoHpProtect;
    AutoHpOrotectTick.Enabled := not g_WgInfo.boAutoHpProtect;
    AutoHpProtectCount.Text := IntToStr(g_WgInfo.boAutoHpProtectCount);
    if Length(g_WgInfo.boAutoHpProtectName) > 2 then
      AutoHpProtectName.Text := g_WgInfo.boAutoHpProtectName;
    AutoHpOrotectTick.Value := g_WgInfo.boAutoHpOrotectTick div 1000;

    AutoCropsMpCount.Enabled := not g_WgInfo.boAutoCropsMp;
    AutoCropsMpName.Enabled := not g_WgInfo.boAutoCropsMp;
    AutoCropsMpTick.Enabled := not g_WgInfo.boAutoCropsMp;
    AutoCropsMpCount.Text := IntToStr(g_WgInfo.boAutoCropsMpCount);
    if Length(g_WgInfo.boAutoCropsMpName) > 2 then
      AutoCropsMpName.Text := g_WgInfo.boAutoCropsMpName;
    AutoCropsMpTick.Value := g_WgInfo.boAutoCropsMpTick div 1000;

    AutoMpCount.Enabled := not g_WgInfo.boAutoMp;
    AutoMpName.Enabled := not g_WgInfo.boAutoMp;
    AutoMpTick.Enabled := not g_WgInfo.boAutoMp;
    AutoMpCount.Text := IntToStr(g_WgInfo.boAutoMpCount);
    if Length(g_WgInfo.boAutoMpName) > 2 then
      AutoMpName.Text := g_WgInfo.boAutoMpName;
    AutoMpTick.Value := g_WgInfo.boAutoMpTick div 1000;

    AutoCropsHpCount.Enabled := not g_WgInfo.boAutoCropsHp;
    AutoCropsHpName.Enabled := not g_WgInfo.boAutoCropsHp;
    AutoCropsHpTick.Enabled := not g_WgInfo.boAutoCropsHp;
    AutoCropsHpCount.Text := IntToStr(g_WgInfo.boAutoCropsHpCount);
    if Length(g_WgInfo.boAutoCropsHpName) > 2 then
      AutoCropsHpName.Text := g_WgInfo.boAutoCropsHpName;
    AutoCropsHpTick.Value := g_WgInfo.boAutoCropsHpTick div 1000;

    AutoHpCount.Enabled := not g_WgInfo.boAutoHp;
    AutoHpName.Enabled := not g_WgInfo.boAutoHp;
    AutoHpTick.Enabled := not g_WgInfo.boAutoHp;
    AutoHpCount.Text := IntToStr(g_WgInfo.boAutoHpCount);
    if Length(g_WgInfo.boAutoHpName) > 2 then
      AutoHpName.Text := g_WgInfo.boAutoHpName;
    AutoHpTick.Value := g_WgInfo.boAutoHpTick div 1000;



    AutoHp.Checked := g_WgInfo.boAutoHp;
    AutoCropsHp.Checked := g_WgInfo.boAutoCropsHp;
    AutoMp.Checked := g_WgInfo.boAutoMp;
    AutoCropsMp.Checked := g_WgInfo.boAutoCropsMp;
    AutoHpProtect.Checked := g_WgInfo.boAutoHpProtect;

       CanAutoAddHp.Checked := g_WgInfo.boCanAutoAddHp;
    CanAutoAddHpCount.Enabled := not g_WgInfo.boCanAutoAddHp;
    CanAutoAddHpTick.Enabled := not g_WgInfo.boCanAutoAddHp;
    CanAutoAddHpCount.Text := IntToStr(g_wgInfo.nCanAutoAddHpCount);
    CanAutoAddHpTick.Value := g_wgInfo.dwCanAutoAddHpTick div 1000;


     CanAmyounsulCls.Enabled := not g_WgInfo.boCanAutoAmyounsul;
     CanAutoAmyounsul.Checked := g_WgInfo.boCanAutoAmyounsul;
    CanAmyounsulCls.ItemIndex := g_WgInfo.btCanAmyounsulCls;

end;


procedure TfrmNeiGua.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Word(Key) of
    VK_F12, VK_HOME:
      begin
        Visible := not Visible;
      end;
  end;
end;

procedure TfrmNeiGua.CheckBox1Click(Sender: TObject);
begin
    g_boBGSound := CheckBox1.Checked;
 //   PlayBgMusic(g_sBgMusic, g_boBGSound, True);
end;

procedure TfrmNeiGua.CheckBox6Click(Sender: TObject);
var
  Item: TListItem;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
begin
       if Sender = CheckBox6 then
        begin
          g_WgInfo.boShowAllItem := CheckBox6.Checked;
        end
        else if Sender = CheckBox7 then
        begin
          g_WgInfo.boShowAllItemFil := CheckBox7.Checked;
        end
        else if Sender = CheckBox8 then
        begin
          g_WgInfo.boCropsItemHit := CheckBox8.Checked;
        end
        else if Sender = CheckBox9 then
        begin
          g_WgInfo.boAutoPuckUpItem := CheckBox9.Checked;
        end
        else if Sender = CheckBox10 then
        begin
          g_WgInfo.boAutoPuckItemFil := CheckBox10.Checked;
        end
        else if Sender = CheckBox32 then
        begin
          g_WgInfo.boAutoDownDrup := CheckBox32.Checked;
        end
        else if Sender = CheckBox33 then
        begin
          g_WgInfo.boAutoOpenItem := CheckBox33.Checked;
        end
         else if Sender = CheckBox12 then
        begin
          g_WgInfo.boShowName := CheckBox12.Checked;
        end
         else if Sender = CheckBox11 then
        begin
          g_WgInfo.boShowAllName := CheckBox11.Checked;
        end
        else if Sender = CheckBox16 then
        begin
          g_WgInfo.boShowDura := CheckBox16.Checked;
        end
        else if Sender = CheckBox36 then
        begin
          g_WgInfo.boCanRunHuman := CheckBox36.Checked;
        end
        else if Sender = CheckBox37 then
        begin
          g_WgInfo.boCanRunMon := CheckBox37.Checked;
        end
        else if Sender = CheckBox38 then
        begin
          g_WgInfo.boCanRunNpc := CheckBox38.Checked;
        end
        else
        if Sender =chk11 then
        begin
          g_WgInfo.boCloseShift := chk11.Checked;
          if not g_WgInfo.boCloseShift then
            g_boShift := False;
        end
         else if Sender = chk12 then
        begin
          g_WgInfo.boParalyCan := chk12.Checked;
        end
        else if Sender = CheckBox3 then
        begin
          g_WgInfo.boShowRedHPLable := CheckBox3.Checked;
        end
       else if Sender = CheckBox4 then
        begin
          g_WgInfo.boShowHPNumber := CheckBox4.Checked;
        end
        else if Sender = CheckBox2 then
        begin
          g_WgInfo.boShowBlueMpLable := CheckBox2.Checked;
        end
        else if Sender = DuraAlert then
        begin
          g_WgInfo.boDuraAlert := DuraAlert.Checked;
        end
        else if Sender = CheckBox5 then //显示等级
        begin
          g_WgInfo.boShowLevel := CheckBox5.Checked;
        end
        else if Sender = CheckBox39 then
        begin
          g_WgInfo.boMoveRedShow := CheckBox39.Checked;
        end
         else if Sender = CheckBox13 then
        begin
          g_WgInfo.boBossHint := CheckBox13.Checked;
        end
end;

procedure TfrmNeiGua.ShowEntironmentClick(Sender: TObject);
begin
    EntironmentTimer.Enabled := ShowEntironment.Checked;
end;

procedure TfrmNeiGua.EntironmentTimerTimer(Sender: TObject);
var
  I: integer;
  actor: TActor;
  Item: TListItem;
begin
  if PageControl1.TabIndex <> 4 then
    exit;
  if not frmNeiGua.Visible then
    exit;
  EntironmentList.Items.Clear;
  for I := 0 to PlayScene.m_ActorList.Count - 1 do
  begin
    actor := TActor(PlayScene.m_ActorList.Items[I]);
    if (actor <> nil) and
      (actor <> g_MySelf) and
      (not actor.m_boDeath) then
    begin
      if EntironmentClass.ItemIndex <> 0 then
      begin
        if (Actor.m_btRace = RCC_USERHUMAN) and (EntironmentClass.ItemIndex <>
          1) then
          Continue;
        if (Actor.m_btRace = RCC_MERCHANT) and (EntironmentClass.ItemIndex <>
          2) then
          Continue;
        if ((Actor.m_btRace > RCC_USERHUMAN) and (Actor.m_btRace <>
          RCC_MERCHANT)) and (EntironmentClass.ItemIndex <> 3) then
          Continue;
      end;
      Item := EntironmentList.Items.Add;
      Item.Caption := actor.m_sUserName;
      Item.SubItems.Add(WayTag[GetNextDirection(g_MySelf.m_nCurrX,
          g_MySelf.m_nCurrY, actor.m_nCurrX, actor.m_nCurrY)]);
      Item.SubItems.Add(Format('%d:%d', [actor.m_nCurrX, actor.m_nCurrY]));
    end;
  end;
end;
 
procedure TfrmNeiGua.ItemListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
  ItemFiltrate: pTItemFiltrate;
begin
  if (ItemList.ItemIndex >= 0) and (ItemList.ItemIndex <=
    g_ItemFiltrateList.Count) then
  begin
    ItemFiltrate := g_ItemFiltrateList.Items[ItemList.ItemIndex];
    Item := ItemList.Items[ItemList.ItemIndex];
    if (X > 91) and (X < 117) then
      ItemFiltrate.boItemShow := not ItemFiltrate.boItemShow;
    if (X > 122) and (X < 148) then
      ItemFiltrate.boItemPick := not ItemFiltrate.boItemPick;
    if (X > 152) and (X < 180) then
      ItemFiltrate.boItemCorps := not ItemFiltrate.boItemCorps;
    if (X > 182) and (X < 208) then
      ItemFiltrate.boItemHit := not ItemFiltrate.boItemHit;
    if ItemFiltrate.boItemShow then
      Item.SubItems.Strings[0] := '√'
    else
      Item.SubItems.Strings[0] := ' ';
    if ItemFiltrate.boItemPick then
      Item.SubItems.Strings[1] := '√'
    else
      Item.SubItems.Strings[1] := ' ';
    if ItemFiltrate.boItemCorps then
      Item.SubItems.Strings[2] := '√'
    else
      Item.SubItems.Strings[2] := ' ';
    if ItemFiltrate.boItemHit then
      Item.SubItems.Strings[3] := '√'
    else
      Item.SubItems.Strings[3] := ' ';
    ChangeShowItem(ItemFiltrate.sItemName);
  end;
end;


procedure TfrmNeiGua.AddItemClick(Sender: TObject);
var
  Item: TListItem;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
begin
         if Sender = DelItem then
        begin
          if (ItemList.ItemIndex >= 0) and (ItemList.ItemIndex <
            g_ItemFiltrateList.Count) then
          begin
            ItemFiltrate := g_ItemFiltrateList.Items[ItemList.ItemIndex];
            ItemFiltrate.boItemShow := False;
            ItemFiltrate.boItemPick := False;
            ItemFiltrate.boItemCorps := False;
            ItemFiltrate.boItemHit := False;
            ChangeShowItem(ItemFiltrate.sItemName);
            Dispose(ItemFiltrate);
            g_ItemFiltrateList.Delete(ItemList.ItemIndex);
            ItemList.Items.Delete(ItemList.ItemIndex);
          end;
        end
        else if Sender = AddItem then
        begin
          if ItemName.Text <> '' then
          begin
            for I := 0 to ItemList.Items.Count - 1 do
            begin
              Item := ItemList.Items[I];
              if CompareText(Trim(ItemName.Text), Item.Caption) = 0 then
              begin
                ItemList.ItemIndex := I;
                exit;
              end;
            end;
            New(ItemFiltrate);
            FillChar(ItemFiltrate^, SizeOf(TItemFiltrate), #0);
            g_ItemFiltrateList.Add(ItemFiltrate);
            ItemFiltrate.sItemName := Trim(ItemName.Text);
            Item := ItemList.Items.Add;
            Item.Caption := ItemFiltrate.sItemName;
            for I := 0 to 3 do
              Item.SubItems.Add(' ');
          end;
        end
          else if Sender = CropsItemShow then
        begin
          g_WgInfo.boCropsItemShow := CropsItemShow.Checked;
        end
end;

procedure TfrmNeiGua.EditRedMsgFColorChange(Sender: TObject);
begin
    if Sender = EditRedMsgFColor then
    begin
      ShowCropsColor.Color := GetRGB(EditRedMsgFColor.Value);
      g_wgInfo.coShowCropsColor := EditRedMsgFColor.Value;
    end
    else
end;

procedure TfrmNeiGua.AddCropsMonClick(Sender: TObject);
var
  Item: TListItem;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
begin
       if Sender = AddCropsMon then
        begin
          if Trim(EditCrops.Text) <> '' then
          begin
            i := CropsMonList.Items.IndexOf(Trim(EditCrops.Text));
            if I = -1 then
            begin
              CropsMonList.Items.Add(Trim(EditCrops.Text));
              g_CorpsMonList.Add(Trim(EditCrops.Text));
              ChangeMonShow(Trim(EditCrops.Text), True);
            end
            else
              CropsMonList.ItemIndex := I;
          end;
        end
        else if Sender = DelCropsMon then
        begin
          if CropsMonList.ItemIndex >= 0 then
          begin
            ChangeMonShow(g_CorpsMonList.Strings[CropsMonList.ItemIndex],
              False);
            CropsMonList.Items.Delete(CropsMonList.ItemIndex);
            g_CorpsMonList.Delete(CropsMonList.ItemIndex);
          end;
        end
        else
         if Sender = CropsMonHit then
        begin
          g_WgInfo.boCropsMonHit := CropsMonHit.Checked;
        end
          else if Sender = CropsAutoLock then
        begin
          g_WgInfo.boCropsAutoLock := CropsAutoLock.Checked;
        end
        else if Sender = CropsChangeColor then
        begin
          g_WgInfo.boCropsChangeColor := CropsChangeColor.Checked;
          CropsColorEff.Enabled := not g_WgInfo.boCropsChangeColor;
        end

end;




procedure TfrmNeiGua.Timer1Timer(Sender: TObject);
Resourcestring
  sTest = '你的[%s]已经用完。';
var
  //  I:Integer;            fd
  II: integer;
  nShift: TShiftState;
  nKey: Word;
begin

    if g_MySelf = nil then
      exit;
    //自动保护
  if (g_WgInfo.boAutoHpProtect) and
    (g_MySelf.m_Abil.HP < g_WgInfo.boAutoHpProtectCount) and
    ((GetTickCount - g_dwAutoHpOrotectTick) > g_wgInfo.boAutoHpOrotectTick)
    then
  begin
    g_dwAutoHpOrotectTick := GetTickCount;
    II := GetItembyName(g_wgInfo.boAutoHpProtectName);
    if II > -1 then
      FrmMain.EatItem(II)
    else
    begin
      pAutoOpenItem(g_wgInfo.boAutoHpProtectName);
      II := GetItembyName(g_wgInfo.boAutoHpProtectName);
      if II > -1 then
        FrmMain.EatItem(II)
      else
        //DScreen.AddHitMsg(Format(sTest, [g_wgInfo.boAutoHpProtectName]));
        DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoHpProtectName]), clWhite, clRed);
    end;
  end;
    //自动补红
  if (g_WgInfo.boAutoHp) and
    (g_MySelf.m_Abil.HP < g_WgInfo.boAutoHpCount) and
    ((GetTickCount - g_dwAutoHpTick) > g_wgInfo.boAutoHpTick) then
  begin
    g_dwAutoHpTick := GetTickCount;
    II := GetItembyName(g_wgInfo.boAutoHpName);
    if II > -1 then
      FrmMain.EatItem(II)
    else
    begin
      pAutoOpenItem(g_wgInfo.boAutoHpName);
      II := GetItembyName(g_wgInfo.boAutoHpName);
      if II > -1 then
        FrmMain.EatItem(II)
      else
        //DScreen.AddHitMsg(Format(sTest, [g_wgInfo.boAutoHpName]));
        DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoHpName]), clWhite, clRed);
    end;
  end;
    //自动补红2
  if (g_WgInfo.boAutoCropsHp) and
    (g_MySelf.m_Abil.HP < g_WgInfo.boAutoCropsHpCount) and
    ((GetTickCount - g_dwAutoCropsHpTick) > g_wgInfo.boAutoCropsHpTick) then
  begin
    g_dwAutoCropsHpTick := GetTickCount;
    II := GetItembyName(g_wgInfo.boAutoCropsHpName);
    if II > -1 then
      FrmMain.EatItem(II)
    else
    begin
      pAutoOpenItem(g_wgInfo.boAutoCropsHpName);
      II := GetItembyName(g_wgInfo.boAutoCropsHpName);
      if II > -1 then
        FrmMain.EatItem(II)
      else
        //DScreen.AddHitMsg(Format(sTest, [g_wgInfo.boAutoCropsHpName]));
        DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoCropsHpName]), clWhite, clRed);
    end;
  end;
    //自动补蓝
  if (g_WgInfo.boAutoMp) and
    (g_MySelf.m_Abil.MP < g_WgInfo.boAutoMpCount) and
    ((GetTickCount - g_dwAutoMpTick) > g_wgInfo.boAutoMpTick) then
  begin
    g_dwAutoMpTick := GetTickCount;
    II := GetItembyName(g_wgInfo.boAutoMpName);
    if II > -1 then
      FrmMain.EatItem(II)
    else
    begin
      pAutoOpenItem(g_wgInfo.boAutoMpName);
      II := GetItembyName(g_wgInfo.boAutoMpName);
      if II > -1 then
        FrmMain.EatItem(II)
      else
        //DScreen.AddHitMsg(Format(sTest, [g_wgInfo.boAutoMpName]));
        DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoMpName]), clWhite, clRed);
    end;
  end;
    //自动补蓝2
  if (g_WgInfo.boAutoCropsMp) and
    (g_MySelf.m_Abil.MP < g_WgInfo.boAutoCropsMpCount) and
    ((GetTickCount - g_dwAutoCropsMpTick) > g_wgInfo.boAutoCropsMpTick) then
  begin
    g_dwAutoCropsMpTick := GetTickCount;
    II := GetItembyName(g_wgInfo.boAutoCropsMpName);
    if II > -1 then
      FrmMain.EatItem(II)
    else
    begin
      pAutoOpenItem(g_wgInfo.boAutoCropsMpName);
      II := GetItembyName(g_wgInfo.boAutoCropsMpName);
      if II > -1 then
        FrmMain.EatItem(II)
      else
        //DScreen.AddHitMsg(Format(sTest, [g_wgInfo.boAutoCropsMpName]));
        DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoCropsMpName]), clWhite, clRed);
    end;
  end;

    //道士自动补血
  if (g_wgInfo.boCanAutoAddHp) and
   // (not g_MySelf.m_boIsShop) and
    (g_MySelf.m_btHorse = 0) and
    (g_MySelf.m_Abil.HP <= g_wgInfo.nCanAutoAddHpCount) and
    (g_MySelf.m_Abil.MP > 10) and
    (g_MyMagic[2] <> nil) and
    ((GetTickCount - g_dwCanAutoAddHpTime) > g_wgInfo.dwCanAutoAddHpTick) and
    ((GetTickCount - g_dwLatestSpellTick) > g_dwSpellTime) then
  begin
    g_dwCanAutoAddHpTime := GetTickCount;
    g_dwLatestSpellTick := GetTickCount;
    g_dwMagicDelayTime := 0;
    FrmMain.UseMagic(g_nMouseX, g_nMouseY, g_MyMagic[2], True);
  end;
end;

procedure TfrmNeiGua.AutoHpClick(Sender: TObject);
var
  Item: TListItem;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
begin
    if Sender = AutoHp then
      begin
        g_WgInfo.boAutoHp := AutoHp.Checked;
        AutoHpCount.Enabled := not g_WgInfo.boAutoHp;
        AutoHpName.Enabled := not g_WgInfo.boAutoHp;
        AutoHpTick.Enabled := not g_WgInfo.boAutoHp;
        g_WgInfo.boAutoHpCount := Str_ToInt(AutoHpCount.Text, 100);
        g_WgInfo.boAutoHpName := AutoHpName.Text;
        g_WgInfo.boAutoHpTick := AutoHpTick.Value * 1000;
      end
      else if Sender = AutoCropsHp then
      begin
        g_WgInfo.boAutoCropsHp := AutoCropsHp.Checked;
        AutoCropsHpCount.Enabled := not g_WgInfo.boAutoCropsHp;
        AutoCropsHpName.Enabled := not g_WgInfo.boAutoCropsHp;
        AutoCropsHpTick.Enabled := not g_WgInfo.boAutoCropsHp;
        g_WgInfo.boAutoCropsHpCount := Str_ToInt(AutoCropsHpCount.Text, 100);
        g_WgInfo.boAutoCropsHpName := AutoCropsHpName.Text;
        g_WgInfo.boAutoCropsHpTick := AutoCropsHpTick.Value * 1000;
      end
      else if Sender = AutoMp then
      begin
        g_WgInfo.boAutoMp := AutoMp.Checked;
        AutoMpCount.Enabled := not g_WgInfo.boAutoMp;
        AutoMpName.Enabled := not g_WgInfo.boAutoMp;
        AutoMpTick.Enabled := not g_WgInfo.boAutoMp;
        g_WgInfo.boAutoMpCount := Str_ToInt(AutoMpCount.Text, 100);
        g_WgInfo.boAutoMpName := AutoMpName.Text;
        g_WgInfo.boAutoMpTick := AutoMpTick.Value * 1000;
      end
      else if Sender = AutoCropsMp then
      begin
        g_WgInfo.boAutoCropsMp := AutoCropsMp.Checked;
        AutoCropsMpCount.Enabled := not g_WgInfo.boAutoCropsMp;
        AutoCropsMpName.Enabled := not g_WgInfo.boAutoCropsMp;
        AutoCropsMpTick.Enabled := not g_WgInfo.boAutoCropsMp;
        g_WgInfo.boAutoCropsMpCount := Str_ToInt(AutoCropsMpCount.Text, 100);
        g_WgInfo.boAutoCropsMpName := AutoCropsMpName.Text;
        g_WgInfo.boAutoCropsMpTick := AutoCropsMpTick.Value * 1000;
      end
      else if Sender = AutoHpProtect then
      begin
        g_WgInfo.boAutoHpProtect := AutoHpProtect.Checked;
        AutoHpProtectCount.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpProtectName.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpOrotectTick.Enabled := not g_WgInfo.boAutoHpProtect;
        g_WgInfo.boAutoHpProtectCount := Str_ToInt(AutoHpProtectCount.Text,
          100);
        g_WgInfo.boAutoHpProtectName := AutoHpProtectName.Text;
        g_WgInfo.boAutoHpOrotectTick := AutoHpOrotectTick.Value * 1000;
      end
      else
       if Sender = AutoCropsMp then
      begin
        g_WgInfo.boAutoCropsMp := AutoCropsMp.Checked;
        AutoCropsMpCount.Enabled := not g_WgInfo.boAutoCropsMp;
        AutoCropsMpName.Enabled := not g_WgInfo.boAutoCropsMp;
        AutoCropsMpTick.Enabled := not g_WgInfo.boAutoCropsMp;
        g_WgInfo.boAutoCropsMpCount := Str_ToInt(AutoCropsMpCount.Text, 100);
        g_WgInfo.boAutoCropsMpName := AutoCropsMpName.Text;
        g_WgInfo.boAutoCropsMpTick := AutoCropsMpTick.Value * 1000;
      end
      else if Sender = AutoHpProtect then
      begin
        g_WgInfo.boAutoHpProtect := AutoHpProtect.Checked;
        AutoHpProtectCount.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpProtectName.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpOrotectTick.Enabled := not g_WgInfo.boAutoHpProtect;
        g_WgInfo.boAutoHpProtectCount := Str_ToInt(AutoHpProtectCount.Text,
          100);
        g_WgInfo.boAutoHpProtectName := AutoHpProtectName.Text;
        g_WgInfo.boAutoHpOrotectTick := AutoHpOrotectTick.Value * 1000;
      end
      else if Sender = AutoHpProtect then
      begin
        g_WgInfo.boAutoHpProtect := AutoHpProtect.Checked;
        AutoHpProtectCount.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpProtectName.Enabled := not g_WgInfo.boAutoHpProtect;
        AutoHpOrotectTick.Enabled := not g_WgInfo.boAutoHpProtect;
        g_WgInfo.boAutoHpProtectCount := Str_ToInt(AutoHpProtectCount.Text,
          100);
        g_WgInfo.boAutoHpProtectName := AutoHpProtectName.Text;
        g_WgInfo.boAutoHpOrotectTick := AutoHpOrotectTick.Value * 1000;
      end
end;

procedure TfrmNeiGua.CheckBoxOpenMsgClick(Sender: TObject);
begin
    if Trim(EditSysMsg.Text) <> '' then
    begin
      g_AutoSysMsg := CheckBoxOpenMsg.Checked;
      g_AutoMsgTick := GetTickCount;
      g_AutoMsg := EditSysMsg.Text;
    end;
end;

procedure TfrmNeiGua.Button1Click(Sender: TObject);
begin
    if ComboBox1.ItemIndex >= 0 then
      FrmMain.SendSay('@' + ComboBox1.Items[ComboBox1.ItemIndex]);
end;

procedure TfrmNeiGua.Button2Click(Sender: TObject);

var
  Item: TListItem;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
begin
       if Sender = Button2 then
        begin
          if Trim(Edit1.Text) <> '' then
          begin
            i := ListBoxBossHintList.Items.IndexOf(Trim(Edit1.Text));
            if I = -1 then
            begin
              ListBoxBossHintList.Items.Add(Trim(Edit1.Text));
              g_BossMonList.Add(Trim(Edit1.Text));
              ChangeMonShow(Trim(Edit1.Text), True);
            end
            else
              ListBoxBossHintList.ItemIndex := I;
          end;
        end
        else if Sender = Button3 then
        begin
          if ListBoxBossHintList.ItemIndex >= 0 then
          begin
            ChangeMonShow(g_BossMonList.Strings[ListBoxBossHintList.ItemIndex],
              False);
            ListBoxBossHintList.Items.Delete(ListBoxBossHintList.ItemIndex);
            g_BossMonList.Delete(ListBoxBossHintList.ItemIndex);
          end;
        end

end;

procedure TfrmNeiGua.CanLongHitClick(Sender: TObject);
begin
      if Sender = CanLongHit then
      begin
        g_WgInfo.boCanLongHit := CanLongHit.Checked;
      end
      else if Sender = CanWideHit then
      begin
        g_WgInfo.boCanWideHit := CanWideHit.Checked;
        
      end
      else if Sender = CanFireSide then
      begin
        g_WgInfo.boCanFireSide := CanFireSide.Checked;
      end
      else if Sender = CanLongHit2 then
      begin
      g_WgInfo.boCanLongHit2 := CanLongHit2.Checked;
      end
      ///////////////////////////////////////////
      else if Sender = CanShieldClsT then
      begin
        g_WgInfo.boCanShieldCls := True;
      end
      else if Sender = CanShieldClsF then
      begin
        g_WgInfo.boCanShieldCls := False;
      end
      else if Sender = CanShield then
      begin
        g_WgInfo.boCanShield := CanShield.Checked;
        CanShieldClsT.Enabled := not g_WgInfo.boCanShield;
        CanShieldClsF.Enabled := not g_WgInfo.boCanShield;
      end
      else if Sender = CanFirewind then
      begin
        g_WgInfo.boCanFirewind := CanFirewind.Checked;
      end
end;

procedure TfrmNeiGua.CanAutoAddHpClick(Sender: TObject);
begin
     if Sender = CanAutoAddHp then
      begin
        g_WgInfo.boCanAutoAddHp := CanAutoAddHp.Checked;
        CanAutoAddHpCount.Enabled := not g_WgInfo.boCanAutoAddHp;
        CanAutoAddHpTick.Enabled := not g_WgInfo.boCanAutoAddHp;
        g_wgInfo.nCanAutoAddHpCount := Str_ToInt(CanAutoAddHpCount.Text, 200);
        g_wgInfo.dwCanAutoAddHpTick := CanAutoAddHpTick.Value * 1000;
      end

    else if Sender = CanCrossingOver then
  begin
    g_WgInfo.boCanCrossingOver := CanCrossingOver.Checked;
  end
  else if Sender = CanAutoAmyounsul then
  begin
    g_WgInfo.boCanAutoAmyounsul := CanAutoAmyounsul.Checked;
    g_WgInfo.btCanAmyounsulCls := CanAmyounsulCls.ItemIndex;
    CanAmyounsulCls.Enabled := not g_WgInfo.boCanAutoAmyounsul;
  end
  else if Sender = CanAutoAmyounsul then
  begin
    g_WgInfo.boCanAutoAmyounsul := CanAutoAmyounsul.Checked;
    g_WgInfo.btCanAmyounsulCls := CanAmyounsulCls.ItemIndex;
    CanAmyounsulCls.Enabled := not g_WgInfo.boCanAutoAmyounsul;
  end
end;

initialization
  begin
    FillChar(g_WgItemArr, SizeOf(TClientItem) * 6, #0);
    g_HumList := TList.Create;
  end;

finalization
  begin
    g_HumList.Free;
  end;
end.













