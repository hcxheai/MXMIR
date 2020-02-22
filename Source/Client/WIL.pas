unit WIL;


interface

uses
  Windows, Classes, Graphics, SysUtils, DXDraws, DXClass,DirectX, DIB, wmUtil, HUtil32;

type
  TLibType = (ltLoadBmp, ltLoadMemory, ltLoadMunual, ltUseCache);


  TBmpImage = record
    Bmp           :TBitmap;
    dwLatestTime  :LongWord;
  end;
  pTBmpImage = ^TBmpImage;

   TBmpImageArr  = array[0..MaxListSize div 4] of TBmpImage;
   TDxImageArr   = array[0..MaxListSize div 4] of TDxImage;
   PTBmpImageArr = ^TBmpImageArr;
   PTDxImageArr  = ^TDxImageArr;

   TWMImages = class(TComponent)
   private
      FFileName: String;              //0x24
      FImageCount: integer;           //0x28
      FLibType: TLibType;             //0x2C
      FDxDraw: TDxDraw;               //0x30
      FDDraw: TDirectDraw;            //0x34
     // FMaxMemorySize: integer;        //0x38
      btVersion:Byte;                 //0x3C
      m_bt458    :Byte;
      FAppr:Word;
      FBitFormat:TPixelFormat;
      FBytesPerPixels:byte;
      
      procedure LoadAllData;
      procedure LoadIndex (idxfile: string);
      procedure LoadDxImage (position: integer; pdximg: PTDxImage);
      procedure LoadBmpImage (position: integer; pbmpimg: PTBmpImage);
      procedure FreeOldMemorys;
      function  FGetImageSurface (index: integer): TDirectDrawSurface;
      procedure FSetDxDraw (fdd: TDxDraw);
      procedure FreeOldBmps;
      function  FGetImageBitmap (index: integer): TBitmap;
   protected
      //MemorySize: integer;      //0x3C      ?
      lsDib: TDib;              //0x40
      lsBitmap:TBitmap;
      m_dwMemChecktTick: LongWord;   //0x44
   public
      m_ImgArr    :pTDxImageArr;     //0x48
      m_BmpArr    :pTBmpImageArr;    //0x4C
      m_IndexList :TList;         //0x50
      m_FileStream: TFileStream;      //0x54
      MainPalette: TRgbQuads;
      constructor Create (AOwner: TComponent); override;
      destructor Destroy; override;

      procedure Initialize;
      procedure Finalize;
      procedure ClearCache;
      procedure LoadPalette;
      procedure FreeBitmap (index: integer);
      function  GetImage (index: integer; var px, py: integer): TDirectDrawSurface;
      function  GetCachedImage (index: integer; var px, py: integer): TDirectDrawSurface;
      function  GetCachedSurface (index: integer): TDirectDrawSurface;
      function  GetCachedBitmap (index: integer): TBitmap;
      procedure DrawZoom (paper: TCanvas; x, y, index: integer; zoom: Real);
      procedure DrawZoomEx (paper: TCanvas; x, y, index: integer; zoom: Real; leftzero: Boolean);
      property Images[index: integer]: TDirectDrawSurface read FGetImageSurface;
    	property Bitmaps[Index: Integer]: TBitmap read FGetImageBitmap;
      property DDraw: TDirectDraw read FDDraw write FDDraw;
   published
      property FileName: string read FFileName write FFileName;
      property ImageCount: integer read FImageCount;
      property DxDraw: TDxDraw read FDxDraw write FSetDxDraw;
      property LibType: TLibType read FLibType write FLibType;
    //  property MaxMemorySize: integer read FMaxMemorySize write FMaxMemorySize;
      property Appr:Word read FAppr write FAppr;
   end;

function TDXDrawRGBQuadsToPaletteEntries(const RGBQuads: TRGBQuads; AllowPalette256: Boolean): TPaletteEntries;
procedure ChangeDIBPixelFormat(adib:TDIB;pf:TPixelFormat);
procedure Register;


implementation

//uses
//   ClMain;//¼ÇÂ¼µ÷ÊÔÐÅÏ¢


procedure Register;
begin
   RegisterComponents('MirGame', [TWmImages]);
end;

