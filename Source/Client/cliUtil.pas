unit cliUtil;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DXClass, WIL, Grobal2, StdCtrls, DirectX, DIB, HUtil32,
  wmutil, Share; //, bmputil;


const
   MAXGRADE = 64;
  DIVUNIT = 4; //新加
type
  TRGB = record
    b, g, r: Byte;
  end;

  TRGB24 = record {here is specification for all color depth resolution}
    r, g, b: Byte;
  end;
  TRGB32 = record
    b, g, r, a: Byte;
  end;

  TRGB16 = Word;
  TRGB8 = Byte;
  PRGB = ^TRGB;
  PRGB24 = ^TRGB24;
  PRGB32 = ^TRGB32;

  TColorEffect = (ceNone, ceGrayScale, ceBright, ceBlack, ceWhite, ceRed, ceGreen, ceBlue, ceYellow, ceFuchsia, ceDieColor);
  TNearestIndexHeader = record
    Title: string[30];
    IndexCount: integer;
    desc: array[0..10] of byte;
  end;

function HasMMX: Boolean;   //新加


procedure MakeDark (ssuf: TDirectDrawSurface; darklevel: integer);
procedure DrawBlend (dsuf: TDirectDrawSurface; x, y: integer; ssuf: TDirectDrawSurface; blendmode: integer);
procedure DrawBlendEx(dsuf: TDirectDrawSurface; x, y: integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight, blendmode: integer);

procedure MakeDark16(ssuf: TDirectDrawSurface; DarkLevel: Integer);
procedure DrawBlendAnti16(dsuf: TDirectDrawSurface; X, Y: Integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight: Integer);
procedure DrawBlend16(dsuf: TDirectDrawSurface; X, Y: Integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight: Integer);

procedure DrawEffect (X, Y: Integer; ssuf, dsuf: TDirectDrawSurface; eff: TColorEffect);
procedure DrawLine(Surface: TDirectDrawSurface);

procedure BrightEffect(ssuf: TDirectDrawSurface; Width, Height: Integer);
procedure RedEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
procedure FuchsiaEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
procedure YellowEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
procedure GrayEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);

procedure BlackEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
procedure WhiteEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
procedure GreenEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
procedure BlueEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
procedure DrawFog (ssuf: TDirectDrawSurface; fogmask: PByte; fogwidth: integer);
procedure FogCopy (PSource: Pbyte; ssx, ssy, swidth, sheight: integer;
                   PDest: Pbyte; ddx, ddy, dwidth, dheight, maxfog: integer);
procedure DrawFog2(ssuf: TDirectDrawSurface; fogmask: PByte; fogwidth: integer);
var
  DarkLevel: Integer;
  mask_r: Int64 = $F800F800F800F800; // 红色掩码
  mask_g: Int64 = $07E007E007E007E0; // 绿色掩码
  mask_b: Int64 = $001F001F001F001F; // 蓝色掩码

implementation

uses  ClMain, Mshare;

var
  RgbIndexTable: array[0..MAXGRADE-1, 0..MAXGRADE-1, 0..MAXGRADE-1] of byte;
  Color256Mix: array[0..255, 0..255] of byte;
  Color256Anti: array[0..255, 0..255] of byte;
  HeavyDarkColorLevel: array[0..255, 0..255] of byte;
  LightDarkColorLevel: array[0..255, 0..255] of byte;
  DengunColorLevel: array[0..255, 0..255] of byte;
  BrightColorLevel: array[0..255] of byte;
  GrayScaleLevel: array[0..255] of byte;
  RedishColorLevel: array[0..255] of byte;
  BlackColorLevel: array[0..255] of byte;
  WhiteColorLevel: array[0..255] of byte;
  GreenColorLevel: array[0..255] of byte;
  YellowColorLevel: array[0..255] of byte;
  BlueColorLevel: array[0..255] of byte;
  FuchsiaColorLevel: array[0..255] of byte;
//解决火龙教主引起程序崩溃问题  20080608
  Color256real: array[0..255, 0..255] of byte;
  MASKCol: array[1..3] of Int64;
 //以下新加
function HasMMX: Boolean;
var
  n: byte;
begin
  asm
      mov   eax, 1
      db $0F,$A2               /// CPUID
      test  edx, 00800000H
      mov   n, 1
      jnz   @@Found
      mov   n, 0
   @@Found:
  end;
  if n = 1 then Result := TRUE
  else Result := FALSE;
end;

//以上新加

