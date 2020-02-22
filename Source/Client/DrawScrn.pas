unit DrawScrn;

interface

uses
Windows, Messages, SysUtils,StrUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DXClass, DirectX, IntroScn, Actor, cliUtil, clFunc,NWGfig,HUtil32;



const
   MAXSYSLINE = 8;

   BOTTOMBOARD = 1;
   VIEWCHATLINE = 9;
   AREASTATEICONBASE = 150;
   HEALTHBAR_BLACK = 0;
   HEALTHBAR_RED = 1;


type
   TDrawScreen = class
   private
      m_dwFrameTime       :LongWord;
      m_dwFrameCount      :LongWord;
      m_dwDrawFrameCount  :LongWord;
      m_SysMsgList        :TStringList;
   public
      CurrentScene: TScene;
      ChatStrs: TStringList;
      ChatBks: TList;
      ChatBoardTop: integer;

      HintList: TStringList;
      HintX, HintY, HintWidth, HintHeight: integer;
      HintUp: Boolean;
      HintColor: TColor;

      constructor Create;
      destructor Destroy; override;
      procedure KeyPress (var Key: Char);
      procedure KeyDown (var Key: Word; Shift: TShiftState);
      procedure MouseMove (Shift: TShiftState; X, Y: Integer);
      procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure Initialize;
      procedure Finalize;
      procedure ChangeScene (scenetype: TSceneType);
      procedure DrawScreen (MSurface: TDirectDrawSurface);
      procedure DrawScreenTop (MSurface: TDirectDrawSurface);
      procedure AddSysMsg (msg: string);
      procedure AddChatBoardString (str: string; fcolor, bcolor: integer);
      procedure ClearChatBoard;

      procedure ShowHint (x, y: integer; str: string; color: TColor; drawup: Boolean);
      procedure ClearHint;
      procedure DrawHint (MSurface: TDirectDrawSurface);
   end;


implementation

uses

   ClMain, MShare, Share,FState,WIL,magiceff,DIB,grobal2;

 const
    UseItem    : Array[0..13] of String =(
      '衣　服',
      '武　器',
      '配　带',
      '项　链',
      '头　盔',
      '左手镯',
      '右手镯',
      '左戒指',
      '右戒指',
      '消耗品',
      '腰　带',
      '靴　子',
      '宝　石',
      '斗　笠'
   );

constructor TDrawScreen.Create;
var
   i: integer;
begin
   CurrentScene := nil;
   m_dwFrameTime := GetTickCount;
   m_dwFrameCount := 0;
   m_SysMsgList := TStringList.Create;
   ChatStrs := TStringList.Create;
   ChatBks := TList.Create;
   ChatBoardTop := 0;

   HintList := TStringList.Create;

end;

destructor TDrawScreen.Destroy;
begin
   m_SysMsgList.Free;
   ChatStrs.Free;
   ChatBks.Free;
   HintList.Free;
   inherited Destroy;
end;

procedure TDrawScreen.Initialize;
begin
end;

procedure TDrawScreen.Finalize;
begin
end;

procedure TDrawScreen.KeyPress (var Key: Char);
begin
   if CurrentScene <> nil then
      CurrentScene.KeyPress (Key);
end;

procedure TDrawScreen.KeyDown (var Key: Word; Shift: TShiftState);
begin
   if CurrentScene <> nil then
      CurrentScene.KeyDown (Key, Shift);
end;

procedure TDrawScreen.MouseMove (Shift: TShiftState; X, Y: Integer);
begin
   if CurrentScene <> nil then
      CurrentScene.MouseMove (Shift, X, Y);
end;

procedure TDrawScreen.MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if CurrentScene <> nil then
      CurrentScene.MouseDown (Button, Shift, X, Y);
end;

procedure TDrawScreen.ChangeScene (scenetype: TSceneType);
begin
   if CurrentScene <> nil then
      CurrentScene.CloseScene;
   case scenetype of
      stIntro:  CurrentScene := IntroScene;
      stLogin:  CurrentScene := LoginScene;
      stSelectCountry:  ;
      stSelectChr: CurrentScene := SelectChrScene;
      stNewChr:     ;
      stLoading:    ;
      stLoginNotice: CurrentScene := LoginNoticeScene;
      stPlayGame: CurrentScene := PlayScene;
   end;
   if CurrentScene <> nil then
      CurrentScene.OpenScene;