procedure ChangeDIBPixelFormat(adib:TDIB;pf:TPixelFormat);
begin
     if pf=pf8bit then begin
       with aDib.PixelFormat do begin
         RBitMask:=$FF0000;
         GBitMask:=$00FF00;
         BBitMask:=$0000FF;
       end;
       aDib.BitCount:=8;
     end else if pf=pf16bit then begin
       with aDib.PixelFormat do begin  //565¸ñÊ½
         RBitMask:=$F800;
         GBitMask:=$07E0;
         BBitMask:=$001F;
       end;
       aDib.BitCount:=16;
     end else if pf=pf24bit then begin
        with aDib.PixelFormat do begin
         RBitMask:=$FF0000;
         GBitMask:=$00FF00;
         BBitMask:=$0000FF;
       end;
       aDib.BitCount:=24;
     end else if pf=pf32Bit then begin
       with aDib.PixelFormat do begin
         RBitMask:=$FF0000;
         GBitMask:=$00FF00;
         BBitMask:=$0000FF;
       end;
       aDib.BitCount:=32;
     end;
end;

constructor TWMImages.Create (AOwner: TComponent);
begin
   inherited Create (AOwner);
   FFileName := '';
   FLibType := ltLoadBmp;
   FImageCount := 0;
   //MemorySize := 0;//?
  // FMaxMemorySize := 1024*1000; //1M

   FDDraw := nil;
   FDxDraw := nil;
   m_FileStream := nil;
   m_ImgArr := nil;
   m_BmpArr := nil;
   m_IndexList := TList.Create;
   lsDib := TDib.Create;
   lsDib.BitCount := 8;
   //BmpList := TList.Create;  //Bmp¿ëÀ¸·Î »ç¿ëÇÒ ¶§¹® »ç¿ë

   lsBitmap:=TBitmap.create;
   lsBitmap.Handle:=0;
  //lsBitmap.PixelFormat:=ColorDeep;

   m_dwMemChecktTick := GetTickCount;
   btVersion:=0;
   m_bt458:=0;   
end;

destructor TWMImages.Destroy;
begin
   m_IndexList.Free;
  lsBitmap.Free;
   if m_FileStream <> nil then m_FileStream.Free;
   lsDib.Free;
   inherited Destroy;
end;

procedure TWMImages.Initialize;
var
  Idxfile: String;
  Header :TWMImageHeader;
begin
   if not (csDesigning in ComponentState) then begin
      if FFileName = '' then begin
        // raise Exception.Create ('FileName not assigned..');
         exit;
      end;
      if (LibType <> ltLoadBmp) and (FDDraw = nil) then begin
       //  raise Exception.Create ('DDraw not assigned..');
         exit;
      end;
      if FileExists (FFileName) then begin
         if m_FileStream = nil then
            m_FileStream := TFileStream.Create (FFileName, fmOpenRead or fmShareDenyNone);
         m_FileStream.Read (Header, SizeOf(TWMImageHeader));

         if header.VerFlag = 0 then begin
           btVersion:=1;
           m_FileStream.Seek(-4,soFromCurrent);
         end;
         FImageCount := Header.ImageCount;

           if header.ColorCount=256 then begin
             FBitFormat:=pf8Bit; FBytesPerPixels:=1;
           end else if header.ColorCount=65536 then begin
              FBitFormat:=pf16bit; FBytesPerPixels:=2;
           end else if header.colorcount=16777216 then begin
              FBitFormat:=pf24Bit; FBytesPerPixels:=4;
           end else if header.ColorCount>16777216 then begin
              FBitFormat:=pf32Bit; FBytesPerPixels:=4;
           end;
           ChangeDIBPixelFormat(lsDIB,FBitFormat);

         if LibType = ltLoadBmp then begin
            m_BmpArr := AllocMem (SizeOf(TBmpImage) * FImageCount);
            if m_BmpArr = nil then
               raise Exception.Create (self.Name + ' BmpArr = nil');
         end else begin
            m_ImgArr:=AllocMem(SizeOf(TDxImage) * FImageCount);
            if m_ImgArr = nil then
               raise Exception.Create (self.Name + ' ImgArr = nil');
         end;

         idxfile := ExtractFilePath(FFileName) + ExtractFileNameOnly(FFileName) + '.WIX';
         LoadPalette;
         if LibType = ltLoadMemory then
            LoadAllData
         else begin
            LoadIndex (idxfile);
         end;
      end else begin
