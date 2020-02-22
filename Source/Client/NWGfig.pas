
unit NWGfig;

interface
uses
  Classes, SysUtils, Graphics, Actor, StrUtils, Windows, grobal2, Share,
  INIFiles;


type
  TWGInfo = record
    boShowRedHPLable: Boolean; //显示血条
    boShowBlueMpLable: Boolean; //显示蓝条
    boShowHPNumber: Boolean; //数字显血
    boShowAllItem: Boolean; //显示物品
    boShowAllItemFil: Boolean; //显示过滤
    coShowCropsColor: Byte; //特殊物品颜色
    boCropsItemShow: Boolean; //特殊变色显示
    boCropsItemHit: Boolean; //特殊物品提示
    boAutoPuckUpItem: Boolean; //自动捡物
    boAutoPuckItemFil: Boolean; //捡取过滤
    boAutoDownDrup: Boolean; //自动放药
    boAutoOpenItem: Boolean; //自动解包
    boShowName: Boolean; //显示人名
    boShowAllName: Boolean; //显示全名
    boShowDura: Boolean; //显示持久
    boCanRunHuman: Boolean; //穿过人物
    boCanRunMon: Boolean; //穿过怪物
    boCanRunNpc: Boolean; //穿过NPC
    boCloseShift: Boolean; //免Shift
    boParalyCan: Boolean; //防石化
    boDuraAlert: Boolean; //持久警告
    boShowLevel: Boolean; //显示等级
    boMoveRedShow: Boolean; //去血显示

    boCropsMonHit: Boolean; //特殊怪物接近提示
    boCropsAutoLock: Boolean; //特殊怪物自动锁定
    boCropsChangeColor: Boolean; //特殊怪物变色显示
    nCropsColorEff: Byte; //颜色
    boBossHint      :Boolean;//BOOS提示
    //-------------------------------------
    dwCanAttackTick: LongWord;
    boAutoHp: Boolean;
    boAutoHpName: string[14];
    boAutoHpTick: LongWord;
    boAutoHpCount: Integer;
    boAutoCropsHp: Boolean;
    boAutoCropsHpName: string[14];
    boAutoCropsHpTick: LongWord;
    boAutoCropsHpCount: Integer;
    boAutoMp: Boolean;
    boAutoMpName: string[14];
    boAutoMpTick: LongWord;
    boAutoMpCount: Integer;
    boAutoCropsMp: Boolean;
    boAutoCropsMpName: string[14];
    boAutoCropsMpTick: LongWord;
    boAutoCropsMpCount: Integer;

    boAutoHpProtect: Boolean;
    boAutoHpProtectName: string[14];
    boAutoHpProtectCount: Integer;
    boAutoHpOrotectTick: LongWord;
    boAutoDownHorse: Boolean;

   boCanLongHit: Boolean; //刀刀刺杀
   boCanWideHit: Boolean; //智能半月
   boCanAutoFireHit: Boolean; //自动烈火
   nFireHitSkillTime:LongWord;
   boCanFireSide: Boolean; //烈火近身
   boCanLongHit2: Boolean;
   boCanShield: Boolean; //自动开盾
   boCanShieldCls: Boolean; //开盾类型
   boCanFirewind: Boolean; //接近抗拒
   ////////////////////////////////////
   boCanAutoAddHp: Boolean; //自动补血
    nCanAutoAddHpCount: Integer; //补血线
    dwCanAutoAddHpTick: LongWord; //补血间隔

    boCanAutoAmyounsul: Boolean; //自动放毒
    boCanCrossingOver: Boolean; //红绿毒互换
    btCanAmyounsulCls: Byte; //放毒类型
   
 end;

  TItemFiltrate = record
    sItemName: string[16];
    boItemShow: Boolean;
    boItemPick: Boolean;
    boItemCorps: Boolean;
    boItemHit: Boolean;
  end;
  pTItemFiltrate = ^TItemFiltrate;