end;

procedure TDrawScreen.AddSysMsg (msg: string);
begin
   if m_SysMsgList.Count >= 10 then m_SysMsgList.Delete (0);
   m_SysMsgList.AddObject (msg, TObject(GetTickCount));
end;

procedure TDrawScreen.AddChatBoardString (str: string; fcolor, bcolor: integer);
var
   i, len, aline: integer;
   dline, temp: string;
const
   BOXWIDTH = (SCREENWIDTH div 2 - 214) * 2{374}; //41 聊天框文字宽度
begin
   len := Length (str);
   temp := '';
   i := 1;
   while TRUE do begin
      if i > len then break;
      if byte (str[i]) >= 128 then begin
         temp := temp + str[i];
         Inc (i);
         if i <= len then temp := temp + str[i]
         else break;
      end else
         temp := temp + str[i];

      aline := FrmMain.Canvas.TextWidth (temp);
      if aline > BOXWIDTH then begin
         ChatStrs.AddObject (temp, TObject(fcolor));
         ChatBks.Add (Pointer(bcolor));
         str := Copy (str, i+1, Len-i);
         temp := '';
         break;
      end;
      Inc (i);
   end;
   if temp <> '' then begin
      ChatStrs.AddObject (temp, TObject(fcolor));
      ChatBks.Add (Pointer(bcolor));
      str := '';
   end;
   if ChatStrs.Count > 200 then begin
      ChatStrs.Delete (0);
      ChatBks.Delete (0);
      if ChatStrs.Count - ChatBoardTop < VIEWCHATLINE then Dec(ChatBoardTop);
   end else if (ChatStrs.Count-ChatBoardTop) > VIEWCHATLINE then begin
      Inc (ChatBoardTop);
   end;

   if str <> '' then
      AddChatBoardString (' ' + str, fcolor, bcolor);

end;

procedure TDrawScreen.ShowHint (x, y: integer; str: string; color: TColor; drawup: Boolean);
var
   data: string;
   w, h: integer;