//         MessageDlg (FFileName + ' Cannot find file.', mtWarning, [mbOk], 0);
      end;
   end;
end;

procedure TWMImages.Finalize;
var
   i: integer;
begin
   for i:=0 to FImageCount-1 do begin
      if m_ImgArr[i].Surface <> nil then begin
         m_ImgArr[i].Surface.Free;
         m_ImgArr[i].Surface := nil;
      end;
   end;
   if m_FileStream <> nil then begin
      m_FileStream.Free;
      m_FileStream := nil;
   end;
end;

function TDXDrawRGBQuadsToPaletteEntries(const RGBQuads: TRGBQuads;
  AllowPalette256: Boolean): TPaletteEntries;
var
  Entries: TPaletteEntries;
  dc: THandle;
  i: Integer;
begin
  Result := RGBQuadsToPaletteEntries(RGBQuads);

  if not AllowPalette256 then
  begin
    dc := GetDC(0);
    GetSystemPaletteEntries(dc, 0, 256, Entries);
    ReleaseDC(0, dc);

    for i:=0 to 9 do
      Result[i] := Entries[i];

    for i:=256 - 10 to 255 do
      Result[i] := Entries[i];
  end;

  for i:=0 to 255 do
    Result[i].peFlags := D3DPAL_READONLY;
end;

//Cache¾øÀÌ ÇÑ²¨¹ø¿¡ ·ÎµùÇÔ.
procedure TWMImages.LoadAllData;
var
   i: integer;
   imgi: TWMImageInfo;
   dib: TDIB;
   dximg: TDxImage;
begin
   dib := TDIB.Create;
   for i:=0 to FImageCount-1 do begin
   if btVersion <> 0 then m_FileStream.Read (imgi, sizeof(TWMImageInfo) - 4)
   else m_FileStream.Read (imgi, sizeof(TWMImageInfo));

      dib.Width := imgi.nWidth;
      dib.Height := imgi.nHeight;
      ChangeDIBPixelFormat(dib,FBitFormat);
      dib.ColorTable := MainPalette;
      dib.UpdatePalette;
      m_FileStream.Read (dib.PBits^, imgi.nWidth * imgi.nHeight * FBytesPerPixels);

      dximg.nPx := imgi.px;
      dximg.nPy := imgi.py;
      dximg.surface := TDirectDrawSurface.Create (FDDraw);
      dximg.surface.SystemMemory := TRUE;
      dximg.surface.SetSize (imgi.nWidth, imgi.nHeight);
      dximg.surface.Canvas.Draw (0, 0, dib);
      dximg.surface.Canvas.Release;
      dib.Clear; //FreeImage;

      dximg.surface.TransparentColor := 0;
      m_ImgArr[i] := dximg;
   end;
   dib.Free;
end;


procedure TWMImages.LoadPalette;
begin
   if btVersion <> 0 then
     m_FileStream.Seek (sizeof(TWMImageHeader) - 4, 0)
   else
     m_FileStream.Seek (sizeof(TWMImageHeader), 0);
     
   m_FileStream.Read (MainPalette, sizeof(TRgbQuad) * 256); //
end;

procedure TWMImages.LoadIndex (idxfile: string);
var
   fhandle, i, value: integer;
   header: TWMIndexHeader;
  // pidx: PTWMIndexInfo;
   pvalue: PInteger;
begin
   m_IndexList.Clear;
   if FileExists (idxfile) then begin
      fhandle := FileOpen (idxfile, fmOpenRead or fmShareDenyNone);
      if fhandle > 0 then begin
         if btVersion <> 0 then
           FileRead (fhandle, header, sizeof(TWMIndexHeader) - 4)
         else
           FileRead (fhandle, header, sizeof(TWMIndexHeader));
           
         GetMem (pvalue, 4*header.IndexCount);
         FileRead (fhandle, pvalue^, 4*header.IndexCount);
         if header.IndexCount > 0 then //20080629
         for i:=0 to header.IndexCount-1 do begin
            value := PInteger(integer(pvalue) + 4*i)^;
            m_IndexList.Add (pointer(value));
         end;
         FreeMem (pvalue);
         FileClose (fhandle);
      end;
   end;