procedure MakeDark16(ssuf: TDirectDrawSurface; DarkLevel: Integer);
var
  I, j, idx, row, n, Count: Integer;
  ddsd: TDDSurfaceDesc;
  sptr, mptr, pmix: PWord;
  r, g, b: Word;
  sptr24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  if not DarkLevel in [1..30] then Exit;
  if ssuf.Width > SCREENWIDTH + 100 then Exit;
  try
    ddsd.dwSize := SizeOf(ddsd);
    ssuf.Lock(TRect(nil^), ddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to ssuf.Height - 1 do begin
        sptr32 := PRGBQuad(Integer(ddsd.lpSurface) + (I * ddsd.lPitch));
        for j := 0 to ssuf.Width - 1 do begin
          sptr32.rgbRed := _MAX(_MIN(Round(sptr32.rgbRed * DarkLevel / 31) - 5, 255), 0);
          sptr32.rgbGreen := _MAX(_MIN(Round(sptr32.rgbGreen * DarkLevel / 31) - 5, 255), 0);
          sptr32.rgbBlue := _MAX(_MIN(Round(sptr32.rgbBlue * DarkLevel / 31) - 5, 255), 0);
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      for I := 0 to ssuf.Height - 1 do begin
        sptr24 := PRGBTriple(Integer(ddsd.lpSurface) + (I * ddsd.lPitch));
        for j := 0 to ssuf.Width - 1 do begin
          sptr24.rgbtRed := _MAX(_MIN(Round(sptr24.rgbtRed * DarkLevel / 31) - 5, 255), 0);
          sptr24.rgbtGreen := _MAX(_MIN(Round(sptr24.rgbtGreen * DarkLevel / 31) - 5, 255), 0);
          sptr24.rgbtBlue := _MAX(_MIN(Round(sptr24.rgbtBlue * DarkLevel / 31) - 5, 255), 0);
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to ssuf.Height - 1 do begin
        sptr := PWord(Integer(ddsd.lpSurface) + (I * ddsd.lPitch));
        for j := 0 to ssuf.Width - 1 do begin
          r := (sptr^) and $F800 shr 8;
          g := (sptr^) and $07E0 shr 3;
          b := (sptr^) and $001F shl 3;

          r := _MAX(_MIN(Round(r * DarkLevel / 31) - 5, 255), 0);
          g := _MAX(_MIN(Round(g * DarkLevel / 31) - 5, 255), 0);
          b := _MAX(_MIN(Round(b * DarkLevel / 31) - 5, 255), 0);
          sptr^ := (r shl 8 and $F800) or (g shl 3 and $07E0) or (b shr 3 and $001F);
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock();
  end;
end;
//以下新加
procedure MakeDark(ssuf: TDirectDrawSurface; darklevel: integer);
begin
   MakeDark16(ssuf, DarkLevel);
end;



//以下新加
procedure DrawBlend(dsuf: TDirectDrawSurface; x, y: integer; ssuf: TDirectDrawSurface; blendmode: integer);
begin
  {DrawBlendEx(dsuf, x, y, ssuf, 0, 0, ssuf.width, ssuf.height, blendmode);}
  if (dsuf = nil) or (ssuf = nil) or (dsuf.Canvas = nil) or (ssuf.Canvas = nil) then Exit;
  DrawBlendEx(dsuf, X, Y, ssuf, 0, 0, ssuf.Width, ssuf.Height, blendmode);
end;

procedure DrawBlendEx(dsuf: TDirectDrawSurface; X, Y: integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight, blendmode: integer);
var
  I, j, srcleft, srctop, srcwidth, srcbottom, sidx, didx: Integer;
  sddsd, dddsd: TDDSurfaceDesc;
  sptr, dptr, pmix: PByte;
  source, Dest: array[0..910] of Byte;
  bitindex, scount, dcount, srclen, destlen, wcount, awidth, bwidth: Integer;
begin
  if (dsuf = nil) or (ssuf = nil) or (dsuf.Canvas = nil) or (ssuf.Canvas = nil) then Exit;
  if blendmode = 0 then begin
    DrawBlend16(dsuf, X, Y, ssuf, ssufleft, ssuftop, ssufwidth, ssufheight);
  end else begin
    DrawBlendAnti16(dsuf, X, Y, ssuf, ssufleft, ssuftop, ssufwidth, ssufheight);
  end;
end;

procedure MMXDraw32(pSrc, pDst: PByte; nWidth: Integer);
begin
  asm
    Push ESI
    Push EDI

    Mov  EDI, pDst
    Mov  ESI, pSrc
    MOV  ECX, nWidth
    Test ECX,ECX

    Mov  EAX,$00000000//$FFFFFFFF
    movd MM7,EAX
    PUNPCKLBW MM7,MM7
    PSRLW MM7,8                  // MM7 = $00 FF 00 FF 00 FF 00 FF

    MOV  EAX,120
    movd MM3,EAX
    PUNPCKLWD  MM3,MM3           // MM3 = Alpha Mask Byte 0-256
    PUNPCKLWD  MM3,MM3

    PSUBUSW    MM7,MM3

    JZ   @Exit

 @Loop:

    Movd MM0,[ESI]                // Overlay Color
    Movd MM1,[EDI]                // Background Color

    PUNPCKLBW  MM0,MM0            // Byte -&gt; Word Expand
    PSRLW      MM0,8              // MM0 = Overlay Layer

    PUNPCKLBW  MM1,MM1            // Byte -&gt; Word Expand
    PSRLW      MM1,8              // MM1 = Background Layer

    PMULLW     MM0,MM3            // MM0 = OverlayAlpha * OverlayColor
    PMULLW     MM1,MM7            // MM1 = (255-OverlayAlpha)* BackGroundColor

    PADDUSW    MM0,MM1            // ADD Result
    PSRLW      MM0,8
    PACKUSWB   MM0,MM0            // Pack Word-&gt;Byte


    Movd       [EDI],MM0          // Store result

    ADD ESI,4
    ADD EDI,4
    DEC ECX
    JNZ @Loop

 @Exit:
    Emms
    Pop EDI
    Pop ESI
  end;
end;
{var
 srcleft,srctop,srcwidth,srcheight:Integer;

begin
   if x >= dsuf.Width then exit;
   if y >= dsuf.Height then exit;
   if x < 0 then begin
    srcwidth := ssufwidth + X;
    srcleft := ssufwidth - srcwidth;
    X := 0;
   end else begin
    srcleft := ssufleft;
    srcwidth := ssufwidth;
   end;
   if Y < 0 then begin
    srcheight := ssufheight + Y;
    srctop := ssufheight - srcheight;
    Y := 0;
   end else begin
    srctop := ssuftop;
    srcheight := ssufheight;
   end;

   if (srcwidth <= 0) or (srcheight <= 0) or (srcleft >= ssuf.Width) or (srctop >= ssuf.Height) then exit;
    if blendMode=1 then
     dsuf.DrawAdd(rect(x, y,x+srcwidth, y+srcheight),
     rect(srcleft,srctop,srcleft+srcwidth,srctop+srcheight),ssuf,true,128)//192,110 此处就是魔法浓度
    else
     dsuf.DrawAlpha(rect(x, y,x+srcwidth, y+srcheight),
     rect(srcleft,srctop,srcleft+srcwidth,srctop+srcheight),ssuf,true,162); //225 ,172   这东西不知道是做啥子的
end;
     }


//以上新加
procedure DrawBlend16(dsuf: TDirectDrawSurface; X, Y: Integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight: Integer);
var
  I, J, K, L, srcleft, srctop, srcwidth, srcbottom, sidx, didx, nY: Integer;
  sddsd, dddsd: TDDSurfaceDesc;
  sptr, dptr, pmix: PWord;
  source, Dest: array[0..910] of Byte;
  bitindex, scount, dcount, srclen, destlen, wcount, awidth, bwidth: Integer;
  r, g, b, stmp, dtmp: Word;
  sptr24, dptr24: PRGBTriple;
  sptr32, dptr32: PRGBQuad;
  masknogreen, maskred, maskblue, maskgreen, maskbyte, maskkey: Int64;
  nWidth, nHeight: Integer;
  wColor, wSP, wDP: Word;
begin
   //如果目标页面或者源页面无效则推出
  if (dsuf.Canvas = nil) or (ssuf.Canvas = nil) then Exit;
   //检测目标xy坐标是否超出目标页面范围 ，并处理xy小于0的情况等坐标检测
  if X >= dsuf.Width then Exit;
  if Y >= dsuf.Height then Exit;
  if X < 0 then begin
    srcleft := -X;
    srcwidth := ssufwidth + X;
    X := 0;
  end else begin
    srcleft := ssufleft;
    srcwidth := ssufwidth;
  end;
  if Y < 0 then begin
    srctop := -Y;
    srcbottom := ssufheight;
    Y := 0;
  end else begin
    srctop := ssuftop;
    srcbottom := srctop + ssufheight;
  end;
  if srcleft + srcwidth > ssuf.Width then srcwidth := ssuf.Width - srcleft;
  if srcbottom > ssuf.Height then
    srcbottom := ssuf.Height; //-srcheight;
  if X + srcwidth > dsuf.Width then srcwidth := (dsuf.Width - X) div 4 * 4;
  if Y + srcbottom - srctop > dsuf.Height then
    srcbottom := dsuf.Height - Y + srctop;
  if (X + srcwidth) * (Y + srcbottom - srctop) > dsuf.Width * dsuf.Height then //烙矫..
    srcbottom := srctop + (srcbottom - srctop) div 2;

  if (srcwidth <= 0) or (srcbottom <= 0) or (srcleft >= ssuf.Width) or (srctop >= ssuf.Height) then Exit;
//   if srcWidth > 900 then exit;
  if srcwidth > SCREENWIDTH + 100 then Exit;
  if ssuf.Height > 350 then begin
       //TfrmMain.DScreen.AddChatBoardString('test; ' + InttoStr(srcwidth) + ' ' + InttoStr(srcbottom) + ' ' + InttoStr(srctop),clWhite, clBlack);
  end;
  try
    sddsd.dwSize := SizeOf(sddsd);
    dddsd.dwSize := SizeOf(dddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    dsuf.Lock(TRect(nil^), dddsd);
    awidth := srcwidth div 4; //ssuf.Width div 4;
    bwidth := srcwidth; //ssuf.Width;
    srclen := srcwidth; //ssuf.Width;
    destlen := srcwidth; //ssuf.Width;
    if ssuf.BitCount = 32 then begin
      for I := srctop to srcbottom - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + sddsd.lPitch * I + srcleft * 4);
        dptr32 := PRGBQuad(Integer(dddsd.lpSurface) + (Y + I - srctop) * dddsd.lPitch + X * 4);
        for j := 1 to srcwidth do begin
          if not (Integer(sptr32^) = 0) then
          begin
            dptr32.rgbRed := (dptr32.rgbRed shr 1) + (sptr32.rgbRed shr 1);
            dptr32.rgbGreen := (dptr32.rgbGreen shr 1) + (sptr32.rgbGreen shr 1);
            dptr32.rgbBlue := (dptr32.rgbBlue shr 1) + (sptr32.rgbBlue shr 1);
          end;
          Inc(sptr32);
          Inc(dptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      for I := srctop to srcbottom - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + sddsd.lPitch * I + srcleft * 3);
        dptr24 := PRGBTriple(Integer(dddsd.lpSurface) + (Y + I - srctop) * dddsd.lPitch + X * 3);
        for j := 1 to srcwidth do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin
            sptr24.rgbtRed := (sptr24.rgbtRed shr 1) + (sptr24.rgbtRed shr 1);
            sptr24.rgbtGreen := (sptr24.rgbtGreen shr 1) + (sptr24.rgbtGreen shr 1);
            sptr24.rgbtBlue := (sptr24.rgbtBlue shr 1) + (sptr24.rgbtBlue shr 1);
          end;
          Inc(sptr24);
          Inc(dptr24);
        end;
      end;
    end else begin
      {masknogreen := $F81FF81FF81FF81F;
      maskred := $F800F800F800F800;
      maskgreen := $7E007E007E007E0;
      maskblue := $1F001F001F001F;
      maskbyte := $7F7F7F7F7F7F7F7F;
      maskkey := $0000000000000000;
      }
      nWidth := srcwidth;
      nHeight := srcbottom - srctop;
      maskbyte := $7BEF7BEF7BEF7BEF;
      maskkey := $0000000000000000;
      //for I := srctop to srcbottom - 1 do begin
      //sptr := PWord(Integer(sddsd.lpSurface) + sddsd.lPitch * I + srcleft * 2);
      //dptr := PWord(Integer(dddsd.lpSurface) + (Y + I - srctop) * dddsd.lPitch + X * 2);

    {  sptr := PWord(Integer(sddsd.lpSurface) + sddsd.lPitch * srctop + srcleft * 2);
      dptr := PWord(Integer(dddsd.lpSurface) + Y * dddsd.lPitch + X * 2);   }


      //for nY := 0 to nHeight - 1 do begin
      for I := srctop to srcbottom - 1 do begin
        //sptr := PWord(Integer(sddsd.lpSurface) + sddsd.lPitch * (srctop + nY) + srcleft * 2);
        //dptr := PWord(Integer(dddsd.lpSurface) + (Y + nY - srctop) * dddsd.lPitch + X * 2);
        sptr := PWord(Integer(sddsd.lpSurface) + sddsd.lPitch * I + srcleft * 2);
        dptr := PWord(Integer(dddsd.lpSurface) + (Y + I - srctop) * dddsd.lPitch + X * 2);

          //pSrc := PByte(Integer(Source.PBits) + (SrcRect.Top + nY) * Source.Pitch + SrcRect.Left * 2);
          //pDst := PByte(Integer(PBits) + (DestRect.Top + nY) * Pitch + DestRect.Left * 2);
        J := nWidth div 4;
        K := nWidth mod 4;
        {  for L := 0 to nWidth - 1 do begin //剩余处理
            if wColor <> PWord(pSrc)^ then begin
              wSP := PWord(pSrc)^ shr 1 and $7BEF;
              wDP := PWord(pDst)^ shr 1 and $7BEF;
              r := (wSP shr 11) + (wDP shr 11);
              g := (wSP shr 5 and $3F) + (wDP shr 5 and $3F);
              b := (wSP and $1F) + (wDP and $1F);
              PWord(pDst)^ := (r shl 11) or (g shl 5) or b;
            end;
            Inc(pSrc, 2);
            Inc(pDst, 2);
          end;}


        asm
                 push    eax
                 push    ecx
                 push    edx

                 mov ecx, dptr
                 mov eax, sptr
                 movq mm6, maskkey
                 movq mm7, maskbyte
                 movlps xmm6, maskkey
                 movhps xmm6, maskkey
                 movlps xmm7, maskbyte
                 movhps xmm7, maskbyte
                 movd   edx, mm6

             @SSE:
                 cmp J, 0
                 jle @Exit
                 cmp J, 1
                 jle @MMX
                 // 跳过4字全为透明色
                 cmp [eax], edx
                 jnz @notequal_sse2
                 cmp [eax+8], edx
                 jnz @notequal_sse2
                 jmp @finishone_sse2
             @notequal_sse2:
                 movdqu xmm0, [eax]
                 movdqu xmm1, [ecx]
                 movdqu xmm5, xmm0
                 movdqu xmm2, xmm1
                 pcmpeqw xmm5, xmm6	// xmm5为透明掩码
                 psrlq xmm2, 1
                 psrlq xmm0, 1
                 pand xmm2, xmm7
                 pand xmm0, xmm7
                 paddw xmm2, xmm0		// xmm2为混合结果
                 pand xmm1, xmm5		// 目的数据非透明点置0
                 psubusw xmm2, xmm5	// 混合结果透明点置0
                 por xmm1, xmm2		// 相或得最终结果
                 movdqu [ecx], xmm1
             @finishone_sse2:
                 add eax, 16
                 add ecx, 16
                 sub J, 2
                 mov integer ptr[sptr],eax
                 mov integer ptr[dptr],ecx
                 jmp @SSE

             @MMX:
                 cmp J, 0
                 jle @Exit
                 // 跳过4字全为透明色
                 cmp [eax], edx
                 jnz @notequal
                 cmp [eax+4], edx
                 jnz @notequal
                 jmp @finishone
             @notequal:
                 movq mm0, [eax]
                 movq mm1, [ecx]
                 movq mm5, mm0
                 movq mm2, mm1
                 pcmpeqw mm5, mm6	// mm5为透明掩码
                 psrlq mm2, 1
                 psrlq mm0, 1
                 pand mm2, mm7
                 pand mm0, mm7
                 paddw mm2, mm0		// mm2为混合结果
                 pand mm1, mm5		// 目的数据非透明点置0
                 psubusw mm2, mm5	// 混合结果透明点置0
                 por mm1, mm2		// 相或得最终结果
                 movq [ecx], mm1
             @finishone:
                 add eax, 8
                 add ecx, 8
                 sub J,   1
                 mov integer ptr[sptr],eax
                 mov integer ptr[dptr],ecx
                 jmp @MMX

             @Exit:
                 emms
                 pop     eax
                 pop     ecx
                 pop     edx
        end;
        for L := 1 to K do begin //剩余处理
          if wColor <> PWord(sptr)^ then begin
            wSP := PWord(sptr)^ shr 1 and $7BEF;
            wDP := PWord(dptr)^ shr 1 and $7BEF;
            r := (wSP shr 11) + (wDP shr 11);
            g := (wSP shr 5 and $3F) + (wDP shr 5 and $3F);
            b := (wSP and $1F) + (wDP and $1F);
            PWord(dptr)^ := (r shl 11) or (g shl 5) or b;
          end;
          Inc(sptr);
          Inc(dptr);
        end;
      end;


    end;
  finally
    ssuf.UnLock();
    dsuf.UnLock();
  end;
end;

//画另一种混合效果

procedure DrawBlendAnti16(dsuf: TDirectDrawSurface; X, Y: Integer; ssuf: TDirectDrawSurface; ssufleft, ssuftop, ssufwidth, ssufheight: Integer);
var
  ta, tb, tc, td, I, j, k, l, tmp, srcleft, srctop, srcwidth, srcbottom, sidx, didx: Integer;
  sddsd, dddsd: TDDSurfaceDesc;
  sptr, dptr, pmix: PWord;
  source, Dest: array[0..910] of Byte;
  bitindex, scount, dcount, srclen, destlen, wcount, awidth, bwidth: Integer;
  r, g, b, dr, dg, db, stmp, dtmp: Word;
  sptr24, dptr24: PRGBTriple;
  sptr32, dptr32, sp32, dp32: PRGBQuad;
  masknogreen, maskred, maskblue, maskgreen, maskbyte, maskkey, maskdate1, maskdate2, maskdate3, maskdate4, maskdate5, maskdate6: Int64;
  //masknogreen, maskred, maskblue, maskgreen, maskbyte, maskkey, maskdate1, maskdate2, maskdate3, maskdate4, maskdate5, maskdate6: Cardinal;
begin
   //如果目标页面或者源页面无效则推出
  if (dsuf.Canvas = nil) or (ssuf.Canvas = nil) then Exit;
   //检测目标xy坐标是否超出目标页面范围 ，并处理xy小于0的情况等坐标检测
  if X >= dsuf.Width then Exit;
  if Y >= dsuf.Height then Exit;
  if X < 0 then begin
    srcleft := -X;
    srcwidth := ssufwidth + X;
    X := 0;
  end else begin
    srcleft := ssufleft;
    srcwidth := ssufwidth;
  end;
  if Y < 0 then begin
    srctop := -Y;
    srcbottom := ssufheight;
    Y := 0;
  end else begin
    srctop := ssuftop;
    srcbottom := srctop + ssufheight;
  end;
  if srcleft + srcwidth > ssuf.Width then srcwidth := ssuf.Width - srcleft;
  if srcbottom > ssuf.Height then
    srcbottom := ssuf.Height; //-srcheight;
  if X + srcwidth > dsuf.Width then srcwidth := (dsuf.Width - X) div 4 * 4;
  if Y + srcbottom - srctop > dsuf.Height then
    srcbottom := dsuf.Height - Y + srctop;
  if (X + srcwidth) * (Y + srcbottom - srctop) > dsuf.Width * dsuf.Height then //烙矫..
    srcbottom := srctop + (srcbottom - srctop) div 2;

  if (srcwidth <= 0) or (srcbottom <= 0) or (srcleft >= ssuf.Width) or (srctop >= ssuf.Height) then Exit;
//   if srcWidth > 900 then exit;
  if srcwidth > SCREENWIDTH + 100 then Exit;
  if ssuf.Height > 350 then begin
       //TfrmMain.DScreen.AddChatBoardString('test; ' + InttoStr(srcwidth) + ' ' + InttoStr(srcbottom) + ' ' + InttoStr(srctop),clWhite, clBlack);
  end;
  try
    sddsd.dwSize := SizeOf(sddsd);
    dddsd.dwSize := SizeOf(dddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    dsuf.Lock(TRect(nil^), dddsd);
    awidth := srcwidth div 4; //ssuf.Width div 4;
    bwidth := srcwidth; //ssuf.Width;
    srclen := srcwidth; //ssuf.Width;
    destlen := srcwidth; //ssuf.Width;

    if ssuf.BitCount = 32 then begin
      maskbyte := $000000FF00FF00FF;
      maskkey := $0000000000000000;

      ta := srcbottom - 1;
      tb := srcleft * 4 + Integer(sddsd.lpSurface);
      tc := Y - srctop;
      td := X * 4 + Integer(dddsd.lpSurface) + tc * dddsd.lPitch;
      I := srctop;
      sp32 := PRGBQuad(sddsd.lPitch * I + tb);
      dp32 := PRGBQuad(dddsd.lPitch * I + td);
      sptr32 := sp32;
      dptr32 := dp32;
       //for i:=srctop to ta{srcbottom-1} do begin
          //sptr32 := PRGBQuad(integer(sddsd.lpSurface) + sddsd.lPitch * i + srcleft*4);
          //dptr32 := PRGBQuad(integer(dddsd.lpSurface) + (y+i-srctop) * dddsd.lPitch + x*4);
                 {sptr32 := PRGBQuad(sddsd.lPitch * i + tb);
          dptr32 := PRGBQuad(i * dddsd.lPitch + td);   }
                 //j := srcwidth;
      asm

                push edx
                push ecx
                push EAX
              @@doheightflag:
                mov EAX,i

                cmp EAX,ta//EBX
                JG @@exitflag
                mov EAX,srcwidth
                mov j,EAX
              @@doflag:
                cmp j,0
                jle @@NextHeightFlag

                mov ecx,sptr32
                mov edx,dptr32

                mov EAX,[sptr32]
                cmp [EAX], 0
                je @@NextFlag

                movd mm0,[ecx]
                movd mm1,[edx]
                pxor mm2,mm2
                PUNPCKLBW mm0,mm2
                PUNPCKLBW mm1,mm2
                movq mm2,maskbyte
                PSUBSW mm2,mm0
                PMULLW mm2,mm1
                PSRLW mm2,8
                PADDUSW mm2,mm0
                PACKUSWB mm2,mm2

                movd [edx],mm2
             @@NextFlag:
                add ecx,4
                add edx,4
                mov integer ptr[sptr32],ecx
                mov integer ptr[dptr32],edx

                sub j,1
                jmp @@doflag
              @@NextHeightFlag:
                add i,1
                mov ecx,sp32
                mov edx,dp32
                add ecx,sddsd.lPitch
                add edx,dddsd.lPitch
                mov integer ptr[sp32],ecx
                mov integer ptr[dp32],edx
                mov integer ptr[sptr32],ecx
                mov integer ptr[dptr32],edx
                jmp @@doHeightFlag
              @@exitflag:
                emms
                pop edx
                pop ecx
                pop eax

      end;

    end else if ssuf.BitCount = 24 then begin
    end else begin
      maskbyte := $7E0F81F;
      maskdate1 := $00FF00FF00FF00FF;
      maskdate3 := $00F800F800F800F8;
      maskdate4 := $00FC00FC00FC00FC;
      maskdate5 := $0008000800080008;
      maskdate6 := $000C000C000C000C;
      maskdate2 := $FFFFFFFFFFFFFFFF;
      maskred := $F800F800F800F800;
      maskgreen := $07E007E007E007E0;
              //maskgreen := $07c007c007c007c0;
      maskblue := $001F001F001F001F;
      maskkey := $0000000000000000;

      for I := srctop to srcbottom - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + sddsd.lPitch * I + srcleft * 2);
        dptr := PWord(Integer(dddsd.lpSurface) + (Y + I - srctop) * dddsd.lPitch + X * 2);
        j := srcwidth div 4;
        k := srcwidth mod 4;
        asm
                                push edx
                                push ecx
                       //sse2处理
                        @@doflag_sse2:
                                cmp j,0
                                jle @@exitflag
                                cmp j,1
                                jle @@doflag

                                mov ecx,sptr
                                mov edx,dptr

                                movdqu xmm7,[ecx]
                                movlps xmm4,maskkey
                                movhps xmm4,maskkey
                                PCMPEQW xmm7,xmm4

                                movdqu xmm0,[ecx]
                                movdqu xmm1,[edx]
                                movlps xmm4,maskred
                                movhps xmm4,maskred
                                pand xmm0,xmm4
                                pand xmm1,xmm4
                                PSRLW xmm0,8
                                PSRLW xmm1,8
                                movlps xmm2,maskdate1
                                movhps xmm2,maskdate1
                                PSUBUSW xmm2,xmm0
                                PMULLW xmm2,xmm1
                                PSRLW xmm2,8      //成组数据的逻辑右移8
                                PADDUSW xmm2,xmm0
                                movlps xmm4,maskdate3
                                movhps xmm4,maskdate3
                                PMINSW xmm2,xmm4
                                movlps xmm4,maskdate5
                                movhps xmm4,maskdate5
                                PMAXSW xmm2,xmm4
                                PSLLW xmm2,8
                                movlps xmm4,maskred
                                movhps xmm4,maskred
                                pand xmm2,xmm4

                                movdqu xmm0,[ecx]
                                movdqu xmm1,[edx]
                                movlps xmm4,maskgreen
                                movhps xmm4,maskgreen
                                pand xmm0,xmm4
                                pand xmm1,xmm4
                                PSRLW xmm0,3
                                PSRLW xmm1,3
                                movlps xmm3,maskdate1
                                movhps xmm3,maskdate1
                                PSUBUSW xmm3,xmm0
                                PMULLW xmm3,xmm1
                                PSRLW xmm3,8
                                PADDUSW xmm3,xmm0
                                movlps xmm4,maskdate4
                                movhps xmm4,maskdate4
                                PMINSW xmm3,xmm4
                                movlps xmm4,maskdate6
                                movhps xmm4,maskdate6
                                PMAXSW xmm3,xmm4
                                PSLLW xmm3,3
                                movlps xmm4,maskgreen
                                movhps xmm4,maskgreen
                                pand xmm3,xmm4
                                por xmm2,xmm3

                                movdqu xmm0,[ecx]
                                movdqu xmm1,[edx]
                                movlps xmm4,maskblue
                                movhps xmm4,maskblue
                                pand xmm0,xmm4
                                pand xmm1,xmm4
                                PSLLW xmm0,3
                                PSLLW xmm1,3
                                movlps xmm3,maskdate1
                                movhps xmm3,maskdate1
                                PSUBUSW xmm3,xmm0
                                PMULLW xmm3,xmm1
                                PSRLW xmm3,8
                                PADDUSW xmm3,xmm0
                                movlps xmm4,maskdate3
                                movhps xmm4,maskdate3
                                PMINSW xmm3,xmm4
                                movlps xmm4,maskdate5
                                movhps xmm4,maskdate5
                                PMAXSW xmm3,xmm4
                                PSRLW xmm3,3
                                movlps xmm4,maskblue
                                movhps xmm4,maskblue
                                pand xmm3,xmm4
                                por xmm2,xmm3

                                movdqu xmm1,[edx]
                                pand xmm1,xmm7
                                movlps xmm4,maskdate2
                                movhps xmm4,maskdate2
                                pandn xmm7,xmm4
                                pand xmm2,xmm7

                                por xmm2,xmm1
                                movdqu [edx],xmm2

                                add ecx,16
                                add edx,16
                                mov sptr,ecx
                                mov dptr,edx

                                sub j,2
                                jmp @@doflag_sse2

                        //mmx处理
                        @@doflag:
                                cmp j,0
                                jle @@exitflag

                                mov ecx,sptr
                                mov edx,dptr

                                movq mm7,[ecx]
                                PCMPEQW mm7,maskkey

                                movq mm0,[ecx]
                                movq mm1,[edx]
                                pand mm0,maskred
                                pand mm1,maskred
                                PSRLW mm0,8
                                PSRLW mm1,8
                                movq mm2,maskdate1
                                PSUBUSW mm2,mm0
                                PMULLW mm2,mm1
                                PSRLW mm2,8      //成组数据的逻辑右移8
                                PADDUSW mm2,mm0
                                PMINSW mm2,maskdate3
                                PMAXSW mm2,maskdate5
                                PSLLW mm2,8
                                pand mm2,maskred

                                movq mm0,[ecx]
                                movq mm1,[edx]
                                pand mm0,maskgreen
                                pand mm1,maskgreen
                                PSRLW mm0,3
                                PSRLW mm1,3
                                movq mm3,maskdate1
                                PSUBUSW mm3,mm0
                                PMULLW mm3,mm1
                                PSRLW mm3,8
                                PADDUSW mm3,mm0
                                PMINSW mm3,maskdate4
                                PMAXSW mm3,maskdate6
                                PSLLW mm3,3
                                pand mm3,maskgreen
                                por mm2,mm3

                                movq mm0,[ecx]
                                movq mm1,[edx]
                                pand mm0,maskblue
                                pand mm1,maskblue
                                PSLLW mm0,3
                                PSLLW mm1,3
                                movq mm3,maskdate1
                                PSUBUSW mm3,mm0
                                PMULLW mm3,mm1
                                PSRLW mm3,8
                                PADDUSW mm3,mm0
                                PMINSW mm3,maskdate3
                                PMAXSW mm3,maskdate5
                                PSRLW mm3,3
                                pand mm3,maskblue
                                por mm2,mm3

                                movq mm1,[edx]
                                pand mm1,mm7
                                pandn mm7,maskdate2
                                pand mm2,mm7

                                por mm2,mm1
                                movq [edx],mm2
                        @@Nextflag:
                                add ecx,8
                                add edx,8
                                mov sptr,ecx
                                mov dptr,edx

                                sub j,1
                                jmp @@doflag

                        @@exitflag:
                                emms
                                pop edx
                                pop ecx

        end;
        for l := 1 to k do begin //剩余像素处理
          r := (sptr^) and $F800 shr 8;
          g := (sptr^) and $07E0 shr 3;
          b := (sptr^) and $001F shl 3;

          dr := (dptr^) and $F800 shr 8;
          dg := (dptr^) and $07E0 shr 3;
          db := (dptr^) and $001F shl 3;

          r := _MIN(255, r + Round((255 - r) / 255 * dr));
          g := _MIN(255, g + Round((255 - g) / 255 * dg));
          b := _MIN(255, b + Round((255 - b) / 255 * db));

          dptr^ := (r shl 8 and $F800) or (g shl 3 and $07E0) or (b shr 3 and $001F);
          Inc(sptr, 1);
          Inc(dptr, 1);
        end;
      end;
    end;

  finally
    ssuf.UnLock();
    dsuf.UnLock();
  end;
end;



 //以下新加

procedure DrawEffect (X, Y: Integer; ssuf, dsuf: TDirectDrawSurface; eff: TColorEffect);
var
  I, j, n, scount, srclen: Integer;
  sddsd: TDDSurfaceDesc;
  sptr, peff: PByte;
   //source: array[0..810] of byte;
  source: array[0..SCREENWIDTH + 10] of Byte;
begin
  if (ssuf = nil) or (ssuf.Canvas = nil) then Exit;
  case eff of
    ceBright:
      begin
        BrightEffect(ssuf, dsuf.Width, dsuf.Height);
        Exit;
      end;
    ceGrayScale:
      begin
        GrayEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceRed:
      begin
        RedEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceBlack:
      begin
        BlackEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceWhite:
      begin
        WhiteEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceGreen:
      begin
        GreenEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceBlue:
      begin
        BlueEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceYellow:
      begin
        YellowEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
    ceFuchsia:
      begin
        FuchsiaEffect(X, Y, dsuf.Width, dsuf.Height, ssuf);
        Exit;
      end;
  end;
end;
procedure BrightEffect(ssuf: TDirectDrawSurface; Width, Height: Integer);
var
  I, j, k, l: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (I * sddsd.lPitch));
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := _MIN(Round(sptr32.rgbRed * 1.3), 255);
            sptr32.rgbGreen := _MIN(Round(sptr32.rgbGreen * 1.3), 255);
            sptr32.rgbBlue := _MIN(Round(sptr32.rgbBlue * 1.3), 255);
          end;
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (I * sddsd.lPitch));
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := _MIN(Round(sptr24.rgbtRed * 1.3), 255);
            sptr24.rgbtGreen := _MIN(Round(sptr24.rgbtGreen * 1.3), 255);
            sptr24.rgbtBlue := _MIN(Round(sptr24.rgbtBlue * 1.3), 255);
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (I * sddsd.lPitch));
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := _MIN(Round((tmp and $F800 shr 8) * 1.3), 255);
            g := _MIN(Round((tmp and $07E0 shr 3) * 1.3), 255);
            b := _MIN(Round((tmp and $001F shl 3) * 1.3), 255);
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure RedEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3);
            sptr32.rgbGreen := 0;
            sptr32.rgbBlue := 0;
          end;
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3);
            sptr24.rgbtGreen := 0;
            sptr24.rgbtBlue := 0;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := Word(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3));
            g := 0;
            b := 0;
            sptr^ := _MAX(Word(r and $F8 shl 8), $0800);
                                                //sptr^ :=  word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure FuchsiaEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3);
            sptr32.rgbGreen := 0;
            sptr32.rgbBlue := sptr32.rgbRed;
          end;
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3);
            sptr24.rgbtGreen := 0;
            sptr24.rgbtBlue := sptr24.rgbtRed;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := Word(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3));
            g := 0;
            b := r;
            sptr^ := _MAX(Word((r and $F8 shl 8) or (b and $F8 shr 3)), $0801);
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure YellowEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3);
            sptr32.rgbGreen := sptr32.rgbRed;
            sptr32.rgbBlue := 0;
          end;
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3);
            sptr24.rgbtGreen := sptr24.rgbtRed;
            sptr24.rgbtBlue := 0;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := Word(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3));
            g := r;
            b := 0;
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure GrayEffect(X, Y, Width, Height: Integer; ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3);
            sptr32.rgbGreen := sptr32.rgbRed;
            sptr32.rgbBlue := sptr32.rgbRed;
          end;
          Inc(sptr32);
        end;
      end;
    end else if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3);
            sptr24.rgbtGreen := sptr24.rgbtRed;
            sptr24.rgbtBlue := sptr24.rgbtRed;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := Word(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3));
            g := r;
            b := r;
            sptr^ := _MAX(Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3)), $0821);
                                                {if  ((tmp and $F800 shr 8) = 160)  or ((r>200) and (g>200) and (b>200)) then
                                                begin
                                                        sptr^ := $0821;
                                                end;     }
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure BlackEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := _MAX(Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3 * 0.6), 1);
            sptr32.rgbGreen := sptr32.rgbRed;
            sptr32.rgbBlue := sptr32.rgbRed;
          end;
          Inc(sptr32);
        end;
      end;
    end else
      if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := _MAX(Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3 * 0.6), 1);
            sptr24.rgbtGreen := sptr24.rgbtRed;
            sptr24.rgbtBlue := sptr24.rgbtRed;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := Word(_MAX(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3 * 0.6), 1));
            g := r;
            b := r;
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;

