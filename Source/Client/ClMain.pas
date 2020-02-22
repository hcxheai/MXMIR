unit ClMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JSocket, ExtCtrls, DXDraws, DirectX, DXClass, DrawScrn, NWGfig ,
  IntroScn, PlayScn, MapUnit, WIL, Grobal2, SDK,
  Actor, DIB, StdCtrls, CliUtil, HUtil32, EdCode,
  DWinCtl, ClFunc, magiceff, SoundUtil, DXSounds, clEvent, Wave, IniFiles,
  Spin, ComCtrls, Grids, Mpeg, Menus, Mask, MShare, Share;

const
   BO_FOR_TEST = FALSE;
   EnglishVersion = True; //TRUE;
   BoNeedPatch = TRUE;
   boOutbugStr: Boolean = TRUE;
   NEARESTPALETTEINDEXFILE = 'Data\npal.idx';

   MonImageDir = '.\Graphics\Monster\';
   NpcImageDir = '.\Graphics\Npc\';
   ItemImageDir = '.\Graphics\Items\';
   WeaponImageDir = '.\Graphics\Weapon\';
   HumImageDir = '.\Graphics\Human\';

type
  TKornetWorld = record
    CPIPcode:  string;
    SVCcode:   string;
    LoginID:   string;
    CheckSum:  string;
  end;

  TOneClickMode = (toNone, toKornetWorld);



  TfrmMain = class(TDxForm)
    CSocket: TClientSocket;
    Timer1: TTimer;
    MouseTimer: TTimer;
    WaitMsgTimer: TTimer;
    SelChrWaitTimer: TTimer;
    CmdTimer: TTimer;
    MinTimer: TTimer;
    SpeedHackTimer: TTimer;
    DXDraw: TDXDraw;
    WgTimer: TTimer;
    


    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DXDrawFinalize(Sender: TObject);
    procedure CSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure CSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure CSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXDrawDblClick(Sender: TObject);
    procedure WaitMsgTimerTimer(Sender: TObject);
    procedure SelChrWaitTimerTimer(Sender: TObject);
    procedure DXDrawClick(Sender: TObject);
    procedure CmdTimerTimer(Sender: TObject);
    procedure MinTimerTimer(Sender: TObject);
    procedure CheckHackTimerTimer(Sender: TObject);
    procedure SendTimeTimerTimer(Sender: TObject);
    procedure SpeedHackTimerTimer(Sender: TObject);
    procedure WgTimerTimer(Sender: TObject);
    procedure OutClmainall;
    procedure FormShow(Sender: TObject);
  private
    SocStr, BufferStr: string;
    WarningLevel: Integer;
    TimerCmd: TTimerCommand;
    MakeNewId: string;

    ActionLockTime: LongWord;
    LastHitTick: LongWord;
    ActionFailLock: Boolean;
    ActionFailLockTime:LongWord;
    FailAction, FailDir: integer;
    ActionKey: word;

    CursorSurface: TDirectDrawSurface;
    mousedowntime: longword;
    WaitingMsg: TDefaultMessage;
    WaitingStr: string;
    WhisperName: string;

    procedure HintBoss(actor:Tactor); //Boss��ʾ
    Procedure AutoPickUpItem(boFlag: Boolean = False);

    procedure ProcessKeyMessages;
    procedure ProcessActionMessages;
    procedure CheckSpeedHack (rtime: Longword);
    procedure DecodeMessagePacket (datablock: string);
    procedure ActionFailed;
    function  GetMagicByKey (Key: char): PTClientMagic;

 //   procedure UseMagic (tx, ty: integer; pcm: PTClientMagic);
    procedure UseMagicSpell (who, effnum, targetx, targety, magic_id: integer);
    procedure UseMagicFire (who, efftype, effnum, targetx, targety, target: integer);
    procedure UseMagicFireFail (who: integer);

    procedure CloseAllWindows;
    procedure ClearDropItems;
    procedure ResetGameVariables;
    procedure ChangeServerClearGameVariables;
    procedure _DXDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AttackTarget (target: TActor);

    function  CheckDoorAction (dx, dy: integer): Boolean;
    procedure ClientGetPasswdSuccess (body: string);
    procedure ClientGetNeedUpdateAccount (body: string);
    procedure ClientGetSelectServer;
    procedure ClientGetPasswordOK(Msg:TDefaultMessage;sBody:String);
    procedure ClientGetReceiveChrs (body: string);
    procedure ClientGetStartPlay (body: string);
    procedure ClientGetReconnect (body: string);
    procedure ClientGetServerConfig(Msg:TDefaultMessage;sBody:String);
    procedure ClientGetMapDescription (Msg:TDefaultMessage;sBody:String);
    procedure ClientGetGameGoldName (Msg:TDefaultMessage;sBody:String);
    Procedure ClientGetMoveHMShow(Actor: TActor; Param, Tag: Word);
    Procedure ClientGetMonMoveHMShow(Actor: TActor; Param, nTag: Word; boDis:
      Boolean);
    procedure ClientGetAdjustBonus (bonus: integer; body: string);
    procedure ClientGetAddItem (body: string);
    procedure ClientGetUpdateItem (body: string);
    procedure ClientGetDelItem (body: string);
    procedure ClientGetDelItems (body: string);
    procedure ClientGetBagItmes (body: string);
    procedure ClientGetDropItemFail (iname: string; sindex: integer);
    procedure ClientGetShowItem (itemid, x, y, looks: integer; itmname: string);
    procedure ClientGetHideItem (itemid, x, y: integer);
    procedure ClientGetSenduseItems (body: string);
    procedure ClientGetSendAddUseItems (body: string);
    procedure ClientGetAddMagic (body: string);
    procedure ClientGetDelMagic (magid: integer);
    procedure ClientGetMyMagics (body: string);
    procedure ClientGetMagicLvExp (magid, maglv, magtrain: integer);
    procedure ClientGetDuraChange (uidx, newdura, newduramax: integer);
    procedure ClientGetMerchantSay (merchant, face: integer; saying: string);
    procedure ClientGetSendGoodsList (merchant, count: integer; body: string);
    procedure ClientGetSendMakeDrugList (merchant: integer; body: string);
    procedure ClientGetSendUserSell (merchant: integer);
    procedure ClientGetSendUserRepair (merchant: integer);
    procedure ClientGetSendUserStorage (merchant: integer);
    procedure ClientGetSaveItemList (merchant: integer; bodystr: string);
    procedure ClientGetSendDetailGoodsList (merchant, count, topline: integer; bodystr: string);
    procedure ClientGetSendNotice (body: string);
    procedure ClientGetGroupMembers (bodystr: string);
    procedure ClientGetOpenGuildDlg (bodystr: string);
    procedure ClientGetSendGuildMemberList (body: string);
    procedure ClientGetDealRemoteAddItem (body: string);
    procedure ClientGetDealRemoteDelItem (body: string);
    procedure ClientGetReadMiniMap (mapindex: integer);
    procedure ClientGetChangeGuildName (body: string);
    procedure ClientGetSendUserState (body: string);
    procedure DrawEffectHum(nType,nX,nY:Integer);
    procedure ClientGetNeedPassword(Body:String);
    procedure ClientGetPasswordStatus(Msg:pTDefaultMessage;Body:String);
    procedure ClientGetRegInfo(Msg:pTDefaultMessage;Body:String);

    procedure SetInputStatus();
    procedure CmdShowHumanMsg(sParam1, sParam2, sParam3, sParam4,
      sParam5: String);
    procedure ShowHumanMsg(Msg: pTDefaultMessage);
    procedure SendPowerBlock;

  public
    LoginId, LoginPasswd, CharName: string;
    Certification: integer;
    ActionLock: Boolean;
    //MainSurface: TDirectDrawSurface;

 //   NpcImageList:TList;
   // ItemImageList:TList;
   // WeaponImageList:TList;
   // HumImageList:TList;
    DXRETime:LongWord;

    procedure UseMagic(tx, ty: integer; pcm: PTClientMagic; boFlag: Boolean =
      False);
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure ProcOnIdle;
    procedure AppOnIdle (Sender: TObject; var Done: Boolean);
    procedure AppLogout;
    procedure AppExit;
    procedure PrintScreenNow;
    procedure EatItem (idx: integer);

    Procedure EatOpenItem(idx: integer);
    Procedure OpenEatItem(idx: integer; sIteName: String);

    procedure SendClientMessage (msg, Recog, param, tag, series: integer);
    procedure SendLogin (uid, passwd: string);
    procedure SendNewAccount (ue: TUserEntry; ua: TUserEntryAdd);
    procedure SendUpdateAccount (ue: TUserEntry; ua: TUserEntryAdd);
    procedure SendSelectServer (svname: string);
    procedure SendChgPw (id, passwd, newpasswd: string);
    procedure SendNewChr (uid, uname, shair, sjob, ssex: string);
    procedure SendQueryChr;
    procedure SendDelChr (chrname: string);
    procedure SendSelChr (chrname: string);
    procedure SendRunLogin;
    procedure SendSay (str: string);
    procedure SendActMsg (ident, x, y, dir: integer);
    procedure SendSpellMsg (ident, x, y, dir, target: integer);
    procedure SendQueryUserName (targetid, x, y: integer);
    procedure SendDropItem (name: string; itemserverindex: integer);
    procedure SendPickup;
    procedure SendTakeOnItem (where: byte; itmindex: integer; itmname: string);
    procedure SendTakeOffItem (where: byte; itmindex: integer; itmname: string);
    procedure SendEat (itmindex: integer; itmname: string);
    procedure SendButchAnimal (x, y, dir, actorid: integer);
    procedure SendMagicKeyChange (magid: integer; keych: char);
    procedure SendMerchantDlgSelect (merchant: integer; rstr: string);
    procedure SendQueryPrice (merchant, itemindex: integer; itemname: string);
    procedure SendQueryRepairCost (merchant, itemindex: integer; itemname: string);
    procedure SendSellItem (merchant, itemindex: integer; itemname: string);
    procedure SendRepairItem (merchant, itemindex: integer; itemname: string);
    procedure SendStorageItem (merchant, itemindex: integer; itemname: string);
    procedure SendGetDetailItem (merchant, menuindex: integer; itemname: string);
    procedure SendBuyItem (merchant, itemserverindex: integer; itemname: string);
    procedure SendTakeBackStorageItem (merchant, itemserverindex: integer; itemname: string);
    procedure SendMakeDrugItem (merchant: integer; itemname: string);
    procedure SendDropGold (dropgold: integer);
    procedure SendGroupMode (onoff: Boolean);
    procedure SendCreateGroup (withwho: string);
    procedure SendWantMiniMap;
    procedure SendDealTry; //�տ� ����� �ִ��� �˻�
    procedure SendGuildDlg;
    procedure SendCancelDeal;
    procedure SendAddDealItem (ci: TClientItem);
    procedure SendDelDealItem (ci: TClientItem);
    procedure SendChangeDealGold (gold: integer);
    procedure SendDealEnd;
    procedure SendAddGroupMember (withwho: string);
    procedure SendDelGroupMember (withwho: string);
    procedure SendGuildHome;
    procedure SendGuildMemberList;
    procedure SendGuildAddMem (who: string);
    procedure SendGuildDelMem (who: string);
    procedure SendGuildUpdateNotice (notices: string);
    procedure SendGuildUpdateGrade (rankinfo: string);
    procedure SendSpeedHackUser;  //SpeedHaker ����ڸ� ������ �뺸�Ѵ�.
    procedure SendAdjustBonus (remain: integer; babil: TNakedAbility);
    procedure SendPassword(sPassword:String;nIdent:Integer);
    
    function  TargetInSwordLongAttackRange (ndir: integer): Boolean;
    function  TargetInSwordWideAttackRange (ndir: integer): Boolean;
    function  TargetInSwordCrsAttackRange(ndir: integer): Boolean;
    procedure OnProgramException (Sender: TObject; E: Exception);
    procedure SendSocket (sendstr: string);
    function  ServerAcceptNextAction: Boolean;
    function  CanNextAction: Boolean;
    function  CanNextHit: Boolean;
    function  IsUnLockAction (action, adir: integer): Boolean;
    procedure ActiveCmdTimer (cmd: TTimerCommand);
    function  IsGroupMember (uname: string): Boolean;
    procedure SelectChr(sChrName:String);

//    function  GetNpcImg(wAppr: Word; var WMImage: TWMImages): Boolean;
    function  GetWStateImg(Idx:Integer): TDirectDrawSurface;overload;
    function  GetWStateImg(Idx:Integer;var ax,ay:integer): TDirectDrawSurface;overload;
    function  GetWWeaponImg(Weapon,m_btSex,nFrame:Integer;var ax,ay:integer): TDirectDrawSurface;
    function  GetWHumImg(Dress,m_btSex,nFrame:Integer;var ax,ay:integer): TDirectDrawSurface;
    procedure ProcessCommand(sData:String);
  end;
  function IsDebug():Boolean;
  function IsDebugA():Boolean;
  function  CheckMirProgram: Boolean;
  procedure PomiTextOut (dsurface: TDirectDrawSurface; x, y: integer; str: string);
  procedure WaitAndPass (msec: longword);
  function  GetRGB (c256: byte): integer;
  procedure DebugOutStr (msg: string);

var
  nLeft            :integer = 10;
  nTop             :integer = 10;
  nWidth           :integer;
  nHeight          :integer;
  g_boShowMemoLog  :Boolean = False;
  g_boShowRecog    :Integer = 0;
  frmMain          :TfrmMain;
  DScreen          :TDrawScreen;
  IntroScene       :TIntroScene;
  LoginScene       :TLoginScene;
  SelectChrScene   :TSelectChrScene;
  PlayScene        :TPlayScene;
  LoginNoticeScene :TLoginNotice;
  code: byte = 1;
  busy: Boolean = FALSE;
  LocalLanguage    :TImeMode = imSHanguel;
  
  MP3              :TMPEG;
  TestServerAddr   :String = '127.0.0.1';
  BGMusicList      :TStringList;
  //DObjList: TList;  //�ٴڿ� ����� ������ ǥ��
  EventMan         :TClEventManager;
  KornetWorld      :TKornetWorld;
  Map              :TMap;
  BoOneClick       :Boolean;
  OneClickMode     :TOneClickMode;
  m_boPasswordIntputStatus:Boolean = False;

implementation

uses
  FState, DlgConfig, gShare,NeiGua;

{$R *.DFM}
var
  ShowMsgActor:TActor;


function  CheckMirProgram: Boolean;
var
   pstr, cstr: array[0..255] of char;
   mirapphandle: HWnd;
begin
   Result := FALSE;
   StrPCopy (pstr, 'legend of mir');
   mirapphandle := FindWindow (nil, pstr);
   if (mirapphandle <> 0) and (mirapphandle <> Application.Handle) then begin
{$IFNDEF COMPILE}
      SetActiveWindow(mirapphandle);
      Result := TRUE;
{$ENDIF}
      exit;
   end;
end;

procedure PomiTextOut (dsurface: TDirectDrawSurface; x, y: integer; str: string);
var
   i, n: integer;
   d: TDirectDrawSurface;
begin
   for i:=1 to Length(str) do begin
      n := byte(str[i]) - byte('0');
      if n in [0..9] then begin //���ڸ� ��
         d := g_WMainImages.Images[30 + n];
         if d <> nil then
            dsurface.Draw (x + i*8, y, d.ClientRect, d, TRUE);
      end else begin
         if str[i] = '-' then begin
            d := g_WMainImages.Images[40];
            if d <> nil then
               dsurface.Draw (x + i*8, y, d.ClientRect, d, TRUE);
         end;
      end;
   end;
end;

procedure WaitAndPass (msec: longword);
var
   start: longword;
begin
   start := GetTickCount;
   while GetTickCount - start < msec do begin
      Application.ProcessMessages;
   end;
end;

function  GetRGB (c256: byte): integer;
begin
   Result := RGB(FrmMain.DxDraw.DefColorTable[c256].rgbRed,
                 FrmMain.DxDraw.DefColorTable[c256].rgbGreen,
                 FrmMain.DxDraw.DefColorTable[c256].rgbBlue);
end;

procedure DebugOutStr (msg: string);
var
  flname: string;
  fhandle: TextFile;
begin
  //DScreen.AddChatBoardString(msg,clWhite, clBlack);
  if not boOutbugStr then Exit;
  flname := '.\!debug.txt';
  if FileExists(flname) then begin
    AssignFile(fhandle, flname);
    Append(fhandle);
  end else begin
    AssignFile(fhandle, flname);
    Rewrite(fhandle);
  end;
  WriteLn(fhandle, TimeToStr(Time) + ' ' + Msg);
  CloseFile(fhandle);
end;

function KeyboardHookProc (Code: Integer; WParam: Longint; var Msg: TMsg): Longint; stdcall;
begin
   Result:=0;//jacky
   if ((WParam = 9){ or (WParam = 13)}) and (g_nLastHookKey = 18) and (GetTickCount - g_dwLastHookKeyTime < 500) then begin
      if FrmMain.WindowState <> wsMinimized then begin
         FrmMain.WindowState := wsMinimized;
      end else
         Result := CallNextHookEx(g_ToolMenuHook, Code, WParam, Longint(@Msg));
      exit;
   end;
   g_nLastHookKey := WParam;
   g_dwLastHookKeyTime := GetTickCount;

   Result := CallNextHookEx(g_ToolMenuHook, Code, WParam, Longint(@Msg));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  flname, str: string;
  ini: TIniFile;
  FtpConf:TIniFile;
begin
  ini := nil;
  FtpConf := nil;



  g_AutoPickupList :=TList.Create;
 // g_ShowItemList   :=TGList.Create;

  g_DWinMan:=TDWinManager.Create(Self);
  g_DXDraw:=DXDraw;
   Randomize;
   ini := TIniFile.Create ('.\mir.ini');
   if ini <> nil then begin
      if EnglishVersion then begin
         g_sServerAddr := ini.ReadString ('Setup', 'ServerAddr', g_sServerAddr);
         g_nServerPort := ini.ReadInteger ('Setup', 'ServerPort', g_nServerPort);
         LocalLanguage := imOpen;
      end;

      g_boFullScreen := ini.ReadBool ('Setup', 'FullScreen', g_boFullScreen);
      g_sCurFontName := ini.ReadString ('Setup', 'FontName', g_sCurFontName);
      g_sLogoText    := ini.ReadString('Server','Server1Caption',g_sLogoText);
      g_sMainParam1:=Ini.ReadString('Setup', 'Param1', '');
      g_sMainParam2:=Ini.ReadString('Setup', 'Param2', '');
      ini.Free;
   end;
  // FtpConf:=TIniFile.Create('.\ftp.ini');

//{$IF CLIENTTYPE = RMCLIENT} //�������ͻ��˵ı�ʶ����ȷ,�����Ȩ��
  //  g_sLogoText:=RMCLIENTTITLE;
//{$ELSE}
 //  if FtpConf <> nil then begin
   //  g_sLogoText:=FtpConf.ReadString('Server','Server1Caption',g_sLogoText);
   //  FtpConf.Free;
 // // end;