end;

{----------------- Private Variables ---------------------}

function  TWMImages.FGetImageSurface (index: integer): TDirectDrawSurface;
begin
   Result := nil;
   if LibType = ltUseCache then begin
      Result := GetCachedSurface (index);
   end else
      if LibType = ltLoadMemory then begin
         if (index >= 0) and (index < ImageCount) then
            Result := m_ImgArr[index].Surface;
      end;

end;

function  TWMImages.FGetImageBitmap (index: integer): TBitmap;
begin
   Result:=nil;
   if LibType <> ltLoadBmp then exit;
   Result := GetCachedBitmap (index);
end;

procedure TWMImages.FSetDxDraw (fdd: TDxDraw);
begin
   FDxDraw := fdd;
end;

// *** DirectDrawSurface Functions

procedure TWMImages.LoadDxImage (position: integer; pdximg: PTDxImage);
var
   imginfo: TWMImageInfo;
   DBits: PByte;
begin

   m_FileStream.Seek (position, 0);
   if btVersion <> 0 then m_FileStream.Read (imginfo, SizeOf(TWMImageInfo)-4)
   else m_FileStream.Read (imginfo, SizeOf(TWMImageInfo));

  // if g_boUseDIBSurface then begin //DIB
      //·ÇÈ«ÆÁÊ±
      try
      lsDib.Clear;
      ChangeDIBPixelFormat(lsDIB,FBitFormat);
      lsDib.Width := imginfo.nWidth;
      lsDib.Height := imginfo.nHeight;
      except
      end;
      lsDib.ColorTable := MainPalette;
      lsDib.UpdatePalette;
      DBits := lsDib.PBits;
      m_FileStream.Read (DBits^, imginfo.nWidth * imgInfo.nHeight * FBytesPerPixels);
      pdximg.nPx := imginfo.px;
      pdximg.nPy := imginfo.py;
      pdximg.surface := TDirectDrawSurface.Create (FDDraw);
      pdximg.surface.SystemMemory := TRUE;
      pdximg.surface.SetSize (imginfo.nWidth, imginfo.nHeight);
      pdximg.surface.Canvas.Draw (0, 0, lsDib);
      pdximg.surface.Canvas.Release;
      pdximg.surface.TransparentColor := 0;  //Í¸Ã÷µÄÉ«
   {end else begin //
      slen  := WidthBytes(imginfo.nWidth);
      GetMem (PSrc, slen * imgInfo.nHeight * FBytesPerPixels);//°ÑÍ¼Æ¬×ÊÁÏÐ´ÈëÄÚ´æ
      SBits := PSrc;
      m_FileStream.Read (PSrc^, slen * imgInfo.nHeight * FBytesPerPixels);
      try
         pdximg.surface := TDirectDrawSurface.Create (FDDraw);
         pdximg.surface.SystemMemory := TRUE;
         pdximg.surface.SetSize (slen, imginfo.nHeight);
         pdximg.nPx := imginfo.px;
         pdximg.nPy := imginfo.py;
         ddsd.dwSize := SizeOf(ddsd);

         pdximg.surface.Lock (TRect(nil^), ddsd);
         DBits := ddsd.lpSurface;
         for n:=imginfo.nHeight - 1 downto 0 do begin
            SBits := PByte (Integer(PSrc) + slen * n * FBytesPerPixels);
            Move(SBits^, DBits^, slen* FBytesPerPixels);
            Inc (integer(DBits), ddsd.lPitch);
         end;
         pdximg.surface.TransparentColor := 0; //Í¸Ã÷µÄÉ«
      finally
        pdximg.surface.UnLock();
        FreeMem (PSrc);
      end;
   end; }
end;




//ÖØÔØ»ò¶ÁÈ¡
procedure TWMImages.LoadBmpImage (position: integer; pbmpimg: PTBmpImage);
var
   imginfo: TWMImageInfo;
   DBits: PByte;