end;

procedure WhiteEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := _MIN(Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3 * 1.6), 255);
            sptr32.rgbGreen := sptr32.rgbRed;
            sptr32.rgbBlue := sptr32.rgbRed;
          end;
          Inc(sptr32);
        end;
      end;
    end else
      if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := _MIN(Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3 * 1.6), 255);
            sptr24.rgbtGreen := sptr24.rgbtRed;
            sptr24.rgbtBlue := sptr24.rgbtRed;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
                                 //if not ((sptr^)=0) then
          begin
            tmp := sptr^;
            r := Word(_MIN(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3 * 1.6), 255));
            g := r;
            b := r;
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;


procedure GreenEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b, n: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := 0;
            sptr32.rgbGreen := _MAX(Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3), 1);
            sptr32.rgbBlue := 0;
          end;
          Inc(sptr32);
        end;
      end;
    end else
      if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := 0;
            sptr24.rgbtGreen := _MAX(Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3), 1);
            sptr24.rgbtBlue := 0;
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then
          begin
            tmp := sptr^;
            r := 0;
            g := Word(_MAX(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3), $20)); //max处理见蓝色的注释
            b := 0;
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
            sptr^ := g and $FC shl 3;
                                                {r := tmp and $F800 shr 8;
                                                g := tmp and $07E0 shr 3;
                                                b := tmp and $001F shl 3;
                                                if (r > 0) or (g > 0) or (b > 0) then begin
                                                        g := _max(round((r + g + b)/3),$20);
                                                        sptr^ := g and $FC shl 3;
                                                end else begin

                                                end;   }


          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;