var
  LevelUseItem: array[0..13] of string = (
    '衣服',
    '武器',
    '配带',
    '项链',
    '头盔',
    '手镯',
    '手镯',
    '戒指',
    '戒指',
    '消耗品',
    '腰带',
    '靴子',
    '宝石',
    '斗笠'
    );
  CropsItem: array[0..6] of string[14] = (
    '随机传送卷', '地牢逃脱卷', '回城卷', '行会回城卷',
    '随机传送石', '盟重传送石', '比奇传送石'
    );

  g_ItemFiltrateList: TList;
  g_OpenItemArray:array of TOpenItem; //解包物品列表
  g_CorpsMonList: TStringList;
  g_BossMonList: TStringList;

  g_dwCanAutoAddHpTime: LongWord = 0;
  g_dwCanHolyShieldTime: LongWord = 0;
  g_dwCanDejiwonhoTime: LongWord = 0;
  g_dwCanAttackTime: LongWord = 0;
  g_dwAutoHpTick: LongWord = 0;
  g_dwAutoCropsHpTick: LongWord = 0;
  g_dwAutoMpTick: LongWord = 0;
  g_nAutoDrinkTick:LongWord = 0;
  g_nHeroAutoDrinkTick:LongWord = 0;
  g_dwAutoCropsMpTick: LongWord = 0;
  g_dwAutoHpOrotectTick: LongWord = 0;

  g_WgInfo: TWGInfo = (
    boShowRedHPLable: True;
    boShowBlueMpLable: False;
    boShowHPNumber: True;
    boShowAllItem: True;
    boShowAllItemFil: False;
    coShowCropsColor: 249;
    boCropsItemShow: False;
    boCropsItemHit: True;
    boAutoPuckUpItem: True;
    boAutoPuckItemFil: False;
    boAutoDownDrup: True;
    boAutoOpenItem: True;
    boShowName: False;
    boShowAllName: False;
    boShowDura: False;
    boCanRunHuman: False;
    boCanRunMon: False;
    boCanRunNpc: False;
    boCloseShift: False;
    boParalyCan: False;
    boDuraAlert: True;
    boShowLevel: False; //显示等级
    boMoveRedShow: True;

        boCropsMonHit: False;
    boCropsAutoLock: False;
    boCropsChangeColor: False;
    nCropsColorEff: 9;
    boBossHint: False;
    //--------------------------------
        dwCanAttackTick: 200 * 1000;
    boAutoHp: False;
    boAutoHpName: '';
    boAutoHpTick: 4 * 1000;
    boAutoHpCount: 200;
    boAutoCropsHp: False;
    boAutoCropsHpName: '';
    boAutoCropsHpTick: 1000;
    boAutoCropsHpCount: 200;
    boAutoMp: False;
    boAutoMpName: '';
    boAutoMpTick: 4 * 1000;
    boAutoMpCount: 80;
    boAutoCropsMp: False;
    boAutoCropsMpName: '';
    boAutoCropsMpTick: 1000;
    boAutoCropsMpCount: 80;
    boAutoHpProtect: False;
    boAutoHpProtectName: '';
    boAutoHpProtectCount: 100;
    boAutoHpOrotectTick: 10 * 1000;
    boAutoDownHorse: True;

    boCanLongHit: False;
    boCanWideHit: False;
    boCanAutoFireHit: False;
    nFireHitSkillTime: 10000;
    boCanFireSide: False;
    boCanLongHit2: False;

    boCanShield: False;
    boCanShieldCls: False;
    boCanFirewind: False;
 //////////////////////////////
     boCanAutoAddHp: False;
    nCanAutoAddHpCount: 200;
    dwCanAutoAddHpTick: 4 * 1000;

        boCanAutoAmyounsul: False;
    boCanCrossingOver: False;
    btCanAmyounsulCls: 0;

    );
  WayTag: array[0..7] of string[2] = ('↑', '↗', '→', '↘', '↓', '↙',
    '←', '↖');
  WideAttack: array[0..2] of Integer = (7, 1, 2);
function GetFiltrateItem(sItemName: string): pTItemFiltrate;
function GetOpenItem(sItemName: string): string;
procedure ChangeShowItem(sIteName: string);
procedure SaveWgInfo(sFileDir: string);
procedure LoadWgInfo(sFileDir: string);
procedure RefWgInfo();
procedure ChangeMonShow(sMonName: string; boFlag: Boolean);
function GetUseAmulet(nClas: byte): TClientItem;
function GetItembyName(sName: string): Integer;
procedure pAutoOpenItem(sName: string);
function PlayEatItem(sName: string; nClas: Integer): Integer;
function CheckBlockListSys(Ident: Integer; sMsg: string): Boolean;
procedure TaosAutoAmyounsul(nMagid: Integer);
implementation
uses MShare, CLMain, ClFunc, Hutil32, NeiGua, Fstate;

procedure RefWgInfo();
begin
  g_WgInfo.boShowRedHPLable := True; //显示血条
  g_WgInfo.boShowBlueMpLable := False; //显示蓝条
  g_WgInfo.boShowHPNumber := True; //数字显血
  g_WgInfo.boShowAllItem := True; //显示物品
  g_WgInfo.boShowAllItemFil := False; //显示过滤
  g_WgInfo.boCropsItemShow := False; //特殊变色显示
  g_WgInfo.boCropsItemHit := False; //特殊物品提示
  g_WgInfo.boAutoPuckUpItem := False; //自动捡物
  g_WgInfo.boAutoPuckItemFil := False; //捡取过滤
  g_WgInfo.boAutoDownDrup := True; //自动放药
  g_WgInfo.boAutoOpenItem := True; //自动解包
  g_WgInfo.boShowName := False; //显示人名
  g_WgInfo.boShowAllName := False; //显示全名
  g_WgInfo.boShowDura := False; //显示持久
  g_WgInfo.boCanRunHuman := True; //穿过人物
  g_WgInfo.boCanRunMon := True; //穿过怪物
  g_WgInfo.boCanRunNpc := False; //穿过NPC
  g_WgInfo.boCloseShift := False; //免Shift
  g_WgInfo.boParalyCan := False; //防石化
  g_WgInfo.boDuraAlert := False; //持久警告
  g_WgInfo.boShowLevel := False; //显示等级
  g_WgInfo.boMoveRedShow := False; //去血显示
  g_WgInfo.boBossHint := False; //BOSS提示

  g_WgInfo.boCropsMonHit := False; //特殊怪物接近提示
  g_WgInfo.boCropsAutoLock := False; //特殊怪物自动锁定
  g_WgInfo.boCropsChangeColor := False; //特殊怪物变色显示
  g_WgInfo.boBossHint := False; //特殊怪物变色显示
  //------------------------------------
  g_WgInfo.boAutoHp := False;
  g_WgInfo.boAutoHpCount := 10;
  g_WgInfo.boAutoCropsHp := False;
  g_WgInfo.boAutoCropsHpCount := 10;
  g_WgInfo.boAutoMp := False;
  g_WgInfo.boAutoMpCount := 10;
  g_WgInfo.boAutoCropsMp := False;
  g_WgInfo.boAutoCropsMpCount := 10;
  g_WgInfo.boAutoHpProtect := False;
  g_WgInfo.boAutoHpProtectCount := 10;
  g_WgInfo.boAutoDownHorse := True;

  g_WgInfo.boCanLongHit := False; //刀刀刺杀
  g_WgInfo.boCanWideHit := False; //智能半月
  g_WgInfo.boCanAutoFireHit := False; //自动烈火
  g_WgInfo.boCanFireSide := False; //烈火近身
  g_WgInfo.boCanLongHit2 := False;
  g_WgInfo.boCanShield := False; //自动开盾
  g_WgInfo.boCanShieldCls := False; //开盾类型
  g_WgInfo.boCanFirewind := False; //接近抗拒

    g_WgInfo.boCanAutoAddHp := False; //自动补血
  g_WgInfo.nCanAutoAddHpCount := 0; //补血线
  g_WgInfo.dwCanAutoAddHpTick := 0; //补血间隔
    g_WgInfo.boCanAutoAmyounsul := True; //自动放毒
  g_WgInfo.btCanAmyounsulCls := 0; //放毒类型
  g_WgInfo.boCanCrossingOver := True; //红绿毒互换