//{$IFEND}

   Caption:=g_sLogoText;

   if g_boFullScreen then begin
   StoreWindow;
    //DXDraw.Cursor := crDefault;
    DXDraw.display.BitCount := 32;
    DXDraw.Options := DXDraw.Options + [doFullScreen];
    end
    else
    begin
    RestoreWindow;
    DXDraw.Options := DXDraw.Options - [doFullScreen];
    frmMain.BorderStyle := bsSingle;
    frmMain.Left := -5;  //�˲����Ǵ��ڻ�ʱ��������ҳ������ʾ����
    frmMain.Top := -29;  //�˲����Ǵ��ڻ�ʱ��������ҳ������ʾ����
    end;
   
   LoadWMImagesLib(nil);
 //  NpcImageList:=TList.Create;
  // ItemImageList:=TList.Create;
  // WeaponImageList:=TList.Create;
  // HumImageList:=TList.Create;
   g_DXSound:=TDXSound.Create(Self);
   g_DXSound.Initialize;
     

   DXDraw.Display.Width:=SCREENWIDTH;
   DXDraw.Display.Height:=SCREENHEIGHT;
   //
  if g_DXSound.Initialized then begin
    g_Sound:= TSoundEngine.Create (g_DXSound.DSound);
    MP3:=TMPEG.Create(nil);
  end else begin
    g_Sound:= nil;
    MP3:=nil;
  end;

   g_ToolMenuHook := SetWindowsHookEx(WH_KEYBOARD, @KeyboardHookProc, 0, GetCurrentThreadID);

   g_SoundList := TStringList.Create;
   BGMusicList:=TStringList.Create;
   
   flname := '.\wav\mirsound.lst';
   LoadSoundList (flname);
   flname := '.\wav\BGList.lst';
   LoadBGMusicList(flname);
   //if FileExists (flname) then
   //   SoundList.LoadFromFile (flname);

   DScreen := TDrawScreen.Create;
   IntroScene := TIntroScene.Create;
   LoginScene := TLoginScene.Create;
   SelectChrScene := TSelectChrScene.Create;
   PlayScene := TPlayScene.Create;
   LoginNoticeScene := TLoginNotice.Create;

   Map              := TMap.Create;
   g_DropedItemList := TList.Create;
   g_MagicList        := TList.Create;
   g_FreeActorList    := TList.Create;
   //DObjList := TList.Create;
   EventMan := TClEventManager.Create;
   g_ChangeFaceReadyList := TList.Create;
   g_ServerList:=TStringList.Create;
   g_MySelf := nil;
   FillChar (g_UseItems, sizeof(TClientItem)*13, #0);
//   FillChar (UseItems, sizeof(TClientItem)*9, #0);
   FillChar (g_ItemArr, sizeof(TClientItem)*MAXBAGITEMCL, #0);
   FillChar (g_DealItems, sizeof(TClientItem)*10, #0);
   FillChar (g_DealRemoteItems, sizeof(TClientItem)*20, #0);
   g_SaveItemList := TList.Create;
   g_MenuItemList := TList.Create;
   g_WaitingUseItem.Item.S.Name := '';  //����â ������ ��Ű��� �ӽ�����
   g_EatingItem.S.Name := '';

   g_nTargetX := -1;
   g_nTargetY := -1;
   g_TargetCret := nil;
   g_FocusCret := nil;
   g_FocusItem := nil;
   g_MagicTarget := nil;
   g_nDebugCount := 0;
   g_nDebugCount1 := 0;
   g_nDebugCount2 := 0;
   g_nTestSendCount := 0;
   g_nTestReceiveCount := 0;
   g_boServerChanging := FALSE;
   g_boBagLoaded := FALSE;
   g_boAutoDig := FALSE;

   g_dwLatestClientTime2 := 0;
   g_dwFirstClientTime := 0;
   g_dwFirstServerTime := 0;
   g_dwFirstClientTimerTime := 0;
   g_dwLatestClientTimerTime := 0;
   g_dwFirstClientGetTime := 0;
   g_dwLatestClientGetTime := 0;

   g_nTimeFakeDetectCount := 0;
   g_nTimeFakeDetectTimer := 0;
   g_nTimeFakeDetectSum := 0;

   g_dwSHGetTime := 0;
   g_dwSHTimerTime := 0;
   g_nSHFakeCount := 0;


   g_nDayBright := 3; //��
   g_nAreaStateValue := 0;
   g_ConnectionStep := cnsLogin;
   g_boSendLogin:=False;
   g_boServerConnected := FALSE;
   SocStr := '';
   WarningLevel := 0;  //�ҷ���Ŷ ���� Ƚ�� (��Ŷ���� ���ɼ� ����)
   ActionFailLock := FALSE;
   g_boMapMoving := FALSE;
   g_boMapMovingWait := FALSE;
   g_boCheckBadMapMode := FALSE;
   g_boCheckSpeedHackDisplay := FALSE;
   g_boViewMiniMap := FALSE;
   g_boShowGreenHint := FALSE;
   g_boShowWhiteHint := FALSE;
   FailDir := 0;
   FailAction := 0;
   g_nDupSelection := 0;


   g_dwLastAttackTick := GetTickCount;
   g_dwLastMoveTick := GetTickCount;
   g_dwLatestSpellTick := GetTickCount;

   g_dwAutoPickupTick := GetTickCount;
   g_boFirstTime := TRUE;
   g_boItemMoving := FALSE;
   g_boDoFadeIn := FALSE;
   g_boDoFadeOut := FALSE;
   g_boDoFastFadeOut := FALSE;
   g_boAttackSlow := FALSE;
   g_boMoveSlow := FALSE;
   g_boNextTimePowerHit := FALSE;
   g_boCanLongHit := FALSE;
   g_boCanWideHit := FALSE;
   g_boCanCrsHit   := False;
   g_boCanTwnHit   := False;

   g_boNextTimeFireHit := FALSE;

   g_boNoDarkness := FALSE;
   g_SoftClosed := FALSE;
   g_boQueryPrice := FALSE;
   g_sSellPriceStr := '';

   g_boAllowGroup := FALSE;
   g_GroupMembers := TStringList.Create;

   MainWinHandle := DxDraw.Handle;

   //��Ŭ��, �ڳݿ��� ��..
   BoOneClick := False;
   OneClickMode := toNone;

   g_boSound:=True;
   g_boBGSound:=True;

   if g_sMainParam1 = '' then begin
     CSocket.Address:=g_sServerAddr;
     CSocket.Port:=g_nServerPort;
   end else begin
      if (g_sMainParam1 <> '') and (g_sMainParam2 = '') then
         CSocket.Address := g_sMainParam1;
      if (g_sMainParam2 <> '') and (g_sMainParam3 = '') then begin
         CSocket.Address := g_sMainParam1;
         CSocket.Port := Str_ToInt (g_sMainParam2, 0);
      end;
      if (g_sMainParam3 <> '') then begin
         if CompareText (g_sMainParam1, '/KWG') = 0 then begin
            {
            CSocket.Address := kornetworldaddress;  //game.megapass.net';
            CSocket.Port := 9000;
            BoOneClick := TRUE;
            OneClickMode := toKornetWorld;
            with KornetWorld do begin
               CPIPcode := MainParam2;
               SVCcode  := MainParam3;
               LoginID  := MainParam4;
               CheckSum := MainParam5; //'dkskxhdkslxlkdkdsaaaasa';
            end;
            }
         end else begin
            CSocket.Address := g_sMainParam2;
            CSocket.Port := Str_ToInt (g_sMainParam3, 0);
            BoOneClick := TRUE;
         end;
      end;
   end;
   if BO_FOR_TEST then
      CSocket.Address := TestServerAddr;

   CSocket.Active:=True;

   //MainSurface := nil;
   DebugOutStr ('----------------------- started ------------------------');

   Application.OnException := OnProgramException;
   Application.OnIdle := AppOnIdle;
   
end;

procedure TfrmMain.OnProgramException (Sender: TObject; E: Exception);
begin
   DebugOutStr (E.Message);
end;

procedure TfrmMain.WMSysCommand(var Message: TWMSysCommand);
begin
{   with Message do begin
      if (CmdType and $FFF0) = SC_KEYMENU then begin
         if (Key = VK_TAB) or (Key = VK_RETURN) then begin
            FrmMain.WindowState := wsMinimized;
         end else
            inherited;
      end else
         inherited;
   end;
}
   inherited;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   OutClmainall;
end;

procedure TfrmMain.OutClmainall;
var
  I: Integer;
begin
 // ClearShowItemList();
//  g_ShowItemList.Free;
//  g_ShowItemList:=nil;
  g_AutoPickupList.Free;
  g_AutoPickupList:=nil;
   if g_ToolMenuHook <> 0 then UnhookWindowsHookEx(g_ToolMenuHook);
   //SoundCloseProc;
   //DXTimer.Enabled := FALSE;
   Timer1.Enabled := FALSE;
   MinTimer.Enabled := FALSE;

   UnLoadWMImagesLib();


   {for I := 0 to NpcImageList.Count - 1 do begin
     TWMImages(NpcImageList.Items[I]).Finalize;
   end;
   for I := 0 to ItemImageList.Count - 1 do begin
     TWMImages(ItemImageList.Items[I]).Finalize;
   end;
   for I := 0 to WeaponImageList.Count - 1 do begin
     TWMImages(WeaponImageList.Items[I]).Finalize;
   end;
   for I := 0 to HumImageList.Count - 1 do begin
     TWMImages(HumImageList.Items[I]).Finalize;
   end;   }

   DScreen.Finalize;
   PlayScene.Finalize;
   LoginNoticeScene.Finalize;

   DScreen.Free;
   IntroScene.Free;
   LoginScene.Free;
   SelectChrScene.Free;
   PlayScene.Free;
   LoginNoticeScene.Free;
   g_SaveItemList.Free;
   g_MenuItemList.Free;
  
   DebugOutStr ('----------------------- closed -------------------------');
   Map.Free;
   g_DropedItemList.Free;
   g_MagicList.Free;
   g_FreeActorList.Free;
   g_ChangeFaceReadyList.Free;

   g_ServerList.Free;
   //if MainSurface <> nil then MainSurface.Free;

   g_Sound.Free;
   g_SoundList.Free;
   BGMusicList.Free;
   //DObjList.Free;
   EventMan.Free;
  // NpcImageList.Free;
  // ItemImageList.Free;
  // WeaponImageList.Free;
  // HumImageList.Free;



   g_DXSound.Finalize;  
   FreeAndNil(g_DXSound);
   g_DWinMan.Free;
   Application.Terminate;
end;

function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
begin
  with Result do
  begin
    rgbRed := Src.rgbRed+((Dest.rgbRed-Src.rgbRed)*Percent div 256);
    rgbGreen := Src.rgbGreen+((Dest.rgbGreen-Src.rgbGreen)*Percent div 256);
    rgbBlue := Src.rgbBlue+((Dest.rgbBlue-Src.rgbBlue)*Percent div 256);
    rgbReserved := 0;
  end;
end;

procedure TfrmMain.DXDrawInitialize(Sender: TObject);
begin

   if g_boFirstTime then begin
      g_boFirstTime := FALSE;

      DxDraw.SurfaceWidth := SCREENWIDTH;
      DxDraw.SurfaceHeight := SCREENHEIGHT;

{$IF USECURSOR = DEFAULTCURSOR}
      DxDraw.Cursor:=crHourGlass;
{$ELSE}
      DxDraw.Cursor:=crNone;
{$IFEND}
      
      DxDraw.Surface.Canvas.Font.Assign (FrmMain.Font);

      FrmMain.Font.Name := g_sCurFontName;
      FrmMain.Canvas.Font.Name := g_sCurFontName;
      DxDraw.Surface.Canvas.Font.Name := g_sCurFontName;
      PlayScene.EdChat.Font.Name := g_sCurFontName;

      //MainSurface := TDirectDrawSurface.Create (frmMain.DxDraw.DDraw);
      //MainSurface.SystemMemory := TRUE;
      //MainSurface.SetSize (SCREENWIDTH, SCREENHEIGHT);

      InitWMImagesLib(DxDraw);

    InitMonImg();
    InitObjectImg();
    InitWeaponImg();
    InitHumImg();
    
      DxDraw.DefColorTable := g_WMainImages.MainPalette;
      DxDraw.ColorTable := DxDraw.DefColorTable;
      DxDraw.UpdatePalette;

      //256 Blend utility
     // if not LoadNearestIndex (NEARESTPALETTEINDEXFILE) then begin
       //  BuildNearestIndex (DxDraw.ColorTable);
       //  SaveNearestIndex (NEARESTPALETTEINDEXFILE);
    //  end;
     // BuildColorLevels (DxDraw.ColorTable);

      DScreen.Initialize;
      PlayScene.Initialize;
      FrmDlg.Initialize;



      if doFullScreen in DxDraw.Options then begin
         //Screen.Cursor := crNone;
      end else begin
         FrmMain.ClientWidth := SCREENWIDTH;
         FrmMain.ClientHeight := SCREENHEIGHT;
         g_boNoDarkness := TRUE;
       //  g_boUseDIBSurface := TRUE;
         //frmMain.BorderStyle := bsSingle;
      end;

      g_ImgMixSurface := TDirectDrawSurface.Create (frmMain.DxDraw.DDraw);
      g_ImgMixSurface.SystemMemory := TRUE;
      g_ImgMixSurface.SetSize (800, 600);
      g_MiniMapSurface := TDirectDrawSurface.Create (frmMain.DxDraw.DDraw);
      g_MiniMapSurface.SystemMemory := TRUE;
      g_MiniMapSurface.SetSize (540, 360);
      //DxDraw.Surface.SystemMemory := TRUE;
   end;

end;

procedure TfrmMain.DXDrawFinalize(Sender: TObject);
begin
   //DXTimer.Enabled := FALSE;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //Savebags ('.\Data\' + ServerName + '.' + CharName + '.itm', @ItemArr);
   //DxTimer.Enabled := FALSE;
     if g_MySelf <> nil then
    SaveUserConfig(CharName);
end;


{------------------------------------------------------------}

procedure TfrmMain.ProcOnIdle;
var
   done: Boolean;
begin
   AppOnIdle (self, done);
   //DXTimerTimer (self, 0);
end;

procedure TfrmMain.AppOnIdle (Sender: TObject; var Done: Boolean);
Resourcestring
  Logo1 = '������Ϸ����';
  Logo2 =
    '���Ʋ�����Ϸ���ܾ�������Ϸ��ע�����ұ�����������ƭ�ϵ����ʶ���Ϸ���ԣ�';
  Logo3 =
    '������Ϸ����������ʱ�䣬���ܽ��������������Ĳ���Ӫ���г������';
//procedure TFrmMain.DXTimerTimer(Sender: TObject; LagCount: Integer);
var
   i, j: integer;
   p: TPoint;
   DF: DDBLTFX;
   d: TDirectDrawSurface;
   nC:integer;
      FClientRect:TRect;
begin
   Done := TRUE;
   if not DxDraw.CanDraw then exit;
 if GetTickCount - DXRETime > 4 then  begin
  // DxDraw.Surface.Fill(0);
  // BoldTextOut (DxDraw.Surface, 0, 0, clBlack, clBlack, 'test test ' + TimeToStr(Time));
  // DxDraw.Surface.Canvas.Release;

   ProcessKeyMessages;
   ProcessActionMessages;
   DScreen.DrawScreen (DxDraw.Surface);
   g_DWinMan.DirectPaint (DxDraw.Surface);
   DScreen.DrawScreenTop (DxDraw.Surface);
   DScreen.DrawHint (DxDraw.Surface);
   
{$IF USECURSOR = IMAGECURSOR}
   {Draw cursor}
   //=========================================
   //��ʾ���
   CursorSurface := g_WMainImages.Images[0];
   if CursorSurface <> nil then begin
      GetCursorPos (p);
      DxDraw.Surface.Draw (p.x, p.y, CursorSurface.ClientRect, CursorSurface, TRUE);
   end;
   //==========================
{$IFEND}

    if g_boItemMoving then begin
      if (g_MovingItem.Item.S.Name <> g_sGoldName {'���'}) then
       d := g_WBagItemImages.Images[g_MovingItem.Item.S.Looks]
      else d := g_WBagItemImages.Images[115]; //�������


      if d <> nil then begin
        GetCursorPos(p);
        P := ScreenToClient(P);
        DxDraw.Surface.Draw(p.x - (d.ClientRect.Right div 2),
          p.y - (d.ClientRect.Bottom div 2),
          d.ClientRect,
          d,
          TRUE);
      end;
    end;
   if g_boDoFadeOut then begin
      if g_nFadeIndex < 1 then g_nFadeIndex := 1;
      MakeDark (DxDraw.Surface, g_nFadeIndex);
      if g_nFadeIndex <= 1 then g_boDoFadeOut := FALSE
      else Dec (g_nFadeIndex, 2);
   end else
   if g_boDoFadeIn then begin
      if g_nFadeIndex > 29 then g_nFadeIndex := 29;
      MakeDark (DxDraw.Surface, g_nFadeIndex);
      if g_nFadeIndex >= 29 then g_boDoFadeIn := FALSE
      else Inc (g_nFadeIndex, 2);
   end else
   if g_boDoFastFadeOut then begin
      if g_nFadeIndex < 1 then g_nFadeIndex := 1;
      MakeDark (DxDraw.Surface, g_nFadeIndex);
      if g_nFadeIndex > 1 then Dec (g_nFadeIndex, 4);
   end;
   {
   for i:=0 to 15 do
      for j:=0 to 15 do begin
         DxDraw.Surface.FillRect(Rect (j*16, i*16, (j+1)*16, (i+1)*16), i*16 + j);
      end;

   for i:=0 to 15 do
      DxDraw.Surface.Canvas.TextOut (600, i*14,
                                    IntToStr(i) + ' ' +
                                    IntToStr(DxDraw.ColorTable[i].rgbRed) + ' ' +
                                    IntToStr(DxDraw.ColorTable[i].rgbGreen) + ' ' +
                                    IntToStr(DxDraw.ColorTable[i].rgbBlue));
   DxDraw.Surface.Canvas.Release;}
    if not FrmDlg.DLOGO.Visible then begin
   //DxDraw.Flip;
   //��¼��ʱ����ʾԲ��LOGO
   if g_ConnectionStep = cnsLogin then begin
     with DxDraw.Surface.Canvas do begin
      SetBkMode (Handle, TRANSPARENT);
       Brush.Color:=clLime;
       nC:=64;
       TextOut(SCREENWIDTH - TextWidth(VERSION_NUMBER_STR) - 5, SCREENHEIGHT - TextHeight('W') - 5, VERSION_NUMBER_STR);
        Font.Color := GetRGB(255) {clYellow};
        TextOut((SCREENWIDTH Div 2) - (TextWidth(Logo1) Div 2), SCREENHEIGHT - 65, Logo1);
        TextOut((SCREENWIDTH Div 2) - (TextWidth(Logo2) Div 2), SCREENHEIGHT - 45, Logo2);
        TextOut((SCREENWIDTH Div 2) - (TextWidth(Logo3) Div 2), SCREENHEIGHT - 25, Logo3);
        Font.Color := clSilver;
       Release;
     end;
   end;
   end;
   
      FClientRect:=FrmMain.ClientRect;
   windows.ClientToScreen(FrmMain.Handle, FClientRect.TopLeft);

  // if g_boFullScreen then begin
  {   DxDraw.Primary.Draw (0, 0, DxDraw.Surface.ClientRect, DxDraw.Surface, FALSE);
   end else begin
     DXDraw.Flip;
   end;}
    if g_boFullScreen then
      DxDraw.Flip
    else
    DxDraw.Primary.Draw (FClientRect.Left, FClientRect.Top, DxDraw.Surface.ClientRect, DxDraw.Surface, FALSE);
    DXRETime := GetTickCount;
    end;
end;


procedure TfrmMain.AppLogout;
begin
   if mrOk = FrmDlg.DMessageDlg ('�����˳���ѡ���ɫ������', [mbOk, mbCancel]) then begin
      SendClientMessage (CM_SOFTCLOSE, 0, 0, 0, 0);
      PlayScene.ClearActors;
      CloseAllWindows;
      if not BoOneClick then begin
//         PlayScene.MemoLog.Lines.Add('С�˹ر�');
         g_SoftClosed := TRUE;
         ActiveCmdTimer (tcSoftClose);
      end else begin
         ActiveCmdTimer (tcReSelConnect);
      end;
      if g_boBagLoaded then
         Savebags ('.\Data\' + g_sServerName + '.' + CharName + '.itm', @g_ItemArr);
      g_boBagLoaded := FALSE;

   end;
end;

procedure TfrmMain.AppExit;
begin
   if mrOk = FrmDlg.DMessageDlg ('�����˳�������?', [mbOk, mbCancel]) then begin
      if g_boBagLoaded then
         Savebags ('.\Data\' + g_sServerName + '.' + CharName + '.itm', @g_ItemArr);
      g_boBagLoaded := FALSE;
      OutClmainall;
      FrmMain.Close;
   end;
end;

//2015-06-16 �޸���ͼ 32λ��
procedure TfrmMain.PrintScreenNow;
   function IntToStr2(n: integer): string;
  begin
      if n < 10 then Result := '0' + IntToStr(n)
      else Result := IntToStr(n);
  end;
  var
   i,n: integer;
   flname: string;
   bmp:TBitmap;
  begin
   if not DxDraw.CanDraw then Exit;
   if not DirectoryExists('Images') then  CreateDir('Images'); 
   while TRUE do
  begin
      flname := 'Images\Images' + IntToStr2(g_nCaptureSerial) + '.bmp';
      if not FileExists (flname) then break;
      Inc (g_nCaptureSerial);
  end;
   bmp:=TBitmap.create;
  try
     bmp.Width:=SCREENWIDTH;
     bmp.Height:=SCREENHEIGHT;
     bmp.PixelFormat:=pf16Bit;
      n := 0;
      if g_MySelf <> nil then
  begin
      BoldTextOut (DxDraw.Primary, 0, 0, clWhite, clBlack, g_sServerName + ' ' + g_MySelf.m_sUserName);
      Inc(n, 1);
  end;
      BoldTextOut (DxDraw.Primary, 0, n*14, clWhite, clBlack, DateToStr(Date) + ' ' + TimeToStr(Time));
      DxDraw.Primary.Canvas.Release;
      bmp.Canvas.CopyRect(bmp.Canvas.ClipRect,dxDraw.Surface.Canvas,dxDraw.Surface.ClientRect);
      n := 0;
      bmp.Canvas.font.size:=8;
      bmp.Canvas.font.Color := clWhite;
      with bmp.Canvas do begin
      SetBkMode (Handle, TRANSPARENT);
      if g_MySelf <> nil then
  begin
      bmp.Canvas.TextOut( 0, 0, g_sServerName + ' ' + g_MySelf.m_sUserName);
      Inc(n, 1);
  end;
      bmp.Canvas.TextOut(0, n * 12, DateToStr(Date)+' '+TimeToStr(Time));
  end;
      bmp.SaveToFile(flName);
      finally
      bmp.free;
  end;
    
end;



{------------------------------------------------------------}

procedure TfrmMain.ProcessKeyMessages;
begin
   {
   case ActionKey of
      VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8:
         begin
            UseMagic (MouseX, MouseY, GetMagicByKey (char ((ActionKey-VK_F1) + byte('1')) )); //��ũ�� ��ǥ
            //DScreen.AddSysMsg ('KEY' + IntToStr(Random(10000)));
            ActionKey := 0;
            TargetX := -1;
            exit;
         end;
   end;
   }
   case ActionKey of
     VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8: begin
       UseMagic (g_nMouseX, g_nMouseY, GetMagicByKey (char ((ActionKey-VK_F1) + byte('1')) )); //��ũ�� ��ǥ
       ActionKey := 0;
       g_nTargetX := -1;
       exit;
     end;
     12..19: begin
       UseMagic (g_nMouseX, g_nMouseY, GetMagicByKey (char ((ActionKey-12) + byte('1') + byte($14)) ));
       ActionKey := 0;
       g_nTargetX := -1;
       exit;
     end;
   end;
end;

procedure TfrmMain.ProcessActionMessages;
var
   mx, my, dx, dy, crun: integer;
   ndir, adir, mdir: byte;
   bowalk, bostop: Boolean;
label
   LB_WALK,TTTT;
begin
   if g_MySelf = nil then exit;

   //Move
   if (g_nTargetX >= 0) and CanNextAction and ServerAcceptNextAction then begin //ActionLock�� Ǯ����, ActionLock�� ������ ������ ���� Ǯ����.
      if (g_nTargetX <> g_MySelf.m_nCurrX) or (g_nTargetY <> g_MySelf.m_nCurrY) then begin
         TTTT:
         mx := g_MySelf.m_nCurrX;
         my := g_MySelf.m_nCurrY;
         dx := g_nTargetX;
         dy := g_nTargetY;
         ndir := GetNextDirection (mx, my, dx, dy);
         case g_ChrAction of
            caWalk: begin
               LB_WALK:
               //Jacky ��
               {
               DScreen.AddSysMsg ('caWalk ' + IntToStr(Myself.XX) + ' ' +
                                              IntToStr(Myself.m_nCurrY) + ' ' +
                                              IntToStr(TargetX) + ' ' +
                                              IntToStr(TargetY));
                                              }
               crun := g_MySelf.CanWalk;
               if IsUnLockAction (CM_WALK, ndir) and (crun > 0) then begin
                  GetNextPosXY (ndir, mx, my);
                  bowalk := TRUE;
                  bostop := FALSE;
                  if not PlayScene.CanWalk (mx, my) then begin
                     bowalk := FALSE;
                     adir := 0;
                     if not bowalk then begin  //�Ա� �˻�
                        mx := g_MySelf.m_nCurrX;
                        my := g_MySelf.m_nCurrY;
                        GetNextPosXY (ndir, mx, my);
                        if CheckDoorAction (mx, my) then
                           bostop := TRUE;
                     end;
                     if not bostop and not PlayScene.CrashMan(mx,my) then begin //����� �ڵ����� ������ ����..
                        mx := g_MySelf.m_nCurrX;
                        my := g_MySelf.m_nCurrY;
                        adir := PrivDir(ndir);
                        GetNextPosXY (adir, mx, my);
                        if not Map.CanMove(mx,my) then begin
                           mx := g_MySelf.m_nCurrX;
                           my := g_MySelf.m_nCurrY;
                           adir := NextDir (ndir);
                           GetNextPosXY (adir, mx, my);
                           if Map.CanMove(mx,my) then
                              bowalk := TRUE;
                        end else
                           bowalk := TRUE;
                     end;
                     if bowalk then begin
                        g_MySelf.UpdateMsg (CM_WALK, mx, my, adir, 0, 0, '', 0);
                        g_dwLastMoveTick := GetTickCount;
                     end else begin
                        mdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, dx, dy);
                        if mdir <> g_MySelf.m_btDir then
                           g_MySelf.SendMsg (CM_TURN, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, 0, 0, '', 0);
                        g_nTargetX := -1;
                     end;
                  end else begin
                     g_MySelf.UpdateMsg (CM_WALK, mx, my, ndir, 0, 0, '', 0);  //�׻� ������ ��ɸ� ���
                     g_dwLastMoveTick := GetTickCount;
                  end;
               end else begin
                  g_nTargetX := -1;
               end;
            end;
            caRun: begin
               //������
               if g_boCanStartRun or (g_nRunReadyCount >= 1) then begin
                  crun := g_MySelf.CanRun;
//����ʼ

                  if (g_MySelf.m_btHorse <> 0)
                     and (GetDistance (mx, my, dx, dy) >= 3)
                     and (crun > 0)
                     and IsUnLockAction (CM_HORSERUN, ndir) then begin
                    GetNextHorseRunXY (ndir, mx, my);
                    if PlayScene.CanRun (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mx, my) then begin
                      g_MySelf.UpdateMsg (CM_HORSERUN, mx, my, ndir, 0, 0, '', 0);
                      g_dwLastMoveTick := GetTickCount;
                     end else begin  //�����ʧ��������ȥ��
                        g_ChrAction:=caWalk;
                        goto TTTT;
                     end;
                  end else begin

//�������
                  if (GetDistance (mx, my, dx, dy) >= 2) and (crun > 0) then begin
                     if IsUnLockAction (CM_RUN, ndir) then begin
                        GetNextRunXY (ndir, mx, my);
                        if PlayScene.CanRun (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mx, my) then begin
                           g_MySelf.UpdateMsg (CM_RUN, mx, my, ndir, 0, 0, '', 0);
                           g_dwLastMoveTick := GetTickCount;
                        end else begin  //�����ʧ��������ȥ��
                          g_ChrAction:=caWalk;
                          goto TTTT;
                        end;
                     end else
                        g_nTargetX := -1;
                  end else begin
                    //Jacky
                    mdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, dx, dy);
                    if mdir <> g_MySelf.m_btDir then
                       g_MySelf.SendMsg (CM_TURN, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, 0, 0, '', 0);
                    g_nTargetX := -1;
                    //Jacky
                     //if crun = -1 then begin
                        //DScreen.AddSysMsg ('������ �� �� �����ϴ�.');
                        //TargetX := -1;
                     //end;
                     goto LB_WALK;
                     {if crun = -2 then begin
                        DScreen.AddSysMsg ('����Ŀ� �� �� �ֽ��ϴ�.');
                        TargetX := -1;
                     end; }
                  end;
                  end;  //�������
               end else begin
                  Inc (g_nRunReadyCount);
                  goto LB_WALK;
               end;
            end;
         end;
      end;
   end;
   g_nTargetX := -1; //�ѹ��� ��ĭ��..
   if g_MySelf.RealActionMsg.Ident > 0 then begin
      FailAction := g_MySelf.RealActionMsg.Ident; //�����Ҷ� ���
      FailDir := g_MySelf.RealActionMsg.Dir;
      if g_MySelf.RealActionMsg.Ident = CM_SPELL then begin
         SendSpellMsg (g_MySelf.RealActionMsg.Ident,
                       g_MySelf.RealActionMsg.X,
                       g_MySelf.RealActionMsg.Y,
                       g_MySelf.RealActionMsg.Dir,
                       g_MySelf.RealActionMsg.State);
      end else
         SendActMsg (g_MySelf.RealActionMsg.Ident,
                  g_MySelf.RealActionMsg.X,
                  g_MySelf.RealActionMsg.Y,
                  g_MySelf.RealActionMsg.Dir);
      g_MySelf.RealActionMsg.Ident := 0;

      //�޴��� ������ 10���ڱ� �̻� ������ �ڵ����� �����
      if g_nMDlgX <> -1 then
         if (abs(g_nMDlgX-g_MySelf.m_nCurrX) >= 8) or (abs(g_nMDlgY-g_MySelf.m_nCurrY) >= 8) then begin
            FrmDlg.CloseMDlg;
            g_nMDlgX := -1;
         end;
   end;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  msg, wc, dir, mx, my: integer;
  ini: TIniFile;
    str: String;
  I: integer;
begin
  if FrmDlg.DLOGO.Visible then begin
     FrmDlg.DLOGOClick(FrmDlg.DLOGO, 0, 0);
  end;
  
  case Key of
    VK_PAUSE: begin
      Key:=0;
      PrintScreenNow();
    end;
  end;

  if g_DWinMan.KeyDown (Key, Shift) then exit;

  if (g_MySelf = nil) or (DScreen.CurrentScene <> PlayScene) then exit;
  mx:=g_MySelf.m_nCurrX;
  my:=g_MySelf.m_nCurrY;

      If g_WgInfo.boCloseShift And (ssShift In Shift) Then
    Begin
      g_boShift := Not g_boShift;
      If g_boShift Then
        str := '�Զ�Shift ��'
      Else
        str := '�Զ�Shift ��';
      DScreen.AddChatBoardString(str, clWhite, clBlue);
    End;

  // If (ssCtrl In Shift)  Then g_WgInfo.boShowAllItem := not g_WgInfo.boShowAllItem;

  case Key of
    VK_F1, VK_F2, VK_F3, VK_F4,
    VK_F5, VK_F6, VK_F7, VK_F8: begin
      if (GetTickCount - g_dwLatestSpellTick > (g_dwSpellTime{500}{+200} + g_dwMagicDelayTime)) then begin
        if ssCtrl in Shift then begin
          ActionKey:=Key - 100;
        end else begin
          ActionKey:=Key;
        end;
      end;
      Key:=0;
    end;
    VK_F9: begin
      FrmDlg.OpenItemBag;
    end;
    VK_F10: begin
      FrmDlg.StatePage := 0;
      FrmDlg.OpenMyStatus;
      Key:=0;
    end;
    VK_F11: begin
      FrmDlg.StatePage := 3;
      FrmDlg.OpenMyStatus;
      Key:=0;
    end;
    VK_F12: begin

        If g_MySelf <> Nil Then
          Begin
            FrmDlg.NewWgWindows;
          End;
    end;

    word('H'): begin
      if ssCtrl in Shift then begin
        SendSay ('@AttackMode');
      end;
    end;
    word('A'): begin
      if ssCtrl in Shift then begin
        SendSay ('@Rest');
      end;
    end;
    word('D'): begin
      if ssCtrl in Shift then begin
        SendPassword('',0);
        {
        SetInputStatus();

        if m_boPasswordIntputStatus then
          DScreen.AddChatBoardString ('���������룺', clBlue, clWhite);
        }
      end;
    end;
    {
    word('D'): begin
      if ssCtrl in Shift then begin
        FrmDlg.DChgGamePwd.Visible:=not FrmDlg.DChgGamePwd.Visible;
      end;
    end;
    }
    word('F'): begin
      if ssCtrl in Shift then begin
        if g_nCurFont < MAXFONT-1 then Inc(g_nCurFont)
        else g_nCurFont := 0;
        g_sCurFontName := g_FontArr[g_nCurFont];
        FrmMain.Font.Name := g_sCurFontName;
        FrmMain.Canvas.Font.Name := g_sCurFontName;
        DxDraw.Surface.Canvas.Font.Name := g_sCurFontName;
        PlayScene.EdChat.Font.Name := g_sCurFontName;

        ini := TIniFile.Create ('.\mir.ini');
        if ini <> nil then begin
          ini.WriteString ('Setup', 'FontName', g_sCurFontName);
          ini.Free;
        end;
      end;
    end;
    word('Z'): begin
      if ssCtrl in Shift then begin
     //   g_boShowAllItem:=not g_boShowAllItem;
      end else
      if not PlayScene.EdChat.Visible then begin
        if CanNextAction and ServerAcceptNextAction then begin
          SendPickup; //����Ʒ
        end;
      end;
    end;
      word('X'):
         begin
            if g_MySelf = nil then exit;
            if ssAlt in Shift then begin
               //ǿ���˳�
               g_dwLatestStruckTick:=GetTickCount() + 10001;
               g_dwLatestMagicTick:=GetTickCount() + 10001;
               g_dwLatestHitTick:=GetTickCount() + 10001;
               //
               if (GetTickCount - g_dwLatestStruckTick > 10000) and
                  (GetTickCount - g_dwLatestMagicTick > 10000) and
                  (GetTickCount - g_dwLatestHitTick > 10000) or
                  (g_MySelf.m_boDeath) then
               begin
                  AppLogOut;
               end else
                  DScreen.AddChatBoardString ('ս��״̬�в����˳���Ϸ...', clYellow, clRed);
            end;
         end;
      word('Q'):
         begin
            if g_MySelf = nil then exit;
            if ssAlt in Shift then begin
               //ǿ���˳�
               g_dwLatestStruckTick:=GetTickCount() + 10001;
               g_dwLatestMagicTick:=GetTickCount() + 10001;
               g_dwLatestHitTick:=GetTickCount() + 10001;
               //            
               if (GetTickCount - g_dwLatestStruckTick > 10000) and
                  (GetTickCount - g_dwLatestMagicTick > 10000) and
                  (GetTickCount - g_dwLatestHitTick > 10000) or
                  (g_MySelf.m_boDeath) then
               begin
                  AppExit;
               end else
                  DScreen.AddChatBoardString ('ս��״̬�в����˳���Ϸ...', clYellow, clRed);
            end;
         end;
      word('V'): begin
        if not PlayScene.EdChat.Visible then begin
          if not g_boViewMiniMap then begin
            if GetTickCount > g_dwQueryMsgTick then begin
              g_dwQueryMsgTick := GetTickCount + 3000;
              FrmMain.SendWantMiniMap;
              g_nViewMinMapLv:=1;
            end;
          end else begin
            if g_nViewMinMapLv >= 2 then begin
              g_nViewMinMapLv:=0;
              g_boViewMiniMap := FALSE;
            end else Inc(g_nViewMinMapLv);
          end;
        end;
      end;
      word('T'): begin
        if not PlayScene.EdChat.Visible then begin
          if GetTickCount > g_dwQueryMsgTick then begin
            g_dwQueryMsgTick := GetTickCount + 3000;
            FrmMain.SendDealTry;
          end;
        end;
      end;
      word('G'): begin
         if ssCtrl in Shift then begin
           if g_FocusCret <> nil then
             if g_GroupMembers.Count = 0 then
               SendCreateGroup(g_FocusCret.m_sUserName)
             else SendAddGroupMember(g_FocusCret.m_sUserName);
             PlayScene.EdChat.Text:=g_FocusCret.m_sUserName;
         end else begin
           if ssAlt in Shift then begin
             if g_FocusCret <> nil then
               SendDelGroupMember(g_FocusCret.m_sUserName)
           end else begin
             if not PlayScene.EdChat.Visible then begin
               if FrmDlg.DGuildDlg.Visible then begin
                 FrmDlg.DGuildDlg.Visible := FALSE;
               end else
                if GetTickCount > g_dwQueryMsgTick then begin
                  g_dwQueryMsgTick := GetTickCount + 3000;
                  FrmMain.SendGuildDlg;
               end;
             end;
           end;
         end;

      end;

      word('P'): begin
        if not PlayScene.EdChat.Visible then
          FrmDlg.ToggleShowGroupDlg;
      end;

      word('C'): begin
        if not PlayScene.EdChat.Visible then begin
          FrmDlg.StatePage := 0;
          FrmDlg.OpenMyStatus;
        end;
      end;

      word('I'): begin
        if not PlayScene.EdChat.Visible then
          FrmDlg.OpenItemBag;
      end;

      word('S'): begin
        if not PlayScene.EdChat.Visible then begin
          FrmDlg.StatePage := 3;
          FrmDlg.OpenMyStatus;
        end;
      end;

      word('W'): begin
        if not PlayScene.EdChat.Visible then
          FrmDlg.OpenFriendDlg();
      end;

      word('M'): begin
        if not PlayScene.EdChat.Visible then
          FrmDlg.OpenAdjustAbility;
      end;
   end;

   case Key of
      VK_UP:
         with DScreen do begin
            if ChatBoardTop > 0 then Dec (ChatBoardTop);
         end;
      VK_DOWN:
         with DScreen do begin
            if ChatBoardTop < ChatStrs.Count-1 then
               Inc (ChatBoardTop);
         end;
      VK_PRIOR:
         with DScreen do begin
            if ChatBoardTop > VIEWCHATLINE then
               ChatBoardTop := ChatBoardTop - VIEWCHATLINE
            else ChatBoardTop := 0;
         end;
      VK_NEXT:
         with DScreen do begin
            if ChatBoardTop + VIEWCHATLINE < ChatStrs.Count-1 then
               ChatBoardTop := ChatBoardTop + VIEWCHATLINE
            else ChatBoardTop := ChatStrs.Count-1;
            if ChatBoardTop < 0 then ChatBoardTop := 0;
         end;
   end;
end;

procedure TfrmMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if g_DWinMan.KeyPress (Key) then exit;
   if DScreen.CurrentScene = PlayScene then begin
      if PlayScene.EdChat.Visible then begin
         //�������� ó���ؾ� �ϴ� ��츸 �Ʒ��� �Ѿ
         exit;
      end;
      case byte(key) of
         byte('1')..byte('6'):
            begin
               EatItem (byte(key) - byte('1')); //��Ʈ �������� ����Ѵ�.
            end;
         27: //ESC
            begin
            end;
         byte(' '), 13: //ä�� �ڽ�
            begin
               PlayScene.EdChat.Visible := TRUE;
               PlayScene.EdChat.SetFocus;
               SetImeMode (PlayScene.EdChat.Handle, LocalLanguage);
               if FrmDlg.BoGuildChat then begin
                  PlayScene.EdChat.Text := '!~';
                  PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
                  PlayScene.EdChat.SelLength := 0;
               end else begin
                  PlayScene.EdChat.Text := '';
               end;
            end;
         byte('@'),
         byte('!'),
         byte('/'):
            begin
               PlayScene.EdChat.Visible := TRUE;
               PlayScene.EdChat.SetFocus;
               SetImeMode (PlayScene.EdChat.Handle, LocalLanguage);
               if key = '/' then begin
                  if WhisperName = '' then PlayScene.EdChat.Text := key
                  else if Length(WhisperName) > 2 then PlayScene.EdChat.Text := '/' + WhisperName + ' '
                  else PlayScene.EdChat.Text := key;
                  PlayScene.EdChat.SelStart := Length(PlayScene.EdChat.Text);
                  PlayScene.EdChat.SelLength := 0;
               end else begin
                  PlayScene.EdChat.Text := key;
                  PlayScene.EdChat.SelStart := 1;
                  PlayScene.EdChat.SelLength := 0;
               end;
            end;
      end;
      key := #0;
   end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
   ShowWindow(application.Handle, SW_HIDE);
end;

function  TfrmMain.GetMagicByKey (Key: char): PTClientMagic;
var
   i: integer;
   pm: PTClientMagic;
begin
   Result := nil;
   for i:=0 to g_MagicList.Count-1 do begin
      pm := PTClientMagic (g_MagicList[i]);
      if pm.Key = Key then begin
         Result := pm;
         break;
      end;
   end;
end;
procedure TfrmMain.UseMagic(tx, ty: integer; pcm: PTClientMagic; boFlag:
  Boolean);
//procedure TfrmMain.UseMagic (tx, ty: integer; pcm: PTClientMagic); //tx, ty: ��ũ�� ��ǥ��.
var
   tdir, targx, targy, targid: integer;
   pmag: PTUseMagicInfo;
begin
   if pcm = nil then exit;
   if (pcm.Def.wSpell + pcm.Def.btDefSpell <= g_MySelf.m_Abil.MP) or (pcm.Def.btEffectType = 0) then begin
      if pcm.Def.btEffectType = 0 then begin //�˹�,ȿ������
         //�˹� Ű�� �ൿ�� ���� ���� �ʴ´�.
         //������ ���� �����Ѵ�.
         //if CanNextAction and ServerAcceptNextAction then begin

         //��ȭ���� �ѹ� ����� 9�ʱ����� �ٽ� �������� �ʰ� �Ѵ�.
         if pcm.Def.wMagicId = 26 then begin //��ȭ��
            if GetTickCount - g_dwLatestFireHitTick < 10 * 1000 then begin
               exit;
            end;
         end;
         //���º��� �ѹ� ����� 3�ʱ����� �ٽ� �������� �ʴ´�.
         if pcm.Def.wMagicId = 27 then begin //���º�
            if GetTickCount - g_dwLatestRushRushTick < 3 * 1000 then begin
               exit;
            end;
         end;

         //�˹��� ������(500ms) ���� ��������.
         if GetTickCount - g_dwLatestSpellTick > g_dwSpellTime{500} then begin
            g_dwLatestSpellTick := GetTickCount;
            g_dwMagicDelayTime := 0; //pcm.Def.DelayTime;
            SendSpellMsg (CM_SPELL, g_MySelf.m_btDir{x}, 0, pcm.Def.wMagicId, 0);
         end;
      end else begin
         tdir := GetFlyDirection (390, 175, tx, ty);
//         MagicTarget := FocusCret;
//ħ������
         if (pcm.Def.wMagicId = 2)
           or (pcm.Def.wMagicId = 14)
           or (pcm.Def.wMagicId = 15)
           or (pcm.Def.wMagicId = 19) then begin
           g_MagicTarget:=g_FocusCret;
         end else begin
           if not g_boMagicLock or (PlayScene.IsValidActor (g_FocusCret) and (not g_FocusCret.m_boDeath)) then begin
             g_MagicLockActor:=g_FocusCret;
           end;
           g_MagicTarget:=g_MagicLockActor;
         end;
         if not PlayScene.IsValidActor (g_MagicTarget) then
            g_MagicTarget := nil;

         if g_MagicTarget = nil then begin
            PlayScene.CXYfromMouseXY (tx, ty, targx, targy);
            targid := 0;
         end else begin
            targx := g_MagicTarget.m_nCurrX;
            targy := g_MagicTarget.m_nCurrY;
            targid := g_MagicTarget.m_nRecogId;
         end;
         if CanNextAction and ServerAcceptNextAction then begin
            g_dwLatestSpellTick := GetTickCount;  //���� ���
            new (pmag);
            FillChar (pmag^, sizeof(TUseMagicInfo), #0);
            pmag.EffectNumber := pcm.Def.btEffect;
            pmag.MagicSerial := pcm.Def.wMagicId;
            pmag.ServerMagicCode := 0;
            g_dwMagicDelayTime := 200 + pcm.Def.dwDelayTime; //���� ������ ����Ҷ����� ���� �ð�

            case pmag.MagicSerial of
               //0, 2, 11, 12, 15, 16, 17, 13, 23, 24, 26, 27, 28, 29: ;
               2, 14, 15, 16, 17, 18, 19, 21, //����� ���� ����
               12, 25, 26, 28, 29, 30, 31: ;
               else g_dwLatestMagicTick := GetTickCount;
            end;

            //����� �����ϴ� ����� ������
            g_dwMagicPKDelayTime := 0;
            if g_MagicTarget <> nil then
               if g_MagicTarget.m_btRace = 0 then
                  g_dwMagicPKDelayTime := 300 + Random(1100); //(600+200 + MagicDelayTime div 5);

           if g_wgInfo.boCanAutoAmyounsul then
          TaosAutoAmyounsul(pcm.Def.wMagicID);

            g_MySelf.SendMsg (CM_SPELL, targx, targy, tdir, Integer(pmag), targid, '', 0);
         end;// else
            //Dscreen.AddSysMsg ('����Ŀ� ����� �� �ֽ��ϴ�.');
         //Inc (SpellCount);
      end;
   end else
      Dscreen.AddSysMsg ('û���㹻��ħ��������');
      //Dscreen.AddSysMsg ('ħ��ֵ����������' + IntToStr(pcm.Def.wSpell) + '+' + IntToStr(pcm.Def.btDefSpell) + '/' +IntToStr(g_MySelf.m_Abil.MP));
end;

procedure TfrmMain.UseMagicSpell(who, effnum, targetx, targety, magic_id: Integer);
var
  Actor: TActor;
  adir: Integer;
  UseMagic: PTUseMagicInfo;
begin
  Actor := PlayScene.FindActor(who);
  if Actor <> nil then begin
    adir := GetFlyDirection(Actor.m_nCurrX, Actor.m_nCurrY, targetx, targety);
    new(UseMagic);
    FillChar(UseMagic^, sizeof(TUseMagicInfo), #0);
    UseMagic.EffectNumber := effnum; //magnum;
    UseMagic.ServerMagicCode := 0; //�ӽ�
    UseMagic.MagicSerial := magic_id;
    Actor.SendMsg(SM_SPELL, 0, 0, adir, Integer(UseMagic), 0, '', 0);
    Inc(g_nSpellCount);
  end else
    Inc(g_nSpellFailCount);
end;

procedure TfrmMain.UseMagicFire (who, efftype, effnum, targetx, targety, target: integer);
var
  Actor: TActor;
  adir, sound: Integer;
  pmag: PTUseMagicInfo;
begin
  sound := 0; //jacky
  Actor := PlayScene.FindActor(who);
  if Actor <> nil then begin
    Actor.SendMsg(SM_MAGICFIRE, target, efftype, effnum, targetx, targety, '', sound);

    if g_nFireCount < g_nSpellCount then
      Inc(g_nFireCount);
  end;
  g_MagicTarget := nil;
end;


procedure TfrmMain.UseMagicFireFail (who: integer);
var
   actor: TActor;
begin
   actor := PlayScene.FindActor (who);
   if actor <> nil then begin
      actor.SendMsg (SM_MAGICFIRE_FAIL, 0, 0, 0, 0, 0, '', 0);
   end;
   g_MagicTarget := nil;
end;

procedure TfrmMain.EatItem (idx: integer);
begin
   if idx in [0..MAXBAGITEMCL-1] then begin
      if (g_EatingItem.S.Name <> '') and (GetTickCount - g_dwEatTime > 5 * 1000) then begin
         g_EatingItem.S.Name := '';
      end;
      if (g_EatingItem.S.Name = '') and (g_ItemArr[idx].S.Name <> '') and (g_ItemArr[idx].S.StdMode <= 3) then begin
         g_EatingItem := g_ItemArr[idx];
         g_ItemArr[idx].S.Name := '';
         //å�� �д� ��... ���� ���� �� �����.
         if (g_ItemArr[idx].S.StdMode = 4) and (g_ItemArr[idx].S.Shape < 100) then begin
            //shape > 100�̸� ���� ������ ��..
            if g_ItemArr[idx].S.Shape < 50 then begin
               If mrYes <> FrmDlg.DMessageDlg('[' + g_ItemArr[idx].S.Name +'] ����Ҫ��ʼѵ����', [mbYes, mbNo]) Then begin
                  g_ItemArr[idx] := g_EatingItem;
                  exit;
               end;
            end else begin
                //shape > 50�̸� �ֹ� �� ����...
               If mrYes <> FrmDlg.DMessageDlg('[' + g_ItemArr[idx].S.Name +'] ����Ҫ��ʼѵ����', [mbYes, mbNo]) Then begin
                  g_ItemArr[idx] := g_EatingItem;
                  exit;
               end;
            end;
         end;
         g_dwEatTime := GetTickCount;
         SendEat (g_ItemArr[idx].MakeIndex, g_ItemArr[idx].S.Name );
         ItemUseSound (g_ItemArr[idx].S.StdMode);
      end;
   end else begin
      if (idx = -1) and g_boItemMoving then begin
         g_boItemMoving := FALSE;
         g_EatingItem := g_MovingItem.Item;
         g_MovingItem.Item.S.Name := '';
         //å�� �д� ��... ���� ���� �� �����.
         if (g_EatingItem.S.StdMode = 4) and (g_EatingItem.S.Shape < 100) then begin
            //shape > 100�̸� ���� ������ ��..
            if g_EatingItem.S.Shape < 50 then begin
               If mrYes <> FrmDlg.DMessageDlg('[' + g_EatingItem.S.Name + '] ����Ҫ��ʼѵ����', [mbYes, mbNo]) Then begin
                  AddItemBag (g_EatingItem);
                  exit;
               end;
            end else begin
                //shape > 50�̸� �ֹ� �� ����...
               If mrYes <> FrmDlg.DMessageDlg('[' + g_EatingItem.S.Name +'] ����Ҫ��ʼѵ����', [mbYes, mbNo]) Then begin
                  AddItemBag (g_EatingItem);
                  exit;
               end;
            end;
         end;
         g_dwEatTime := GetTickCount;
         SendEat (g_EatingItem.MakeIndex, g_EatingItem.S.Name );
         ItemUseSound (g_EatingItem.S.StdMode);
      end;
   end;
end;

function  TfrmMain.TargetInSwordLongAttackRange (ndir: integer): Boolean;
var
   nx, ny: integer;
   actor: TActor;
begin
   Result := FALSE;
   GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, ndir, nx, ny);
   GetFrontPosition (nx, ny, ndir, nx, ny);
   if (abs(g_MySelf.m_nCurrX - nx) = 2) or (abs(g_MySelf.m_nCurrY-ny) = 2) then begin
      actor := PlayScene.FindActorXY (nx, ny);
      if actor <> nil then
         if not actor.m_boDeath then
            Result := TRUE;
   end;
end;

function  TfrmMain.TargetInSwordWideAttackRange (ndir: integer): Boolean;
var
   nx, ny, rx, ry, mdir: integer;
   actor, ractor: TActor;
begin
   Result := FALSE;
   GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, ndir, nx, ny);
   actor := PlayScene.FindActorXY (nx, ny);

   mdir := (ndir + 1) mod 8;
   GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
   ractor := PlayScene.FindActorXY (rx, ry);
   if ractor = nil then begin
      mdir := (ndir + 2) mod 8;
      GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
      ractor := PlayScene.FindActorXY (rx, ry);
   end;
   if ractor = nil then begin
      mdir := (ndir + 7) mod 8;
      GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
      ractor := PlayScene.FindActorXY (rx, ry);
   end;

   if (actor <> nil) and (ractor <> nil) then
      if not actor.m_boDeath and not ractor.m_boDeath then
         Result := TRUE;
end;
function  TfrmMain.TargetInSwordCrsAttackRange (ndir: integer): Boolean;
var
   nx, ny, rx, ry, mdir: integer;
   actor, ractor: TActor;
begin
   Result := FALSE;
   GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, ndir, nx, ny);
   actor := PlayScene.FindActorXY (nx, ny);

   mdir := (ndir + 1) mod 8;
   GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
   ractor := PlayScene.FindActorXY (rx, ry);
   if ractor = nil then begin
      mdir := (ndir + 2) mod 8;
      GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
      ractor := PlayScene.FindActorXY (rx, ry);
   end;
   if ractor = nil then begin
      mdir := (ndir + 7) mod 8;
      GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, mdir, rx, ry);
      ractor := PlayScene.FindActorXY (rx, ry);
   end;

   if (actor <> nil) and (ractor <> nil) then
      if not actor.m_boDeath and not ractor.m_boDeath then
         Result := TRUE;
end;

{--------------------- Mouse Interface ----------------------}

procedure TfrmMain.DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   i, mx, my, msx, msy, sel: integer;
   target: TActor;
   itemnames: string;
begin
   if g_DWinMan.MouseMove (Shift, X, Y) then exit;
   if (g_MySelf = nil) or (DScreen.CurrentScene <> PlayScene) then exit;
   g_boSelectMyself := PlayScene.IsSelectMyself (X, Y);

   target := PlayScene.GetAttackFocusCharacter (X, Y, g_nDupSelection, sel, FALSE);
   if g_nDupSelection <> sel then g_nDupSelection := 0;
   if target <> nil then begin
      if (target.m_sUserName = '') and (GetTickCount - target.m_dwSendQueryUserNameTime > 10 * 1000) then begin
         target.m_dwSendQueryUserNameTime := GetTickCount;
         SendQueryUserName (target.m_nRecogId, target.m_nCurrX, target.m_nCurrY);
      end;
      g_FocusCret := target;
   end else
      g_FocusCret := nil;

   g_FocusItem := PlayScene.GetDropItems (X, Y, itemnames);
   if g_FocusItem <> nil then begin
      PlayScene.ScreenXYfromMCXY (g_FocusItem.X, g_FocusItem.Y, mx, my);
      DScreen.ShowHint (mx-20,
                        my-10,
                        itemnames, //PTDropItem(ilist[i]).Name,
                        clWhite,
                        TRUE);
   end else
      DScreen.ClearHint;

   PlayScene.CXYfromMouseXY (X, Y, g_nMouseCurrX, g_nMouseCurrY);
   g_nMouseX := X;
   g_nMouseY := Y;
   g_MouseItem.S.Name := '';
   g_MouseStateItem.S.Name := '';
   g_MouseUserStateItem.S.Name := '';
   if ((ssLeft in Shift) or (ssRight in Shift)) and (GetTickCount - mousedowntime > 300) then
      _DXDrawMouseDown(self, mbLeft, Shift, X, Y);

end;

procedure TfrmMain.DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   mousedowntime := GetTickCount;
   g_nRunReadyCount := 0;     //����ݱ� ���(�ٱ� �ΰ��)
   _DXDrawMouseDown (Sender, Button, Shift, X, Y);
end;

procedure TfrmMain.AttackTarget (target: TActor);
var
   tdir, dx, dy, nHitMsg: integer;
begin
   nHitMsg := CM_HIT;
   if g_UseItems[U_WEAPON].S.StdMode = 6 then nHitMsg := CM_HEAVYHIT;

   tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, target.m_nCurrX, target.m_nCurrY);
   if (abs(g_MySelf.m_nCurrX - target.m_nCurrX) <= 1) and (abs(g_MySelf.m_nCurrY-target.m_nCurrY) <= 1) and (not target.m_boDeath) then begin
      if CanNextAction and ServerAcceptNextAction and CanNextHit then begin

         if g_boNextTimeFireHit and (g_MySelf.m_Abil.MP >= 7) then begin
            g_boNextTimeFireHit := FALSE;
            nHitMsg := CM_FIREHIT;
         end else
         if g_boNextTimePowerHit then begin  //�Ŀ� ������ ���, �����˹�
            g_boNextTimePowerHit := FALSE;
            nHitMsg := CM_POWERHIT;
         end else
         if g_boCanTwnHit and (g_MySelf.m_Abil.MP >= 10) then begin
            g_boCanTwnHit := FALSE;
            nHitMsg := CM_TWINHIT;
         end else
         if g_boCanWideHit and (g_MySelf.m_Abil.MP >= 3) then begin //and (TargetInSwordWideAttackRange (tdir)) then begin  //�� ������ ���, �ݿ��˹�
            nHitMsg := CM_WIDEHIT;
         end else
         if g_boCanCrsHit and (g_MySelf.m_Abil.MP >= 6) then begin
            nHitMsg := CM_CRSHIT;
         end else
         if g_boCanLongHit
          and (TargetInSwordLongAttackRange (tdir)) Or( g_WgInfo.boCanLongHit)then begin  //�� ������ ���, ��˼�
            nHitMsg := CM_LONGHIT;
         end;

         //if ((target.m_btRace <> RCC_USERHUMAN) and (target.m_btRace <> RCC_GUARD)) or (ssShift in Shift) then //����� �Ǽ��� �����ϴ� ���� ����
         g_MySelf.SendMsg (nHitMsg, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0);
         g_dwLatestHitTick := GetTickCount;
      end;
      g_dwLastAttackTick := GetTickCount;
   end else begin
      //�񵵸� ��� ������
      //if (UseItems[U_WEAPON].S.Shape = 6) and (target <> nil) then begin
      //   Myself.SendMsg (CM_THROW, Myself.XX, Myself.m_nCurrY, tdir, integer(target), 0, '', 0);
      //   TargetCret := nil;  //
      //end else begin
      if (abs(g_MySelf.m_nCurrX - target.m_nCurrX) <= 2) and (abs(g_MySelf.m_nCurrY-target.m_nCurrY) <= 2) and (not target.m_boDeath) then
         g_ChrAction := caWalk
      else g_ChrAction := caRun;//�ܲ���
      GetBackPosition (target.m_nCurrX, target.m_nCurrY, tdir, dx, dy);
      g_nTargetX := dx;
      g_nTargetY := dy;
      //end;
   end;
end;

procedure TfrmMain._DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   tdir, nx, ny, nHitMsg, sel: integer;
   target: TActor;
begin
   ActionKey := 0;
   g_nMouseX := X;
   g_nMouseY := Y;
   g_boAutoDig := FALSE;

   if (Button = mbRight) and g_boItemMoving then begin      //�Ƿ�ǰ���ƶ���Ʒ
      FrmDlg.CancelItemMoving;
      exit;
   end;
   if g_DWinMan.MouseDown (Button, Shift, X, Y) then exit; //����Ƶ���������������
   if (g_MySelf = nil) or (DScreen.CurrentScene <> PlayScene) then exit;  //��������˳�������

   if ssRight in Shift then begin       //����Ҽ�
      if Shift = [ssRight] then Inc (g_nDupSelection);  //������ ��� ����
      target := PlayScene.GetAttackFocusCharacter (X, Y, g_nDupSelection, sel, FALSE); //ȡָ�������ϵĽ�ɫ
      if g_nDupSelection <> sel then g_nDupSelection := 0;
      if target <> nil then begin
         if ssCtrl in Shift then begin //CTRL + ����Ҽ� = ��ʾ��ɫ����Ϣ
            if GetTickCount - g_dwLastMoveTick > 1000 then begin
               if (target.m_btRace = 0) and (not target.m_boDeath) then begin
                  //ȡ��������Ϣ
                  SendClientMessage (CM_QUERYUSERSTATE, target.m_nRecogId, target.m_nCurrX, target.m_nCurrY, 0);
                  exit;
               end;
            end;
         end;
      end else
         g_nDupSelection := 0;
      //������Ҽ����������ָ���λ��
      PlayScene.CXYfromMouseXY (X, Y, g_nMouseCurrX, g_nMouseCurrY);

      if (abs(g_MySelf.m_nCurrX - g_nMouseCurrX) <= 2) and (abs(g_MySelf.m_nCurrY - g_nMouseCurrY) <= 2) then begin //Ŀ������
         tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_nMouseCurrX, g_nMouseCurrY);
         if CanNextAction and ServerAcceptNextAction then begin
            g_MySelf.SendMsg (CM_TURN, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0);
         end;
      end else begin //�ٱ�
         g_ChrAction := caRun;
         g_nTargetX := g_nMouseCurrX;
         g_nTargetY := g_nMouseCurrY;
         exit;
      end;