begin
   ClearHint;
   HintX := x;
   HintY := y;
   HintWidth := 0;
   HintHeight := 0;
   HintUp := drawup;
   HintColor := color;
   while TRUE do begin
      if str = '' then break;
      str := GetValidStr3 (str, data, ['\']);
      w := FrmMain.Canvas.TextWidth (data) + 4{咯归} * 2;
      if w > HintWidth then HintWidth := w;
      if data <> '' then
         HintList.Add (data)
   end;
   HintHeight := (FrmMain.Canvas.TextHeight('A') + 1) * HintList.Count + 3{咯归} * 2;
   if HintUp then
      HintY := HintY - HintHeight;
end;

procedure TDrawScreen.ClearHint;
begin
   HintList.Clear;
end;

procedure TDrawScreen.ClearChatBoard;
begin
   m_SysMsgList.Clear;
   ChatStrs.Clear;
   ChatBks.Clear;
   ChatBoardTop := 0;
end;


procedure TDrawScreen.DrawScreen (MSurface: TDirectDrawSurface);
  procedure NameTextOut (surface: TDirectDrawSurface; x, y, fcolor, bcolor: integer; namestr: string);
   var
     row: integer;
     nstr: string;
   begin
      row := 0;
      while True do begin
        if namestr = '' then break;
         namestr := GetValidStr3 (namestr, nstr, ['\']);
         if nstr<>'' then begin

           BoldTextOut (surface,
                        x -TextWidthAndHeight(surface.Canvas.Handle,nstr).cx{surface.Canvas.TextWidth(nstr)} div 2,
                        y + row * 12,
                        fcolor, bcolor, nstr);
           Inc (row);
         end;
      end;
   end;
var
   i, k, {line, sx, sy,}nX,nY, fcolor{,dx,dy, bcolor,idx}: integer;
   actor: TActor;
   {str,} uname: string;
//   dsurface: TDirectDrawSurface;
   d: TDirectDrawSurface;
   rc: TRect;
   infoMsg :String;
   ax,ay:integer;
   II:integer;
   boInc:Boolean;
   MoveShow:pTMoveHMShow;
   HpIdx:integer;
   WMainImages:TWMImages;
   nCorpIdx:Integer;
   sz: SIZE;
begin
   MSurface.Fill(0);
   if CurrentScene <> nil then
      CurrentScene.PlayScene (MSurface);

   if GetTickCount - m_dwFrameTime > 1000 then begin
      m_dwFrameTime := GetTickCount;
      m_dwDrawFrameCount := m_dwFrameCount;
      m_dwFrameCount := 0;
   end;
   Inc (m_dwFrameCount);

   if g_MySelf = nil then exit;
   //exit;
   if CurrentScene = PlayScene then begin
      with MSurface do begin
         //赣府困俊 眉仿 钎矫 秦具 窍绰 巴甸
         with PlayScene do begin
            for k:=0 to m_ActorList.Count-1 do begin
               actor := m_ActorList[k];
              
              //显示移动HP
              II:=0;
               with actor do begin
                 while TRUE do begin
                   if II >=m_nMoveHpList.Count then break;
                   MoveShow:=m_nMoveHpList.Items[II];
                   if MoveShow.boMoveHpShow then begin
                      for I:=0 to MoveShow.nMoveHpCount do begin
                        d := g_WMain99Images.GetCachedImage (MoveShow.nMoveHpList[I], ax, ay);
                        if d <> nil then
                          MSurface.Draw (ax+m_nSayX + MoveShow.nMoveHpEnd+I*8,
                                         ay+m_nSayY - MoveShow.nMoveHpEnd-30,
                                         d.ClientRect,
                                         d,
                                         TRUE);
                      end;
                      if (GetTickCount-MoveShow.dwMoveHpTick) > 30 then begin
                        MoveShow.dwMoveHpTick:=GetTickCount;
                        Inc(MoveShow.nMoveHpEnd);
                      end;
                      if MoveShow.nMoveHpEnd > 20 then begin
                        MoveShow.boMoveHpShow:=False;
                        m_nMoveHpList.Delete(II);
                        Dispose(MoveShow);
                      end else Inc(II);
                   end;
                 end;
               end;

               if actor.m_btHorse=0 then actor.m_nShowY:=6
               else actor.m_nShowY:=26;
               if g_wgInfo.boShowBlueMpLable and (not actor.m_boDeath) then begin   //显示蓝条
                  if actor.m_Abil.MaxMP > 0 then begin
                      Inc(actor.m_nShowY,2);
                      d := g_WMain3Images.Images[HEALTHBAR_BLACK];
                      if d <> nil then begin
                        MSurface.Draw (actor.m_nSayX - d.Width div 2, actor.m_nSayY - actor.m_nShowY, d.ClientRect, d, TRUE);
                        d := g_WMain99Images.Images[2];
                        if d <> nil then begin
                          rc := d.ClientRect;
                          rc.Right := Round((rc.Right-rc.Left) / actor.m_Abil.MaxMP * actor.m_Abil.MP);
                          MSurface.Draw (actor.m_nSayX - d.Width div 2, actor.m_nSayY - actor.m_nShowY, rc, d, TRUE);
                        end;
                      end;
                  end;
               end;

               if g_WgInfo.boShowRedHPLable  and (not actor.m_boDeath) and (not ((actor.m_wAppearance=71) and (actor.m_nCurrentAction=SM_WALK))) then begin; //显示血条
                    HpIdx:=HEALTHBAR_RED;
                    case actor.m_btRace of
                      50: begin
                            if not (actor.m_wAppearance in [33..50,52..69,72..75]) then begin
                              HpIdx:=3;
                              WMainImages:=g_WMain99Images; //npc
                            end else WMainImages:=Nil;
                          end;
                      12: begin
                            HpIdx:=4;
                            WMainImages:=g_WMain99Images; //大刀
                          end;
                      0:  begin
                            HpIdx:=HEALTHBAR_RED;
                            WMainImages:=g_WMain3Images;

                          end;
                      else begin
                            HpIdx:=HEALTHBAR_RED;
                            WMainImages:=g_WMain3Images;
                           end;
                    end;
                    if WMainImages<>Nil then begin
                      Inc(actor.m_nShowY,6);
                      if actor.m_noInstanceOpenHealth then
                         if GetTickCount - actor.m_dwOpenHealthStart > actor.m_dwOpenHealthTime then
                            actor.m_noInstanceOpenHealth := FALSE;
                      d := g_WMain3Images.Images[HEALTHBAR_BLACK];
                      if d <> nil then
                        MSurface.Draw (actor.m_nSayX - d.Width div 2, actor.m_nSayY - actor.m_nShowY, d.ClientRect, d, TRUE);

                      d := WMainImages.Images[HpIdx];
                      if d=Nil then d := g_WMain3Images.Images[HEALTHBAR_RED];
                      if d <> nil then begin
                         rc := d.ClientRect;
                         if actor.m_Abil.MaxHP > 2 then
                            rc.Right := Round((rc.Right-rc.Left) / actor.m_Abil.MaxHP * actor.m_Abil.HP);

                          MSurface.Draw (actor.m_nSayX - d.Width div 2, actor.m_nSayY - actor.m_nShowY, rc, d, TRUE);
                      end;
                    end;
                 end;


               SetBkMode (Canvas.Handle, TRANSPARENT);

          //显示人物血量(数字显示)
          if g_wgInfo.boShowHPNumber  and (actor.m_Abil.MaxHP > 1) and (not actor.m_boDeath) and (actor.m_btRace <> 50) then begin
            SetBkMode(Canvas.Handle, TRANSPARENT);
            Inc(actor.m_nShowY,12);
            infoMsg := IntToStr(Actor.m_Abil.HP) + '/' + IntToStr(Actor.m_Abil.MaxHP);
            //显示等级
            if (Actor.m_btRace = 0) and g_WgInfo.boShowLevel  then begin
              if infoMsg <> '' then infoMsg := infoMsg;
              infoMsg := '(Lv:' + IntToStr(Actor.m_Abil.Level) + ') ' + infoMsg;
            end;
           // BoldTextOut(MSurface, Actor.m_nSayX - TextWidthAndHeight(Canvas.Handle, infoMsg).cx div 2, Actor.m_nSayY - 21, clWhite, clBlack, infoMsg);
           BoldTextOut (MSurface,actor.m_nSayX -TextWidthAndHeight(Canvas.Handle,infoMsg).cx div 2 ,actor.m_nSayY - actor.m_nShowY, clWhite, clBlack,infoMsg );

            Canvas.Release;
          end;

               //显示人物名称
               if (g_wginfo.boShowName)  and (actor.m_btRace in [0,50]) and (g_FocusCret<>actor) and (not ((actor.m_wAppearance=71) and (actor.m_nCurrentAction=SM_WALK))) then begin
                SetBkMode (Canvas.Handle, TRANSPARENT);
                  if actor=g_MySelf then begin
                    if not g_boSelectMyself then begin
                      if g_wginfo.boShowAllName  then uname:=actor.m_sDescUserName+ '\' +actor.m_sUserName
                      else uname := actor.m_sUserName;
                      NameTextOut (MSurface,
                                   actor.m_nSayX,
                                   actor.m_nSayY + 30,
                                   actor.m_nNameColor, clBlack,
                                   uname);
                    end;
                  end else begin
                    if g_wginfo.boShowAllName  then uname:=actor.m_sDescUserName+ '\' +actor.m_sUserName
                    else uname := actor.m_sUserName;
                    NameTextOut (MSurface,
                                 actor.m_nSayX,
                                 actor.m_nSayY + 30,
                                 actor.m_nNameColor, clBlack,
                                 uname);
                  end;
                  Canvas.Release;
               end;
               Canvas.Release;
            end;
         end;



         //付快胶肺 措绊 乐绰 某腐磐 捞抚 唱坷扁
         SetBkMode (Canvas.Handle, TRANSPARENT);
         if (g_FocusCret <> nil) and PlayScene.IsValidActor (g_FocusCret) then begin
            //if FocusCret.Grouped then uname := char(7) + FocusCret.UserName
            //else
            uname := g_FocusCret.m_sDescUserName + '\' + g_FocusCret.m_sUserName;
            NameTextOut (MSurface,
                      g_FocusCret.m_nSayX, // - Canvas.TextWidth(uname) div 2,
                      g_FocusCret.m_nSayY + 30,
                      g_FocusCret.m_nNameColor, clBlack,
                      uname);
         end;
         if g_boSelectMyself then begin
            uname := g_MySelf.m_sDescUserName + '\' + g_MySelf.m_sUserName;
            NameTextOut (MSurface,
                      g_MySelf.m_nSayX, // - Canvas.TextWidth(uname) div 2,
                      g_MySelf.m_nSayY + 30,
                      g_MySelf.m_nNameColor, clBlack,
                      uname);
         end;

         Canvas.Font.Color := clWhite;

                  //显示角色说话文字
         with PlayScene do begin
            for k:=0 to m_ActorList.Count-1 do begin
               actor := m_ActorList[k];
               if actor.m_SayingArr[0] <> '' then begin
                  if GetTickCount - actor.m_dwSayTime < 4 * 1000 then begin
                     for i:=0 to actor.m_nSayLineCount - 1 do
                        if actor.m_boDeath then
                           BoldTextOut (MSurface,
                                     actor.m_nSayX - (actor.m_SayWidthsArr[i] div 2),
                                     actor.m_nSayY - (actor.m_nSayLineCount*16) + i*14,
                                     clGray, clBlack,
                                     actor.m_SayingArr[i])
                        else
                           BoldTextOut (MSurface,
                                     actor.m_nSayX - (actor.m_SayWidthsArr[i] div 2),
                                     actor.m_nSayY - (actor.m_nSayLineCount*16) + i*14,
                                     clWhite, clBlack,
                                     actor.m_SayingArr[i]);
                  end else
                     actor.m_SayingArr[0] := '';
               end;
            end;
         end;

         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(SendCount) + ' : ' + IntToStr(ReceiveCount));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, 'HITSPEED=' + IntToStr(Myself.HitSpeed));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, 'DupSel=' + IntToStr(DupSelection));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(LastHookKey));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack,
         //             IntToStr(
         //                int64(GetTickCount - LatestSpellTime) - int64(700 + MagicDelayTime)
         //                ));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack, IntToStr(PlayScene.EffectList.Count));
         //BoldTextOut (MSurface, 0, 0, clWhite, clBlack,
         //                  IntToStr(Myself.XX) + ',' + IntToStr(Myself.m_nCurrY) + '  ' +
         //                  IntToStr(Myself.ShiftX) + ',' + IntToStr(Myself.ShiftY));

         //System Message
         //甘狼 惑怕 钎矫 (烙矫 钎矫)
         if (g_nAreaStateValue and $04) <> 0 then begin
            BoldTextOut (MSurface, 0, 0, clWhite, clBlack, '攻城区域');
         end;
         Canvas.Release;


         //甘狼 惑怕 钎矫
         k := 0;
         for i:=0 to 15 do begin
            if g_nAreaStateValue and ($01 shr i) <> 0 then begin
               d := g_WMainImages.Images[AREASTATEICONBASE + i];
               if d <> nil then begin
                  k := k + d.Width;
                  MSurface.Draw (SCREENWIDTH-k, 0, d.ClientRect, d, TRUE);
               end;
            end;
         end;

      end;
   end;