end;

procedure LoadWgInfo(sFileDir: string);
const
  IniClass = 'Assistant';
  sOpenItem = '%s'#9'%s';
  sItemFiltrate = '%s'#9'%s'#9'%s'#9'%s'#9'%s';
var
  INI: TINIFile;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
  StrList: TStringList;
  Str, sName, n1, n2, n3, n4, sFileName: string;
begin


    sFileName := sFileDir + AssistantDir;

    if not FileExists(sFileName) then
    begin
      sFileName := JsDefInfo + AssistantDir;
    end;

    if FileExists(sFileName) then
    begin
      ini := TINIFile.Create(sFileName);
      try

        begin
          g_WgInfo.boShowRedHPLable := Ini.ReadBool(IniClass, 'ShowRedHPLable',g_WgInfo.boShowRedHPLable);
          g_WgInfo.boShowBlueMpLable := Ini.ReadBool(IniClass,'ShowBlueMpLable', g_WgInfo.boShowBlueMpLable);
          g_WgInfo.boShowHPNumber := Ini.ReadBool(IniClass, 'ShowHPNumber',g_WgInfo.boShowHPNumber);
          g_WgInfo.boShowAllItem := Ini.ReadBool(IniClass, 'ShowAllItem',g_WgInfo.boShowAllItem);
          g_WgInfo.boShowAllItemFil := Ini.ReadBool(IniClass, 'ShowAllItemFil',g_WgInfo.boShowAllItemFil);
          g_WgInfo.coShowCropsColor := Ini.ReadInteger(IniClass,'ShowCropsColor', g_WgInfo.coShowCropsColor);
          g_WgInfo.boCropsItemShow := Ini.ReadBool(IniClass, 'CropsItemShow',g_WgInfo.boCropsItemShow);
          g_WgInfo.boCropsItemHit := Ini.ReadBool(IniClass, 'CropsItemHit',g_WgInfo.boCropsItemHit);
          g_WgInfo.boAutoPuckUpItem := Ini.ReadBool(IniClass, 'AutoPuckUpItem',g_WgInfo.boAutoPuckUpItem);
          g_WgInfo.boAutoPuckItemFil := Ini.ReadBool(IniClass, 'AutoPuckItemFil', g_WgInfo.boAutoPuckItemFil);
          g_WgInfo.boAutoDownDrup := Ini.ReadBool(IniClass, 'AutoDownDrup',g_WgInfo.boAutoDownDrup);
          g_WgInfo.boAutoOpenItem := Ini.ReadBool(IniClass, 'AutoOpenItem',g_WgInfo.boAutoOpenItem);
          g_WgInfo.boShowName := Ini.ReadBool(IniClass, 'ShowName',g_WgInfo.boShowName);
          g_WgInfo.boShowAllName := Ini.ReadBool(IniClass, 'ShowAllName',g_WgInfo.boShowAllName);
          g_WgInfo.boShowDura := Ini.ReadBool(IniClass, 'ShowDura',g_WgInfo.boShowDura);
          g_WgInfo.boCanRunHuman := Ini.ReadBool(IniClass, 'CanRunHuman',g_WgInfo.boCanRunHuman);
          g_WgInfo.boCanRunMon := Ini.ReadBool(IniClass, 'CanRunMon',g_WgInfo.boCanRunMon);
          g_WgInfo.boCanRunNpc := Ini.ReadBool(IniClass, 'CanRunNpc',g_WgInfo.boCanRunNpc);
          g_WgInfo.boCloseShift := Ini.ReadBool(IniClass, 'CloseShift',g_WgInfo.boCloseShift);
          g_WgInfo.boParalyCan := Ini.ReadBool(IniClass, 'ParalyCan',g_WgInfo.boParalyCan);
          g_WgInfo.boDuraAlert := Ini.ReadBool(IniClass, 'DuraAlert',g_WgInfo.boDuraAlert);
          g_WgInfo.boShowLevel := Ini.ReadBool(IniClass, 'ShowLevel', g_WgInfo.boShowLevel); //显示等级
          g_WgInfo.boMoveRedShow := Ini.ReadBool(IniClass, 'MoveRedShow',g_WgInfo.boMoveRedShow);
          g_WgInfo.boCropsMonHit := Ini.ReadBool(IniClass, 'CropsMonHit',g_WgInfo.boCropsMonHit);
          g_WgInfo.boCropsAutoLock := Ini.ReadBool(IniClass, 'CropsAutoLock',g_WgInfo.boCropsAutoLock);
          g_WgInfo.boCropsChangeColor := Ini.ReadBool(IniClass,'CropsChangeColor', g_WgInfo.boCropsChangeColor);
          g_WgInfo.nCropsColorEff := Ini.ReadInteger(IniClass, 'CropsColorEff',g_WgInfo.nCropsColorEff);
          g_WgInfo.boBossHint := Ini.ReadBool(IniClass, 'boBossHint',g_WgInfo.boBossHint);
          //-------------------------------------------------------------------------
                    g_WgInfo.boAutoHp := Ini.ReadBool(IniClass, 'AutoHp', g_WgInfo.boAutoHp);
          g_WgInfo.boAutoHpName := Ini.ReadString(IniClass, 'AutoHpName',g_WgInfo.boAutoHpName);
          g_WgInfo.boAutoHpTick := Ini.ReadInteger(IniClass, 'AutoHpTick',g_WgInfo.boAutoHpTick);
          g_WgInfo.boAutoHpCount := Ini.ReadInteger(IniClass, 'AutoHpCount',g_WgInfo.boAutoHpCount);
          g_WgInfo.boAutoCropsHp := Ini.ReadBool(IniClass, 'AutoCropsHp',g_WgInfo.boAutoCropsHp);
          g_WgInfo.boAutoCropsHpName := Ini.ReadString(IniClass,'AutoCropsHpName', g_WgInfo.boAutoCropsHpName);
          g_WgInfo.boAutoCropsHpTick := Ini.ReadInteger(IniClass,'AutoCropsHpTick', g_WgInfo.boAutoCropsHpTick);
          g_WgInfo.boAutoCropsHpCount := Ini.ReadInteger(IniClass,'AutoCropsHpCount', g_WgInfo.boAutoCropsHpCount);
          g_WgInfo.boAutoMp := Ini.ReadBool(IniClass, 'AutoMp',g_WgInfo.boAutoMp);
          g_WgInfo.boAutoMpName := Ini.ReadString(IniClass, 'AutoMpName',g_WgInfo.boAutoMpName);
          g_WgInfo.boAutoMpTick := Ini.ReadInteger(IniClass, 'AutoMpTick',g_WgInfo.boAutoMpTick);
          g_WgInfo.boAutoMpCount := Ini.ReadInteger(IniClass, 'AutoMpCount',g_WgInfo.boAutoMpCount);
          g_WgInfo.boAutoCropsHp := Ini.ReadBool(IniClass, 'AutoCropsMp',g_WgInfo.boAutoCropsHp);
          g_WgInfo.boAutoCropsMpName := Ini.ReadString(IniClass,'AutoCropsMpName', g_WgInfo.boAutoCropsMpName);
          g_WgInfo.boAutoCropsMpTick := Ini.ReadInteger(IniClass,'AutoCropsMpTick', g_WgInfo.boAutoCropsMpTick);
          g_WgInfo.boAutoCropsMpCount := Ini.ReadInteger(IniClass,'AutoCropsMpCount', g_WgInfo.boAutoCropsMpCount);
          g_WgInfo.boAutoHpProtect := Ini.ReadBool(IniClass, 'AutoHpProtect',g_WgInfo.boAutoHpProtect);
          g_WgInfo.boAutoHpProtectName := Ini.ReadString(IniClass,'AutoHpProtectName', g_WgInfo.boAutoHpProtectName);
          g_WgInfo.boAutoHpOrotectTick := Ini.ReadInteger(IniClass,'AutoHpOrotectTick', g_WgInfo.boAutoHpOrotectTick);
          g_WgInfo.boAutoHpProtectCount := Ini.ReadInteger(IniClass,'AutoHpProtectCount', g_WgInfo.boAutoHpProtectCount);

          g_WgInfo.boCanLongHit := Ini.ReadBool(IniClass, 'CanLongHit',g_WgInfo.boCanLongHit);
          g_WgInfo.boCanWideHit := Ini.ReadBool(IniClass, 'CanWideHit',g_WgInfo.boCanWideHit);
          g_WgInfo.boCanAutoFireHit := Ini.ReadBool(IniClass, 'CanAutoFireHit',g_WgInfo.boCanAutoFireHit);
          g_WgInfo.boCanFireSide := Ini.ReadBool(IniClass, 'CanFireSide',g_WgInfo.boCanFireSide);
          g_WgInfo.boCanLongHit2 := Ini.ReadBool(IniClass, 'CanLongHit2',g_WgInfo.boCanLongHit2);

          g_WgInfo.boCanShield := Ini.ReadBool(IniClass, 'CanShield',g_WgInfo.boCanShield);
          g_WgInfo.boCanShieldCls := Ini.ReadBool(IniClass, 'CanShieldCls',g_WgInfo.boCanShieldCls);
          g_WgInfo.boCanFirewind := Ini.ReadBool(IniClass, 'CanFirewind',g_WgInfo.boCanFirewind);