procedure BlueEffect(X, Y, Width, Height: Integer;  ssuf: TDirectDrawSurface);
var
  I, j: Integer;
  sddsd: TDDSurfaceDesc;
  sptr: PWord;
  tmp: Word;
  r, g, b: Byte;
  sptr24, tmp24: PRGBTriple;
  sptr32: PRGBQuad;
begin
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    if ssuf.BitCount = 32 then begin
      for I := 0 to Height - 1 do begin
        sptr32 := PRGBQuad(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 4);
        for j := 0 to Width - 1 do begin
          if not (Integer(sptr32^) = 0) then
          begin;
            sptr32.rgbRed := 0;
            sptr32.rgbGreen := 0;
            sptr32.rgbBlue := _MAX(Round((sptr32.rgbRed + sptr32.rgbGreen + sptr32.rgbBlue) / 3), 1);
          end;
          Inc(sptr32);
        end;
      end;
    end else
      if ssuf.BitCount = 24 then begin
      tmp24.rgbtBlue := 0;
      tmp24.rgbtGreen := 0;
      tmp24.rgbtRed := 0;
      for I := 0 to Height - 1 do begin
        sptr24 := PRGBTriple(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 3);
        for j := 0 to Width - 1 do begin
          if (sptr24.rgbtBlue <> 0) or (sptr24.rgbtGreen <> 0) or (sptr24.rgbtRed <> 0) then
          begin;
            sptr24.rgbtRed := 0;
            sptr24.rgbtGreen := 0;
            sptr24.rgbtBlue := _MAX(Round((sptr24.rgbtRed + sptr24.rgbtGreen + sptr24.rgbtBlue) / 3), 1);
          end;
          Inc(sptr24);
        end;
      end;
    end else begin
      for I := 0 to Height - 1 do begin
        sptr := PWord(Integer(sddsd.lpSurface) + (Y + I) * sddsd.lPitch + X * 2);
        for j := 0 to Width - 1 do begin
          if not ((sptr^) = 0) then begin
            tmp := sptr^;
            r := 0;
            g := 0;
            b := Word(_MAX(Round(((tmp and $F800 shr 8) + (tmp and $07E0 shr 3) + (tmp and $001F shl 3)) / 3), $08)); //0x08是最小的颜色值，如果不这样处理，可能会变成黑色，就是透明了
            sptr^ := Word((r and $F8 shl 8) or (g and $FC shl 3) or (b and $F8 shr 3));
          end;
          Inc(sptr);
        end;
      end;
    end;
  finally
    ssuf.UnLock()
  end;