{
      if CanNextAction and ServerAcceptNextAction then begin
        //����������Ŀ������֮���Ƿ�С��2��С�����߲���
        if (abs(Myself.XX-MCX) <= 2) and (abs(Myself.m_nCurrY-MCY) <= 2) then begin
           ChrAction := caWalk;
        end else begin //�ܲ���
           ChrAction := caRun;
        end;
           TargetX := MCX;
           TargetY := MCY;
           exit;
      end;
 }
   end;

   if ssLeft in Shift {Button = mbLeft} then begin
      //����... ���� ������ ���õ�
      target := PlayScene.GetAttackFocusCharacter (X, Y, g_nDupSelection, sel, TRUE); //����ִ� ��..
      PlayScene.CXYfromMouseXY (X, Y, g_nMouseCurrX, g_nMouseCurrY);
      g_TargetCret := nil;

      if (g_UseItems[U_WEAPON].S.Name <> '') and (target = nil)
//����״̬�����Բ���
        and (g_MySelf.m_btHorse = 0) then begin
         //�ڿ�
         if g_UseItems[U_WEAPON].S.Shape = 19 then begin //�����
            tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_nMouseCurrX, g_nMouseCurrY);
            GetFrontPosition (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, nx, ny);
            if not Map.CanMove(nx, ny) or (ssShift in Shift) then begin  //�����ƶ���ǿ���ڿ�
               if CanNextAction and ServerAcceptNextAction and CanNextHit then begin
                  g_MySelf.SendMsg (CM_HIT+1, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0);
               end;
               g_boAutoDig := TRUE;
               exit;
            end;
         end;
      end;

      if (ssAlt in Shift)
//����״̬�����Բ���
        and (g_MySelf.m_btHorse = 0) then begin
         //����Ʒ
         tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_nMouseCurrX, g_nMouseCurrY);
         if CanNextAction and ServerAcceptNextAction then begin
            target := PlayScene.ButchAnimal (g_nMouseCurrX, g_nMouseCurrY);
            if target <> nil then begin
               SendButchAnimal (g_nMouseCurrX, g_nMouseCurrY, tdir, target.m_nRecogId);
               g_MySelf.SendMsg (CM_SITDOWN, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0); //�ڼ��� ����
               exit;
            end;
            g_MySelf.SendMsg (CM_SITDOWN, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0);
         end;
         g_nTargetX := -1;
      end else begin
         if (target <> nil) or (ssShift in Shift) then begin
            //���ʸ��콺 Ŭ�� �Ǵ� Ÿ���� ����.
            g_nTargetX := -1;
            if target <> nil then begin
               //Ÿ���� ����.

               //�ȴٰ� ���� �޴��� ������ ���� ����.
               if GetTickCount - g_dwLastMoveTick > 1500 then begin
                  //������ ���,
                  if target.m_btRace = RCC_MERCHANT then begin
                     SendClientMessage (CM_CLICKNPC, target.m_nRecogId, 0, 0, 0);
                     exit;
                  end;
               end;

               if (not target.m_boDeath)
//�����������
                 and (g_MySelf.m_btHorse = 0) then begin
                  g_TargetCret := target;
                  if ((target.m_btRace <> RCC_USERHUMAN) and
                      (target.m_btRace <> RCC_GUARD) and
                      (target.m_btRace <> RCC_MERCHANT) and
                      (pos('(', target.m_sUserName) = 0) //����'('�Ľ�ɫ����Ϊ�ٻ��ı���
                     )
                     or (ssShift in Shift) //SHIFT + ������
                     or (target.m_nNameColor = ENEMYCOLOR)   //���� �ڵ� ������ ��
                  then begin
                     AttackTarget (target);
                     g_dwLatestHitTick := GetTickCount;
                  end;
               end;
            end else begin
//�����������
               if (g_MySelf.m_btHorse = 0) then begin
               tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_nMouseCurrX, g_nMouseCurrY);
               if CanNextAction and ServerAcceptNextAction and CanNextHit then begin
                  nHitMsg := CM_HIT+Random(3);
                  if g_boCanLongHit and (TargetInSwordLongAttackRange (tdir)) then begin  //�Ƿ����ʹ�ô�ɱ
                     nHitMsg := CM_LONGHIT;
                  end;
                  if g_boCanWideHit and (g_MySelf.m_Abil.MP >= 3) and (TargetInSwordWideAttackRange (tdir)) then begin  //�Ƿ����ʹ�ð���
                     nHitMsg := CM_WIDEHIT;
                  end;
                  if g_boCanCrsHit and (g_MySelf.m_Abil.MP >= 6) and (TargetInSwordCrsAttackRange (tdir)) then begin  //�Ƿ����ʹ�ð���
                     nHitMsg := CM_CRSHIT;
                  end;
                  g_MySelf.SendMsg (nHitMsg, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, tdir, 0, 0, '', 0);
               end;
               g_dwLastAttackTick := GetTickCount;
               end;
            end;
         end else begin
//            if (MCX = Myself.XX) and (MCY = Myself.m_nCurrY) then begin
            if (g_nMouseCurrX = (g_MySelf.m_nCurrX)) and (g_nMouseCurrY = (g_MySelf.m_nCurrY)) then begin
               tdir := GetNextDirection (g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_nMouseCurrX, g_nMouseCurrY);
               if CanNextAction and ServerAcceptNextAction then begin
                  SendPickup; //����Ʒ
               end;
            end else
               if GetTickCount - g_dwLastAttackTick > 1000 then begin //��󹥻�����ͣ��ָ��ʱ������ƶ�
                  if ssCtrl in Shift then begin
                     g_ChrAction := caRun;
                  end else begin
                     g_ChrAction := caWalk;
                  end;
                  g_nTargetX := g_nMouseCurrX;
                  g_nTargetY := g_nMouseCurrY;
               end;
         end;
      end;
   end;
end;

procedure TfrmMain.DXDrawDblClick(Sender: TObject);
var
   pt: TPoint;
begin
   GetCursorPos (pt);
   pt:= ScreenToClient(pt);
   if g_DWinMan.DblClick (pt.X, pt.Y) then exit;
end;

function  TfrmMain.CheckDoorAction (dx, dy: integer): Boolean;
var
   nx, ny, ndir, door: integer;
begin
   Result := FALSE;
   //if not Map.CanMove (dx, dy) then begin
      //if (Abs(dx-Myself.XX) <= 2) and (Abs(dy-Myself.m_nCurrY) <= 2) then begin
         door := Map.GetDoor (dx, dy);
         if door > 0 then begin
            if not Map.IsDoorOpen (dx, dy) then begin
               SendClientMessage (CM_OPENDOOR, door, dx, dy, 0);
               Result := TRUE;
            end;    
         end;
      //end;
   //end;
end;

procedure TfrmMain.DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if g_DWinMan.MouseUp (Button, Shift, X, Y) then exit;
   g_nTargetX := -1;
end;

procedure TfrmMain.DXDrawClick(Sender: TObject);
var
   pt: TPoint;
begin
   GetCursorPos (pt);
   pt:= ScreenToClient(pt);
   if g_DWinMan.Click (pt.X, pt.Y) then Exit;
end;

procedure TfrmMain.MouseTimerTimer(Sender: TObject);
var
  I: Integer;
   pt: TPoint;
   keyvalue: TKeyBoardState;
   shift: TShiftState;