//----------------------------------------------------------------------------------------------
          g_WgInfo.boCanAutoAddHp := Ini.ReadBool(IniClass, 'CanAutoAddHp',g_WgInfo.boCanAutoAddHp);
          g_WgInfo.nCanAutoAddHpCount := Ini.ReadInteger(IniClass,'CanAutoAddHpCount', g_WgInfo.nCanAutoAddHpCount);
          g_WgInfo.dwCanAutoAddHpTick := Ini.ReadInteger(IniClass,'CanAutoAddHpTick', g_WgInfo.dwCanAutoAddHpTick);

          g_WgInfo.boCanCrossingOver := Ini.ReadBool(IniClass, 'CanCrossingOver', g_WgInfo.boCanCrossingOver);
          g_WgInfo.btCanAmyounsulCls := Ini.ReadInteger(IniClass, 'CanAmyounsulCls', g_WgInfo.btCanAmyounsulCls);
          g_WgInfo.boCanAutoAmyounsul := Ini.ReadBool(IniClass, 'CanAutoAmyounsul', g_WgInfo.boCanAutoAmyounsul);



        end;
      finally
        Ini.Free;
      end;
      end;
 //////////////////////////////////
   sFileName := sFileDir + MonHintDir;
    if (not FileExists(sFileName)) then
    begin
      sFileName := JsDefInfo + MonHintDir;
    end;
    if FileExists(sFileName) then
    begin
      g_CorpsMonList.Clear;
      g_CorpsMonList.LoadFromFile(sFileName);
    end;