begin
   m_FileStream.Seek (position, 0);
   m_FileStream.Read (imginfo, sizeof(TWMImageInfo)-4);
 ChangeDIBPixelFormat(lsDib,FBitFormat);
   lsDib.Width := imginfo.nWidth;
   lsDib.Height := imginfo.nHeight;
   lsDib.ColorTable := MainPalette;
   lsDib.UpdatePalette;
   DBits := lsDib.PBits;
   m_FileStream.Read (DBits^, imginfo.nWidth *imgInfo.nHeight * FBytesPerPixels); //

   pbmpimg.bmp := TBitmap.Create;
   pbmpimg.bmp.Width := lsDib.Width;
   pbmpimg.bmp.Height := lsDib.Height;
   pbmpimg.bmp.Canvas.Draw (0, 0, lsDib);
   lsDib.Clear;
end;


procedure TWMImages.ClearCache;
var
   i: integer;
begin
   for i:=0 to ImageCount - 1 do begin
      if m_ImgArr[i].Surface <> nil then begin
         m_ImgArr[i].Surface.Free;
         m_ImgArr[i].Surface := nil;
      end;
   end;
   //MemorySize := 0;
end;

function  TWMImages.GetImage (index: integer; var px, py: integer): TDirectDrawSurface;
begin
   if (index >= 0) and (index < ImageCount) then begin
      px := m_ImgArr[index].nPx;
      py := m_ImgArr[index].nPy;
      Result := m_ImgArr[index].surface;
   end else
      Result := nil;
end;

{--------------- BMP functions ----------------}

procedure TWMImages.FreeOldBmps;
var
   i, n, ntime, curtime: integer;
begin
   n := -1;
   ntime := 0;
   //limit := FMaxMemorySize * 9 div 10;
   for i:=0 to ImageCount-1 do begin
      curtime := GetTickCount;
      if m_BmpArr[i].Bmp <> nil then begin
         if GetTickCount - m_BmpArr[i].dwLatestTime > 5 * 1000 then begin
            m_BmpArr[i].Bmp.Free;
            m_BmpArr[i].Bmp := nil;
         end else begin
            if GetTickCount - m_BmpArr[i].dwLatestTime > ntime then begin
               ntime := GetTickCount - m_BmpArr[i].dwLatestTime;
               n := i;
            end;
         end;
      end;
   end;
end;

procedure TWMImages.FreeBitmap (index: integer);
begin
   if (index >= 0) and (index < ImageCount) then begin
      if m_BmpArr[index].Bmp <> nil then begin
         //MemorySize  := MemorySize - BmpArr[index].Bmp.Width * BmpArr[index].Bmp.Height;
         //if MemorySize < 0 then MemorySize := 0;
         m_BmpArr[index].Bmp.FreeImage;
         m_BmpArr[index].Bmp.Free;
         m_BmpArr[index].Bmp := nil;
      end;
   end;
end;


//¿À·¡µÈ Ä³½Ã Áö¿ò
procedure TWMImages.FreeOldMemorys;
var
   i, n, ntime, curtime: integer;
begin
   n := -1;
   ntime := 0;
   curtime := GetTickCount;
   for i:=0 to ImageCount-1 do begin
      if m_ImgArr[i].Surface <> nil then begin
         if GetTickCount - m_ImgArr[i].dwLatestTime > 5 * 60 * 1000 then begin
            m_ImgArr[i].Surface.Free;
            m_ImgArr[i].Surface := nil;
         end;
      end;
   end;
end;

//Cache¸¦ ÀÌ¿ëÇÔ
function  TWMImages.GetCachedSurface (index: integer): TDirectDrawSurface;
var
  nPosition:Integer;
begin
  Result := nil;
  try
  if (index < 0) or (index >= ImageCount) then exit;
  if GetTickCount - m_dwMemChecktTick > 10000 then  begin
      m_dwMemChecktTick := GetTickCount;
      FreeOldMemorys;
   end;
   if m_ImgArr[index].Surface = nil then begin //cacheµÇ¾î ÀÖÁö ¾ÊÀ½. »õ·Î ÀÐ¾î¾ßÇÔ.
      if index < m_IndexList.Count then begin
         nPosition:= Integer(m_IndexList[index]);
         LoadDxImage (nPosition, @m_ImgArr[index]);
         m_ImgArr[index].dwLatestTime := GetTickCount;
         Result := m_ImgArr[index].Surface;
      end;
   end else begin
      m_ImgArr[index].dwLatestTime := GetTickCount;
      Result := m_ImgArr[index].Surface;
   end;

   except
   end;
