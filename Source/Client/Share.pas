unit Share;

interface

const
  RUNLOGINCODE       = 0; //������Ϸ״̬��,Ĭ��Ϊ0 ����Ϊ 9

  STDCLIENT          = 0;
  RMCLIENT           = 99;
  CLIENTTYPE         = RMCLIENT; //��ͨ��Ϊ0 ,99 Ϊ����ͻ���

  RMCLIENTTITLE      = 'ktest';

  MAXLEFT2 = 10;
  MAXTOP2 = 8;

  DEBUG         = 0;
  SWH800        = 0;
  SWH1024       = 1;
  SWH           = SWH800;

  CUSTOMLIBFILE = 0; //�Զ���ͼ��λ��

{$IF SWH = SWH800}
   SCREENWIDTH = 800;
   SCREENHEIGHT = 600;
{$ELSEIF SWH = SWH1024}
   SCREENWIDTH = 1024;
   SCREENHEIGHT = 768;
{$IFEND}

   MAPSURFACEWIDTH = SCREENWIDTH;
   MAPSURFACEHEIGHT = SCREENHEIGHT- 155;

   WINLEFT = 60;
   WINTOP  = 60;
   WINRIGHT = SCREENWIDTH-60;
   BOTTOMEDGE = SCREENHEIGHT-30;  // Bottom WINBOTTOM

   MAPDIR             = 'Map\'; //��ͼ�ļ�����Ŀ¼
  CONFIGFILE = 'Config\%s.ini';
  INIFileDir = '.\Config\';
  FriendListFile = 'Friend.txt';
  BlackListFile = 'HeiMingDan.txt';
  AssistantDir = 'Assistant.ini';
  ItemUntieDir = 'Untie.txt';
  JsDefInfo = '.\Config\JsDefInfo\';
  ItemFiltrateDir = 'Filtrate.txt';
  MonHintDir = 'MonHint.txt';
  BossHintDir = 'BossHint.txt';
  SaveIniFileDir = '.\Config\%s_%s\';

{$IF CUSTOMLIBFILE = 1}
   EFFECTIMAGEDIR     = 'Graphics\Effect\';
   MAINIMAGEFILE      = 'Graphics\FrmMain\Main.wil';
   MAINIMAGEFILE2     = 'Graphics\FrmMain\Main2.wil';
   MAINIMAGEFILE3     = 'Graphics\FrmMain\Main3.wil';
{$ELSE}
   MAINIMAGEFILE      = 'Data\Prguse.wil';
   MAINIMAGEFILE2     = 'Data\Prguse2.wil';
   MAINIMAGEFILE3     = 'Data\Prguse3.wil';
   EFFECTIMAGEDIR     = 'Data\';
{$IFEND}

   CHRSELIMAGEFILE    = 'Data\ChrSel.wil';
   MINMAPIMAGEFILE    = 'Data\mmap.wil';
   TITLESIMAGEFILE    = 'Data\Tiles.wil';
   SMLTITLESIMAGEFILE = 'Data\SmTiles.wil';
   HUMWINGIMAGESFILE  = 'Data\HumEffect.wil';
   MAGICONIMAGESFILE  = 'Data\MagIcon.wil';

   HUMIMGIMAGESFILE   = 'Data\Hum.wil';
   HUMIMGIMAGESFILE1 = 'Data\Hum%d.wil';
   
   HAIRIMGIMAGESFILE  = 'Data\Hair.wil';

   WEAPONIMAGESFILE   = 'Data\Weapon.wil';
   WEAPONIMAGESFILE1 = 'Data\Weapon%d.wil';

   NPCIMAGESFILE      = 'Data\Npc.wil';
   MAGICIMAGESFILE    = 'Data\Magic.wil';
   MAGIC2IMAGESFILE   = 'Data\Magic2.wil';
   EVENTEFFECTIMAGESFILE = EFFECTIMAGEDIR + 'Event.wil';
   BAGITEMIMAGESFILE   = 'Data\Items.wil';
   STATEITEMIMAGESFILE = 'Data\StateItem.wil';
   DNITEMIMAGESFILE    = 'Data\DnItems.wil';
   OBJECTIMAGEFILE     = 'Data\Objects.wil';
   OBJECTIMAGEFILE1    = 'Data\Objects%d.wil';
   MONIMAGEFILE        = 'Data\Mon%d.wil';

   DRAGONIMAGEFILE     = 'Data\Dragon.wil';
   EFFECTIMAGEFILE     = 'Data\Effect.wil';
   DRAGONIMGESFILE     = 'Data\Dragon.wil';


   
  // MONIMAGEFILEEX      = 'Graphics\Monster\%d.wil';
   //MONPMFILE           = 'Graphics\Monster\%d.pm';
   GAMRPIANIMAGEFILE   = 'Data\GamePlan.wil';

   {
   MAXX = 40;
   MAXY = 40;
   }
  MAXX = SCREENWIDTH div 20;
  MAXY = SCREENWIDTH div 20;

  DEFAULTCURSOR = 0; //ϵͳĬ�Ϲ��
  IMAGECURSOR   = 1; //ͼ�ι��

  USECURSOR     = DEFAULTCURSOR; //ʹ��ʲô���͵Ĺ��

  MAXBAGITEMCL = 52;
  MAXFONT = 8;
  ENEMYCOLOR = 69;

implementation

end.