end;


//显示左上角信息文字
procedure TDrawScreen.DrawScreenTop (MSurface: TDirectDrawSurface);
var
   i, sx, sy: integer;
begin
   if g_MySelf = nil then exit;

   if CurrentScene = PlayScene then begin
      with MSurface do begin
         SetBkMode (Canvas.Handle, TRANSPARENT);
         if m_SysMsgList.Count > 0 then begin
            sx := 30;
            sy := 40;
            for i:=0 to m_SysMsgList.Count-1 do begin
               BoldTextOut (MSurface, sx, sy, clGreen, clBlack, m_SysMsgList[i]);
               inc (sy, 16);
            end;
            if GetTickCount - longword(m_SysMsgList.Objects[0]) >= 3000 then
               m_SysMsgList.Delete (0);
         end;
         Canvas.Release;
      end;
   end;
end;

procedure TDrawScreen.DrawHint (MSurface: TDirectDrawSurface);
ResourceString
  sTest1  = '负重：%d/%d 金币：%d 鼠标：%d:%d(%d:%d) 目标: %s(%d/%d) 锁定目标：%s(%d/%d)';
  sTest2  = '%s (%d/%d)%d';
var
   d: TDirectDrawSurface;
   i, hx, hy, old: integer;
   str: string;
    infoMsg:String;
   sName,sName2:String;
   nHp,nMp,nHp2,nMp2:Integer;
   rc: TRect;
   oldcolor: TColor;
   HintBack: TDirectDrawSurface;