end;
procedure DrawLine(Surface: TDirectDrawSurface);
var
  nX, nY: integer;
begin
  for nX := 0 to Surface.width - 1 do begin
    Surface.Pixels[nX, 0] := 255;
  end;
  for nY := 0 to Surface.height - 1 do begin
    Surface.Pixels[0, nY] := 255;
  end;
  Surface.height
end;
//以上新加
 
//生成雾的效果
procedure FogCopy (PSource: Pbyte; ssx, ssy, swidth, sheight: integer;
                   PDest: Pbyte; ddx, ddy, dwidth, dheight, maxfog: integer);
var
  row, srclen, srcheight, spitch, dpitch: integer;
begin
   if (PSource = nil) or (pDest = nil) then exit; 
   spitch := swidth;
   dpitch := dwidth;
   if ddx < 0 then begin
      ssx := ssx - ddx;
      swidth := swidth + ddx;
      ddx := 0;
   end;
   if ddy < 0 then begin
      ssy := ssy - ddy;
      sheight := sheight + ddy;
      ddy := 0;
   end;
   srclen := _MIN(swidth, dwidth-ddx);
   srcheight := _MIN(sheight, dheight-ddy);
   if (srclen <= 0) or (srcheight <= 0) then exit;
   asm
         mov   row, 0
      @@NextRow:
         mov   eax, row
         cmp   eax, srcheight
         jae   @@Finish

         mov   esi, psource
         mov   eax, ssy
         add   eax, row
         mov   ebx, spitch
         imul  eax, ebx
         add   eax, ssx
         add   esi, eax          //sptr

         mov   edi, pdest
         mov   eax, ddy
         add   eax, row
         mov   ebx, dpitch
         imul  eax, ebx
         add   eax, ddx
         add   edi, eax          //dptr

         mov   ebx, srclen
      @@FogNext:
         cmp   ebx, 0
         jbe   @@FinOne
         cmp   ebx, 8
         jb    @@FinOne   //@@EageNext

         db $0F,$6F,$06           /// movq  mm0, [esi]
         db $0F,$6F,$0F           /// movq  mm1, [edi]
         db $0F,$FE,$C8           /// paddd mm1, mm0
         db $0F,$7F,$0F           /// movq [edi], mm1

         sub   ebx, 8
         add   esi, 8
         add   edi, 8
         jmp   @@FogNext
      @@FinOne:
         inc   row
         jmp   @@NextRow

      @@Finish:
         db $0F,$77               /// emms
   end;