begin
   GetCursorPos (pt);
   SetCursorPos (pt.X, pt.Y);

   if g_TargetCret <> nil then begin
      if ActionKey > 0 then begin
         ProcessKeyMessages;
      end else begin
         if not g_TargetCret.m_boDeath and PlayScene.IsValidActor(g_TargetCret) then begin
            FillChar(keyvalue, sizeof(TKeyboardState), #0);
            if GetKeyboardState (keyvalue) then begin
               shift := [];
               if ((keyvalue[VK_SHIFT] and $80) <> 0) then shift := shift + [ssShift];
               if ((g_TargetCret.m_btRace <> RCC_USERHUMAN) and
                   (g_TargetCret.m_btRace <> RCC_GUARD) and
                   (g_TargetCret.m_btRace <> RCC_MERCHANT) and
                   (pos('(', g_TargetCret.m_sUserName) = 0) //�����ִ� ��(�������� �ؾ���)
                  )
                  or (g_TargetCret.m_nNameColor = ENEMYCOLOR)   //���� �ڵ� ������ ��

                   or  (((ssShift In Shift) Or g_boShift) And (Not PlayScene.EdChat.Visible)) then begin 
                 // or ((ssShift in Shift) Or g_boShift) and (not PlayScene.EdChat.Visible)) then begin //����� �Ǽ��� �����ϴ� ���� ����
                  AttackTarget (g_TargetCret);
               end; //else begin
                  //TargetCret := nil;
               //end
            end;
         end else
            g_TargetCret := nil;
      end;
   end;
   if g_boAutoDig then begin
      if CanNextAction and ServerAcceptNextAction and CanNextHit then begin
         g_MySelf.SendMsg (CM_HIT+1, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, g_MySelf.m_btDir, 0, 0, '', 0);
      end;
   end;
   //���Լ�ȡ
  { if g_boAutoPuckUpItem and
      (g_MySelf <> nil) and
      ((GetTickCount() - g_dwAutoPickupTick) > g_dwAutoPickupTime) then begin

     g_dwAutoPickupTick:=GetTickCount();
     AutoPickUpItem();
   end;}

      //���Լ�ȡ
    Try
      If g_WgInfo.boAutoPuckUpItem And

        (g_MySelf <> Nil) And
        ((GetTickCount() - g_dwAutoPickupTick) > g_AutoPuckUpItemTime) Then
      Begin

        g_dwAutoPickupTick := GetTickCount();
        AutoPickUpItem();
      End;
    Except
    End;


end;
procedure TfrmMain.AutoPickUpItem(boFlag: Boolean);
var
  I: Integer;
  //  ItemList:TList;
  DropItem: pTDropItem;
  //  ShowItem:pTShowItem;
begin
      If CanNextAction And ServerAcceptNextAction Then
    Begin
      If g_AutoPickupList = Nil Then
        exit;

      g_AutoPickupList.Clear;
      PlayScene.GetXYDropItemsList(g_MySelf.m_nCurrX, g_MySelf.m_nCurrY,
        g_AutoPickupList);
      If g_AutoPickupList.Count > 0 Then
        For I := 0 To g_AutoPickupList.Count - 1 Do
        Begin
          DropItem := g_AutoPickupList.Items[I];
          If (DropItem.boItemPick) Or (Not g_WgInfo.boAutoPuckItemFil) Or
            (boFlag) Then
          Begin
            SendPickup;
            Break;
          End;
        End;
    End;
end;

procedure TfrmMain.WaitMsgTimerTimer(Sender: TObject);
begin
   if g_MySelf = nil then exit;
   if g_MySelf.ActionFinished then begin
      WaitMsgTimer.Enabled := FALSE;
//      PlayScene.MemoLog.Lines.Add('WaitingMsg: ' + IntToStr(WaitingMsg.Ident));
      case WaitingMsg.Ident of
         SM_CHANGEMAP:
            begin
               g_boMapMovingWait := FALSE;
               g_boMapMoving := FALSE;
               //
               if g_nMDlgX <> -1 then begin
                  FrmDlg.CloseMDlg;
                  g_nMDlgX := -1;
               end;
               ClearDropItems;
               PlayScene.CleanObjects;
               g_sMapTitle := '';
               g_MySelf.CleanCharMapSetting (WaitingMsg.Param, WaitingMsg.Tag);
               PlayScene.SendMsg (SM_CHANGEMAP, 0,
                                    WaitingMsg.Param{x},
                                    WaitingMsg.tag{y},
                                    WaitingMsg.Series{darkness},
                                    0, 0,
                                    WaitingStr{mapname});

               //DScreen.AddSysMsg (IntToStr(WaitingMsg.Param) + ' ' +
               //                   IntToStr(WaitingMsg.Tag) + ' : My ' +
               //                   IntToStr(Myself.XX) + ' ' +
               //                   IntToStr(Myself.m_nCurrY) + ' ' +
               //                   IntToStr(Myself.RX) + ' ' +
               //                   IntToStr(Myself.RY) + ' '
               //                  );
               g_nTargetX := -1;
               g_TargetCret := nil;
               g_FocusCret := nil;

            end;
      end;
   end;
end;



{----------------------- Socket -----------------------}

procedure TfrmMain.SelChrWaitTimerTimer(Sender: TObject);
begin
   SelChrWaitTimer.Enabled := FALSE;
   SendQueryChr;
end;

procedure TfrmMain.ActiveCmdTimer (cmd: TTimerCommand);
begin
   CmdTimer.Enabled := TRUE;
   TimerCmd := cmd;
end;

procedure TfrmMain.CmdTimerTimer(Sender: TObject);
begin
   CmdTimer.Enabled := FALSE;
   CmdTimer.Interval := 2000;
//   PlayScene.MemoLog.Lines.Add('CmdTimerTimer -' + IntToStr(Integer(TimerCmd)));
   case TimerCmd of
      tcSoftClose:
         begin
//            PlayScene.MemoLog.Lines.Add('tcSoftClose');
            CmdTimer.Enabled := FALSE;
            CSocket.Socket.Close;
         end;
      tcReSelConnect:
         begin
           // try
//            PlayScene.MemoLog.Lines.Add('ConnectionStep -1');
            //���� ���� �ʱ�ȭ...
            ResetGameVariables;
//            PlayScene.MemoLog.Lines.Add('ConnectionStep -2');
            //
            DScreen.ChangeScene (stSelectChr);
//            PlayScene.MemoLog.Lines.Add('ConnectionStep -3');
            g_ConnectionStep := cnsReSelChr;
            {
            except
              on e: Exception do
              PlayScene.MemoLog.Lines.Add(e.Message);
            end;
            }
//            if ConnectionStep = cnsReSelChr then
//              PlayScene.MemoLog.Lines.Add('ConnectionStep -cnsReSelChr');
            if not BoOneClick then begin
//               PlayScene.MemoLog.Lines.Add('cnsReSelChr -' +  SelChrAddr + '/' + IntToStr(SelChrPort) );
               with CSocket do begin
                  Active := FALSE;
                  Address := g_sSelChrAddr;
                  Port := g_nSelChrPort;
                  Active := TRUE;
               end;

            end else begin
               if CSocket.Socket.Connected then
                  CSocket.Socket.SendText ('$S' + g_sSelChrAddr + '/' + IntToStr(g_nSelChrPort) + '%');
               CmdTimer.Interval := 1;
               ActiveCmdTimer (tcFastQueryChr);
            end;

         end;
      tcFastQueryChr:
         begin
            SendQueryChr;
         end;
   end;
end;

procedure TfrmMain.CloseAllWindows;
begin
   with FrmDlg do begin
      DItemBag.Visible := FALSE;
      DMsgDlg.Visible := FALSE;
      DStateWin.Visible := FALSE;
      DMerchantDlg.Visible := FALSE;
      DSellDlg.Visible := FALSE;
      DMenuDlg.Visible := FALSE;
      DKeySelDlg.Visible := FALSE;
      DGroupDlg.Visible := FALSE;
      DDealDlg.Visible := FALSE;
      DDealRemoteDlg.Visible := FALSE;
      DGuildDlg.Visible := FALSE;
      DGuildEditNotice.Visible := FALSE;
      DUserState1.Visible := FALSE;
      DAdjustAbility.Visible := FALSE;
   end;
   if g_nMDlgX <> -1 then begin
      FrmDlg.CloseMDlg;
      g_nMDlgX := -1;
   end;
   g_boItemMoving := FALSE;  //
end;

procedure TfrmMain.ClearDropItems;
var
  I:Integer;
begin
  for I:=0 to g_DropedItemList.Count - 1 do begin
    Dispose (PTDropItem(g_DropedItemList[I]));
  end;
  g_DropedItemList.Clear;
end;

procedure TfrmMain.ResetGameVariables;
var
   i: integer;
   ClientMagic:pTClientMagic;
begin
try
   CloseAllWindows;
   ClearDropItems;
  // ClearShowItemList();
   for i:=0 to g_MagicList.Count - 1  do begin
    Dispose(pTClientMagic(g_MagicList[i]));
   end;
   g_MagicList.Clear;



   g_boItemMoving := FALSE;
   g_WaitingUseItem.Item.S.Name := '';
   g_EatingItem.S.name := '';
   g_nTargetX := -1;
   g_TargetCret := nil;
   g_FocusCret := nil;
   g_MagicTarget := nil;
   ActionLock := FALSE;
   g_GroupMembers.Clear;
   g_sGuildRankName := '';
   g_sGuildName := '';

   g_boMapMoving := FALSE;
   WaitMsgTimer.Enabled := FALSE;
   g_boMapMovingWait := FALSE;
   DScreen.ChatBoardTop := 0;
   g_boNextTimePowerHit := FALSE;
   g_boCanLongHit := FALSE;
   g_boCanWideHit := FALSE;
   g_boCanCrsHit   := False;
   g_boCanTwnHit   := False;

   g_boNextTimeFireHit := FALSE;

   FillChar (g_UseItems, sizeof(TClientItem)*9, #0);
   FillChar (g_ItemArr, sizeof(TClientItem)*MAXBAGITEMCL, #0);

   with SelectChrScene do begin
      FillChar (ChrArr, sizeof(TSelChar)*2, #0);
      ChrArr[0].FreezeState := TRUE; //�⺻�� ��� �ִ� ����
      ChrArr[1].FreezeState := TRUE;
   end;
   PlayScene.ClearActors;
   ClearDropItems;
   EventMan.ClearEvents;
   PlayScene.CleanObjects;
   //DxDrawRestoreSurface (self);
   g_MySelf := nil;

except
//  on e: Exception do
//    PlayScene.MemoLog.Lines.Add(e.Message);
end;
end;

procedure TfrmMain.ChangeServerClearGameVariables;
var
   i: integer;
begin
   CloseAllWindows;
   ClearDropItems;
   for i:=0 to g_MagicList.Count-1 do
      Dispose (PTClientMagic (g_MagicList[i]));
   g_MagicList.Clear;
   g_boItemMoving := FALSE;
   g_WaitingUseItem.Item.S.Name := '';
   g_EatingItem.S.name := '';
   g_nTargetX := -1;
   g_TargetCret := nil;
   g_FocusCret := nil;
   g_MagicTarget := nil;
   ActionLock := FALSE;
   g_GroupMembers.Clear;
   g_sGuildRankName := '';
   g_sGuildName := '';

   g_boMapMoving := FALSE;
   WaitMsgTimer.Enabled := FALSE;
   g_boMapMovingWait := FALSE;
   g_boNextTimePowerHit := FALSE;
   g_boCanLongHit := FALSE;
   g_boCanWideHit := FALSE;
   g_boCanCrsHit   := False;
   g_boCanTwnHit   := False;

   ClearDropItems;
   EventMan.ClearEvents;
   PlayScene.CleanObjects;
end;

procedure TfrmMain.CSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
   packet: array[0..255] of char;
   strbuf: array[0..255] of char;
   str: string;
begin
   g_boServerConnected := TRUE;
   if g_ConnectionStep = cnsLogin then begin
      if OneClickMode = toKornetWorld then begin  //�ڳݿ��带 �����ؼ� ���ӿ� ����
         FillChar (packet, 256, #0);
         str := 'KwGwMGS';             StrPCopy (strbuf, str);  Move (strbuf, (@packet[0])^, Length(str));
         str := 'CONNECT';             StrPCopy (strbuf, str);  Move (strbuf, (@packet[8])^, Length(str));
         str := KornetWorld.CPIPcode;  StrPCopy (strbuf, str);  Move (strbuf, (@packet[16])^, Length(str));
         str := KornetWorld.SVCcode;   StrPCopy (strbuf, str);  Move (strbuf, (@packet[32])^, Length(str));
         str := KornetWorld.LoginID;   StrPCopy (strbuf, str);  Move (strbuf, (@packet[48])^, Length(str));
         str := KornetWorld.CheckSum;  StrPCopy (strbuf, str);  Move (strbuf, (@packet[64])^, Length(str));
         Socket.SendBuf (packet, 256);
      end;
      DScreen.ChangeScene (stLogin);
{$IF USECURSOR = DEFAULTCURSOR}
      DxDraw.Cursor:=crDefault;
{$IFEND}
   end;
   if g_ConnectionStep = cnsSelChr then begin
      LoginScene.OpenLoginDoor;
      SelChrWaitTimer.Enabled := TRUE;
   end;
   if g_ConnectionStep = cnsReSelChr then begin
      CmdTimer.Interval := 1;
      ActiveCmdTimer (tcFastQueryChr);
   end;
   if g_ConnectionStep = cnsPlay then begin
      if not g_boServerChanging then begin
         ClearBag;  //���� �ʱ�ȭ
         DScreen.ClearChatBoard; //ä��â �ʱ�ȭ
         DScreen.ChangeScene (stLoginNotice);
      end else begin
         ChangeServerClearGameVariables;
      end;
      SendRunLogin;
   end;
   SocStr := '';
   BufferStr := '';
end;

procedure TfrmMain.CSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   g_boServerConnected := FALSE;
      FrmDlg.DLOGO.Visible := False;
   if (g_ConnectionStep = cnsLogin) and not g_boSendLogin then begin
     FrmDlg.DMessageDlg ('Connection closed...', [mbOk]);
     Close;
   end;
   if g_SoftClosed then begin
//      PlayScene.MemoLog.Lines.Add('CSocketDisconnect - tcSoftClose');
      g_SoftClosed := FALSE;
      ActiveCmdTimer (tcReSelConnect);
   end;
end;

procedure TfrmMain.CSocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Socket.Close;
end;

procedure TfrmMain.CSocketRead(Sender: TObject; Socket: TCustomWinSocket);
var
   n: integer;
   data, data2: string;
begin
   data := Socket.ReceiveText;
   //if pos('GOOD', data) > 0 then DScreen.AddSysMsg (data);

   n := pos('*', data);
   if n > 0 then begin
      data2 := Copy (data, 1, n-1);
      data := data2 + Copy (data, n+1, Length(data));
      //SendSocket ('*');
      CSocket.Socket.SendText ('*');
   end;
   SocStr := SocStr + data;
end;

{-------------------------------------------------------------}

procedure TfrmMain.SendSocket (sendstr: string);
//const
 //  code: byte = 1;
var
   sSendText:String;
begin
   if CSocket.Socket.Connected then begin
      CSocket.Socket.SendText ('#' + IntToStr(code) + sendstr + '!');
     Inc (code);
     if code >= 10 then code := 1;
   end;
end;


procedure TfrmMain.SendClientMessage (msg, Recog, param, tag, series: integer);
var
   dmsg: TDefaultMessage;
begin
   dmsg := MakeDefaultMsg (msg, Recog, param, tag, series);
   SendSocket (EncodeMessage (dmsg));
end;

procedure TfrmMain.SendLogin (uid, passwd: string);
var
   msg: TDefaultMessage;
begin
   LoginId := uid;
   LoginPasswd := passwd;
   msg := MakeDefaultMsg (CM_IDPASSWORD, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString(uid + '/' + passwd));
   g_boSendLogin:=True;
end;

procedure TfrmMain.SendNewAccount (ue: TUserEntry; ua: TUserEntryAdd);
var
   msg: TDefaultMessage;
begin
   MakeNewId := ue.sAccount;
   msg := MakeDefaultMsg (CM_ADDNEWUSER, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeBuffer(@ue, sizeof(TUserEntry)) + EncodeBuffer(@ua, sizeof(TUserEntryAdd)));
end;

procedure TfrmMain.SendUpdateAccount (ue: TUserEntry; ua: TUserEntryAdd);
var
   msg: TDefaultMessage;
begin
   MakeNewId := ue.sAccount;
   msg := MakeDefaultMsg (CM_UPDATEUSER, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeBuffer(@ue, sizeof(TUserEntry)) + EncodeBuffer(@ua, sizeof(TUserEntryAdd)));
end;

procedure TfrmMain.SendSelectServer (svname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_SELECTSERVER, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString(svname));
end;

procedure TfrmMain.SendChgPw (id, passwd, newpasswd: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_CHANGEPASSWORD, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (id + #9 + passwd + #9 + newpasswd));
end;

procedure TfrmMain.SendNewChr (uid, uname, shair, sjob, ssex: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_NEWCHR, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (uid + '/' + uname + '/' + shair + '/' + sjob + '/' + ssex));
end;

procedure TfrmMain.SendQueryChr;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_QUERYCHR, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString(LoginId + '/' + IntToStr(Certification)));
end;

procedure TfrmMain.SendDelChr (chrname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DELCHR, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString(chrname));
end;

procedure TfrmMain.SendSelChr (chrname: string);
var
   msg: TDefaultMessage;
begin
   CharName := chrname;
   msg := MakeDefaultMsg (CM_SELCHR, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString(LoginId + '/' + chrname));
   PlayScene.EdAccountt.Visible:=False;//2004/05/17
   PlayScene.EdChrNamet.Visible:=False;//2004/05/17
end;

procedure TfrmMain.SendRunLogin;
var
   msg: TDefaultMessage;
   str: string;
   sSendMsg:String;
begin
   //ǿ�е�¼
   {
   str := '**' +
          PlayScene.EdAccountt.Text + '/' +
          PlayScene.EdChrNamet.Text + '/' +
          IntToStr(Certification) + '/' +
          IntToStr(VERSION_NUMBER) + '/';
  }

(*   str := '**' +
          LoginId + '/' +
          CharName + '/' +
          IntToStr(Certification) + '/' +
          IntToStr(VERSION_NUMBER) + '/';

//          IntToStr(VERSION_NUMBER_0522) + '/';

   //if NewGameStart then begin
   //   str := str + '0';
   //   NewGameStart := FALSE;
   //end else str := str + '1';
   str := str + '9';*)
   sSendMsg:=format('**%s/%s/%d/%d/%d',[LoginId,CharName,Certification,CLIENT_VERSION_NUMBER,RUNLOGINCODE]);
   SendSocket (EncodeString (sSendMsg));
   
end;

procedure TfrmMain.SendSay (str: string);
var
   msg: TDefaultMessage;
begin
   if str <> '' then begin
     if m_boPasswordIntputStatus then begin
       m_boPasswordIntputStatus      := False;
       PlayScene.EdChat.PasswordChar := #0;
       PlayScene.EdChat.Visible      := False;
       SendPassword(str,1);
       exit;
     end;
     if CompareLstr(str,'/cmd',length('/cmd')) then begin
       ProcessCommand(str);
       exit;
     end;
       
      if str = '/debug check' then begin
        g_boShowMemoLog:=not g_boShowMemoLog;
        PlayScene.MemoLog.Clear;
        PlayScene.MemoLog.Visible:=g_boShowMemoLog;
        exit;
      end;
      if str = '/debug powerblock' then begin
        SendPowerBlock();
        exit;
      end;

      if str = '/debug screen' then begin
         g_boCheckBadMapMode := not g_boCheckBadMapMode;
         if g_boCheckBadMapMode then DScreen.AddSysMsg ('On')
         else DScreen.AddSysMsg ('Off');
         exit;
      end;
      if str = '/check speedhack' then begin
         g_boCheckSpeedHackDisplay := not g_boCheckSpeedHackDisplay;
         exit;
      end;
      if str = '/hungry' then begin
         Inc(g_nMyHungryState);
         if g_nMyHungryState > 4 then g_nMyHungryState:=1;
           
         exit;
      end;
      if str = '/hint screen' then begin
         g_boShowGreenHint := not g_boShowGreenHint;
         g_boShowWhiteHint := not g_boShowWhiteHint;
         exit;
      end;

      if str = '@password' then begin
         if PlayScene.EdChat.PasswordChar = #0 then
            PlayScene.EdChat.PasswordChar := '*'
         else PlayScene.EdChat.PasswordChar := #0;
         exit;   
      end;
      if PlayScene.EdChat.PasswordChar = '*' then
        PlayScene.EdChat.PasswordChar:= #0;

      msg := MakeDefaultMsg (CM_SAY, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString(str));
      if str[1] = '/' then begin
         DScreen.AddChatBoardString (str, GetRGB(180), clWhite);
         GetValidStr3 (Copy(str,2,Length(str)-1), WhisperName, [' ']);
      end;
   end;
end;

procedure TfrmMain.SendActMsg (ident, x, y, dir: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (ident, MakeLong(x,y), 0, dir, 0);
   SendSocket (EncodeMessage (msg));
   ActionLock := TRUE; //�������� #+FAIL! �̳� #+GOOD!�� �ö����� ��ٸ�
   ActionLockTime := GetTickCount;
   Inc (g_nSendCount);
end;

procedure TfrmMain.SendSpellMsg (ident, x, y, dir, target: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (ident, MakeLong(x,y), Loword(target), dir, Hiword(target));
   SendSocket (EncodeMessage (msg));
   ActionLock := TRUE; //�������� #+FAIL! �̳� #+GOOD!�� �ö����� ��ٸ�
   ActionLockTime := GetTickCount;
   Inc (g_nSendCount);
end;

procedure TfrmMain.SendQueryUserName (targetid, x, y: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_QUERYUSERNAME, targetid, x, y, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendDropItem (name: string; itemserverindex: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DROPITEM, itemserverindex, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (name));
end;

procedure TfrmMain.SendPickup;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_PICKUP, 0, g_MySelf.m_nCurrX, g_MySelf.m_nCurrY, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendTakeOnItem (where: byte; itmindex: integer; itmname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_TAKEONITEM, itmindex, where, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itmname));
end;

procedure TfrmMain.SendTakeOffItem (where: byte; itmindex: integer; itmname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_TAKEOFFITEM, itmindex, where, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itmname));
end;

procedure TfrmMain.SendEat (itmindex: integer; itmname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_EAT, itmindex, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itmname));
end;

procedure TfrmMain.SendButchAnimal (x, y, dir, actorid: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_BUTCH, actorid, x, y, dir);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendMagicKeyChange (magid: integer; keych: char);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_MAGICKEYCHANGE, magid, byte(keych), 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendMerchantDlgSelect (merchant: integer; rstr: string);
var
   msg: TDefaultMessage;
   param: string;
begin
   if Length(rstr) >= 2 then begin  //�Ķ��Ÿ�� �ʿ��� ��찡 ����.
      if (rstr[1] = '@') and (rstr[2] = '@') then begin
         if rstr = '@@buildguildnow' then
            FrmDlg.DMessageDlg ('���������뽨�����л�����֡�', [mbOk, mbAbort])
         else FrmDlg.DMessageDlg ('�����롣', [mbOk, mbAbort]);
         param := Trim (FrmDlg.DlgEditText);
         rstr := rstr + #13 + param;
      end;
   end;
   msg := MakeDefaultMsg (CM_MERCHANTDLGSELECT, merchant, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (rstr));
end;

procedure TfrmMain.SendQueryPrice (merchant, itemindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_MERCHANTQUERYSELLPRICE, merchant, Loword(itemindex), Hiword(itemindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendQueryRepairCost (merchant, itemindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_MERCHANTQUERYREPAIRCOST, merchant, Loword(itemindex), Hiword(itemindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendSellItem (merchant, itemindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERSELLITEM, merchant, Loword(itemindex), Hiword(itemindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendRepairItem (merchant, itemindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERREPAIRITEM, merchant, Loword(itemindex), Hiword(itemindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendStorageItem (merchant, itemindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERSTORAGEITEM, merchant, Loword(itemindex), Hiword(itemindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendGetDetailItem (merchant, menuindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERGETDETAILITEM, merchant, menuindex, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendBuyItem (merchant, itemserverindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERBUYITEM, merchant, Loword(itemserverindex), Hiword(itemserverindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendTakeBackStorageItem (merchant, itemserverindex: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERTAKEBACKSTORAGEITEM, merchant, Loword(itemserverindex), Hiword(itemserverindex), 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendMakeDrugItem (merchant: integer; itemname: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_USERMAKEDRUGITEM, merchant, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (itemname));
end;

procedure TfrmMain.SendDropGold (dropgold: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DROPGOLD, dropgold, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendGroupMode (onoff: Boolean);
var
   msg: TDefaultMessage;
begin
   if onoff then
      msg := MakeDefaultMsg (CM_GROUPMODE, 0, 1, 0, 0)   //on
   else msg := MakeDefaultMsg (CM_GROUPMODE, 0, 0, 0, 0);  //off
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendCreateGroup (withwho: string);
var
   msg: TDefaultMessage;
begin
   if withwho <> '' then begin
      msg := MakeDefaultMsg (CM_CREATEGROUP, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (withwho));
   end;
end;

procedure TfrmMain.SendWantMiniMap;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_WANTMINIMAP, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendDealTry;
var
   msg: TDefaultMessage;
   i, fx, fy: integer;
   actor: TActor;
   who: string;
   proper: Boolean;
begin
   (*proper := FALSE;
   GetFrontPosition (Myself.XX, Myself.m_nCurrY, Myself.Dir, fx, fy);
   with PlayScene do
      for i:=0 to ActorList.Count-1 do begin
         actor := TActor (ActorList[i]);
         if {(actor.m_btRace = 0) and} (actor.XX = fx) and (actor.m_nCurrY = fy) then begin
            proper := TRUE;
            who := actor.UserName;
            break;
         end;
      end;
   if proper then begin*)
      msg := MakeDefaultMsg (CM_DEALTRY, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (who));
   //end;
end;

procedure TfrmMain.SendGuildDlg;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_OPENGUILDDLG, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendCancelDeal;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DEALCANCEL, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendAddDealItem (ci: TClientItem);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DEALADDITEM, ci.MakeIndex, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (ci.S.Name));
end;

procedure TfrmMain.SendDelDealItem (ci: TClientItem);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DEALDELITEM, ci.MakeIndex, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (ci.S.Name));
end;

procedure TfrmMain.SendChangeDealGold (gold: integer);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DEALCHGGOLD, gold, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendDealEnd;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_DEALEND, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendAddGroupMember (withwho: string);
var
   msg: TDefaultMessage;
begin
   if withwho <> '' then begin
      msg := MakeDefaultMsg (CM_ADDGROUPMEMBER, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (withwho));
   end;
end;

procedure TfrmMain.SendDelGroupMember (withwho: string);
var
   msg: TDefaultMessage;
begin
   if withwho <> '' then begin
      msg := MakeDefaultMsg (CM_DELGROUPMEMBER, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (withwho));
   end;
end;

procedure TfrmMain.SendGuildHome;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_GUILDHOME, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendGuildMemberList;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_GUILDMEMBERLIST, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendGuildAddMem (who: string);
var
   msg: TDefaultMessage;
begin
   if Trim(who) <> '' then begin
      msg := MakeDefaultMsg (CM_GUILDADDMEMBER, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (who));
   end;
end;

procedure TfrmMain.SendGuildDelMem (who: string);
var
   msg: TDefaultMessage;
begin
   if Trim(who) <> '' then begin
      msg := MakeDefaultMsg (CM_GUILDDELMEMBER, 0, 0, 0, 0);
      SendSocket (EncodeMessage (msg) + EncodeString (who));
   end;
end;

procedure TfrmMain.SendGuildUpdateNotice (notices: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_GUILDUPDATENOTICE, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (notices));
end;

procedure TfrmMain.SendGuildUpdateGrade (rankinfo: string);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_GUILDUPDATERANKINFO, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeString (rankinfo));
end;

procedure TfrmMain.SendSpeedHackUser;
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_SPEEDHACKUSER, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg));
end;

procedure TfrmMain.SendAdjustBonus (remain: integer; babil: TNakedAbility);
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_ADJUST_BONUS, remain, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeBuffer (@babil, sizeof(TNakedAbility)));
end;

procedure TfrmMain.SendPowerBlock();
var
   msg: TDefaultMessage;
begin
   msg := MakeDefaultMsg (CM_POWERBLOCK, 0, 0, 0, 0);
   SendSocket (EncodeMessage (msg) + EncodeBuffer (@g_PowerBlock, sizeof(TPowerBlock)));
end;
{---------------------------------------------------------------}


function  TfrmMain.ServerAcceptNextAction: Boolean;
begin
   Result := TRUE;
   //���� �ൿ�� �������� �����Ǿ�����
   if ActionLock then begin
      if GetTickCount - ActionLockTime > 10 * 1000 then begin
         ActionLock := FALSE;
         //Dec (WarningLevel);
      end;
      Result := FALSE;
   end;
end;

function  TfrmMain.CanNextAction: Boolean;
begin
  If (g_MySelf.IsIdle) And
    ((g_MySelf.m_nState And $04000000 = 0) Or (g_wgInfo.boParalyCan )) And //��ʯ��
  (GetTickCount - g_dwDizzyDelayStart > g_dwDizzyDelayTime) Then
  Begin
    Result := TRUE;
  End
  Else
    Result := FALSE;
end;
//�Ƿ���Թ��������ƹ����ٶ�
function  TfrmMain.CanNextHit: Boolean;
var
   NextHitTime, LevelFastTime:Integer;
begin
   LevelFastTime:= _MIN (370, (g_MySelf.m_Abil.Level * 14));
   LevelFastTime:= _MIN (800, LevelFastTime + g_MySelf.m_nHitSpeed * g_nItemSpeed{60});

   if g_boAttackSlow then
      NextHitTime:= g_nHitTime{1400} - LevelFastTime + 1500 //��������ʱ�����������ٶ�
   else NextHitTime:= g_nHitTime{1400} - LevelFastTime;

   if NextHitTime < 0 then NextHitTime:= 0;

   if GetTickCount - LastHitTick > LongWord(NextHitTime) then begin
      LastHitTick:=GetTickCount;
      Result:=True;
   end else Result:=False;
end;

procedure TfrmMain.ActionFailed;
begin
   g_nTargetX := -1;
   g_nTargetY := -1;
   ActionFailLock := TRUE; //���� �������� �����̵����и� �������ؼ�, FailDir�� �Բ� ���
   ActionFailLockTime :=GetTickCount();//Jacky
   g_MySelf.MoveFail;
end;

function  TfrmMain.IsUnLockAction (action, adir: integer): Boolean;
begin
   if ActionFailLock then begin //�������������������ָ��ʱ������
     if GetTickCount() - ActionFailLockTime > 1000 then ActionFailLock:=False;
   end;
   if (ActionFailLock) or (g_boMapMoving) or (g_boServerChanging) then begin
      Result := FALSE;
   end else Result := TRUE;

{
   if (ActionFailLock and (action = FailAction) and (adir = FailDir))
      or (MapMoving)
      or (BoServerChanging) then begin
      Result := FALSE;
   end else begin
      ActionFailLock := FALSE;
      Result := TRUE;
   end;
}
end;

function TfrmMain.IsGroupMember (uname: string): Boolean;
var
   i: integer;
begin
   Result := FALSE;
   for i:=0 to g_GroupMembers.Count-1 do
      if g_GroupMembers[i] = uname then begin
         Result := TRUE;
         break;
      end;
end;

{-------------------------------------------------------------}

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
   str, data: string;
   len, i, n, mcnt : integer;
//const
 //  busy: Boolean = FALSE;
begin
   if busy then exit;
   //if ServerConnected then
   //   DxTimer.Enabled := TRUE
   //else
   //   DxTimer.Enabled := FALSE;

   busy := TRUE;
   try
      BufferStr := BufferStr + SocStr;
      SocStr := '';
      if BufferStr <> '' then begin
         mcnt := 0;
         while Length(BufferStr) >= 2 do begin
            if g_boMapMovingWait then break; // ���..
            if Pos('!', BufferStr) <= 0 then break;
            BufferStr := ArrestStringEx (BufferStr, '#', '!', data);
            if data = '' then break;
            DecodeMessagePacket (data);
            if Pos('!', BufferStr) <= 0 then break;
         end;
      end;
   finally
      busy := FALSE;
   end;

   if WarningLevel > 30 then
      FrmMain.Close;

   if g_boQueryPrice then begin
      if GetTickCount - g_dwQueryPriceTime > 500 then begin
         g_boQueryPrice := FALSE;
         case FrmDlg.SpotDlgMode of
            dmSell: SendQueryPrice (g_nCurMerchant, g_SellDlgItem.MakeIndex, g_SellDlgItem.S.Name);
            dmRepair: SendQueryRepairCost (g_nCurMerchant, g_SellDlgItem.MakeIndex, g_SellDlgItem.S.Name);
         end;
      end;
   end;

   if g_nBonusPoint > 0 then begin
      FrmDlg.DBotPlusAbil.Visible := TRUE;
   end else begin
      FrmDlg.DBotPlusAbil.Visible := FALSE;
   end;

end;

procedure TfrmMain.SpeedHackTimerTimer(Sender: TObject);
var
   gcount, timer: longword;
   ahour, amin, asec, amsec: word;
begin
   DecodeTime (Time, ahour, amin, asec, amsec);
   timer := ahour * 1000 * 60 * 60 + amin * 1000 * 60 + asec * 1000 + amsec;
   gcount := GetTickCount;
   if g_dwSHGetTime > 0 then begin
      if abs((gcount - g_dwSHGetTime) - (timer - g_dwSHTimerTime)) > 70 then begin
         Inc (g_nSHFakeCount);
      end else
         g_nSHFakeCount := 0;
      if g_nSHFakeCount > 4 then begin
         FrmDlg.DMessageDlg ('Terminate the program. CODE=10001\' +
                             'Please contact game master.',
                             [mbOk]);
         FrmMain.Close;
      end;
      if g_boCheckSpeedHackDisplay then begin
         DScreen.AddSysMsg ('->' + IntToStr(gcount - g_dwSHGetTime) + ' - ' +
                                   IntToStr(timer - g_dwSHTimerTime) + ' = ' +
                                   IntToStr(abs((gcount - g_dwSHGetTime) - (timer - g_dwSHTimerTime))) + ' (' +
                                   IntToStr(g_nSHFakeCount) + ')');
      end;
   end;
   g_dwSHGetTime := gcount;
   g_dwSHTimerTime := timer;
end;

procedure TfrmMain.CheckSpeedHack (rtime: Longword);
var
   cltime, svtime: integer;
   str: string;
begin
   if g_dwFirstServerTime > 0 then begin
      if (GetTickCount - g_dwFirstClientTime) > 1 * 60 * 60 * 1000 then begin  //1�ð� ���� �ʱ�ȭ
         g_dwFirstServerTime := rtime; //�ʱ�ȭ
         g_dwFirstClientTime := GetTickCount;
         //ServerTimeGap := rtime - int64(GetTickCount);
      end;
      cltime := GetTickCount - g_dwFirstClientTime;
      svtime := rtime - g_dwFirstServerTime + 3000;

      if cltime > svtime then begin
         Inc (g_nTimeFakeDetectCount);
         if g_nTimeFakeDetectCount > 6 then begin
            //�ð�����...
            str := 'Bad';
            //SendSpeedHackUser;
            FrmDlg.DMessageDlg ('Terminate the program. CODE=10000\' +
                                'Connection is bad or system is unstable.\' +
                                'Please contact game master.',
                                [mbOk]);
            FrmMain.Close;
         end;
      end else begin
         str := 'Good';
         g_nTimeFakeDetectCount := 0;
      end;
      if g_boCheckSpeedHackDisplay then begin
         DScreen.AddSysMsg (IntToStr(svtime) + ' - ' +
                            IntToStr(cltime) + ' = ' +
                            IntToStr(svtime-cltime) +
                            ' ' + str);
      end;
   end else begin
      g_dwFirstServerTime := rtime;
      g_dwFirstClientTime := GetTickCount;
      //ServerTimeGap := int64(GetTickCount) - longword(msg.Recog);
   end;
end;

procedure TfrmMain.DecodeMessagePacket (datablock: string);
var
   head, body, body2, tagstr, data, rdstr, str: String;
   msg : TDefaultMessage;
   smsg: TShortMessage;
   mbw: TMessageBodyW;
   desc: TCharDesc;
   wl: TMessageBodyWL;
   featureEx: word;
   L, i, j, n, BLKSize, param, sound, cltime, svtime: integer;
   tempb: boolean;
   actor: TActor;
   event: TClEvent;
begin

   if datablock[1] = '+' then begin  //checkcode
      data := Copy (datablock, 2, Length(datablock)-1);
      data := GetValidStr3 (data, tagstr, ['/']);
      if tagstr = 'PWR'  then g_boNextTimePowerHit := True;  //�򿪹�ɱ
      if tagstr = 'LNG'  then g_boCanLongHit := True;        //�򿪴�ɱ
      if tagstr = 'ULNG' then g_boCanLongHit := False;       //�رմ�ɱ
      if tagstr = 'WID'  then g_boCanWideHit := True;        //�򿪰���
      if tagstr = 'UWID' then g_boCanWideHit := False;       //�رհ���
      if tagstr = 'CRS'  then g_boCanCrsHit := True;
      if tagstr = 'UCRS' then g_boCanCrsHit := False;
      if tagstr = 'TWN'  then g_boCanTwnHit := True;
      if tagstr = 'UTWN' then g_boCanTwnHit := False;
      if tagstr = 'STN'  then g_boCanStnHit := True;
      if tagstr = 'USTN' then g_boCanStnHit := False;
      if tagstr = 'FIR'  then begin
         g_boNextTimeFireHit := TRUE;  //���һ�
         g_dwLatestFireHitTick := GetTickCount;
         //Myself.SendMsg (SM_READYFIREHIT, Myself.XX, Myself.m_nCurrY, Myself.Dir, 0, 0, '', 0);
      end;
      if tagstr = 'UFIR' then g_boNextTimeFireHit := False; //�ر��һ�
      if tagstr = 'GOOD' then begin
         ActionLock := FALSE;
         Inc(g_nReceiveCount);
      end;
      if tagstr = 'FAIL' then begin
         ActionFailed;
         ActionLock := FALSE;
         Inc(g_nReceiveCount);
      end;
      //DScreen.AddSysmsg (data);
      if data <> '' then begin
         CheckSpeedHack (Str_ToInt(data, 0));
      end;
      exit;
   end;
   if Length(datablock) < DEFBLOCKSIZE then begin
      if datablock[1] = '=' then begin
         data := Copy (datablock, 2, Length(datablock)-1);
         if data = 'DIG' then begin
            g_MySelf.m_boDigFragment := TRUE;
         end;
      end;
      exit;
   end;

   head := Copy (datablock, 1, DEFBLOCKSIZE);
   body := Copy (datablock, DEFBLOCKSIZE+1, Length(datablock)-DEFBLOCKSIZE);
   msg  := DecodeMessage (head);

   //DScreen.AddSysMsg (IntToStr(msg.Ident));

   if (msg.Ident <> SM_HEALTHSPELLCHANGED) and
      (msg.Ident <> SM_HEALTHSPELLCHANGED)
      then begin

     if g_boShowMemoLog then begin
       ShowHumanMsg(@Msg);
       //PlayScene.MemoLog.Lines.Add('Ident: ' + IntToStr(msg.Recog) + '/' + IntToStr(msg.Ident));
     end;
   end;
//   PlayScene.MemoLog.Lines.Add('datablock: ' + datablock);
   if g_MySelf = nil then begin
      case msg.Ident of
         SM_NEWID_SUCCESS:
            begin
               FrmDlg.DMessageDlg ('����˺��Ѿ������ˡ�' +
                                   '�����Ʊ�������˻������룬\' +
                                   '���Ҳ�Ҫ���κ�ԭ���������������.\' +
                                   '�������������,\' +
                                   '�����ͨ�����ǵ���ҳ�����һ���.\' +
                                   '(http://www.skym2.com))', [mbOk]);
            end;
         SM_NEWID_FAIL:
            begin
               case msg.Recog of
                  0: begin
                        FrmDlg.DMessageDlg('[' + MakeNewId +']�Ѿ����������ʹ���ˡ�\������ѡ���û�����', [mbOk]);
                        LoginScene.NewIdRetry (FALSE);  //�ٽ� �õ�
                     end;
                  -2: FrmDlg.DMessageDlg('�ڱ��������ϣ����û����ѱ���ֹʹ�á�\����ѡһ����ͬ�����֡�', [mbOk]);
                  else
                   FrmDlg.DMessageDlg('����IDʧ�ܣ���ȷ��û�а����ո�\���⡢�����Ա��ϵ��ַ��� ', [mbOk]);
               end;
            end;
         SM_PASSWD_FAIL:
            begin
            Case msg.Recog Of
              -1: FrmDlg.DMessageDlg('[ʧ��]���������', [mbOk]);
              -2: FrmDlg.DMessageDlg('[ʧ��]���˺ű�������������󳬹����Σ����Ժ����ԣ�', [mbOk]);
              -3: FrmDlg.DMessageDlg('[ʧ��]���˺ű������������û�����ʹ�õ��У�', [mbOk]);
              -4: FrmDlg.DMessageDlg('[ʧ��]��������ע�������˺ţ�',[mbOk]);
              -5: FrmDlg.DMessageDlg('[ʧ��]�������˺��ѹ��ڣ��ѱ���ͣʹ�ã�', [mbOk]);
            Else
              FrmDlg.DMessageDlg('[ʧ��]���˺Ų����ڣ�', [mbOk]);
            End;
               LoginScene.PassWdFail;
            end;
         SM_NEEDUPDATE_ACCOUNT: //���� ������ �ٽ� �Է��϶�.
            begin
               ClientGetNeedUpdateAccount (body);
            end;
         SM_UPDATEID_SUCCESS:
            begin
               FrmDlg.DMessageDlg ('����˺��Ѿ����¡�\' +
                                   '�����Ʊ�������˻������룬\' +
                                   '���Ҳ�Ҫ���κ�ԭ���������������.\' +
                                   '�����ͨ�����ǵ���ҳ�����һ���.\', [mbOk]);
               ClientGetSelectServer;
            end;
         SM_UPDATEID_FAIL:
            begin
               FrmDlg.DMessageDlg ('�����˻�ʧ��.', [mbOk]);
               ClientGetSelectServer;
            end;
         SM_PASSOK_SELECTSERVER: begin
           ClientGetPasswordOK(msg,body);
         end;
         SM_SELECTSERVER_OK: begin
           ClientGetPasswdSuccess (body);
         end;
         SM_QUERYCHR: begin
           ClientGetReceiveChrs (body);
         end;
         SM_QUERYCHR_FAIL: begin
           g_boDoFastFadeOut := FALSE;
           g_boDoFadeIn := FALSE;
           g_boDoFadeOut := FALSE;
           FrmDlg.DMessageDlg ('����˺Ų����ã���������֤ʧ�ܡ�', [mbOk]);
           Close;
         end;
         SM_NEWCHR_SUCCESS: begin
           SendQueryChr;
         end;
         SM_NEWCHR_FAIL: begin
              Case msg.Recog Of
              0: FrmDlg.DMessageDlg('[ʧ��]����ɫ����ʧ�ܣ�\ \��ɫ����ֻ�������֡�Ӣ�ĺͼ��庺���ַ�.\��ȷ�Ͻ�ɫ�����Ƿ���зǷ��ַ�', [mbOk]);
              2: FrmDlg.DMessageDlg('[ʧ��]����������Ѵ���.', [mbOk]);
              3: FrmDlg.DMessageDlg('[ʧ��]�������ֻ��Ϊһ���˺�����2����ɫ.', [mbOk]);
              4: FrmDlg.DMessageDlg('[ʧ��]����ɫ����ʧ�ܣ�\ \��ɫ����ֻ�������֡�Ӣ�ĺͼ��庺���ַ�.\��ȷ�Ͻ�ɫ�����Ƿ���зǷ��ַ�', [mbOk]);
              5:FrmDlg.DMessageDlg('[ʧ��]�����������Ľ�ɫ�����Ѵ�����.', [mbOk]);
            Else
              FrmDlg.DMessageDlg('[ʧ��]����ɫ����ʧ�ܣ�\ \��ɫ����ֻ�������֡�Ӣ�ĺͼ��庺���ַ�.\��ȷ�Ͻ�ɫ�����Ƿ���зǷ��ַ�', [mbOk]);
            End;
         end;
         SM_CHGPASSWD_SUCCESS: begin
           FrmDlg.DMessageDlg('�������ɹ�.', [mbOk]);
         end;
         SM_CHGPASSWD_FAIL: begin
              Case msg.Recog Of
              -1: FrmDlg.DMessageDlg('[ʧ��]��ԭ������˺Ŵ��󣬲����޸�.', [mbOk]);
              -2:FrmDlg.DMessageDlg('[ʧ��]���˺ű����������Ժ�����.',[mbOk]);
            Else
              FrmDlg.DMessageDlg('[ʧ��]��ԭ������˺Ŵ��󣬲����޸�.', [mbOk]);
            End;
         end;
         SM_DELCHR_SUCCESS: begin
           SendQueryChr;
         end;
         SM_DELCHR_FAIL: begin
            FrmDlg.DMessageDlg('[ʧ��]�� ɾ����ɫʧ�ܡ�', [mbOk]);
         end;
         SM_STARTPLAY: begin
           ClientGetStartPlay (body);
           exit;
         end;
         SM_STARTFAIL: begin
           FrmDlg.DMessageDlg ('�˷�������Ա��', [mbOk]);
//               FrmMain.Close;
//               frmSelMain.Close;
           ClientGetSelectServer();
           exit;
         end;
         SM_VERSION_FAIL: begin
           FrmDlg.DMessageDlg('�汾����. ���������ؿͻ���. (http://www.legendofmir.net)', [mbOk]);
           FrmMain.Close;
           exit;
         end;
         SM_OUTOFCONNECTION,
         SM_NEWMAP,
         SM_LOGON,
         SM_RECONNECT,
         SM_SENDNOTICE: ;  //�Ʒ����� ó��
         else
            exit;
      end;
   end;
   if g_boMapMoving then begin
      if msg.Ident = SM_CHANGEMAP then begin
         WaitingMsg := msg;
         WaitingStr := DecodeString (body);
         g_boMapMovingWait := TRUE;
         WaitMsgTimer.Enabled := TRUE;
      end;
      exit;
   end;

  case msg.Ident of
    //Damian
    SM_VERSION_FAIL: begin
      i := MakeLong(msg.Param,msg.Tag);
      DecodeBuffer (body, @j, sizeof(Integer));
      if (msg.Recog <> g_nThisCRC) and
         (i <> g_nThisCRC) and
         (j <> g_nThisCRC) then begin

      //  FrmDlg.DMessageDlg ('Wrong version. Please download latest version.', [mbOk]);
      //  DScreen.AddChatBoardString ('Wrong version. Please download latest version.', clYellow, clRed);
      //  CSocket.Close;
//        FrmMain.Close;
//        frmSelMain.Close;
    //  exit;
        {FrmDlg.DMessageDlg ('Wrong version. Please download latest version. (http://www.legendofmir.net)', [mbOk]);
        Close;
        exit;}
      end;
    end;
      SM_NEWMAP: begin
        g_sMapTitle := '';
        str := DecodeString (body); //mapname
//        PlayScene.MemoLog.Lines.Add('X: ' + IntToStr(msg.Param) + 'Y: ' + IntToStr(msg.tag) + ' Map: ' + str);
        PlayScene.SendMsg (SM_NEWMAP, 0,
                           msg.Param{x},
                           msg.tag{y},
                           msg.Series{darkness},
                           0, 0,
                           str{mapname});
      end;
        SM_OpenItemArray:   //2015-06-07 ����б�
         begin
           SetLength(g_OpenItemArray,msg.Param);
           FillChar(g_OpenItemArray[0],msg.Param,#0);
           DecodeBuffer(Body, @g_OpenItemArray[0],msg.Recog);
           //RefWgInfo();
           LoadUserConfig(CharName);
         end;

      SM_LOGON: begin
        g_dwFirstServerTime := 0;
        g_dwFirstClientTime := 0;
        with msg do begin
          DecodeBuffer (body, @wl, sizeof(TMessageBodyWL));
          PlayScene.SendMsg (SM_LOGON, msg.Recog,
                             msg.Param{x},
                             msg.tag{y},
                             msg.Series{dir},
                             wl.lParam1, //desc.Feature,
                             wl.lParam2, //desc.Status,
                             '');
          DScreen.ChangeScene (stPlayGame);
          SendClientMessage (CM_QUERYBAGITEMS, 0, 0, 0, 0);
          if Lobyte(Loword(wl.lTag1)) = 1 then g_boAllowGroup := TRUE
          else g_boAllowGroup := FALSE;
          g_boServerChanging := FALSE;
        end;
        if g_wAvailIDDay > 0 then begin
          DScreen.AddChatBoardString ('You are connected through personal account.', clGreen, clWhite)
        end else if g_wAvailIPDay > 0 then begin
          DScreen.AddChatBoardString ('You are connected through fixed amount IP.', clGreen, clWhite)
        end else if g_wAvailIPHour > 0 then begin
          DScreen.AddChatBoardString ('You are connected through fixed time IP.', clGreen, clWhite)
        end else if g_wAvailIDHour > 0 then begin
          DScreen.AddChatBoardString ('You are connected through fixed time account.', clGreen, clWhite)
        end;
        LoadUserConfig(CharName);
        //DScreen.AddChatBoardString ('��ǰ��������Ϣ: ' + g_sRunServerAddr + ':' + IntToStr(g_nRunServerPort), clGreen, clWhite)
      end;
      SM_SERVERCONFIG: ClientGetServerConfig(Msg,Body);

      SM_RECONNECT: begin
        ClientGetReconnect (body);
      end;
      SM_TIMECHECK_MSG:
         begin
            CheckSpeedHack (msg.Recog);
         end;

      SM_AREASTATE:
         begin
            g_nAreaStateValue := msg.Recog;
         end;

      SM_MAPDESCRIPTION: begin
        ClientGetMapDescription(Msg,body);
      end;
      SM_GAMEGOLDNAME: begin
        ClientGetGameGoldName(msg,body);
      end;
      SM_ADJUST_BONUS: begin
        ClientGetAdjustBonus (msg.Recog, body);
      end;
      SM_MYSTATUS: begin
        g_nMyHungryState:=msg.Param;
      end;

      SM_TURN:
         begin
            if Length(body) > GetCodeMsgSize(sizeof(TCharDesc)*4/3) then begin
               Body2 := Copy (Body, GetCodeMsgSize(sizeof(TCharDesc)*4/3)+1, Length(body));
               data := DecodeString (body2); //ĳ�� �̸�
               str := GetValidStr3 (data, data, ['/']);
               //data = �̸�
               //str = ����
            end else data := '';
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            PlayScene.SendMsg (SM_TURN, msg.Recog,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir + light},
                                 desc.Feature,
                                 desc.Status,
                                 ''); //�̸�
            if data <> '' then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then begin
                  actor.m_sDescUserName := GetValidStr3(data, actor.m_sUserName, ['\']);
                  //actor.UserName := data;
                   HintBoss(Actor); //Boss��ʾ
                  actor.m_nNameColor := GetRGB(Str_ToInt(str, 0));
               end;
            end;
         end;

      SM_BACKSTEP:
         begin
            if Length(body) > GetCodeMsgSize(sizeof(TCharDesc)*4/3) then begin
               Body2 := Copy (Body, GetCodeMsgSize(sizeof(TCharDesc)*4/3)+1, Length(body));
               data := DecodeString (body2); //ĳ�� �̸�
               str := GetValidStr3 (data, data, ['/']);
               //data = �̸�
               //str = ����
            end else data := '';
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            PlayScene.SendMsg (SM_BACKSTEP, msg.Recog,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir + light},
                                 desc.Feature,
                                 desc.Status,
                                 ''); //�̸�
            if data <> '' then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then begin
                  actor.m_sDescUserName := GetValidStr3(data, actor.m_sUserName, ['\']);
                  //actor.UserName := data;
                  HintBoss(Actor); //Boss��ʾ
                  actor.m_nNameColor := GetRGB(Str_ToInt(str, 0));
               end;
            end;
         end;

      SM_SPACEMOVE_HIDE,
      SM_SPACEMOVE_HIDE2:
         begin
            if msg.Recog <> g_MySelf.m_nRecogId then begin
               PlayScene.SendMsg (msg.Ident, msg.Recog, msg.Param{x}, msg.tag{y}, 0, 0, 0, '')
            end;
         end;

      SM_SPACEMOVE_SHOW,
      SM_SPACEMOVE_SHOW2:
         begin
            if Length(body) > GetCodeMsgSize(sizeof(TCharDesc)*4/3) then begin
               Body2 := Copy (Body, GetCodeMsgSize(sizeof(TCharDesc)*4/3)+1, Length(body));
               data := DecodeString (body2); //ĳ�� �̸�
               str := GetValidStr3 (data, data, ['/']);
               //data = �̸�
               //str = ����
            end else data := '';
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            if msg.Recog <> g_MySelf.m_nRecogId then begin //�ٸ� ĳ������ ���
              PlayScene.NewActor (msg.Recog, msg.Param, msg.tag, msg.Series, desc.feature, desc.Status);
            end;
            PlayScene.SendMsg (msg.Ident, msg.Recog,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir + light},
                                 desc.Feature,
                                 desc.Status,
                                 ''); //�̸�
            if data <> '' then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then begin
                  actor.m_sDescUserName := GetValidStr3(data, actor.m_sUserName, ['\']);
                  //actor.UserName := data;
                  HintBoss(Actor);//BOSS��ʾ
                  actor.m_nNameColor := GetRGB(Str_ToInt(str, 0));
               end;
            end;
         end;

      SM_WALK, SM_RUSH, SM_RUSHKUNG:
         begin
            //DScreen.AddSysMsg ('WALK ' + IntToStr(msg.Param) + ':' + IntToStr(msg.Tag));
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            if (msg.Recog <> g_MySelf.m_nRecogId) or (msg.Ident = SM_RUSH) or (msg.Ident = SM_RUSHKUNG) then
               PlayScene.SendMsg (msg.Ident, msg.Recog,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir+light},
                                 desc.Feature,
                                 desc.Status, '');
            if msg.Ident = SM_RUSH then
               g_dwLatestRushRushTick := GetTickCount;                      
         end;

      SM_RUN,SM_HORSERUN:
         begin
            //DScreen.AddSysMsg ('RUN ' + IntToStr(msg.Param) + ':' + IntToStr(msg.Tag));
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            if msg.Recog <> g_MySelf.m_nRecogId then
               PlayScene.SendMsg (msg.Ident, msg.Recog,
                                    msg.Param{x},
                                    msg.tag{y},
                                    msg.Series{dir+light},
                                    desc.Feature,
                                    desc.Status, '');
               (*
               PlayScene.SendMsg (SM_RUN, msg.Recog,
                                    msg.Param{x},
                                    msg.tag{y},
                                    msg.Series{dir+light},
                                    desc.Feature,
                                    desc.Status, '');
               *)
         end;

      SM_CHANGELIGHT://��Ϸ����
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.m_nChrLight := msg.Param;
            end;
         end;

      SM_LAMPCHANGEDURA:
         begin
            if g_UseItems[U_RIGHTHAND].S.Name <> '' then begin
               g_UseItems[U_RIGHTHAND].Dura := msg.Recog;
            end;
         end;

      SM_MOVEFAIL: begin
        ActionFailed;
        DecodeBuffer (body, @desc, sizeof(TCharDesc));
        PlayScene.SendMsg (SM_TURN, msg.Recog,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir},
                                 desc.Feature,
                                 desc.Status, '');
      end;
      SM_BUTCH:
         begin
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            if msg.Recog <> g_MySelf.m_nRecogId then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then
                  actor.SendMsg (SM_SITDOWN,
                                    msg.Param{x},
                                    msg.tag{y},
                                    msg.Series{dir},
                                    0, 0, '', 0);
            end;
         end;
      SM_SITDOWN:
         begin
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            if msg.Recog <> g_MySelf.m_nRecogId then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then
                  actor.SendMsg (SM_SITDOWN,
                                    msg.Param{x},
                                    msg.tag{y},
                                    msg.Series{dir},
                                    0, 0, '', 0);
            end;
         end;

      SM_HIT,           //14
      SM_HEAVYHIT,      //15
      SM_POWERHIT,      //18
      SM_LONGHIT,       //19
      SM_WIDEHIT,       //24
      SM_BIGHIT,        //16
      SM_FIREHIT,       //8
      SM_CRSHIT,
      SM_TWINHIT:
         begin
            if msg.Recog <> g_MySelf.m_nRecogId then begin
               actor := PlayScene.FindActor (msg.Recog);
               if actor <> nil then begin
                  actor.SendMsg (msg.Ident,
                                    msg.Param{x},
                                    msg.tag{y},
                                    msg.Series{dir},
                                    0, 0, '',
                                    0);
                  if msg.ident = SM_HEAVYHIT then begin
                     if body <> '' then
                        actor.m_boDigFragment := TRUE;
                  end;
               end;
            end;
         end;
      SM_FLYAXE:
         begin
            DecodeBuffer (body, @mbw, sizeof(TMessageBodyW));
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.SendMsg (msg.Ident,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir},
                                 0, 0, '',
                                 0);
               actor.m_nTargetX := mbw.Param1;  //x ������ ��ǥ
               actor.m_nTargetY := mbw.Param2;    //y
               actor.m_nTargetRecog := MakeLong(mbw.Tag1, mbw.Tag2);
            end;
         end;

      SM_LIGHTING:
         begin
            DecodeBuffer (body, @wl, sizeof(TMessageBodyWL));
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.SendMsg (msg.Ident,
                                 msg.Param{x},
                                 msg.tag{y},
                                 msg.Series{dir},
                                 0, 0, '',
                                 0);
               actor.m_nTargetX := wl.lParam1;  //x ������ ��ǥ
               actor.m_nTargetY := wl.lParam2;    //y
               actor.m_nTargetRecog := wl.lTag1;
               actor.m_nMagicNum := wl.lTag2;   //���� ��ȣ
            end;
         end;

      SM_SPELL: begin
        UseMagicSpell (msg.Recog{who}, msg.Series{effectnum}, msg.Param{tx}, msg.Tag{y}, Str_ToInt(body,0));
      end;
      SM_MAGICFIRE: begin
        DecodeBuffer (body, @param, sizeof(integer));
        UseMagicFire (msg.Recog{who}, Lobyte(msg.Series){efftype}, Hibyte(msg.Series){effnum}, msg.Param{tx}, msg.Tag{y}, param);
        //Lobyte(msg.Series) = EffectType
        //Hibyte(msg.Series) = Effect
      end;
      SM_MAGICFIRE_FAIL:
         begin
            UseMagicFireFail (msg.Recog{who});
         end;


      SM_OUTOFCONNECTION:
         begin
            g_boDoFastFadeOut := FALSE;
            g_boDoFadeIn := FALSE;
            g_boDoFadeOut := FALSE;
            FrmDlg.DMessageDlg ('���������ӱ�ǿ���жϡ�\' +
                                '����ʱ����ܳ������ơ�\' +
                                '�����û������������ӡ�', [mbOk]);
            Close;
         end;

      SM_DEATH,
      SM_NOWDEATH:
         begin
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.SendMsg (msg.Ident,
                              msg.param{x}, msg.Tag{y}, msg.Series{damage},
                              desc.Feature, desc.Status, '',
                              0);
               actor.m_Abil.HP := 0;
            end else begin
               PlayScene.SendMsg (SM_DEATH, msg.Recog, msg.param{x}, msg.Tag{y}, msg.Series{damage}, desc.Feature, desc.Status, '');
            end;
         end;
      SM_SKELETON:
         begin
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            PlayScene.SendMsg (SM_SKELETON, msg.Recog, msg.param{HP}, msg.Tag{maxHP}, msg.Series{damage}, desc.Feature, desc.Status, '');
         end;
      SM_ALIVE:
         begin
            DecodeBuffer (body, @desc, sizeof(TCharDesc));
            PlayScene.SendMsg (SM_ALIVE, msg.Recog, msg.param{HP}, msg.Tag{maxHP}, msg.Series{damage}, desc.Feature, desc.Status, '');
         end;

      SM_ABILITY:
         begin
            g_MySelf.m_nGold := msg.Recog;
            g_MySelf.m_btJob := msg.Param;
            g_MySelf.m_nGameGold:=MakeLong(msg.Tag,msg.Series);
            DecodeBuffer (body, @g_MySelf.m_Abil, sizeof(TAbility));
         end;

      SM_SUBABILITY: begin
        g_nMyHitPoint      := Lobyte(Msg.Param);
        g_nMySpeedPoint    := Hibyte(Msg.Param);
        g_nMyAntiPoison    := Lobyte(Msg.Tag);
        g_nMyPoisonRecover := Hibyte(Msg.Tag);
        g_nMyHealthRecover := Lobyte(Msg.Series);
        g_nMySpellRecover  := Hibyte(Msg.Series);
        g_nMyAntiMagic     := LoByte(LongWord(Msg.Recog));
      end;

      SM_DAYCHANGING:
         begin
            g_nDayBright := msg.Param;
            DarkLevel := msg.Tag;
            if DarkLevel = 0 then g_boViewFog := FALSE
            else g_boViewFog := TRUE;
         end;

      SM_WINEXP:
         begin
            g_MySelf.m_Abil.Exp := msg.Recog; //���� ����ġ
            DScreen.AddChatBoardString (IntToStr(LongWord(MakeLong(msg.Param,msg.Tag))) + ' �㾭��ֵ����.',clWhite, clRed);
         end;

      SM_LEVELUP:
         begin
            g_MySelf.m_Abil.Level:=msg.Param;
            DScreen.AddSysMsg ('����!');
        //  DScreen.AddChatBoardString ('Congratulation! Your level is up. Your HP, MP are all recovered.',clWhite, clPurple);
         end;

      SM_HEALTHSPELLCHANGED: begin
        Actor := PlayScene.FindActor (msg.Recog);
        if Actor <> nil then begin
          ClientGetMoveHMShow(Actor, msg.Param, msg.Tag);
          Actor.m_Abil.HP    := msg.Param;
          Actor.m_Abil.MP    := msg.Tag;
          Actor.m_Abil.MaxHP := msg.Series;
        end;
      end;

      SM_STRUCK:
         begin
            //wl: TMessageBodyWL;
            DecodeBuffer (body, @wl, sizeof(TMessageBodyWL));
            Actor := PlayScene.FindActor (msg.Recog);
            if Actor <> nil then begin
               if Actor = g_MySelf then begin
                  if g_MySelf.m_nNameColor = 249 then //�����̴� ������ ������ �� ���´�.
                     g_dwLatestStruckTick := GetTickCount;
               end else begin
                  if Actor.CanCancelAction then
                     Actor.CancelAction;
               end;
               Actor.UpdateMsg (SM_STRUCK, wl.lTag2, 0,
                           msg.Series{damage}, wl.lParam1, wl.lParam2,
                           '', wl.lTag1{��������̵�});
               ClientGetMonMoveHMShow(Actor, msg.param, msg.Tag, (msg.Series = 10));
               Actor.m_Abil.HP := msg.param;
               Actor.m_Abil.MaxHP := msg.Tag;
            end;
         end;

      SM_CHANGEFACE:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               DecodeBuffer (body, @desc, sizeof(TCharDesc));
               actor.m_nWaitForRecogId := MakeLong(msg.Param, msg.Tag);
               actor.m_nWaitForFeature := desc.Feature;
               actor.m_nWaitForStatus := desc.Status;
               AddChangeFace (actor.m_nWaitForRecogId);
            end;
         end;
      SM_PASSWORD: begin
        //PlayScene.EdChat.PasswordChar:='*';
        SetInputStatus();
      end;
      SM_OPENHEALTH:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               if actor <> g_MySelf then begin
                  actor.m_Abil.HP := msg.Param;
                  actor.m_Abil.MaxHP := msg.Tag;
               end;
               actor.m_boOpenHealth := TRUE;
               //actor.OpenHealthTime := 999999999;
               //actor.OpenHealthStart := GetTickCount;
            end;
         end;
      SM_CLOSEHEALTH:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.m_boOpenHealth := FALSE;
            end;
         end;
      SM_INSTANCEHEALGUAGE:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.m_Abil.HP := msg.param;
               actor.m_Abil.MaxHP := msg.Tag;
               actor.m_noInstanceOpenHealth := TRUE;
               actor.m_dwOpenHealthTime := 2 * 1000;
               actor.m_dwOpenHealthStart := GetTickCount;
            end;
         end;

      SM_BREAKWEAPON:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               if actor is THumActor then
                  THumActor(actor).DoWeaponBreakEffect;
            end;
         end;

      SM_CRY,
      SM_GROUPMESSAGE,//   �׷� �޼���
      SM_GUILDMESSAGE,
      SM_WHISPER,
      SM_SYSMESSAGE:  //ϵͳ��Ϣ
         begin
            {str := DecodeString (body);
            DScreen.AddChatBoardString (str, GetRGB(Lobyte(msg.Param)), GetRGB(Hibyte(msg.Param)));
            if msg.Ident = SM_GUILDMESSAGE then
               FrmDlg.AddGuildChat (str);  }
                         If (Msg.Ident = SM_CRY) And (g_CloseCrcSys) Then
            exit;
          If (Msg.Ident = SM_WHISPER) And (g_CloseMySys) Then
            exit;
          If (Msg.Ident = SM_GUILDMESSAGE) And (g_CloseGuildSys) Then
            exit;
          str := DecodeString(body);
          If (msg.Ident = SM_SYSMESSAGE) Or (CheckBlockListSys(msg.Ident, str))
            Then
            DScreen.AddChatBoardString(str, GetRGB(Lobyte(msg.Param)),
              GetRGB(Hibyte(msg.Param)));
          If msg.Ident = SM_GUILDMESSAGE Then
            FrmDlg.AddGuildChat(str);
         end;

      SM_HEAR:
         begin
           { str := DecodeString (body);
            DScreen.AddChatBoardString (str, GetRGB(Lobyte(msg.Param)), GetRGB(Hibyte(msg.Param)));
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then
               actor.Say (str); }
                   str := DecodeString(body);
          If (Not g_CloseAllSys) And (CheckBlockListSys(msg.Ident, str)) Then
            DScreen.AddChatBoardString(str, GetRGB(Lobyte(msg.Param)),
              GetRGB(Hibyte(msg.Param)));
          actor := PlayScene.FindActor(msg.Recog);
          If actor <> Nil Then
            actor.Say(str);
         end;

      SM_USERNAME:
         begin
            str := DecodeString (body);
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.m_sDescUserName := GetValidStr3(str, actor.m_sUserName, ['\']);
               //actor.UserName := str;
               HintBoss(Actor);//BOSS��ʾ
               actor.m_nNameColor := GetRGB (msg.Param);
            end;
         end;
      SM_CHANGENAMECOLOR:
         begin
            actor := PlayScene.FindActor (msg.Recog);
            if actor <> nil then begin
               actor.m_nNameColor := GetRGB (msg.Param);
            end;
         end;

      SM_HIDE,
      SM_GHOST,  //�ܻ�..
      SM_DISAPPEAR:
         begin
            if g_MySelf.m_nRecogId <> msg.Recog then
               PlayScene.SendMsg (SM_HIDE, msg.Recog, msg.Param{x}, msg.tag{y}, 0, 0, 0, '');
         end;

      SM_DIGUP:
         begin
            DecodeBuffer (body, @wl, sizeof(TMessageBodyWL));
            actor := PlayScene.FindActor (msg.Recog);
            if actor = nil then
               actor := PlayScene.NewActor (msg.Recog, msg.Param, msg.tag, msg.Series, wl.lParam1, wl.lParam2);
            actor.m_nCurrentEvent := wl.lTag1;
            actor.SendMsg (SM_DIGUP,
                           msg.Param{x},
                           msg.tag{y},
                           msg.Series{dir + light},
                           wl.lParam1,
                           wl.lParam2, '', 0);
         end;
      SM_DIGDOWN:
         begin
            PlayScene.SendMsg (SM_DIGDOWN, msg.Recog, msg.Param{x}, msg.tag{y}, 0, 0, 0, '');
         end;
      SM_SHOWEVENT:
         begin
            DecodeBuffer (body, @smsg, sizeof(TShortMessage));
            event := TClEvent.Create (msg.Recog, Loword(msg.Tag){x}, msg.Series{y}, msg.Param{e-type});
            event.m_nDir := 0;
            event.m_nEventParam := smsg.Ident;
            EventMan.AddEvent (event);  //clvent�� Free�� �� ����
         end;
      SM_HIDEEVENT:
         begin
            EventMan.DelEventById (msg.Recog);
         end;

      //Item ??
      SM_ADDITEM:
         begin
            ClientGetAddItem (body);
         end;
      SM_BAGITEMS:
         begin
            ClientGetBagItmes (body);
         end;
      SM_UPDATEITEM:
         begin
            ClientGetUpdateItem (body);
         end;
      SM_DELITEM:
         begin
            ClientGetDelItem (body);
         end;
      SM_DELITEMS:
         begin
            ClientGetDelItems (body);
         end;

      SM_DROPITEM_SUCCESS:
         begin
            DelDropItem (DecodeString(body), msg.Recog);
         end;
      SM_DROPITEM_FAIL:
         begin
            ClientGetDropItemFail (DecodeString(body), msg.Recog);
         end;

      SM_ITEMSHOW       :ClientGetShowItem (msg.Recog, msg.param{x}, msg.Tag{y}, msg.Series{looks}, DecodeString(body));
      SM_ITEMHIDE       :ClientGetHideItem (msg.Recog, msg.param, msg.Tag);
      SM_OPENDOOR_OK    :Map.OpenDoor (msg.param, msg.tag);
      SM_OPENDOOR_LOCK  :DScreen.AddSysMsg ('�ű���ס��');
      SM_CLOSEDOOR      :Map.CloseDoor (msg.param, msg.tag);

      SM_TAKEON_OK:
         begin
            g_MySelf.m_nFeature := msg.Recog;
            g_MySelf.FeatureChanged;
//            if WaitingUseItem.Index in [0..8] then
            if g_WaitingUseItem.Index in [0..12] then
               g_UseItems[g_WaitingUseItem.Index] := g_WaitingUseItem.Item;
            g_WaitingUseItem.Item.S.Name := '';
         end;
      SM_TAKEON_FAIL:
         begin
            AddItemBag (g_WaitingUseItem.Item);
            g_WaitingUseItem.Item.S.Name := '';
         end;
      SM_TAKEOFF_OK:
         begin
            g_MySelf.m_nFeature := msg.Recog;
            g_MySelf.FeatureChanged;
            g_WaitingUseItem.Item.S.Name := '';
         end;
      SM_TAKEOFF_FAIL:
         begin
            if g_WaitingUseItem.Index < 0 then begin
               n := -(g_WaitingUseItem.Index+1);
               g_UseItems[n] := g_WaitingUseItem.Item;
            end;
            g_WaitingUseItem.Item.S.Name := '';
         end;
      SM_EXCHGTAKEON_OK:       ;
      SM_EXCHGTAKEON_FAIL:     ;

      SM_SENDUSEITEMS:
         begin
            ClientGetSenduseItems (body);
         end;
      SM_WEIGHTCHANGED:
         begin
            g_MySelf.m_Abil.Weight := msg.Recog;
            g_MySelf.m_Abil.WearWeight := msg.Param;
            g_MySelf.m_Abil.HandWeight := msg.Tag;
         end;
      SM_GOLDCHANGED:
         begin
            SoundUtil.PlaySound (s_money);
            if msg.Recog > g_MySelf.m_nGold then begin
               DScreen.AddSysMsg (IntToStr(msg.Recog-g_MySelf.m_nGold) + ' ' + g_sGoldName + ' gained.');
            end;
            g_MySelf.m_nGold := msg.Recog;
            g_MySelf.m_nGameGold:=MakeLong(msg.Param,msg.Tag);
         end;
      SM_FEATURECHANGED: begin
        PlayScene.SendMsg (msg.Ident, msg.Recog, 0, 0, 0, MakeLong(msg.Param, msg.Tag), MakeLong(msg.Series,0), '');
      end;
      SM_CHARSTATUSCHANGED: begin
        PlayScene.SendMsg (msg.Ident, msg.Recog, 0, 0, 0, MakeLong(msg.Param, msg.Tag), msg.Series, '');
      end;
      SM_CLEAROBJECTS:
         begin
            PlayScene.CleanObjects;
            g_boMapMoving := TRUE; //
         end;

      SM_EAT_OK:
         begin
            g_EatingItem.S.Name := '';
            ArrangeItembag;
         end;
      SM_EAT_FAIL:
         begin
            AddItemBag (g_EatingItem);
            g_EatingItem.S.Name := '';
         end;

      SM_ADDMAGIC:
         begin
            if body <> '' then
               ClientGetAddMagic (body);
         end;
      SM_SENDMYMAGIC: if body <> '' then ClientGetMyMagics (body);

      SM_DELMAGIC:
         begin
            ClientGetDelMagic (msg.Recog);
         end;
      SM_MAGIC_LVEXP:
         begin
            ClientGetMagicLvExp (msg.Recog{magid}, msg.Param{lv}, MakeLong(msg.Tag, msg.Series));
         end;
      SM_DURACHANGE:
         begin
            ClientGetDuraChange (msg.Param{useitem index}, msg.Recog, MakeLong(msg.Tag, msg.Series));
         end;

      SM_MERCHANTSAY:
         begin
            ClientGetMerchantSay (msg.Recog, msg.Param, DecodeString (body));
         end;
      SM_MERCHANTDLGCLOSE:
         begin
            FrmDlg.CloseMDlg;
         end;
      SM_SENDGOODSLIST:
         begin
            ClientGetSendGoodsList (msg.Recog, msg.Param, body);
         end;
      SM_SENDUSERMAKEDRUGITEMLIST:
         begin
            ClientGetSendMakeDrugList (msg.Recog, body);
         end;
      SM_SENDUSERSELL:
         begin
            ClientGetSendUserSell (msg.Recog);
         end;
      SM_SENDUSERREPAIR:
         begin
            ClientGetSendUserRepair (msg.Recog);
         end;
      SM_SENDBUYPRICE:
         begin
            if g_SellDlgItem.S.Name <> '' then begin
               if msg.Recog > 0 then
                  g_sSellPriceStr := IntToStr(msg.Recog) + ' ' + g_sGoldName{���'}
               else g_sSellPriceStr := '???? ' + g_sGoldName{���'};
            end;
         end;
      SM_USERSELLITEM_OK:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            g_MySelf.m_nGold := msg.Recog;
            g_SellDlgItemSellWait.S.Name := '';
         end;

      SM_USERSELLITEM_FAIL:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            AddItemBag (g_SellDlgItemSellWait);
            g_SellDlgItemSellWait.S.Name := '';
             Case Msg.Recog Of
            -1: FrmDlg.DMessageDlg(Format('����ļ۸���С��1�����%d��', [High(Integer)]), [mbOk]);
            -2: FrmDlg.DMessageDlg('��Ʒ�����ڡ�', [mbOk]);
            -3: FrmDlg.DMessageDlg('��Ʒ�����ڡ�', [mbOk]);
            -4: FrmDlg.DMessageDlg('����Ʒ��������ۡ�', [mbOk]);
          Else
            FrmDlg.DMessageDlg('�㲻�ܳ��۸���Ʒ��', [mbOk]);
          End;
         end;

      SM_SENDREPAIRCOST:
         begin
            if g_SellDlgItem.S.Name <> '' then begin
               if msg.Recog >= 0 then
                  g_sSellPriceStr := IntToStr(msg.Recog) + ' ' + g_sGoldName{���}
               else g_sSellPriceStr := '???? ' + g_sGoldName{���};
            end;
         end;
      SM_USERREPAIRITEM_OK:
         begin
            if g_SellDlgItemSellWait.S.Name <> '' then begin
               FrmDlg.LastestClickTime := GetTickCount;
               g_MySelf.m_nGold := msg.Recog;
               g_SellDlgItemSellWait.Dura := msg.Param;
               g_SellDlgItemSellWait.DuraMax := msg.Tag;
               AddItemBag (g_SellDlgItemSellWait);
               g_SellDlgItemSellWait.S.Name := '';
            end;
         end;
      SM_USERREPAIRITEM_FAIL:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            AddItemBag (g_SellDlgItemSellWait);
            g_SellDlgItemSellWait.S.Name := '';
            FrmDlg.DMessageDlg ('�㲻�����������Ʒ.', [mbOk]);
         end;
      SM_STORAGE_OK,
      SM_STORAGE_FULL,
      SM_STORAGE_FAIL:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            if msg.Ident <> SM_STORAGE_OK then begin
               if msg.Ident = SM_STORAGE_FULL then
                  FrmDlg.DMessageDlg ('���ĸ��˲ֿ�����. �������ټĴ��κζ���.', [mbOk])
               else
                  FrmDlg.DMessageDlg ('�㲻�ܼĴ�.', [mbOk]);
               AddItemBag (g_SellDlgItemSellWait);
            end;
            g_SellDlgItemSellWait.S.Name := '';
         end;
      SM_SAVEITEMLIST:
         begin
            ClientGetSaveItemList (msg.Recog, body);
         end;
      SM_TAKEBACKSTORAGEITEM_OK,
      SM_TAKEBACKSTORAGEITEM_FAIL,
      SM_TAKEBACKSTORAGEITEM_FULLBAG:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            if msg.Ident <> SM_TAKEBACKSTORAGEITEM_OK then begin
               if msg.Ident = SM_TAKEBACKSTORAGEITEM_FULLBAG then
                  FrmDlg.DMessageDlg ('�㲻��Я������Ķ�����.', [mbOk])
               else
                  FrmDlg.DMessageDlg ('�㲻��ȡ��.', [mbOk]);
            end else
               FrmDlg.DelStorageItem (msg.Recog); //itemserverindex
         end;

      SM_BUYITEM_SUCCESS:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            g_MySelf.m_nGold := msg.Recog;
            FrmDlg.SoldOutGoods (MakeLong(msg.Param, msg.Tag)); //�ȸ� ������ �޴����� ��
         end;
      SM_BUYITEM_FAIL:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            case msg.Recog of
            1: FrmDlg.DMessageDlg('��Ʒ������.', [mbOk]);
            2: FrmDlg.DMessageDlg('û�и������Ʒ����Я����.',  [mbOk]);
            3: FrmDlg.DMessageDlg(g_sGoldName {'���'} + '����.', [mbOk]);
            end;
         end;
      SM_MAKEDRUG_SUCCESS:
         begin
            FrmDlg.LastestClickTime := GetTickCount;
            g_MySelf.m_nGold := msg.Recog;
            FrmDlg.DMessageDlg ('��Ʒ�Ѿ�����ȷ����', [mbOk]);
         end;
      SM_MAKEDRUG_FAIL: begin
        FrmDlg.LastestClickTime := GetTickCount;
        case msg.Recog of
            1: FrmDlg.DMessageDlg('�����˴���.', [mbOk]);
            2: FrmDlg.DMessageDlg('û�и������Ʒ����Я����.', [mbOk]);
            3: FrmDlg.DMessageDlg(g_sGoldName {'���'} + '����.', [mbOk]);
            4: FrmDlg.DMessageDlg('��ȱ�����������Ʒ��', [mbOk]);
        end;
      end;
      SM_716: begin
        DrawEffectHum(Msg.Series{type},Msg.Param{x},Msg.Tag{y});
      end;
      SM_SENDDETAILGOODSLIST: begin
        ClientGetSendDetailGoodsList (msg.Recog, msg.Param, msg.Tag, body);
      end;
      SM_TEST:
         begin
            Inc (g_nTestReceiveCount);
         end;

      SM_SENDNOTICE: begin
        ClientGetSendNotice (body);
      end;
      SM_GROUPMODECHANGED: //�������� ���� �׷� ������ ����Ǿ���.
         begin
            if msg.Param > 0 then g_boAllowGroup := TRUE
            else g_boAllowGroup := FALSE;
            g_dwChangeGroupModeTick := GetTickCount;
         end;
      SM_CREATEGROUP_OK:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            g_boAllowGroup := TRUE;
            {GroupMembers.Add (Myself.UserName);
            GroupMembers.Add (DecodeString(body));}
         end;
      SM_CREATEGROUP_FAIL:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            case msg.Recog of
              -1: FrmDlg.DMessageDlg('�Ѿ��������.', [mbOk]);
              -2:FrmDlg.DMessageDlg('������ӽ�����������ǲ���ȷ��.', [mbOk]);
              -3: FrmDlg.DMessageDlg('����ӽ��������λ�û��Ѿ�����������ĳ�Ա��.', [mbOk]);
              -4: FrmDlg.DMessageDlg('�Է����������.', [mbOk]);
            end;
         end;
      SM_GROUPADDMEM_OK:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            //GroupMembers.Add (DecodeString(body));
         end;
      SM_GROUPADDMEM_FAIL:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            case msg.Recog of
              -1: FrmDlg.DMessageDlg('���黹δ�����������������ȼ�����.', [mbOk]);
              -2: FrmDlg.DMessageDlg('������ӽ�����������ǲ���ȷ��.', [mbOk]);
              -3: FrmDlg.DMessageDlg('�Ѿ��������.', [mbOk]);
              -4: FrmDlg.DMessageDlg('�Է����������.', [mbOk]);
              -5: FrmDlg.DMessageDlg('��Ա�Ѵ����ޣ�', [mbOk]);
            end;
         end;
      SM_GROUPDELMEM_OK:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            {data := DecodeString (body);
            for i:=0 to GroupMembers.Count-1 do begin
               if GroupMembers[i] = data then begin
                  GroupMembers.Delete (i);
                  break;
               end;
            end; }
         end;
      SM_GROUPDELMEM_FAIL:
         begin
            g_dwChangeGroupModeTick := GetTickCount;
            case msg.Recog of
              -1: FrmDlg.DMessageDlg('���黹δ�����������������ȼ�������', [mbOk]);
              -2: FrmDlg.DMessageDlg('������ӽ�����������ǲ���ȷ�ġ�', [mbOk]);
              -3: FrmDlg.DMessageDlg('���Ծɲ��ڱ����С�', [mbOk]);
            end;
         end;
      SM_GROUPCANCEL: begin
        g_GroupMembers.Clear;
      end;
      SM_GROUPMEMBERS:
         begin
            ClientGetGroupMembers (DecodeString(Body));
         end;

      SM_OPENGUILDDLG:
         begin
            g_dwQueryMsgTick := GetTickCount;
            ClientGetOpenGuildDlg (body);
         end;

      SM_SENDGUILDMEMBERLIST:
         begin
            g_dwQueryMsgTick := GetTickCount;
            ClientGetSendGuildMemberList (body);
         end;

      SM_OPENGUILDDLG_FAIL:
         begin
            g_dwQueryMsgTick := GetTickCount;
            FrmDlg.DMessageDlg ('��Ŀǰû�м����κ��лᣡ', [mbOk]);
         end;

      SM_DEALTRY_FAIL: begin
        g_dwQueryMsgTick := GetTickCount;
        FrmDlg.DMessageDlg('���ױ�ȡ��.\Ҫ��ȷ����������ͶԷ������.', [mbOk]);
      end;
      SM_DEALMENU:
         begin
            g_dwQueryMsgTick := GetTickCount;
            g_sDealWho := DecodeString (body);
            FrmDlg.OpenDealDlg;
         end;
      SM_DEALCANCEL: begin
        MoveDealItemToBag;
        if g_DealDlgItem.S.Name <> '' then begin
          AddItemBag (g_DealDlgItem);  //���濡 �߰�
          g_DealDlgItem.S.Name := '';
        end;
        if g_nDealGold > 0 then begin
          g_MySelf.m_nGold := g_MySelf.m_nGold + g_nDealGold;
          g_nDealGold := 0;
        end;
        FrmDlg.CloseDealDlg;
      end;
      SM_DEALADDITEM_OK:
         begin
            g_dwDealActionTick := GetTickCount;
            if g_DealDlgItem.S.Name <> '' then begin
               AddDealItem (g_DealDlgItem);  //Deal Dlg�� �߰�
               g_DealDlgItem.S.Name := '';
            end;
         end;
      SM_DEALADDITEM_FAIL: begin
        g_dwDealActionTick:=GetTickCount;
        if g_DealDlgItem.S.Name <> '' then begin
          AddItemBag(g_DealDlgItem);  //���濡 �߰�
          g_DealDlgItem.S.Name:= '';
        end;
      end;
      SM_DEALDELITEM_OK: begin
        g_dwDealActionTick:=GetTickCount;
        if g_DealDlgItem.S.Name <> '' then begin
               //AddItemBag (DealDlgItem);  //���濡 �߰�
          g_DealDlgItem.S.Name := '';
        end;
      end;
      SM_DEALDELITEM_FAIL: begin
        g_dwDealActionTick := GetTickCount;
        if g_DealDlgItem.S.Name <> '' then begin
          DelItemBag (g_DealDlgItem.S.Name, g_DealDlgItem.MakeIndex);
          AddDealItem (g_DealDlgItem);
          g_DealDlgItem.S.Name := '';
        end;
      end;
      SM_DEALREMOTEADDITEM: ClientGetDealRemoteAddItem (body);
      SM_DEALREMOTEDELITEM: ClientGetDealRemoteDelItem (body);
      SM_DEALCHGGOLD_OK: begin
        g_nDealGold:=msg.Recog;
        g_MySelf.m_nGold:=MakeLong(msg.param, msg.tag);
        g_dwDealActionTick:=GetTickCount;
      end;
      SM_DEALCHGGOLD_FAIL: begin
        g_nDealGold:=msg.Recog;
        g_MySelf.m_nGold:=MakeLong(msg.param, msg.tag);
        g_dwDealActionTick:=GetTickCount;
      end;
      SM_DEALREMOTECHGGOLD: begin
        g_nDealRemoteGold:=msg.Recog;
        SoundUtil.PlaySound(s_money);  //������ ���� ������ ��� �Ҹ��� ����.
      end;
      SM_DEALSUCCESS: begin
        FrmDlg.CloseDealDlg;
      end;
      SM_SENDUSERSTORAGEITEM: begin
        ClientGetSendUserStorage(msg.Recog);
      end;
      SM_READMINIMAP_OK: begin
        g_dwQueryMsgTick:=GetTickCount;
        ClientGetReadMiniMap(msg.Param);
      end;
      SM_READMINIMAP_FAIL: begin
        g_dwQueryMsgTick := GetTickCount;
        DScreen.AddChatBoardString ('û�п��õ�ͼ��', clWhite, clRed);
        g_nMiniMapIndex:= -1;
      end;
      SM_CHANGEGUILDNAME: begin
        ClientGetChangeGuildName(DecodeString (body));
      end;
      SM_SENDUSERSTATE: begin
        ClientGetSendUserState(body);
      end;
      SM_GUILDADDMEMBER_OK: begin
        SendGuildMemberList;
      end;
      SM_GUILDADDMEMBER_FAIL: begin
        case msg.Recog of
              1: FrmDlg.DMessageDlg('��û��Ȩ��ʹ���������.', [mbOk]);
              2: FrmDlg.DMessageDlg('���������ĳ�ԱӦ�����������.', [mbOk]);
              3: FrmDlg.DMessageDlg('���Ѽ��������л�.', [mbOk]);
              4: FrmDlg.DMessageDlg('�Ѿ����������л�.', [mbOk]);
              5: FrmDlg.DMessageDlg('�Է�����������л�.', [mbOk]);
              6: FrmDlg.DMessageDlg('����л��Ա�����Ѵ��������.', [mbOk]);
        end;
      end;
      SM_GUILDDELMEMBER_OK: begin
        SendGuildMemberList;
      end;
      SM_GUILDDELMEMBER_FAIL: begin
        case msg.Recog of
              1: FrmDlg.DMessageDlg('��û��Ȩ��ʹ���������.', [mbOk]);
              2: FrmDlg.DMessageDlg('�������ǵ��л��Ա��', [mbOk]);
              3: FrmDlg.DMessageDlg('�л������˲���ɾ�����Լ���', [mbOk]);
              4: FrmDlg.DMessageDlg('����ʹ������.', [mbOk]);
        end;
      end;
      SM_GUILDRANKUPDATE_FAIL: begin
        case msg.Recog of
              -2: FrmDlg.DMessageDlg('[��������] ������λ���ǿյġ�',[mbOk]);
              -3: FrmDlg.DMessageDlg('[��������] ������ְλ�ǿյġ�',[mbOk]);
              -4: FrmDlg.DMessageDlg('[��������] һ���л����ֻ����2�������ˡ�', [mbOk]);
              -5: FrmDlg.DMessageDlg('[��������] �µ��������Ѿ�����λ��', [mbOk]);
              -6: FrmDlg.DMessageDlg('[��������] ������ӳ�Ա/ɾ����Ա��', [mbOk]);
              -7: FrmDlg.DMessageDlg('[��������] ְλ�ظ����߳���',[mbOk]);
        end;
      end;
      SM_GUILDMAKEALLY_OK,
      SM_GUILDMAKEALLY_FAIL: begin
        case msg.Recog of
              -1: FrmDlg.DMessageDlg('��û��Ȩ����', [mbOk]);
              -2: FrmDlg.DMessageDlg('����ʧ�ܣ�', [mbOk]);
              -3: FrmDlg.DMessageDlg('��Ӧ���������Ҫ���˵��л������ˣ�', [mbOk]);
              -4: FrmDlg.DMessageDlg('�Է��л������˲�������ˣ�',[mbOk]);
        end;
      end;
      SM_GUILDBREAKALLY_OK,
      SM_GUILDBREAKALLY_FAIL: begin
        case msg.Recog of
              -1: FrmDlg.DMessageDlg('��û��Ȩ����', [mbOk]);
              -2: FrmDlg.DMessageDlg('�㲻���л������У�', [mbOk]);
              -3: FrmDlg.DMessageDlg('�ⲻ��һ�����е��лᣡ', [mbOk]);
        end;
      end;
      SM_BUILDGUILD_OK: begin
        FrmDlg.LastestClickTime := GetTickCount;
        FrmDlg.DMessageDlg ('�л���ȷ����.', [mbOk]);
      end;
      SM_BUILDGUILD_FAIL: begin
        FrmDlg.LastestClickTime := GetTickCount;
            Case msg.Recog Of
              -1: FrmDlg.DMessageDlg('�Ѿ������лᡣ', [mbOk]);
              -2: FrmDlg.DMessageDlg('ȱ�ٴ������á�', [mbOk]);
              -3:  FrmDlg.DMessageDlg('��û��׼������Ҫ��ȫ����Ʒ��', [mbOk]);
            Else
              FrmDlg.DMessageDlg('�����л�ʧ�ܣ�����', [mbOk]);
         End;
      end;
      SM_MENU_OK: begin
        FrmDlg.LastestClickTime:=GetTickCount;
        if body <> '' then
          FrmDlg.DMessageDlg(DecodeString(body), [mbOk]);
      end;
      SM_DLGMSG: begin
        if body <> '' then
          FrmDlg.DMessageDlg(DecodeString(body), [mbOk]);
      end;
      SM_DONATE_OK: begin
        FrmDlg.LastestClickTime:=GetTickCount;
      end;
      SM_DONATE_FAIL: begin
        FrmDlg.LastestClickTime:=GetTickCount;
      end;

      SM_PLAYDICE: begin
        Body2:=Copy(Body,GetCodeMsgSize(sizeof(TMessageBodyWL)*4/3) + 1, Length(body));
        DecodeBuffer(body,@wl,SizeOf(TMessageBodyWL));
        data:=DecodeString(Body2);
        FrmDlg.m_nDiceCount:=Msg.Param;       //QuestActionInfo.nParam1
        FrmDlg.m_Dice[0].nDicePoint:=LoByte(LoWord(Wl.lParam1)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[1].nDicePoint:=HiByte(LoWord(Wl.lParam1)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[2].nDicePoint:=LoByte(HiWord(Wl.lParam1)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[3].nDicePoint:=HiByte(HiWord(Wl.lParam1)); //UserHuman.m_DyVal[0]

        FrmDlg.m_Dice[4].nDicePoint:=LoByte(LoWord(Wl.lParam2)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[5].nDicePoint:=HiByte(LoWord(Wl.lParam2)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[6].nDicePoint:=LoByte(HiWord(Wl.lParam2)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[7].nDicePoint:=HiByte(HiWord(Wl.lParam2)); //UserHuman.m_DyVal[0]

        FrmDlg.m_Dice[8].nDicePoint:=LoByte(LoWord(Wl.lTag1)); //UserHuman.m_DyVal[0]
        FrmDlg.m_Dice[9].nDicePoint:=HiByte(LoWord(Wl.lTag1)); //UserHuman.m_DyVal[0]
        FrmDlg.DialogSize:=0;
        FrmDlg.DMessageDlg('',[]);
        SendMerchantDlgSelect(Msg.Recog,data);
      end;
      SM_NEEDPASSWORD: begin
        ClientGetNeedPassword(Body);
      end;
      SM_PASSWORDSTATUS: begin
        ClientGetPasswordStatus(@Msg,Body);
      end;
      SM_GETREGINFO: ClientGetRegInfo(@Msg,Body);
      else begin
        if g_MySelf = nil then exit;     //Jacky ��δ������Ϸʱ����������
//Jacky
//            DScreen.AddSysMsg (IntToStr(msg.Ident) + ' : ' + body);
        PlayScene.MemoLog.Lines.Add('Ident: ' + IntToStr(msg.Ident));
        PlayScene.MemoLog.Lines.Add('Recog: ' + IntToStr(msg.Recog));
        PlayScene.MemoLog.Lines.Add('Param: ' + IntToStr(msg.Param));
        PlayScene.MemoLog.Lines.Add('Tag: ' + IntToStr(msg.Tag));
        PlayScene.MemoLog.Lines.Add('Series: ' + IntToStr(msg.Series));
      end;
   end;

   if Pos('#', datablock) > 0 then
      DScreen.AddSysMsg (datablock);
end;


procedure TfrmMain.ClientGetPasswdSuccess (body: string);
var
   str, runaddr, runport, uid, certifystr: string;
begin
   str := DecodeString (body);
   str := GetValidStr3 (str, runaddr, ['/']);
   str := GetValidStr3 (str, runport, ['/']);
   str := GetValidStr3 (str, certifystr, ['/']);
   Certification := Str_ToInt(certifystr, 0);

   if not BoOneClick then begin
      CSocket.Active:=False;
      CSocket.Host:='';
      CSocket.Port:=0;
      FrmDlg.DSelServerDlg.Visible := FALSE;
      WaitAndPass (500); //0.5�ʵ��� ��ٸ�
      g_ConnectionStep := cnsSelChr;
      with CSocket do begin
         g_sSelChrAddr := runaddr;
         g_nSelChrPort := Str_ToInt (runport, 0);
         Address := g_sSelChrAddr;
         Port := g_nSelChrPort;
         Active := TRUE;
      end;
   end else begin
      FrmDlg.DSelServerDlg.Visible := FALSE;
      g_sSelChrAddr := runaddr;
      g_nSelChrPort := Str_ToInt (runport, 0);
      if CSocket.Socket.Connected then
         CSocket.Socket.SendText ('$S' + runaddr + '/' + runport + '%');
      WaitAndPass (500); //0.5�ʵ��� ��ٸ�
      g_ConnectionStep := cnsSelChr;
      LoginScene.OpenLoginDoor;
      SelChrWaitTimer.Enabled := TRUE;
   end;
end;
procedure TfrmMain.ClientGetPasswordOK(Msg: TDefaultMessage;
  sBody: String);
var
  I: Integer;
  sServerName:String;
  sServerStatus:String;
  nCount:Integer;
begin
  sBody:=DeCodeString(sBody);
//  FrmDlg.DMessageDlg (sBody + '/' + IntToStr(Msg.Series), [mbOk]);
  nCount:=_MIN(6,msg.Series);
  g_ServerList.Clear;
  for I := 0 to nCount - 1 do begin
    sBody:=GetValidStr3(sBody,sServerName,['/']);
    sBody:=GetValidStr3(sBody,sServerStatus,['/']);
    g_ServerList.AddObject(sServerName,TObject(Str_ToInt(sServerStatus,0)));
  end;
  //if g_ServerList.Count = 0 then begin
//    g_ServerList.InsertObject(0,'���´���',TObject(Str_ToInt(sServerStatus,0)));
//  end;
    


               g_wAvailIDDay := Loword(msg.Recog);
               g_wAvailIDHour := Hiword(msg.Recog);
               g_wAvailIPDay := msg.Param;
               g_wAvailIPHour := msg.Tag;

               if g_wAvailIDDay > 0 then begin
                  if g_wAvailIDDay = 1 then
                     FrmDlg.DMessageDlg ('����ǰID���õ�����Ϊֹ��', [mbOk])
                  else if g_wAvailIDDay <= 3 then
                     FrmDlg.DMessageDlg ('����ǰIP���û�ʣ ' + IntToStr(g_wAvailIDDay) + ' �졣', [mbOk]);
               end else if g_wAvailIPDay > 0 then begin
                  if g_wAvailIPDay = 1 then
                     FrmDlg.DMessageDlg ('����ǰIP���õ�����Ϊֹ��', [mbOk])
                  else if g_wAvailIPDay <= 3 then
                     FrmDlg.DMessageDlg ('����ǰIP���û�ʣ ' + IntToStr(g_wAvailIPDay) + ' �졣', [mbOk]);
               end else if g_wAvailIPHour > 0 then begin
                  if g_wAvailIPHour <= 100 then
                     FrmDlg.DMessageDlg ('����ǰIP���û�ʣ ' + IntToStr(g_wAvailIPHour) + ' Сʱ��', [mbOk]);
               end else if g_wAvailIDHour > 0 then begin
                  FrmDlg.DMessageDlg ('����ǰID���û�ʣ ' + IntToStr(g_wAvailIDHour) + ' Сʱ��', [mbOk]);;
               end;

               if not LoginScene.m_boUpdateAccountMode then
                  ClientGetSelectServer;
end;

procedure TfrmMain.ClientGetSelectServer;
var
  sname: string;
begin
  LoginScene.HideLoginBox;
  FrmDlg.ShowSelectServerDlg;
end;

procedure TfrmMain.ClientGetNeedUpdateAccount (body: string);
var
   ue: TUserEntry;
begin
   DecodeBuffer (body, @ue, sizeof(TUserEntry));
   LoginScene.UpdateAccountInfos (ue);
end;

procedure TfrmMain.ClientGetReceiveChrs (body: string);
var
   i, select: integer;
   str, uname, sjob, shair, slevel, ssex: string;
begin
   SelectChrScene.ClearChrs;
   str := DecodeString (body);
   for i:=0 to 1 do begin
      str := GetValidStr3 (str, uname, ['/']);
      str := GetValidStr3 (str, sjob, ['/']);
      str := GetValidStr3 (str, shair, ['/']);
      str := GetValidStr3 (str, slevel, ['/']);
      str := GetValidStr3 (str, ssex, ['/']);
      select := 0;
      if (uname <> '') and (slevel <> '') and (ssex <> '') then begin
         if uname[1] = '*' then begin
            select := i;
            uname := Copy (uname, 2, Length(uname)-1);
         end;
         SelectChrScene.AddChr (uname, Str_ToInt(sjob, 0), Str_ToInt(shair, 0), Str_ToInt(slevel, 0), Str_ToInt(ssex, 0));
      end;
      with SelectChrScene do begin
         if select = 0 then begin
            ChrArr[0].FreezeState := FALSE;
            ChrArr[0].Selected := TRUE;
            ChrArr[1].FreezeState := TRUE;
            ChrArr[1].Selected := FALSE;
         end else begin
            ChrArr[0].FreezeState := TRUE;
            ChrArr[0].Selected := FALSE;
            ChrArr[1].FreezeState := FALSE;
            ChrArr[1].Selected := TRUE;
         end;
      end;
   end;
   PlayScene.EdAccountt.Text:=LoginId;
   //2004/05/17  ǿ�е�¼
   {
   if SelectChrScene.ChrArr[0].Valid and SelectChrScene.ChrArr[0].Selected then PlayScene.EdChrNamet.Text := SelectChrScene.ChrArr[0].UserChr.Name;
   if SelectChrScene.ChrArr[1].Valid and SelectChrScene.ChrArr[1].Selected then PlayScene.EdChrNamet.Text := SelectChrScene.ChrArr[1].UserChr.Name;
   PlayScene.EdAccountt.Visible:=True;
   PlayScene.EdChrNamet.Visible:=True;
   }
   //2004/05/17
end;

procedure TfrmMain.ClientGetStartPlay (body: string);
var
   str, addr, sport: string;
begin
   str := DecodeString (body);
   sport := GetValidStr3 (str, g_sRunServerAddr, ['/']);
   g_nRunServerPort:=Str_ToInt (sport, 0);

   if not BoOneClick then begin
      CSocket.Active := FALSE;  //�α��ο� ����� ���� ����
      CSocket.Host:='';
      CSocket.Port:=0;
      WaitAndPass (500); //0.5�ʵ��� ��ٸ�

      g_ConnectionStep := cnsPlay;
      with CSocket do begin
         Address := g_sRunServerAddr;
         Port := g_nRunServerPort;
         Active := TRUE;
      end;
   end else begin
      SocStr := '';
      BufferStr := '';
      if CSocket.Socket.Connected then
         CSocket.Socket.SendText ('$R' + addr + '/' + sport + '%');

      g_ConnectionStep := cnsPlay;
      ClearBag;  //���� �ʱ�ȭ
      DScreen.ClearChatBoard; //ä��â �ʱ�ȭ
      DScreen.ChangeScene (stLoginNotice);

      WaitAndPass (500); //0.5�ʵ��� ��ٸ�
      SendRunLogin;
   end;
end;

procedure TfrmMain.ClientGetReconnect (body: string);
var
   str, addr, sport: string;
begin
   str := DecodeString (body);
   sport := GetValidStr3 (str, addr, ['/']);

   if not BoOneClick then begin
      if g_boBagLoaded then
         Savebags ('.\Data\' + g_sServerName + '.' + CharName + '.itm', @g_ItemArr);
      g_boBagLoaded := FALSE;

      g_boServerChanging := TRUE;
      CSocket.Active := FALSE;  //�α��ο� ����� ���� ����
      CSocket.Host:='';
      CSocket.Port:=0;

      WaitAndPass (500); //0.5�ʵ��� ��ٸ�

      g_ConnectionStep := cnsPlay;
      with CSocket do begin
         Address := addr;
         Port := Str_ToInt (sport, 0);
         Active := TRUE;
      end;

   end else begin
      if g_boBagLoaded then
         Savebags ('.\Data\' + g_sServerName + '.' + CharName + '.itm', @g_ItemArr);
      g_boBagLoaded := FALSE;

      SocStr := '';
      BufferStr := '';
      g_boServerChanging := TRUE;

      if CSocket.Socket.Connected then   //���� ���� ��ȣ ������.
         CSocket.Socket.SendText ('$C' + addr + '/' + sport + '%');

      WaitAndPass (500); //0.5�ʵ��� ��ٸ�
      if CSocket.Socket.Connected then   //����..
         CSocket.Socket.SendText ('$R' + addr + '/' + sport + '%');

      g_ConnectionStep := cnsPlay;
      ClearBag;  //���� �ʱ�ȭ
      DScreen.ClearChatBoard; //ä��â �ʱ�ȭ
      DScreen.ChangeScene (stLoginNotice);

      WaitAndPass (300); //0.5�ʵ��� ��ٸ�
      ChangeServerClearGameVariables;

      SendRunLogin;
   end;
end;

procedure TfrmMain.ClientGetMapDescription(Msg:TDefaultMessage;sBody:String);
var
  sTitle:String;
begin
  sBody:=DecodeString(sBody);
  sBody:=GetValidStr3(sBody, sTitle, [#13]);
  g_sMapTitle:=sTitle;
  g_nMapMusic:=Msg.Recog;
  PlayMapMusic(True);
end;

procedure TfrmMain.ClientGetGameGoldName(Msg:TDefaultMessage;sBody: String);
var
  sData:String;
begin
  if sBody <> '' then begin
    sBody:=DecodeString(sBody);
    sBody:=GetValidStr3(sBody, sData, [#13]);
    g_sGameGoldName:=sData;
    g_sGamePointName:=sBody;
  end;
  g_MySelf.m_nGameGold:=Msg.Recog;
  g_MySelf.m_nGamePoint:=MakeLong(Msg.Param,Msg.Tag);
end;

procedure TfrmMain.ClientGetAdjustBonus (bonus: integer; body: string);
var
   str1, str2, str3: string;
begin
   g_nBonusPoint := bonus;
   body := GetValidStr3 (body, str1, ['/']);
   str3 := GetValidStr3 (body, str2, ['/']);
   DecodeBuffer (str1, @g_BonusTick, sizeof(TNakedAbility));
   DecodeBuffer (str2, @g_BonusAbil, sizeof(TNakedAbility));
   DecodeBuffer (str3, @g_NakedAbil, sizeof(TNakedAbility));
   FillChar (g_BonusAbilChg, sizeof(TNakedAbility), #0);
end;

procedure TfrmMain.ClientGetAddItem (body: string);
var
   cu: TClientItem;
begin
   if body <> '' then begin
      DecodeBuffer (body, @cu, sizeof(TClientItem));
      AddItemBag (cu);
      DScreen.AddSysMsg (cu.S.Name + ' ������');
   end;
end;

procedure TfrmMain.ClientGetUpdateItem (body: string);
var
   i: integer;
   cu: TClientItem;
begin
   if body <> '' then begin
      DecodeBuffer (body, @cu, sizeof(TClientItem));
      UpdateItemBag (cu);
      for i:=0 to 12 do begin
         if (g_UseItems[i].S.Name = cu.S.Name) and (g_UseItems[i].MakeIndex = cu.MakeIndex) then begin
            g_UseItems[i] := cu;
         end;
      end;
   end;
end;

procedure TfrmMain.ClientGetDelItem (body: string);
var
   i: integer;
   cu: TClientItem;
begin
   if body <> '' then begin
      DecodeBuffer (body, @cu, sizeof(TClientItem));
      DelItemBag (cu.S.Name, cu.MakeIndex);
      for i:=0 to 12 do begin
         if (g_UseItems[i].S.Name = cu.S.Name) and (g_UseItems[i].MakeIndex = cu.MakeIndex) then begin
            g_UseItems[i].S.Name := '';
         end;
      end;
   end;
end;

procedure TfrmMain.ClientGetDelItems (body: string);
var
   i, iindex: integer;
   str, iname: string;
   cu: TClientItem;
begin
   body := DecodeString (body);
   while body <> '' do begin
      body := GetValidStr3 (body, iname, ['/']);
      body := GetValidStr3 (body, str, ['/']);
      if (iname <> '') and (str <> '') then begin
         iindex := Str_ToInt(str, 0);
         DelItemBag (iname, iindex);
         for i:=0 to 12 do begin
            if (g_UseItems[i].S.Name = iname) and (g_UseItems[i].MakeIndex = iindex) then begin
               g_UseItems[i].S.Name := '';
            end;
         end;
      end else
         break;
   end;
end;

procedure TfrmMain.ClientGetBagItmes (body: string);
var
   str: string;
   cu: TClientItem;
   ItemSaveArr: array[0..MAXBAGITEMCL-1] of TClientItem;

   function CompareItemArr: Boolean;
   var
      i, j: integer;
      flag: Boolean;
   begin
      flag := TRUE;
      for i:=0 to MAXBAGITEMCL-1 do begin
         if ItemSaveArr[i].S.Name <> '' then begin
            flag := FALSE;
            for j:=0 to MAXBAGITEMCL-1 do begin
               if (g_ItemArr[j].S.Name = ItemSaveArr[i].S.Name) and
                  (g_ItemArr[j].MakeIndex = ItemSaveArr[i].MakeIndex) then begin
                  if (g_ItemArr[j].Dura = ItemSaveArr[i].Dura) and
                     (g_ItemArr[j].DuraMax = ItemSaveArr[i].DuraMax) then begin
                     flag := TRUE;
                  end;
                  break;
               end;
            end;
            if not flag then break;
         end;
      end;
      if flag then begin
         for i:=0 to MAXBAGITEMCL-1 do begin
            if g_ItemArr[i].S.Name <> '' then begin
               flag := FALSE;
               for j:=0 to MAXBAGITEMCL-1 do begin
                  if (g_ItemArr[i].S.Name = ItemSaveArr[j].S.Name) and
                     (g_ItemArr[i].MakeIndex = ItemSaveArr[j].MakeIndex) then begin
                     if (g_ItemArr[i].Dura = ItemSaveArr[j].Dura) and
                        (g_ItemArr[i].DuraMax = ItemSaveArr[j].DuraMax) then begin
                        flag := TRUE;
                     end;
                     break;
                  end;
               end;
               if not flag then break;
            end;
         end;
      end;
      Result := flag;
   end;
begin
   //ClearBag;
   FillChar (g_ItemArr, sizeof(TClientItem)*MAXBAGITEMCL, #0);
   while TRUE do begin
      if body = '' then break;
      body := GetValidStr3 (body, str, ['/']);
      DecodeBuffer (str, @cu, sizeof(TClientItem));
      AddItemBag (cu);
   end;

   FillChar (ItemSaveArr, sizeof(TClientItem)*MAXBAGITEMCL, #0);
   Loadbags ('.\Data\' + g_sServerName + '.' + CharName + '.itm', @ItemSaveArr);
   if CompareItemArr then begin
      Move (ItemSaveArr, g_ItemArr, sizeof(TClientItem) * MAXBAGITEMCL);
   end;
   
   ArrangeItembag;
   g_boBagLoaded := TRUE;
end;

procedure TfrmMain.ClientGetDropItemFail (iname: string; sindex: integer);
var
   pc: PTClientItem;
begin
   pc := GetDropItem (iname, sindex);
   if pc <> nil then begin
      AddItemBag (pc^);
      DelDropItem (iname, sindex);
   end;
end;

procedure TfrmMain.ClientGetShowItem (itemid, x, y, looks: integer; itmname: string);
var
  I:Integer;
  DropItem:PTDropItem;
begin
  for i:=0 to g_DropedItemList.Count-1 do begin
    if PTDropItem(g_DropedItemList[i]).Id = itemid then
      exit;
  end;
  New(DropItem);
  DropItem.Id := itemid;
  DropItem.X := x;
  DropItem.Y := y;
  DropItem.Looks := looks;
  DropItem.Name := itmname;
  DropItem.FlashTime := GetTickCount - LongWord(Random(3000));
  DropItem.BoFlash := FALSE;
  g_DropedItemList.Add(DropItem);
end;

procedure TfrmMain.ClientGetHideItem (itemid, x, y: integer);
var
  I:Integer;
  DropItem:PTDropItem;
begin
  for I:=0 to g_DropedItemList.Count - 1 do begin
    DropItem:=g_DropedItemList[I];
    if DropItem.Id = itemid then begin
      Dispose (DropItem);
      g_DropedItemList.Delete(I);
      break;
    end;
  end;
end;
procedure TfrmMain.ClientGetSendAddUseItems (body: string);
var
   index: integer;
   str, data: string;
   cu: TClientItem;
begin
   while TRUE do begin
      if body = '' then break;
      body := GetValidStr3 (body, str, ['/']);
      body := GetValidStr3 (body, data, ['/']);
      index := Str_ToInt (str, -1);
      if index in [9..12] then begin
         DecodeBuffer (data, @cu, sizeof(TClientItem));
         g_UseItems[index] := cu;
      end;
   end;
end;
procedure TfrmMain.ClientGetSenduseItems (body: string);
var
   index: integer;
   str, data: string;
   cu: TClientItem;
begin
   FillChar (g_UseItems, sizeof(TClientItem)*13, #0);
//   FillChar (UseItems, sizeof(TClientItem)*9, #0);
   while TRUE do begin
      if body = '' then break;
      body := GetValidStr3 (body, str, ['/']);
      body := GetValidStr3 (body, data, ['/']);
      index := Str_ToInt (str, -1);
      if index in [0..12] then begin
         DecodeBuffer (data, @cu, sizeof(TClientItem));
         g_UseItems[index] := cu;
      end;
   end;
end;

procedure TfrmMain.ClientGetAddMagic (body: string);
var
   pcm: PTClientMagic;
begin
   new (pcm);
   DecodeBuffer (body, @(pcm^), sizeof(TClientMagic));
   g_MagicList.Add (pcm);
end;

procedure TfrmMain.ClientGetDelMagic (magid: integer);
var
   i: integer;
begin
   for i:=g_MagicList.Count-1 downto 0 do begin
      if PTClientMagic(g_MagicList[i]).Def.wMagicId = magid then begin
         Dispose (PTClientMagic(g_MagicList[i]));
         g_MagicList.Delete (i);
         break;
      end;
   end;
end;

procedure TfrmMain.ClientGetMyMagics (body: string);
var
   i: integer;
   data: string;
   pcm: PTClientMagic;
begin
   for i:=0 to g_MagicList.Count-1 do
      Dispose (PTClientMagic (g_MagicList[i]));
   g_MagicList.Clear;
   while TRUE do begin
      if body = '' then break;
      body := GetValidStr3 (body, data, ['/']);
      if data <> '' then begin
         new (pcm);
         DecodeBuffer (data, @(pcm^), sizeof(TClientMagic));
         g_MagicList.Add (pcm);

//    PlayScene.MemoLog.Lines.Add(pcm.Def.sMagicName + IntToStr(MagicList.Count));
      end else
         break;
   end;
end;

procedure TfrmMain.ClientGetMagicLvExp (magid, maglv, magtrain: integer);
var
   i: integer;
begin
   for i:=g_MagicList.Count-1 downto 0 do begin
      if PTClientMagic(g_MagicList[i]).Def.wMagicId = magid then begin
         PTClientMagic(g_MagicList[i]).Level := maglv;
         PTClientMagic(g_MagicList[i]).CurTrain := magtrain;
         break;
      end;
   end;
end;

procedure TfrmMain.ClientGetDuraChange (uidx, newdura, newduramax: integer);
begin
   if uidx in [0..12] then begin
      if g_UseItems[uidx].S.Name <> '' then begin
         g_UseItems[uidx].Dura := newdura;
         g_UseItems[uidx].DuraMax := newduramax;
      end;
   end;
end;

procedure TfrmMain.ClientGetMerchantSay (merchant, face: integer; saying: string);
var
   npcname: string;
begin
   g_nMDlgX := g_MySelf.m_nCurrX;
   g_nMDlgY := g_MySelf.m_nCurrY;
   if g_nCurMerchant <> merchant then begin
      g_nCurMerchant := merchant;
      FrmDlg.ResetMenuDlg;
      FrmDlg.CloseMDlg;
   end;
//   ShowMessage(saying);
   saying := GetValidStr3 (saying, npcname, ['/']);
   FrmDlg.ShowMDlg (face, npcname, saying);
end;

procedure TfrmMain.ClientGetSendGoodsList (merchant, count: integer; body: string);
var
   i: integer;
   data, gname, gsub, gprice, gstock: string;
   pcg: PTClientGoods;
begin
   FrmDlg.ResetMenuDlg;
   
   g_nCurMerchant := merchant;
   with FrmDlg do begin
      //deocde body received from server
      body := DecodeString (body);
      while body <> '' do begin
         body := GetValidStr3 (body, gname, ['/']);
         body := GetValidStr3 (body, gsub, ['/']);
         body := GetValidStr3 (body, gprice, ['/']);
         body := GetValidStr3 (body, gstock, ['/']);
         if (gname <> '') and (gprice <> '') and (gstock <> '') then begin
            new (pcg);
            pcg.Name := gname;
            pcg.SubMenu := Str_ToInt (gsub, 0);
            pcg.Price := Str_ToInt (gprice, 0);
            pcg.Stock := Str_ToInt (gstock, 0);
            pcg.Grade := -1;
            MenuList.Add (pcg);
         end else
            break;
      end;
      FrmDlg.ShowShopMenuDlg;
      FrmDlg.CurDetailItem := '';
   end;
end;



procedure TfrmMain.HintBoss(actor:Tactor);      //2015-06-07  ���BOSS��ʾ
var
  i:integer;
  ndir:Integer;
  sDir:String;
  sname:string;
begin
  sname:=Actor.m_sUserName;
  if g_WgInfo.boBossHint then
  begin
     if frmNeiGua.ListBoxBossHintList.Items.IndexOf(sName)>-1 then
     begin
         ndir:=GetNextDirection(g_MySelf.m_nCurrX,g_MySelf.m_nCurrY,Actor.m_nCurrX,Actor.m_nCurrY);
         case ndir of
           0:sDir:='��';
           1:sDir:='�J';
           2:sDir:='��';
           3:sDir:='�K';
           4:sDir:='��';
           5:sDir:='�L';
           6:sDir:='��';
           7:sDir:='�I';
         end;
         DScreen.AddChatBoardString(Format('Boss %s ��(%d,%d %s)�����֣�',[Actor.m_sUserName,actor.m_nCurrX,actor.m_nCurrY,sDir]), clRed, clWhite);
         Exit;
     end;
  end;
end;

procedure TfrmMain.ClientGetSendMakeDrugList (merchant: integer; body: string);
var
   i: integer;
   data, gname, gsub, gprice, gstock: string;
   pcg: PTClientGoods;
begin
   FrmDlg.ResetMenuDlg;

   g_nCurMerchant := merchant;
   with FrmDlg do begin
      //clear shop menu list
      //deocde body received from server
      body := DecodeString (body);
      while body <> '' do begin
         body := GetValidStr3 (body, gname, ['/']);
         body := GetValidStr3 (body, gsub, ['/']);
         body := GetValidStr3 (body, gprice, ['/']);
         body := GetValidStr3 (body, gstock, ['/']);
         if (gname <> '') and (gprice <> '') and (gstock <> '') then begin
            new (pcg);
            pcg.Name := gname;
            pcg.SubMenu := Str_ToInt (gsub, 0);
            pcg.Price := Str_ToInt (gprice, 0);
            pcg.Stock := Str_ToInt (gstock, 0);
            pcg.Grade := -1;
            MenuList.Add (pcg);
         end else
            break;
      end;
      FrmDlg.ShowShopMenuDlg;
      FrmDlg.CurDetailItem := '';
      FrmDlg.BoMakeDrugMenu := TRUE;
   end;
end;


procedure TfrmMain.ClientGetSendUserSell (merchant: integer);
begin
   FrmDlg.CloseDSellDlg;
   g_nCurMerchant := merchant;
   FrmDlg.SpotDlgMode := dmSell;
   FrmDlg.ShowShopSellDlg;
end;

procedure TfrmMain.ClientGetSendUserRepair (merchant: integer);
begin
   FrmDlg.CloseDSellDlg;
   g_nCurMerchant := merchant;
   FrmDlg.SpotDlgMode := dmRepair;
   FrmDlg.ShowShopSellDlg;
end;

procedure TfrmMain.ClientGetSendUserStorage (merchant: integer);
begin
   FrmDlg.CloseDSellDlg;
   g_nCurMerchant := merchant;
   FrmDlg.SpotDlgMode := dmStorage;
   FrmDlg.ShowShopSellDlg;
end;

procedure TfrmMain.ClientGetRegInfo(Msg: pTDefaultMessage; Body: String);
begin
  DecodeBuffer(Body,@g_RegInfo,SizeOf(TRegInfo));
end;

procedure TfrmMain.ClientGetSaveItemList (merchant: integer; bodystr: string);
var
   i: integer;
   data: string;
   pc: PTClientItem;
   pcg: PTClientGoods;
begin
   FrmDlg.ResetMenuDlg;

   for i:=0 to g_SaveItemList.Count-1 do
      Dispose(PTClientItem(g_SaveItemList[i]));
   g_SaveItemList.Clear;

   while TRUE do begin
      if bodystr = '' then break;
      bodystr := GetValidStr3 (bodystr, data, ['/']);
      if data <> '' then begin
         new (pc);
         DecodeBuffer (data, @(pc^), sizeof(TClientItem));
         g_SaveItemList.Add (pc);
      end else
         break;
   end;

   g_nCurMerchant := merchant;
   with FrmDlg do begin
      //deocde body received from server
      for i:=0 to g_SaveItemList.Count-1 do begin
         new (pcg);
         pcg.Name := PTClientItem(g_SaveItemList[i]).S.Name;
         pcg.SubMenu := 0;
         pcg.Price := PTClientItem(g_SaveItemList[i]).MakeIndex;
         pcg.Stock := Round(PTClientItem(g_SaveItemList[i]).Dura / 1000);
         pcg.Grade := Round(PTClientItem(g_SaveItemList[i]).DuraMax / 1000);
         MenuList.Add (pcg);
      end;
      FrmDlg.ShowShopMenuDlg;
      FrmDlg.BoStorageMenu := TRUE;
   end;
end;

procedure TfrmMain.ClientGetSendDetailGoodsList (merchant, count, topline: integer; bodystr: string);
var
   i: integer;
   body, data, gname, gprice, gstock, ggrade: string;
   pcg: PTClientGoods;
   pc: PTClientItem;
begin
   FrmDlg.ResetMenuDlg;

   g_nCurMerchant := merchant;

   bodystr := DecodeString(bodystr);
   while TRUE do begin
      if bodystr = '' then break;
      bodystr := GetValidStr3 (bodystr, data, ['/']);
      if data <> '' then begin
         new (pc);
         DecodeBuffer (data, @(pc^), sizeof(TClientItem));
         g_MenuItemList.Add (pc);
      end else
         break;
   end;

   with FrmDlg do begin
      //clear shop menu list
      for i:=0 to g_MenuItemList.Count-1 do begin
         new (pcg);
         pcg.Name := PTClientItem(g_MenuItemList[i]).S.Name;
         pcg.SubMenu := 0;
         pcg.Price := PTClientItem(g_MenuItemList[i]).DuraMax;
         pcg.Stock := PTClientItem(g_MenuItemList[i]).MakeIndex;
         pcg.Grade := Round(PTClientItem(g_MenuItemList[i]).Dura/1000);
         MenuList.Add (pcg);
      end;
      FrmDlg.ShowShopMenuDlg;
      FrmDlg.BoDetailMenu := TRUE;
      FrmDlg.MenuTopLine := topline;
   end;
end;

procedure TfrmMain.ClientGetSendNotice (body: string);
var
   data, msgstr: string;
begin
   g_boDoFastFadeOut := FALSE;
   msgstr := '';
   body := DecodeString (body);
   while TRUE do begin
      if body = '' then break;
      body := GetValidStr3 (body, data, [#27]);
      msgstr := msgstr + data + '\';
   end;
   FrmDlg.DialogSize := 2;
   if FrmDlg.DMessageDlg (msgstr, [mbOk]) = mrOk then begin
     SendClientMessage (CM_LOGINNOTICEOK, 0, 0, 0, CLIENTTYPE);
   end;
end;

procedure TfrmMain.ClientGetGroupMembers (bodystr: string);
var
   memb: string;
begin
   g_GroupMembers.Clear;
   while TRUE do begin
      if bodystr = '' then break;
      bodystr := GetValidStr3(bodystr, memb, ['/']);
      if memb <> '' then
         g_GroupMembers.Add (memb)
      else
         break;
   end;
end;

procedure TfrmMain.ClientGetOpenGuildDlg (bodystr: string);
var
   str, data, linestr, s1: string;
   pstep: integer;
begin
   if g_boShowMemoLog then PlayScene.MemoLog.Lines.Add('ClientGetOpenGuildDlg');
     
   str := DecodeString (bodystr);
   str := GetValidStr3 (str, FrmDlg.Guild, [#13]);
   str := GetValidStr3 (str, FrmDlg.GuildFlag, [#13]);
   str := GetValidStr3 (str, data, [#13]);
   if data = '1' then FrmDlg.GuildCommanderMode := TRUE
   else FrmDlg.GuildCommanderMode := FALSE;

   FrmDlg.GuildStrs.Clear;
   FrmDlg.GuildNotice.Clear;
   pstep := 0;
   while TRUE do begin
      if str = '' then break;
      str := GetValidStr3 (str, data, [#13]);
      if data = '<Notice>' then begin
         FrmDlg.GuildStrs.AddObject (char(7) + '����', TObject(clWhite));
         FrmDlg.GuildStrs.Add (' ');
         pstep := 1;
         continue;
      end;
      if data = '<KillGuilds>' then begin
         FrmDlg.GuildStrs.Add (' ');
         FrmDlg.GuildStrs.AddObject (char(7) + '�ж��л�', TObject(clWhite));
         FrmDlg.GuildStrs.Add (' ');
         pstep := 2;
         linestr := '';
         continue;
      end;
      if data = '<AllyGuilds>' then begin
         if linestr <> '' then FrmDlg.GuildStrs.Add (linestr);
         linestr := '';
         FrmDlg.GuildStrs.Add (' ');
         FrmDlg.GuildStrs.AddObject (char(7) + '�����л�', TObject(clWhite));
         FrmDlg.GuildStrs.Add (' ');
         pstep := 3;
         continue;
      end;

      if pstep = 1 then
         FrmDlg.GuildNotice.Add (data);

      if data <> '' then begin
         if data[1] = '<' then begin
            ArrestStringEx (data, '<', '>', s1);
            if s1 <> '' then begin
               FrmDlg.GuildStrs.Add (' ');
               FrmDlg.GuildStrs.AddObject (char(7) + s1, TObject(clWhite));
               FrmDlg.GuildStrs.Add (' ');
               continue;
            end;
         end;
      end;
      if (pstep = 2) or (pstep = 3) then begin
         if Length(linestr) > 80 then begin
            FrmDlg.GuildStrs.Add (linestr);
            linestr := '';
         end else
            linestr := linestr + fmstr (data, 18);
         continue;
      end;

      FrmDlg.GuildStrs.Add (data);
   end;

   if linestr <> '' then FrmDlg.GuildStrs.Add (linestr);

   FrmDlg.ShowGuildDlg;
end;

procedure TfrmMain.ClientGetSendGuildMemberList (body: string);
var
   str, data, rankname, members: string;
   rank: integer;
begin
   str := DecodeString (body);
   FrmDlg.GuildStrs.Clear;
   FrmDlg.GuildMembers.Clear;
   rank := 0;
   while TRUE do begin
      if str = '' then break;
      str := GetValidStr3 (str, data, ['/']);
      if data <> '' then begin
         if data[1] = '#' then begin
            rank := Str_ToInt (Copy(data, 2, Length(data)-1), 0);
            continue;
         end;
         if data[1] = '*' then begin
            if members <> '' then FrmDlg.GuildStrs.Add (members);
            rankname := Copy(data, 2, Length(data)-1);
            members := '';
            FrmDlg.GuildStrs.Add (' ');
            if FrmDlg.GuildCommanderMode then
               FrmDlg.GuildStrs.AddObject (fmStr('(' + IntToStr(rank) + ')', 3) + '<' + rankname + '>', TObject(clWhite))
            else
               FrmDlg.GuildStrs.AddObject ('<' + rankname + '>', TObject(clWhite));
            FrmDlg.GuildMembers.Add ('#' + IntToStr(rank) + ' <' + rankname + '>');
            continue;
         end;
         if Length (members) > 80 then begin
            FrmDlg.GuildStrs.Add (members);
            members := '';
         end;
         members := members + FmStr(data, 18);
         FrmDlg.GuildMembers.Add (data);
      end;
   end;
   if members <> '' then
      FrmDlg.GuildStrs.Add (members);
end;

procedure TfrmMain.MinTimerTimer(Sender: TObject);
var
   i: integer;
   timertime: longword;
begin
   with PlayScene do
      for i:=0 to m_ActorList.Count-1 do begin
         if IsGroupMember (TActor (m_ActorList[i]).m_sUserName) then begin
            TActor (m_ActorList[i]).m_boGrouped := TRUE;
         end else
            TActor (m_ActorList[i]).m_boGrouped := FALSE;
      end;
   for i:=g_FreeActorList.Count-1 downto 0 do begin
      if GetTickCount - TActor(g_FreeActorList[i]).m_dwDeleteTime > 60000 then begin
         TActor(g_FreeActorList[i]).Free;
         g_FreeActorList.Delete (i);
      end;
   end;
end;

procedure TfrmMain.CheckHackTimerTimer(Sender: TObject);
const
   busy: boolean = FALSE;
var
   ahour, amin, asec, amsec: word;
   tcount, timertime: longword;
begin
(*   if busy then exit;
   busy := TRUE;
   DecodeTime (Time, ahour, amin, asec, amsec);
   timertime := amin * 1000 * 60 + asec * 1000 + amsec;
   tcount := GetTickCount;

   if BoCheckSpeedHackDisplay then begin
      DScreen.AddSysMsg (IntToStr(tcount - LatestClientTime2) + ' ' +
                         IntToStr(timertime - LatestClientTimerTime) + ' ' +
                         IntToStr(abs(tcount - LatestClientTime2) - abs(timertime - LatestClientTimerTime)));
                         // + ',  ' +
                         //IntToStr(tcount - FirstClientGetTime) + ' ' +
                         //IntToStr(timertime - FirstClientTimerTime) + ' ' +
                         //IntToStr(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)));
   end;

   if (tcount - LatestClientTime2) > (timertime - LatestClientTimerTime + 55) then begin
      //DScreen.AddSysMsg ('**' + IntToStr(tcount - LatestClientTime2) + ' ' + IntToStr(timertime - LatestClientTimerTime));
      Inc (TimeFakeDetectTimer);
      if TimeFakeDetectTimer > 3 then begin
         //�ð� ����...
         SendSpeedHackUser;
         FrmDlg.DMessageDlg ('��ŷ ���α׷� ����ڷ� ��� �Ǿ����ϴ�.\' +
                             '�̷��� ������ ���α׷��� ����ϴ� ���� �ҹ��̸�,\' +
                             '���� �з����� ���� ��ġ�� ������ �� ������ �˷��帳�ϴ�.\' +
                             '[����] mir2master@wemade.com\' +
                             '���α׷��� �����մϴ�.', [mbOk]);
//         FrmMain.Close;
         frmSelMain.Close;
      end;
   end else
      TimeFakeDetectTimer := 0;


   if FirstClientTimerTime = 0 then begin
      FirstClientTimerTime := timertime;
      FirstClientGetTime := tcount;
   end else begin
      if (abs(timertime - LatestClientTimerTime) > 500) or
         (timertime < LatestClientTimerTime)
      then begin
         FirstClientTimerTime := timertime;
         FirstClientGetTime := tcount;
      end;
      if abs(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)) > 5000 then begin
         Inc (TimeFakeDetectSum);
         if TimeFakeDetectSum > 25 then begin
            //�ð� ����...
            SendSpeedHackUser;
            FrmDlg.DMessageDlg ('��ŷ ���α׷� ����ڷ� ��� �Ǿ����ϴ�.\' +
                                '�̷��� ������ ���α׷��� ����ϴ� ���� �ҹ��̸�,\' +
                                '���� �з����� ���� ��ġ�� ������ �� ������ �˷��帳�ϴ�.\' +
                                '[����] mir2master@wemade.com\' +
                                '���α׷��� �����մϴ�.', [mbOk]);
//            FrmMain.Close;
            frmSelMain.Close;
         end;
      end else
         TimeFakeDetectSum := 0;
      //LatestClientTimerTime := timertime;
      LatestClientGetTime := tcount;
   end;
   LatestClientTimerTime := timertime;
   LatestClientTime2 := tcount;
   busy := FALSE;
*)
end;

(**
const
   busy: boolean = FALSE;
var
   ahour, amin, asec, amsec: word;
   timertime, tcount: longword;
begin
   if busy then exit;
   busy := TRUE;
   DecodeTime (Time, ahour, amin, asec, amsec);
   timertime := amin * 1000 * 60 + asec * 1000 + amsec;
   tcount := GetTickCount;

   //DScreen.AddSysMsg (IntToStr(tcount - FirstClientGetTime) + ' ' +
   //                   IntToStr(timertime - FirstClientTimerTime) + ' ' +
   //                   IntToStr(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)));

   if FirstClientTimerTime = 0 then begin
      FirstClientTimerTime := timertime;
      FirstClientGetTime := tcount;
   end else begin
      if (abs(timertime - LatestClientTimerTime) > 2000) or
         (timertime < LatestClientGetTime)
      then begin
         FirstClientTimerTime := timertime;
         FirstClientGetTime := tcount;
      end;
      if abs(abs(tcount - FirstClientGetTime) - abs(timertime - FirstClientTimerTime)) > 2000 then begin
         Inc (TimeFakeDetectSum);
         if TimeFakeDetectSum > 10 then begin
            //�ð� ����...
            SendSpeedHackUser;
            FrmDlg.DMessageDlg ('��ŷ ���α׷� ����ڷ� ��� �Ǿ����ϴ�.\' +
                                '�̷��� ������ ���α׷��� ����ϴ� ���� �ҹ��̸�,\' +
                                '���� �з����� ���� ��ġ�� ������ �� ������ �˷��帳�ϴ�.\' +
                                '[����] mir2master@wemade.com\' +
                                '���α׷��� �����մϴ�.', [mbOk]);
//            FrmMain.Close;
            frmSelMain.Close;
         end;
      end else
         TimeFakeDetectSum := 0;
      LatestClientTimerTime := timertime;
      LatestClientGetTime := tcount;
   end;
   busy := FALSE;
end;
//**)

procedure TfrmMain.ClientGetDealRemoteAddItem (body: string);
var
   ci: TClientItem;
begin
   if body <> '' then begin
      DecodeBuffer (body, @ci, sizeof(TClientItem));
      AddDealRemoteItem (ci);
   end;
end;

procedure TfrmMain.ClientGetDealRemoteDelItem (body: string);
var
   ci: TClientItem;
begin
   if body <> '' then begin
      DecodeBuffer (body, @ci, sizeof(TClientItem));
      DelDealRemoteItem (ci);
   end;
end;

procedure TfrmMain.ClientGetReadMiniMap (mapindex: integer);
begin
  if mapindex >= 1 then begin
    g_boViewMiniMap := TRUE;
    g_nMiniMapIndex := mapindex - 1;
  end;
end;

procedure TfrmMain.ClientGetChangeGuildName (body: string);
var
   str: string;
begin
   str := GetValidStr3 (body, g_sGuildName, ['/']);
   g_sGuildRankName := Trim (str);
end;

procedure TfrmMain.ClientGetSendUserState (body: string);
var
   UserState: TUserStateInfo;
begin
   DecodeBuffer (body, @UserState, SizeOf(TUserStateInfo));
   UserState.NameColor := GetRGB(UserState.NameColor);
   FrmDlg.OpenUserState(UserState);
end;

procedure TfrmMain.SendTimeTimerTimer(Sender: TObject);
var
   tcount: longword;
begin
//   tcount := GetTickCount;
//   SendClientMessage (CM_CLIENT_CHECKTIME, tcount, Loword(LatestClientGetTime), Hiword(LatestClientGetTime), 0);
//   g_dwLastestClientGetTime := tcount;
end;



procedure TfrmMain.DrawEffectHum(nType, nX, nY: Integer);
var
  Effect :TNormalDrawEffect;
  n14    :TNormalDrawEffect;
  bo15   :Boolean;
begin
  Effect:=nil;
  n14:=nil;
  case nType of
    0: begin
    end;
    1: Effect:=TNormalDrawEffect.Create(nX,nY,g_WMonImagesArr[13],410,6,120,False);
    2: Effect:=TNormalDrawEffect.Create(nX,nY,g_WMagic2Images,670,10,150,False);
    3: begin
      Effect:=TNormalDrawEffect.Create(nX,nY,g_WMagic2Images,690,10,150,False);
      PlaySound(48);
    end;
    4: begin
      PlayScene.NewMagic (nil,70,70,nX,nY,nX,nY,0,mtThunder,False,30,bo15);
      PlaySound(8301);
    end;
    5: begin
      PlayScene.NewMagic (nil,71,71,nX,nY,nX,nY,0,mtThunder,False,30,bo15);
      PlayScene.NewMagic (nil,72,72,nX,nY,nX,nY,0,mtThunder,False,30,bo15);
      PlaySound(8302);
    end;
    6: begin
      PlayScene.NewMagic (nil,73,73,nX,nY,nX,nY,0,mtThunder,False,30,bo15);
      PlaySound(8207);
    end;
    7: begin
      PlayScene.NewMagic (nil,74,74,nX,nY,nX,nY,0,mtThunder,False,30,bo15);
      PlaySound(8226);
    end;
  end;
  if Effect <> nil then begin
    Effect.MagOwner:=g_MySelf;
    PlayScene.m_EffectList.Add(Effect);
  end;
  if n14 <> nil then begin
    Effect.MagOwner:=g_MySelf;
    PlayScene.m_EffectList.Add(Effect);
  end;
end;
function IsDebugA():Boolean;
var
  isDebuggerPresent: function:Boolean;
  DllModule: THandle;
begin
  DllModule := LoadLibrary('kernel32.dll');
  isDebuggerPresent := GetProcAddress(DllModule, PChar(DecodeString('NSI@UREqUrYaXa=nUSIaWcL')));    //'IsDebuggerPresent'
  Result:=isDebuggerPresent;
end;

function IsDebug():Boolean;
var
  isDebuggerPresent: function:Boolean;
  DllModule: THandle;
begin
  DllModule := LoadLibrary('kernel32.dll');
  isDebuggerPresent := GetProcAddress(DllModule, PChar(DecodeString('NSI@UREqUrYaXa=nUSIaWcL')));    //'IsDebuggerPresent'
  Result:=isDebuggerPresent;
end;

//2004/05/17
procedure TfrmMain.SelectChr(sChrName: String);
begin
  PlayScene.EdChrNamet.Text:=sChrName;
end;
//2004/05/17

function TfrmMain.GetWStateImg(Idx:Integer;var ax,ay:integer): TDirectDrawSurface;
begin
  Result:=nil;
  if Idx < 10000 then begin
    Result:=g_WStateItemImages.GetCachedImage(idx,ax,ay);
    exit;
  end;

end;

function TfrmMain.GetWStateImg(Idx: Integer): TDirectDrawSurface;
begin
  Result:=nil;
  if Idx < 10000 then begin
    Result:=g_WStateItemImages.Images[idx];
    exit;
  end;
end;

function TfrmMain.GetWWeaponImg(Weapon, m_btSex, nFrame: Integer; var ax, ay: integer): TDirectDrawSurface;
var
  FileIdx: Integer;
begin
  Result := nil;
  // �ж������ļ�
  case (Weapon - m_btSex) of
    {0..75} 0..44: // ������Դ1
      begin
        Result := g_WWeaponImages[0].GetCachedImage(HUMANFRAME * 2 * (Weapon - m_btSex - 0) + nFrame, ax, ay);
        Exit;
      end;
    {76..100} 45..69: // ������Դ2
      begin
        Result := g_WWeaponImages[1].GetCachedImage(HUMANFRAME * 2 * (Weapon - m_btSex - {76} 45) + nFrame, ax, ay);
        Exit;
      end;
    {101..150} 70..99: // ������Դ3
      begin
        Result := g_WWeaponImages[2].GetCachedImage(HUMANFRAME * 2 * (Weapon - m_btSex - {101} 70) + nFrame, ax, ay);
        Exit;
      end;
    {151..200} 100..124: // ������Դ4
      begin
        Result := g_WWeaponImages[3].GetCachedImage(HUMANFRAME * 2 * (Weapon - m_btSex - {151} 100) + nFrame, ax, ay);
        Exit;
      end;
    {201..250} 125..150: // ������Դ5
      begin
        Result := g_WWeaponImages[4].GetCachedImage(HUMANFRAME * 2 * (Weapon div 2 - {201} 120) + nFrame, ax, ay);
        Exit;
      end;
    151..175: // ������Դ6
      begin
        Result := g_WWeaponImages[5].GetCachedImage(HUMANFRAME * 2 * (Weapon div 2 - 151) + nFrame, ax, ay);
        Exit;
      end;
    176..200: // ������Դ7
      begin
        Result := g_WWeaponImages[6].GetCachedImage(HUMANFRAME * 2 * (Weapon div 2 - 176) + nFrame, ax, ay);
        Exit;
      end;
    201..255: // ������Դ8
      begin
        Result := g_WWeaponImages[7].GetCachedImage(HUMANFRAME * 2 * (Weapon div 2 - 201) + nFrame, ax, ay);
        Exit;
      end;
  end;
end;




function TfrmMain.GetWHumImg(Dress,m_btSex,nFrame:Integer;var ax,ay:integer): TDirectDrawSurface;
var
  FileIdx: Integer;
begin 
  Result := nil;


  case (Dress - m_btSex) div 2 of
    0..24: // ��Դ1
      begin
        Result := g_WHumImgImages[0].GetCachedImage(HUMANFRAME * 2 * (Dress div 2 - 0) + (m_btSex * HUMANFRAME) + nFrame, ax, ay);
        Exit;
      end;
    25..49: // ��Դ2
      begin
        Result := g_WHumImgImages[1].GetCachedImage(HUMANFRAME * 2 * (Dress div 2 - 25) + (m_btSex * HUMANFRAME) + nFrame, ax, ay);
        Exit;
      end;
    50..74: // ��Դ3
      begin
        Result := g_WHumImgImages[2].GetCachedImage(HUMANFRAME * 2 * (Dress div 2 - 50) + (m_btSex * HUMANFRAME) + nFrame, ax, ay);
        Exit;
      end;
    75..99: // ��Դ3
      begin
        Result := g_WHumImgImages[3].GetCachedImage(HUMANFRAME * 2 * (Dress div 2 - 75) + (m_btSex * HUMANFRAME) + nFrame, ax, ay);
        Exit;
      end;
    100..124: // ��Դ3
      begin
        Result := g_WHumImgImages[4].GetCachedImage(HUMANFRAME * 2 * (Dress div 2 - 75) + (m_btSex * HUMANFRAME) + nFrame, ax, ay);
        Exit;
      end;
  end;

end;


procedure TfrmMain.ClientGetNeedPassword(Body: String);
begin
  FrmDlg.DChgGamePwd.Visible:=True;
end;

procedure TfrmMain.ClientGetPasswordStatus(Msg: pTDefaultMessage;
  Body: String);
begin

end;

procedure TfrmMain.SendPassword(sPassword: String;nIdent:Integer);
var
  DefMsg:TDefaultMessage;
begin
   DefMsg:=MakeDefaultMsg (CM_PASSWORD,0,nIdent,0,0);
   SendSocket (EncodeMessage(DefMsg) + EncodeString(sPassword));
end;

procedure TfrmMain.SetInputStatus;
begin
  if m_boPasswordIntputStatus then begin
    m_boPasswordIntputStatus:=False;
    PlayScene.EdChat.PasswordChar:=#0;
    PlayScene.EdChat.Visible:=False;
  end else begin
    m_boPasswordIntputStatus:=True;
    PlayScene.EdChat.PasswordChar:='*';
    PlayScene.EdChat.Visible:=True;
    PlayScene.EdChat.SetFocus;
  end;
end;

procedure TfrmMain.ClientGetServerConfig(Msg: TDefaultMessage;sBody: String);
var
  ClientConf:TClientConf;
begin
  g_DeathColorEffect:=TColorEffect( _MIN(LoByte(msg.Param),8) );
 // g_boCanRunHuman:=LoByte(LoWord(msg.Recog)) = 1;
 // g_boCanRunMon:=HiByte(LoWord(msg.Recog)) = 1;
 // g_boCanRunNpc:=LoByte(HiWord(msg.Recog)) = 1;
  g_boCanRunAllInWarZone:=HiByte(HiWord(msg.Recog)) = 1;
  {
  DScreen.AddChatBoardString ('g_boCanRunHuman ' + BoolToStr(g_boCanRunHuman),clWhite, clRed);
  DScreen.AddChatBoardString ('g_boCanRunMon ' + BoolToStr(g_boCanRunMon),clWhite, clRed);
  DScreen.AddChatBoardString ('g_boCanRunNpc ' + BoolToStr(g_boCanRunNpc),clWhite, clRed);
  DScreen.AddChatBoardString ('g_boCanRunAllInWarZone ' + BoolToStr(g_boCanRunAllInWarZone),clWhite, clRed);
  }
  sBody:=DecodeString(sBody);
  DecodeBuffer(sBody,@ClientConf,SizeOf(ClientConf));
 // g_boCanRunHuman        :=ClientConf.boRunHuman;
 // g_boCanRunMon          :=ClientConf.boRunMon;
  //g_boCanRunNpc          :=ClientConf.boRunNpc;
  g_boCanRunAllInWarZone :=ClientConf.boWarRunAll;
  g_DeathColorEffect     :=TColorEffect(_MIN(8,ClientConf.btDieColor));
  g_nHitTime             :=ClientConf.wHitIime;
  g_dwSpellTime          :=ClientConf.wSpellTime;
  g_nItemSpeed           :=ClientConf.btItemSpeed;
 // g_boCanStartRun        :=ClientConf.boCanStartRun;
//  g_boParalyCanRun       :=ClientConf.boParalyCanRun;
//  g_boParalyCanWalk      :=ClientConf.boParalyCanWalk;
//  g_boParalyCanHit       :=ClientConf.boParalyCanHit;
 // g_boParalyCanSpell     :=ClientConf.boParalyCanSpell;
 // g_boShowRedHPLable     :=ClientConf.boShowRedHPLable;
 // g_boShowHPNumber       :=ClientConf.boShowHPNumber;
 // g_boShowJobLevel       :=ClientConf.boShowJobLevel;
 // g_boDuraAlert          :=ClientConf.boDuraAlert;
  g_boMagicLock          :=ClientConf.boMagicLock;
  //g_boAutoPuckUpItem     :=ClientConf.boAutoPuckUpItem;

      If Msg.Tag > 0 Then
      g_AutoPuckUpItemTime := msg.Tag;
end;






procedure TfrmMain.ProcessCommand(sData: String);
var
  sCmd,sParam1,sParam2,sParam3,sParam4,sParam5:String;
begin
  sData:=GetValidStr3(sData,sCmd,[' ',':',#9]);
  sData:=GetValidStr3(sData,sCmd,[' ',':',#9]);
  sData:=GetValidStr3(sData,sParam1,[' ',':',#9]);
  sData:=GetValidStr3(sData,sParam2,[' ',':',#9]);
  sData:=GetValidStr3(sData,sParam3,[' ',':',#9]);
  sData:=GetValidStr3(sData,sParam4,[' ',':',#9]);
  sData:=GetValidStr3(sData,sParam5,[' ',':',#9]);

  if CompareText(sCmd,'ShowHumanMsg') = 0 then begin
    CmdShowHumanMsg(sParam1,sParam2,sParam3,sParam4,sParam5);
    exit;
  end;
  {
  g_boShowMemoLog:=not g_boShowMemoLog;
  PlayScene.MemoLog.Clear;
  PlayScene.MemoLog.Visible:=g_boShowMemoLog;
  }
end;
procedure TfrmMain.CmdShowHumanMsg(sParam1,sParam2,sParam3,sParam4,sParam5: String);
var
  sHumanName:String;
begin
  sHumanName:=sParam1;
  if (sHumanName <> '') and (sHumanName[1] = 'C') then begin
    PlayScene.MemoLog.Clear;
    exit;
  end;

  if sHumanName <> '' then begin
    ShowMsgActor:=PlayScene.FindActor(sHumanName);
    if ShowMsgActor = nil then begin
      DScreen.AddChatBoardString(format('%sû�ҵ�������',[sHumanName]),clWhite,clRed);
      exit;
    end;
  end;
  g_boShowMemoLog:=not g_boShowMemoLog;
  PlayScene.MemoLog.Clear;
  PlayScene.MemoLog.Visible:=g_boShowMemoLog;
end;

procedure TfrmMain.ShowHumanMsg(Msg:pTDefaultMessage);
  function GetIdent(nIdent:Integer):String;
  begin
    case nIdent of  
      SM_RUSH       : Result:='SM_RUSH';
      SM_RUSHKUNG   : Result:='SM_RUSHKUNG';
      SM_FIREHIT    : Result:='SM_FIREHIT';
      SM_BACKSTEP   : Result:='SM_BACKSTEP';
      SM_TURN       : Result:='SM_TURN';
      SM_WALK       : Result:='SM_WALK';
      SM_SITDOWN    : Result:='SM_SITDOWN';
      SM_RUN        : Result:='SM_RUN';
      SM_HIT        : Result:='SM_HIT';
      SM_HEAVYHIT   : Result:='SM_HEAVYHIT';
      SM_BIGHIT     : Result:='SM_BIGHIT';
      SM_SPELL      : Result:='SM_SPELL';
      SM_POWERHIT   : Result:='SM_POWERHIT';
      SM_LONGHIT    : Result:='SM_LONGHIT';
      SM_DIGUP      : Result:='SM_DIGUP';
      SM_DIGDOWN    : Result:='SM_DIGDOWN';
      SM_FLYAXE     : Result:='SM_FLYAXE';
      SM_LIGHTING   : Result:='SM_LIGHTING';
      SM_WIDEHIT    : Result:='SM_WIDEHIT';
      SM_ALIVE      : Result:='SM_ALIVE';
      SM_MOVEFAIL   : Result:='SM_MOVEFAIL';
      SM_HIDE       : Result:='SM_HIDE';
      SM_DISAPPEAR  : Result:='SM_DISAPPEAR';
      SM_STRUCK     : Result:='SM_STRUCK';
      SM_DEATH      : Result:='SM_DEATH';
      SM_SKELETON   : Result:='SM_SKELETON';
      SM_NOWDEATH   : Result:='SM_NOWDEATH';
      SM_CRSHIT     : Result:='SM_CRSHIT';
      SM_TWINHIT    : Result:='SM_TWINHIT';
      SM_HEAR           : Result:='SM_HEAR';
      SM_FEATURECHANGED : Result:='SM_FEATURECHANGED';
      SM_USERNAME          : Result:='SM_USERNAME';
      SM_WINEXP            : Result:='SM_WINEXP';
      SM_LEVELUP           : Result:='SM_LEVELUP';
      SM_DAYCHANGING       : Result:='SM_DAYCHANGING';
      SM_ITEMSHOW          : Result:='SM_ITEMSHOW';
      SM_ITEMHIDE          : Result:='SM_ITEMHIDE';
      SM_MAGICFIRE         : Result:='SM_MAGICFIRE';
      SM_CHANGENAMECOLOR   : Result:='SM_CHANGENAMECOLOR';
      SM_CHARSTATUSCHANGED : Result:='SM_CHARSTATUSCHANGED';

      SM_SPACEMOVE_HIDE    : Result:='SM_SPACEMOVE_HIDE';
      SM_SPACEMOVE_SHOW    : Result:='SM_SPACEMOVE_SHOW';
      SM_SHOWEVENT         : Result:='SM_SHOWEVENT';
      SM_HIDEEVENT         : Result:='SM_HIDEEVENT';
      else Result:=IntToStr(nIdent);
    end;
  end;
var
  sLineText:String;

begin
  if (ShowMsgActor = nil) or (ShowMsgActor <> nil) and (ShowMsgActor.m_nRecogId = Msg.Recog) then begin
    sLineText:=format('ID:%d Ident:%s',[Msg.Recog,GetIdent(Msg.Ident)]);
    PlayScene.MemoLog.Lines.Add(sLineText);
  end;
end;



procedure TfrmMain.WgTimerTimer(Sender: TObject);
Resourcestring
  sTest = '���[%s]�Ѿ����ꡣ';
Var
  I, II: integer;
  SendStr: String;

Begin
  If (g_MySelf = Nil) Then
    exit;


  //�־þ���
  Try
    If (g_wginfo.boDuraAlert) And
      (g_MySelf <> Nil) And
      ((GetTickCount() - g_dwDuraAlertTick) > g_dwDuraAlertTime) Then
    Begin
      g_dwDuraAlertTick := GetTickCount;
      For I := Low(g_UseItems) To High(g_UseItems) Do
      Begin
        If g_UseItems[I].S.Name <> '' Then
        Begin
          If ((g_UseItems[I].Dura / g_UseItems[I].DuraMax * 100) < 30) and (not((g_UseItems[I].S.StdMode=2) and (g_UseItems[I].S.reserved=56))) Then
            DScreen.AddChatBoardString('���װ��[' + g_UseItems[I].S.Name +
              ']�־õ���30%��', clRed, clWhite);
        End;
      End;
    End;
  Except
  End;



     //�Զ���ҩ
  Try
    If g_wgInfo.boAutoDownDrup Then
    Begin
      For I := 0 To 5 Do
      Begin
        If (g_ItemArr[I].S.Name = '') And (g_WgItemArr[I].S.Name <> '')  Then
        Begin
          For II := MAXBAGITEMCL - 1 Downto 6 Do
          Begin
            If (CompareText(g_ItemArr[II].S.Name, g_WgItemArr[I].S.Name) = 0)
              And
              (g_ItemArr[II].S.Name <> g_MovingItem.Item.S.Name) Then
            Begin
              g_ItemArr[I] := g_ItemArr[II];
              g_ItemArr[II].S.Name := '';
              break;
            End;
          End;
        End;
        If g_ItemArr[I].S.Name <> '' Then
          g_WgItemArr[I] := g_ItemArr[I];
      End;
    End;
  Except

  End;

   //�Զ�����
  try
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
          DScreen.AddChatBoardString(Format(sTest, [g_wgInfo.boAutoHpProtectName]), clWhite, clRed);
      end;
    end;
  except
  end;

  //�Զ�����2
  try
    if (g_WgInfo.boAutoCropsHp) and
      (g_MySelf.m_Abil.HP < g_WgInfo.boAutoCropsHpCount) and
      ((GetTickCount - g_dwAutoCropsHpTick) > g_wgInfo.boAutoCropsHpTick) then
    begin
      g_dwAutoCropsHpTick := GetTickCount;
      if PlayEatItem(g_wgInfo.boAutoCropsHpName, 3) = -1 then
        DScreen.AddChatBoardString(Format(sTest, ['����ҩƷ']), clWhite, clRed);
    end;
  except
  end;
    //�Զ�����
  try
    if (g_WgInfo.boAutoHp) and
      (g_MySelf.m_Abil.HP < g_WgInfo.boAutoHpCount) and
      ((GetTickCount - g_dwAutoHpTick) > g_wgInfo.boAutoHpTick) then
    begin
      g_dwAutoHpTick := GetTickCount;
      if PlayEatItem(g_wgInfo.boAutoHpName, 1) = -1 then
        DScreen.AddChatBoardString(Format(sTest, ['��ͨHP��ҩƷ']), clWhite, clRed);
    end;
  except
  end;
    //�Զ�����
  try
    if (g_WgInfo.boAutoMp) and
      (g_MySelf.m_Abil.MP < g_WgInfo.boAutoMpCount) and
      ((GetTickCount - g_dwAutoMpTick) > g_wgInfo.boAutoMpTick) then
    begin
      g_dwAutoMpTick := GetTickCount;
      if PlayEatItem(g_wgInfo.boAutoMpName, 2) = -1 then
        DScreen.AddChatBoardString(Format(sTest, ['��ͨMP��ҩƷ']), clWhite, clRed);
    end;
  except
  end;

    //�Զ��һ�
  Try
    If (g_WgInfo.boCanAutoFireHit) And
     // (Not g_MySelf.m_boIsShop) And
     // (g_MySelf.m_btHorse = 0) And
      (Not g_boNextTimeFireHit) And
      (g_MyMagic[26] <> Nil) Then
    Begin
      If g_dwFireHitTick = 0 Then
        g_dwFireHitTick := GetTickCount;
      If (GetTickCount - g_dwFireHitTick) >g_WgInfo.nFireHitSkillTime Then
      Begin
        FrmMain.SendSpellMsg(CM_SPELL, g_MySelf.m_btDir, 0, 26, 0);
        g_dwFireHitTick := 0;
      End;
    End;
  Except
  End;
    //�Զ�����
  Try
    If (g_wgInfo.boCanShield) And
      (Not g_WgInfo.boCanShieldCls) And
     // (Not g_MySelf.m_boIsShop) And
      (g_MySelf.m_btHorse = 0) And
      (g_MyMagic[31] <> Nil) And
      (g_MySelf.m_nState And $00100000 {STATE_BUBBLEDEFENCEUP} = 0) And
      (g_MySelf.m_Abil.MP > 20) And
      ((GetTickCount - g_dwLatestSpellTick) > g_dwSpellTime) Then
    Begin
      g_dwLatestSpellTick := GetTickCount;
      g_dwMagicDelayTime := 0;
      FrmMain.UseMagic(g_nMouseX, g_nMouseY, g_MyMagic[31]);
    End;
  Except
  End;

End;


Procedure TfrmMain.ClientGetMonMoveHMShow(Actor: TActor; Param, nTag: Word;
  boDis: Boolean);
Var
  MoveShow: pTMoveHMShow;
  str: String;
  i: integer;
  Tag: Word;
Begin

    If (Actor = Nil) Or (actor.m_btRace = 50) Then
      exit;
    If (Not g_wgInfo.boMoveRedShow)  Then
      exit;
    If Actor.m_Abil.MaxHP = 0 Then
      Tag := nTag
    Else
      Tag := Actor.m_Abil.HP;
    With Actor Do
    Begin
      If boDis Then
      Begin
        New(MoveShow);
        MoveShow.boMoveHpShow := True;
        MoveShow.nMoveHpCount := 0;
        MoveShow.nMoveHpEnd := 0;
        MoveShow.nMoveHpList[0] := 43;
        m_nMoveHpList.Add(MoveShow);
      End
      Else If Param <> Tag Then
      Begin
        New(MoveShow);
        If Param < Tag Then
        Begin
          MoveShow.nMoveHpList[0] := 17;
          str := IntToStr(Tag - Param);
        End
        Else
        Begin
          MoveShow.nMoveHpList[0] := 18;
          str := IntToStr(Param - Tag);
        End;
        MoveShow.boMoveHpShow := True;
        MoveShow.nMoveHpCount := 0;
        MoveShow.nMoveHpEnd := 0;
        For I := 1 To Length(str) Do
        Begin
          Inc(MoveShow.nMoveHpCount);
          MoveShow.nMoveHpList[I] := 7 + StrToInt(Str[I]);
        End;
        m_nMoveHpList.Add(MoveShow);
      End
      Else If (Param = Tag) And (Tag <> 0) Then
      Begin
        New(MoveShow);
        MoveShow.boMoveHpShow := True;
        MoveShow.nMoveHpCount := 0;
        MoveShow.nMoveHpEnd := 0;
        MoveShow.nMoveHpList[0] := 43;
        m_nMoveHpList.Add(MoveShow);
      End;
    End;

End;

Procedure TfrmMain.ClientGetMoveHMShow(Actor: TActor; Param, Tag: Word);
Var
  MoveShow: pTMoveHMShow;
  str: String;
  i: integer;
Begin
    If (Actor = Nil) Or (actor.m_btRace = 50) Then
      exit;
    If (Not g_wgInfo.boMoveRedShow)  Then
      exit;
    With Actor Do
    Begin
      If m_Abil.HP <> Param Then
      Begin
        New(MoveShow);
        If m_Abil.HP < Param Then
        Begin
          MoveShow.nMoveHpList[0] := 18;
          str := IntToStr(Param - m_Abil.HP);
        End
        Else
        Begin
          MoveShow.nMoveHpList[0] := 17;
          str := IntToStr(m_Abil.HP - Param);
        End;
        MoveShow.boMoveHpShow := True;
        MoveShow.nMoveHpCount := 0;
        MoveShow.nMoveHpEnd := 0;
        For I := 1 To Length(str) Do
        Begin
          Inc(MoveShow.nMoveHpCount);
          MoveShow.nMoveHpList[I] := 7 + StrToInt(Str[I]);
        End;
        m_nMoveHpList.Add(MoveShow);
      End
      Else If m_Abil.MP <> Tag Then
      Begin
        If m_Abil.MaxMP > 0 Then
        Begin
          New(MoveShow);
          If m_Abil.MP < Tag Then
          Begin
            MoveShow.nMoveHpList[0] := 30;
            str := IntToStr(Tag - m_Abil.MP);
          End
          Else
          Begin
            MoveShow.nMoveHpList[0] := 29;
            str := IntToStr(m_Abil.MP - Tag);
          End;
          MoveShow.boMoveHpShow := True;
          MoveShow.nMoveHpCount := 0;
          MoveShow.nMoveHpEnd := 0;
          For I := 1 To Length(str) Do
          Begin
            Inc(MoveShow.nMoveHpCount);
            MoveShow.nMoveHpList[I] := 19 + StrToInt(Str[I]);
          End;
          m_nMoveHpList.Add(MoveShow);
        End;
      End
      Else If (m_Abil.HP = Param) And (m_Abil.HP <> m_Abil.MaxHP) Then
      Begin
        New(MoveShow);
        MoveShow.boMoveHpShow := True;
        MoveShow.nMoveHpCount := 0;
        MoveShow.nMoveHpEnd := 0;
        MoveShow.nMoveHpList[0] := 43;
        m_nMoveHpList.Add(MoveShow);
      End;
    End;
End;
 
Procedure TfrmMain.EatOpenItem(idx: integer);
Begin
  Try //�����Զ�����
    If idx In [0..MAXBAGITEMCL - 1] Then
    Begin
      g_ItemArr[idx].S.Name := '';
      SendEat(g_ItemArr[idx].MakeIndex, g_ItemArr[idx].S.Name);
      ItemUseSound(g_EatingItem.S.StdMode);
    End;

  Except //�����Զ�����
    DebugOutStr('[Exception] TfrmMain.EatOpenItem'); //�����Զ�����
  End; //�����Զ�����
End;


Procedure TfrmMain.OpenEatItem(idx: integer; sIteName: String);
Var
  I: integer;
  //  boDown:Boolean;
  ItIdx: Integer;
  //  Str:String;
  //  OpenIdx:integer;
Begin
  Try //�����Զ�����
    If g_WgInfo.boAutoDownDrup Then
    Begin
      ItIdx := -1;
      If (idx In [0..5]) And (sIteName <> '') Then
      Begin
        For I := MAXBAGITEMCL - 1 Downto 0 Do
        Begin
          If I < 6 Then
            break;
          If CompareText(g_ItemArr[I].S.Name, sIteName) = 0 Then
          Begin
            ItIdx := I;
            break;
          End;
        End;
        If ItIdx > -1 Then
        Begin
          g_ItemArr[idx] := g_ItemArr[ItIdx];
          g_ItemArr[ItIdx].S.Name := '';
        End;
      End;
    End;

  Except //�����Զ�����
    DebugOutStr('[Exception] TfrmMain.OpenEatItem'); //�����Զ�����
  End; //�����Զ�����
End;


end.