//////////////////////////////////////////////////////////////////////////////////

   sFileName := sFileDir + BossHintDir;
    if (not FileExists(sFileName)) then
    begin
      sFileName := JsDefInfo + BossHintDir;
    end;
    if FileExists(sFileName) then
    begin
      g_BossMonList.Clear;
      g_BossMonList.LoadFromFile(sFileName);
    end;



    sFileName := sFileDir + ItemUntieDir;
    if (not FileExists(sFileName))  then
    begin
      sFileName := JsDefInfo + ItemUntieDir;
    end;
   
    sFileName := sFileDir + ItemFiltrateDir;
    if (not FileExists(sFileName)) then
    begin
      sFileName := JsDefInfo + ItemFiltrateDir;
    end;
    if FileExists(sFileName) then
    begin
      StrList := TStringList.Create;
      try
        StrList.Clear;
        StrList.LoadFromFile(sFileName);
        for I := 0 to StrList.Count - 1 do
        begin
          Str := StrList.Strings[I];
          Str := GetValidStr3(Str, sName, [#9]);
          Str := GetValidStr3(Str, n1, [#9]);
          Str := GetValidStr3(Str, n2, [#9]);
          Str := GetValidStr3(Str, n3, [#9]);
          if (sName <> '') and (n1 <> '') and (n2 <> '') and (n3 <> '') and (str
            <> '') then
          begin
            New(ItemFiltrate);
            with ItemFiltrate^ do
            begin
              sItemName := sName;
              if n1 = '1' then
                boItemShow := True
              else
                boItemShow := False;
              if n2 = '1' then
                boItemPick := True
              else
                boItemPick := False;
              if n3 = '1' then
                boItemCorps := True
              else
                boItemCorps := False;
              if str = '1' then
                boItemHit := True
              else
                boItemHit := False;
            end;
            g_ItemFiltrateList.Add(ItemFiltrate);
          end;
        end;
      finally
        StrList.Free;
      end;
    end;

    if Assigned(frmNeiGua) then
      frmNeiGua.RefWgBut;

end;

procedure SaveWgInfo(sFileDir: string);
const
  IniClass = 'Assistant';
  sOpenItem = '%s'#9'%s';
  sItemFiltrate = '%s'#9'%s'#9'%s'#9'%s'#9'%s';
var
  INI: TINIFile;
  I: integer;
  ItemFiltrate: pTItemFiltrate;
  OpenItem: pTOpenItem;
  StrList: TStringList;
  sName, s1, s2, s3, s4: string;
begin

    Ini := TINIFile.Create(sFileDir + AssistantDir);
    try
      begin
        Ini.WriteBool(IniClass, 'ShowRedHPLable', g_WgInfo.boShowRedHPLable);
        Ini.WriteBool(IniClass, 'ShowBlueMpLable', g_WgInfo.boShowBlueMpLable);
        Ini.WriteBool(IniClass, 'ShowHPNumber', g_WgInfo.boShowHPNumber);
        Ini.WriteBool(IniClass, 'ShowAllItem', g_WgInfo.boShowAllItem);
        Ini.WriteBool(IniClass, 'ShowAllItemFil', g_WgInfo.boShowAllItemFil);
        Ini.WriteInteger(IniClass, 'ShowCropsColor', g_WgInfo.coShowCropsColor);
        Ini.WriteBool(IniClass, 'CropsItemShow', g_WgInfo.boCropsItemShow);
        Ini.WriteBool(IniClass, 'CropsItemHit', g_WgInfo.boCropsItemHit);
        Ini.WriteBool(IniClass, 'AutoPuckUpItem', g_WgInfo.boAutoPuckUpItem);
        Ini.WriteBool(IniClass, 'AutoPuckItemFil', g_WgInfo.boAutoPuckItemFil);
        Ini.WriteBool(IniClass, 'AutoDownDrup', g_WgInfo.boAutoDownDrup);
        Ini.WriteBool(IniClass, 'AutoOpenItem', g_WgInfo.boAutoOpenItem);
        Ini.WriteBool(IniClass, 'ShowName', g_WgInfo.boShowName);
        Ini.WriteBool(IniClass, 'ShowAllName', g_WgInfo.boShowAllName);
        Ini.WriteBool(IniClass, 'ShowDura', g_WgInfo.boShowDura);

        Ini.WriteBool(IniClass, 'CanRunHuman', g_WgInfo.boCanRunHuman);
        Ini.WriteBool(IniClass, 'CanRunMon', g_WgInfo.boCanRunMon);
        Ini.WriteBool(IniClass, 'CanRunNpc', g_WgInfo.boCanRunNpc);
        Ini.WriteBool(IniClass, 'CloseShift', g_WgInfo.boCloseShift);
        Ini.WriteBool(IniClass, 'ParalyCan', g_WgInfo.boParalyCan);
        Ini.WriteBool(IniClass, 'DuraAlert', g_WgInfo.boDuraAlert);
        Ini.WriteBool(IniClass, 'ShowLevel', g_WgInfo.boShowLevel); //显示等级
        Ini.WriteBool(IniClass, 'MoveRedShow', g_WgInfo.boMoveRedShow);
        Ini.WriteBool(IniClass, 'CropsMonHit', g_WgInfo.boCropsMonHit);
        Ini.WriteBool(IniClass, 'CropsAutoLock', g_WgInfo.boCropsAutoLock);
        Ini.WriteBool(IniClass, 'CropsChangeColor',g_WgInfo.boCropsChangeColor);
        Ini.WriteInteger(IniClass, 'CropsColorEff', g_WgInfo.nCropsColorEff);
        Ini.WriteBool(IniClass, 'BossHint', g_WgInfo.boBossHint);

        Ini.WriteInteger(IniClass, 'CanAttackTick', g_WgInfo.dwCanAttackTick);
        Ini.WriteBool(IniClass, 'AutoHp', g_WgInfo.boAutoHp);
        Ini.WriteString(IniClass, 'AutoHpName', g_WgInfo.boAutoHpName);
        Ini.WriteInteger(IniClass, 'AutoHpTick', g_WgInfo.boAutoHpTick);
        Ini.WriteInteger(IniClass, 'AutoHpCount', g_WgInfo.boAutoHpCount);
        Ini.WriteBool(IniClass, 'AutoCropsHp', g_WgInfo.boAutoCropsHp);
        Ini.WriteString(IniClass, 'AutoCropsHpName',g_WgInfo.boAutoCropsHpName);
        Ini.WriteInteger(IniClass, 'AutoCropsHpTick',g_WgInfo.boAutoCropsHpTick);
        Ini.WriteInteger(IniClass, 'AutoCropsHpCount',g_WgInfo.boAutoCropsHpCount);
        Ini.WriteBool(IniClass, 'AutoMp', g_WgInfo.boAutoMp);
        Ini.WriteString(IniClass, 'AutoMpName', g_WgInfo.boAutoMpName);
        Ini.WriteInteger(IniClass, 'AutoMpTick', g_WgInfo.boAutoMpTick);
        Ini.WriteInteger(IniClass, 'AutoMpCount', g_WgInfo.boAutoMpCount);
        Ini.WriteBool(IniClass, 'AutoCropsMp', g_WgInfo.boAutoCropsHp);
        Ini.WriteString(IniClass, 'AutoCropsMpName',g_WgInfo.boAutoCropsMpName);
        Ini.WriteInteger(IniClass, 'AutoCropsMpTick',g_WgInfo.boAutoCropsMpTick);
        Ini.WriteInteger(IniClass, 'AutoCropsMpCount',g_WgInfo.boAutoCropsMpCount);
        Ini.WriteBool(IniClass, 'AutoHpProtect', g_WgInfo.boAutoHpProtect);
        Ini.WriteString(IniClass, 'AutoHpProtectName',g_WgInfo.boAutoHpProtectName);
        Ini.WriteInteger(IniClass, 'AutoHpOrotectTick',g_WgInfo.boAutoHpOrotectTick);
        Ini.WriteInteger(IniClass, 'AutoHpProtectCount',g_WgInfo.boAutoHpProtectCount);
        Ini.WriteBool(IniClass, 'CanLongHit', g_WgInfo.boCanLongHit);
        Ini.WriteBool(IniClass, 'CanWideHit', g_WgInfo.boCanWideHit);
        Ini.WriteBool(IniClass, 'CanAutoFireHit', g_WgInfo.boCanAutoFireHit);
        Ini.WriteBool(IniClass, 'CanFireSide', g_WgInfo.boCanFireSide);
        Ini.WriteBool(IniClass, 'CanLongHit2', g_WgInfo.boCanLongHit2);

        Ini.WriteBool(IniClass, 'CanShield', g_WgInfo.boCanShield);
        Ini.WriteBool(IniClass, 'CanShieldCls', g_WgInfo.boCanShieldCls);
        Ini.WriteBool(IniClass, 'CanFirewind', g_WgInfo.boCanFirewind);
        ///////////////////////////////////////////////////////
        Ini.WriteBool(IniClass, 'CanAutoAddHp', g_WgInfo.boCanAutoAddHp);
        Ini.WriteInteger(IniClass, 'CanAutoAddHpCount',g_WgInfo.nCanAutoAddHpCount);
        Ini.WriteInteger(IniClass, 'CanAutoAddHpTick',g_WgInfo.dwCanAutoAddHpTick);
        Ini.WriteBool(IniClass, 'CanCrossingOver', g_WgInfo.boCanCrossingOver);
        Ini.WriteInteger(IniClass, 'CanAmyounsulCls', g_WgInfo.btCanAmyounsulCls);
        Ini.WriteBool(IniClass, 'CanAutoAmyounsul', g_WgInfo.boCanAutoAmyounsul);


      end;
    finally
      Ini.Free;
    end;
   StrList := TStringList.Create;
    try
      try
        if g_CorpsMonList.Count > 0 then
          g_CorpsMonList.SaveToFile(sFileDir + MonHintDir);
      except
      end;

       try
        if g_BossMonList.Count > 0 then
           g_BossMonList.SaveToFile(sFileDir + BossHintDir);
      except
      end;

      try
        StrList.Clear;
        for I := 0 to g_ItemFiltrateList.Count - 1 do
        begin
          ItemFiltrate := g_ItemFiltrateList.Items[I];
          sName := ItemFiltrate.sItemName;
          if ItemFiltrate.boItemShow then
            s1 := '1'
          else
            s1 := '0';
          if ItemFiltrate.boItemPick then
            s2 := '1'
          else
            s2 := '0';
          if ItemFiltrate.boItemCorps then
            s3 := '1'
          else
            s3 := '0';
          if ItemFiltrate.boItemHit then
            s4 := '1'
          else
            s4 := '0';
          StrList.Add(Format(sItemFiltrate, [sName, s1, s2, s3, s4]));
        end;
        if StrList.Count > 0 then
          StrList.SaveToFile(sFileDir + ItemFiltrateDir);
      except
      end;
    finally
      StrList.Clear;
    end;
end;



//自动解包

procedure pAutoOpenItem(sName: string);
var
  II: integer;
  OpenItemName: string;
begin
  try
    OpenItemName := GetOpenItem(sName);
    if OpenItemName <> '' then
    begin
      for II := 0 to MAXBAGITEMCL - 1 do
      begin
        if CompareText(g_ItemArr[II].S.Name, OpenItemName) = 0 then
        begin
          FrmMain.EatOpenItem(II);
          break;
        end;
      end;
    end;
  except
    DebugOutStr('[Exception] UnWShare.pAutoOpenItem'); //程序自动增加
  end;
end;

function GetItembyName(sName: string): Integer;
var
  I: integer;
begin
  try //程序自动增加
    Result := -1;
    for I := MAXBAGITEMCL - 1 downto 0 do
    begin
      if g_ItemArr[I].S.Name = sName then
      begin
        Result := I;
        break;
      end;
    end;

  except //程序自动增加
    DebugOutStr('[Exception] UnWShare.GetItembyName'); //程序自动增加
  end; //程序自动增加
end;

function GetDrinkItem:integer;
var
  I: integer;
begin
  try //程序自动增加
    Result := -1;
    for I := MAXBAGITEMCL - 1 downto 0 do
    begin
      if (g_ItemArr[I].S.Name<>'') and (g_ItemArr[I].S.StdMode=60) then
      begin
        Result := I;
        break;
      end;
    end;

  except //程序自动增加
    DebugOutStr('[Exception]  GetDrinkItem'); //程序自动增加
  end; //程序自动增加
end;


//ncals 1 hp 2 mp 3特殊药品
function GetItembyNameEX(nClas:Integer): Integer;
var
  I: integer;
begin
  try //程序自动增加
    Result := -1;
    for I := MAXBAGITEMCL - 1 downto 0 do
    begin
      if (g_ItemArr[I].S.Name <> '') and (g_ItemArr[I].S.StdMode=0) then
      begin
        case nClas of
         1:
          begin
            if (g_ItemArr[I].S.AC>0) and (g_ItemArr[I].S.Shape<>1) then
             begin
               Result := I;
               break;
            end;
          end;
         2:
          begin
            if (g_ItemArr[I].S.MAC>0) and (g_ItemArr[I].S.Shape<>1) then
             begin
               Result := I;
               break;
            end;
          end;
          3:
          begin
            if (g_ItemArr[I].S.AC>0) and (g_ItemArr[I].S.Shape=1) then
             begin
               Result := I;
               break;
            end;
          end;
         end;
      end;
    end;

  except //程序自动增加
    DebugOutStr('[Exception] UnWShare.GetItembyNameEX'); //程序自动增加
  end; //程序自动增加
end;

//ncals 1 hp 2 mp 3特殊药品
function PlayEatItem(sName:string;nClas:Integer): Integer;
function GetItembyAniCount(nAniCount: Integer): Integer;
var
  I: integer;
begin
  try
    Result := -1;
    for I := MAXBAGITEMCL - 1 downto 0 do
    begin
      if (g_ItemArr[i].S.Name <> '') and
        (g_ItemArr[i].S.StdMode = 31) and
        (g_ItemArr[i].S.AniCount = nAniCount) then
      begin
        Result := i;
        break;
      end;
    end;
  except
    DebugOutStr('[Exception] UnWShare.GetItembyAniCount');
  end;
end;
procedure SetwgInfo(sName:string;nClas:Integer);
begin
  case nClas of
  1:g_wgInfo.boAutoHpName:=sName;
  2:g_wgInfo.boAutoMpName:=sName;
  3:g_wgInfo.boAutoCropsHpName:=sName;
  end;
end;
var
  II: integer;
begin

      Result := -1;
     if sName='' then
     begin //吃药名称为空的
      ii:=GetItembyNameEX(nClas); //按类型取包里药品
      if II>-1 then
      begin
       SetwgInfo(g_ItemArr[II].S.Name,nClas); //设置吃药名称
       FrmMain.EatItem(II);//吃药
       Result:=II;
      end else
      begin
         ii:=GetItembyAniCount(nClas); //取打包物品
         if II>-1 then
         begin
            FrmMain.EatOpenItem(II);//解包
            Result:=II;
         end;
      end;
     end else
     begin //已经设置了吃药名称的
        II := GetItembyName(sname); //查找包里有没有指定的药
        If II > -1 Then
        begin
          FrmMain.EatItem(II);//吃药
          Result:=II;
        end
        Else
        begin
           SetwgInfo('',nClas);//清空自动吃药的名称
           PlayEatItem('',nClas);
        end;
     end;

end;

procedure ChangeMonShow(sMonName: string; boFlag: Boolean);
var
  Actor: TActor;
  i: integer;
begin

    for I := 0 to PlayScene.m_ActorList.Count - 1 do
    begin
      Actor := TActor(PlayScene.m_ActorList.Items[I]);
      if Actor <> nil then
        if CompareText(sMonName, Actor.m_sUserName) = 0 then
          Actor.m_boChangeEff := boFlag;
    end;

end;

function GetFiltrateItem(sItemName: string): pTItemFiltrate;
var
  ItemFiltrate: pTItemFiltrate;
  I: integer;
begin

    Result := nil;
    for I := 0 to g_ItemFiltrateList.Count - 1 do
    begin
      ItemFiltrate := g_ItemFiltrateList.Items[I];
      if CompareText(sItemName, ItemFiltrate.sItemName) = 0 then
      begin
        Result := ItemFiltrate;
        break;
      end;
    end;

end;

function GetOpenItem(sItemName: string): string;
var
  I: integer;
  OpenItem: pTOpenItem;
begin

    Result := '';
    for I := 0 to High(g_OpenItemArray) do
    begin
      OpenItem := @g_OpenItemArray[I];
      if CompareText(sItemName, OpenItem.sItemName) = 0 then
      begin
        Result := OpenItem.sBItemName;
        break;
      end;
    end;

end;

procedure ChangeShowItem(sIteName: string);
var
  I: integer;
  DropItem: PTDropItem;
  ItemFiltrate: pTItemFiltrate;
begin
    for I := 0 to g_DropedItemList.Count - 1 do
    begin
      DropItem := g_DropedItemList.Items[I];
      if CompareText(sIteName, DropItem.Name) = 0 then
      begin
        ItemFiltrate := GetFiltrateItem(sIteName);
        DropItem.boItemPick := ItemFiltrate.boItemPick;
        DropItem.boItemShow := ItemFiltrate.boItemShow;
        DropItem.boItemCorps := ItemFiltrate.boItemCorps;
      end;
    end;

end;


function CheckBlockListSys(Ident: Integer; sMsg: string): Boolean;
var
  I: integer;
  sUserName: string;
begin
    Result := True;
    case Ident of
      SM_HEAR,
        SM_GROUPMESSAGE,
        SM_GUILDMESSAGE:
        begin
          GetValidStr3(sMsg, sUserName, [':']);
        end;
      SM_CRY:
        begin
          GetValidStr3(sMsg, sUserName, [':']);
          sUserName := RightStr(sUserName, Length(sUserName) - 3);
        end;
      SM_WHISPER: GetValidStr3(sMsg, sUserName, ['=']);
    end;
   { if sUserName <> '' then
    begin
      i := g_MyBlacklist.IndexOf(sUserName);
      if I > -1 then
        Result := False;
    end; }
end;


procedure TaosAutoAmyounsul(nMagid: Integer);
resourcestring
  sTest1 = '你的[%s]已经用完。';
var
  Item: TClientItem;
  nFlg: Byte;
  II: integer;
begin
    if (g_MySelf = nil) or (g_WaitingUseItem.Item.S.Name <> '') then
      exit;
    FillChar(Item, SizeOf(TClientItem), #0);
    case nMagid of
      6, 38:
        begin //用毒
          if g_wgInfo.boCanCrossingOver then
            Inc(g_wgInfo.btCanAmyounsulCls);
          if g_wgInfo.btCanAmyounsulCls > 1 then
            g_wgInfo.btCanAmyounsulCls := 0;
          nFlg := g_wgInfo.btCanAmyounsulCls + 1;
          if (g_UseItems[U_BUJUK].S.Name = '') or
            (g_UseItems[U_BUJUK].S.StdMode <> 25) or
            (g_UseItems[U_BUJUK].S.Shape <> nFlg) or
            (g_UseItems[U_BUJUK].Dura < 100) then
          begin
            Item := GetUseAmulet(nFlg);
            if Item.S.Name = '' then
            begin
              if nFlg = 1 then
                DScreen.AddChatBoardString(Format(sTest1, ['灰色药粉']), clWhite, clRed)
              else
                DScreen.AddChatBoardString(Format(sTest1, ['黄色药粉']), clWhite, clRed);
            end;
          end;
        end;
      13..19, 30, 52, 53:
        begin //用符
          if (g_UseItems[U_BUJUK].S.StdMode = 25) and
            (g_UseItems[U_BUJUK].S.Shape = 5) and
            (g_UseItems[U_BUJUK].Dura <= 100) then
            pAutoOpenItem(g_UseItems[U_BUJUK].S.Name);
          //护身符如果是最后一张就先解包
          if (g_UseItems[U_BUJUK].S.Name = '') or
            (g_UseItems[U_BUJUK].S.StdMode <> 25) or
            (g_UseItems[U_BUJUK].S.Shape <> 5) or
            (g_UseItems[U_BUJUK].Dura < 100) then
          begin
            Item := GetUseAmulet(5);
            if Item.S.Name = '' then
              DScreen.AddChatBoardString(Format(sTest1, ['护身符']), clWhite, clRed);
          end;
        end;
    end;
    //DScreen.AddHitMsg (Format(sTest1,[Item.S.Name]));
    if Item.S.Name <> '' then
    begin
      g_WaitingUseItem.Item := Item;
      g_WaitingUseItem.Index := U_BUJUK;
     // g_WaitingUseItem.Hero := False;
      FrmMain.SendTakeOnItem(U_BUJUK, Item.MakeIndex, Item.S.Name);
    end;
end;

//取符、毒，5为符，2为绿毒，3为红毒
function GetUseAmulet(nClas: byte): TClientItem;
var
  I: integer;
  Item: TClientItem;
begin
    //if nClas<>
    FillChar(Item, SizeOf(TClientItem), #0);
    for I := MAXBAGITEMCL - 1 downto 0 do
    begin
      if (g_ItemArr[I].S.Name <> '') and
        (g_ItemArr[I].S.StdMode = 25) and
        (g_ItemArr[I].S.Shape = nClas) and
        (g_ItemArr[I].Dura >= 100) then
      begin
        Item := g_ItemArr[I];
        g_ItemArr[I].S.Name := '';
        //DScreen.AddHitMsg (Item.S.Name);
        break;
      end;
    end;
    Result := Item;
end;






initialization
  begin
    g_ItemFiltrateList := TList.Create;
    g_CorpsMonList := TStringList.Create;
     g_BossMonList := TStringList.Create;
  end;

finalization
  begin
    g_ItemFiltrateList.Free;
    g_CorpsMonList.Free;
    //Boss
     g_BossMonList.Free;
  end;

end.