end;

//显示雾效果
procedure DrawFog (ssuf: TDirectDrawSurface; fogmask: PByte; fogwidth: integer);
var
   row: integer;
   ddsd: TDDSURFACEDESC;
   srclen, srcheight: integer;
   lpitch: integer;
   psource, pColorLevel: Pbyte;
begin
   if ssuf.Width > 900 then exit;
   case DarkLevel of
      1: pColorLevel := @HeavyDarkColorLevel;  //深夜
      2: pColorLevel := @LightDarkColorLevel;  //中等亮度
      3: pColorLevel := @DengunColorLevel;     //中午
      else exit;
   end;
   try
      ddsd.dwSize := SizeOf(ddsd);
      ssuf.Lock (TRect(nil^), ddsd);
      srclen := _MIN(ssuf.Width, fogwidth);
      srcheight := ssuf.Height;
      lpitch := ddsd.lPitch;
      psource := ddsd.lpSurface;
      asm
            mov   row, 0
         @@NextRow:
            mov   ebx, row
            mov   eax, srcheight
            cmp   ebx, eax
            jae   @@DrawFogFin

            mov   esi, psource      //esi = ddsd.lpSurface;
            mov   eax, lpitch
            mov   ebx, row
            imul  eax, ebx
            add   esi, eax

            mov   edi, fogmask      //edi = fogmask
            mov   eax, fogwidth
            mov   ebx, row
            imul  eax, ebx
            add   edi, eax

            mov   ecx, srclen
            mov   edx, pColorLevel

         @@NextByte:
            cmp   ecx, 0
            jbe   @@Finish

            movzx eax, [edi].byte   //fogmask

            imul  eax, 256
            movzx ebx, [esi].byte   // ddsd.lpSurface;
            add   eax, ebx
            mov   al, [edx+eax].byte //pColorLevel
            mov   [esi].byte, al

            dec   ecx
            inc   esi
            inc   edi
            jmp   @@NextByte

         @@Finish:
            inc   row
            jmp   @@NextRow

         @@DrawFogFin:
            db $0F,$77               /// emms
      end;
   finally
      ssuf.UnLock ();
   end;