end;

function  TWMImages.GetCachedImage (index: integer; var px, py: integer): TDirectDrawSurface;
var
   position: integer;
   nErrCode:Integer;   
begin
   Result := nil;
   nErrCode:=0;
   try
   if (index < 0) or (index >= ImageCount) then exit;
   if GetTickCount - m_dwMemChecktTick > 10000 then  begin
      m_dwMemChecktTick := GetTickCount;
      FreeOldMemorys;
   end;
   nErrCode:=1;
   if m_ImgArr[index].Surface = nil then begin //cache
      if index < m_IndexList.Count then begin
         position := Integer(m_IndexList[index]);
         LoadDxImage (position, @m_ImgArr[index]);
         m_ImgArr[index].dwLatestTime := GetTickCount;
         px := m_ImgArr[index].nPx;
         py := m_ImgArr[index].nPy;
         Result := m_ImgArr[index].Surface;

      end;
   end else begin
      m_ImgArr[index].dwLatestTime := GetTickCount;
      px := m_ImgArr[index].nPx;
      py := m_ImgArr[index].nPy;
      Result := m_ImgArr[index].Surface;
   end;
   except

   end;
end;

function  TWMImages.GetCachedBitmap (index: integer): TBitmap;
var
   position: integer;
begin
   Result := nil;
   if (index < 0) or (index >= ImageCount) then exit;
   if m_BmpArr[index].Bmp = nil then begin //cacheµÇ¾î ÀÖÁö ¾ÊÀ½. »õ·Î ÀÐ¾î¾ßÇÔ.
      if index < m_IndexList.Count then begin
         position := Integer(m_IndexList[index]);
         LoadBmpImage (position, @m_BmpArr[index]);
         m_BmpArr[index].dwLatestTime := GetTickCount;
         Result := m_BmpArr[index].Bmp;
         FreeOldBmps;
      end;
   end else begin
      m_BmpArr[index].dwLatestTime:=GetTickCount;
      Result := m_BmpArr[index].Bmp;
   end;
end;

procedure TWMImages.DrawZoom (paper: TCanvas; x, y, index: integer; zoom: Real);
var
   rc: TRect;
   bmp: TBitmap;
begin
   if LibType <> ltLoadBmp then exit;
   //if index > BmpList.Count-1 then exit;
   bmp := Bitmaps[index];
   if bmp <> nil then begin
      rc.Left := x;
      rc.Top  := y;
      rc.Right := x + Round (bmp.Width * zoom);
      rc.Bottom := y + Round (bmp.Height * zoom);
      if (rc.Right > rc.Left) and (rc.Bottom > rc.Top) then begin
         paper.StretchDraw (rc, Bmp);
         FreeBitmap (index);
      end;
   end;
end;

procedure TWMImages.DrawZoomEx (paper: TCanvas; x, y, index: integer; zoom: Real; leftzero: Boolean);
var
   rc: TRect;
   bmp, bmp2: TBitmap;
begin
   if LibType <> ltLoadBmp then exit;
   //if index > BmpList.Count-1 then exit;
   bmp := Bitmaps[index];
   if bmp <> nil then begin
      Bmp2 := TBitmap.Create;
      Bmp2.Width := Round (Bmp.Width * zoom);
      Bmp2.Height := Round (Bmp.Height * zoom);
      rc.Left := x;
      rc.Top  := y;
      rc.Right := x + Round (bmp.Width * zoom);
      rc.Bottom := y + Round (bmp.Height * zoom);
      if (rc.Right > rc.Left) and (rc.Bottom > rc.Top) then begin
         Bmp2.Canvas.StretchDraw (Rect(0, 0, Bmp2.Width, Bmp2.Height), Bmp);
         if leftzero then begin
            SpliteBitmap (paper.Handle, X, Y, Bmp2, $0)
         end else begin
            SpliteBitmap (paper.Handle, X, Y-Bmp2.Height, Bmp2, $0);
         end;
      end;
      FreeBitmap (index);
      bmp2.Free;
   end;
end;




end.