begin
   hx:=0;
   hy:=0;//Jacky
   if HintList.Count > 0 then begin
      d := g_WMainImages.Images[394];
      if d <> nil then begin
         if HintWidth > d.Width then HintWidth := d.Width;
         if HintHeight > d.Height then HintHeight := d.Height;
         if HintX + HintWidth > SCREENWIDTH then hx := SCREENWIDTH - HintWidth
         else hx := HintX;
         if HintY < 0 then hy := 0
         else hy := HintY;
         if hx < 0 then hx := 0;

         DrawBlendEx (MSurface, hx, hy, d, 0, 0, HintWidth, HintHeight, 0);
      end;
   end;
   with MSurface do begin
      SetBkMode (Canvas.Handle, TRANSPARENT);
      if HintList.Count > 0 then begin
         Canvas.Font.Color := HintColor;
         for i:=0 to HintList.Count-1 do begin
            Canvas.TextOut (hx+4, hy+3+(Canvas.TextHeight('A')+1)*i, HintList[i]);
         end;
      end;

      if g_MySelf <> nil then begin

                //显示持久
         if g_wginfo.boShowDura then begin
            SetBkMode (Canvas.Handle, TRANSPARENT);
            for I:=Low(g_UseItems) to High(g_UseItems) do begin
              infoMsg:=UseItem[I]+'：';
              if g_UseItems[I].S.Name<>'' then begin
                infoMsg:=infoMsg+Format(sTest2,[g_UseItems[I].S.Name,
                                        g_UseItems[I].Dura,
                                        g_UseItems[I].DuraMax,
                                        g_UseItems[I].MakeIndex]);
              end;
              BoldTextOut (MSurface,5,100+I*18, clWhite, clBlack,infoMsg );
            end;
            //Canvas.Release;
         end;


         //显示人物血量
         //BoldTextOut (MSurface, 15, SCREENHEIGHT - 120, clWhite, clBlack, IntToStr(g_MySelf.m_Abil.HP) + '/' + IntToStr(g_MySelf.m_Abil.MaxHP));
         //人物MP值
         //BoldTextOut (MSurface, 115, SCREENHEIGHT - 120, clWhite, clBlack, IntToStr(g_MySelf.m_Abil.MP) + '/' + IntToStr(g_MySelf.m_Abil.MaxMP));
         //人物经验值
         //BoldTextOut (MSurface, 655, SCREENHEIGHT - 55, clWhite, clBlack, IntToStr(g_MySelf.Abil.Exp) + '/' + IntToStr(g_MySelf.Abil.MaxExp));
         //人物背包重量
         //BoldTextOut (MSurface, 655, SCREENHEIGHT - 25, clWhite, clBlack, IntToStr(g_MySelf.Abil.Weight) + '/' + IntToStr(g_MySelf.Abil.MaxWeight));


         if g_boShowGreenHint then begin
          str:= 'Time: ' + TimeToStr(Time) +
                ' Exp: ' + IntToStr(g_MySelf.m_Abil.Exp) + '/' + IntToStr(g_MySelf.m_Abil.MaxExp) +
                ' Weight: ' + IntToStr(g_MySelf.m_Abil.Weight) + '/' + IntToStr(g_MySelf.m_Abil.MaxWeight) +
                ' ' + g_sGoldName + ': ' + IntToStr(g_MySelf.m_nGold) +
                ' Cursor: ' + IntToStr(g_nMouseCurrX) + ':' + IntToStr(g_nMouseCurrY) + '(' + IntToStr(g_nMouseX) + ':' + IntToStr(g_nMouseY) + ')';
          if g_FocusCret <> nil then begin
            str:= str + ' Target: ' + g_FocusCret.m_sUserName + '(' + IntToStr(g_FocusCret.m_Abil.HP) + '/' + IntToStr(g_FocusCret.m_Abil.MaxHP) + ')';
          end else begin
            str:= str + ' Target: -/-';
          end;
          

          BoldTextOut (MSurface, 10, 0, clLime , clBlack, str);

          str:='';
         end;

         if g_boCheckBadMapMode then begin
              str := IntToStr(m_dwDrawFrameCount) +  ' '
              + '  Mouse ' + IntToStr(g_nMouseX) + ':' + IntToStr(g_nMouseY) + '(' + IntToStr(g_nMouseCurrX) + ':' + IntToStr(g_nMouseCurrY) + ')'
              + '  HP' + IntToStr(g_MySelf.m_Abil.HP) + '/' + IntToStr(g_MySelf.m_Abil.MaxHP)
              + '  D0 ' + IntToStr(g_nDebugCount)
              + ' D1 ' + IntToStr(g_nDebugCount1) + ' D2 '
              + IntToStr(g_nDebugCount2);
              BoldTextOut (MSurface, 10, 0, clWhite, clBlack, str);
         end;

         //old := Canvas.Font.Size;
         //Canvas.Font.Size := 8;
         //BoldTextOut (MSurface, 8, SCREENHEIGHT-42, clWhite, clBlack, ServerName);

         if g_boShowWhiteHint then begin
         if g_MySelf.m_nGameGold > 10 then begin
           BoldTextOut (MSurface, 8, SCREENHEIGHT-42, clWhite, clBlack, g_sGameGoldName + ' ' + IntToStr(g_MySelf.m_nGameGold));
         end else begin
           BoldTextOut (MSurface, 8, SCREENHEIGHT-42, clRed, clBlack, g_sGameGoldName + ' ' + IntToStr(g_MySelf.m_nGameGold));
         end;
         if g_MySelf.m_nGamePoint > 10 then begin
           BoldTextOut (MSurface, 8, SCREENHEIGHT-58, clWhite, clBlack, g_sGamePointName + ' ' + IntToStr(g_MySelf.m_nGamePoint));
         end else begin
           BoldTextOut (MSurface, 8, SCREENHEIGHT-58, clRed, clBlack, g_sGamePointName + ' ' + IntToStr(g_MySelf.m_nGamePoint));
         end;

         //鼠标所指坐标
         BoldTextOut (MSurface, 115, SCREENHEIGHT - 40, clWhite, clBlack, IntToStr(g_nMouseCurrX) + ':' + IntToStr(g_nMouseCurrY));
         //显示时间
         BoldTextOut (MSurface, 410, SCREENHEIGHT - 147, clWhite, clBlack, FormatDateTime('dddddd hh:mm:ss ampm', Now));
         end;

//         BoldTextOut (MSurface, 8, SCREENHEIGHT- 74, clWhite, clBlack, format('AllocMemCount:%d',[AllocMemCount]));
//         BoldTextOut (MSurface, 8, SCREENHEIGHT- 90, clWhite, clBlack, format('AllocMemSize:%d',[AllocMemSize div 1024]));

         BoldTextOut (MSurface, 8, SCREENHEIGHT-20, clWhite, clBlack, g_sMapTitle + ' ' + IntToStr(g_MySelf.m_nCurrX) + ':' + IntToStr(g_MySelf.m_nCurrY));
         //Canvas.Font.Size := old;
      end;
      //BoldTextOut (MSurface, 10, 20, clWhite, clBlack, IntToStr(DebugCount) + ' / ' + IntToStr(DebugCount1));
      Canvas.Release;
   end;
end;


end.