end;

procedure DrawFog2(ssuf: TDirectDrawSurface; fogmask: PByte; fogwidth: integer);
var
  i, j, n, scount, srclen, offsvalue: integer;
  sddsd: TDDSurfaceDesc;
  sptr, fptr, pColorLevel: Pbyte;
  source: array[0..810] of byte;
begin
//  if ssuf.Width > SCREENWIDTH then exit;
   if ssuf.Width > 900 then exit;
  try
    sddsd.dwSize := SizeOf(sddsd);
    ssuf.Lock(TRect(nil^), sddsd);
    srclen := _MIN(ssuf.Width, fogwidth);
    case DarkLevel of
      0: pColorLevel := @HeavyDarkColorLevel;
      1: pColorLevel := @LightDarkColorLevel;
      2: pColorLevel := @DengunColorLevel;
    end;
    for i := 0 to ssuf.height - 1 do begin
      sptr := PBYTE(integer(sddsd.lpSurface) + i * sddsd.lPitch);
      fptr := PBYTE(integer(fogmask) + i * fogwidth);
      asm
               mov   scount, 0
               mov   esi, sptr
               lea   edi, source
            @@CopySource:
               mov   ebx, scount        //ebx = scount
               cmp   ebx, srclen
               jae   @@EndSourceCopy
               db $0F,$6F,$04,$1E       /// movq  mm0, [esi+ebx]
               db $0F,$7F,$07           /// movq  [edi], mm0

               xor   ebx, ebx
            @@Loop8:
               cmp   ebx, 8
               jz    @@EndLoop8
               mov   ecx, fptr
               add   ecx, scount
               add   ecx, ebx
               movzx eax, [ecx].byte
               cmp   eax, 30
               jae   @@Skip
               imul  eax, 256
               mov   ecx, eax


               movzx eax, [edi+ebx].byte
               mov   edx, pColorLevel
               add   edx, ecx
               movzx eax, [edx+eax].byte     //
               mov   [edi+ebx], al
            @@Skip:
               inc   ebx
               jmp   @@Loop8
            @@EndLoop8:

               mov   ebx, scount
               db $0F,$6F,$07           /// movq  mm0, [edi]
               db $0F,$7F,$04,$1E       /// movq  [esi+ebx], mm0

               add   edi, 8
               add   scount, 8
               jmp   @@CopySource
            @@EndSourceCopy:
               db $0F,$77               /// emms

      end;
    end;
  finally
    ssuf.UnLock();
  end;

end;


end.
