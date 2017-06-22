unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SdpoVideo4L2, VideoDev2, LCLIntf, ComCtrls, ValEdit, Grids, videoconv,
  rlan, IniPropStorage, TAGraph, TASeries, lNetComponents, CamFeatures, lNet,
  BGRABitmap, BGRABitmapTypes, math;

type
  PTRGBAcc = ^TRGBAcc;
  TRGBAcc = record
    R, G, B, L, S: integer;
    //col: integer;
    //suppressed: boolean;
  end;

  TRGBAccBand = record
    Y, Xi, Xf, LineCount: integer;
    pix: array of TRGBAcc;
    //count: integer;
  end;

  TRGBAccBands = array of TRGBAccBand;

  TScanSeg = record
    Y, Xi, Xf: integer;
  end;

  TScanSegs = array of TScanSeg;


  { TFMain }

  TFMain = class(TForm)
    BSetScanLines: TButton;
    CBVideoActive: TCheckBox;
    Chart: TChart;
    CBChartActive: TCheckBox;
    CBShowImage: TCheckBox;
    LineSeriesProc: TLineSeries;
    LineSeriesRED: TLineSeries;
    EditDevice: TEdit;
    IniPropStorage: TIniPropStorage;
    MemoDebug: TMemo;
    SGScanLines: TStringGrid;
    UDPRob: TLUDPComponent;
    Memo: TMemo;
    StatusBar: TStatusBar;
    Video: TSdpoVideo4L2;
    procedure BSetScanLinesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SendCameraMessage(mtype: integer);
    procedure CBVideoActiveChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure VideoFrame(Sender: TObject; FramePtr: PByte);
    //procedure qsort(var a : TMaxColorArray);
  private
    procedure ProcessLines(Image: TBGRABitmap);
    { private declarations }
  public
    { public declarations }
    FrameRate: integer;
    FrameTime : DWord;

    AccBands: TRGBAccBands;
    AccBandsCount: integer;

    ScanSegs: TScanSegs;
    ScanSegsCount: integer;
  end;

var
  FMain: TFMain;
  NetOutBuf: TUDPBuffer;


implementation

uses showimage;

{ TFMain }

procedure TFMain.SendCameraMessage(mtype: integer);
var i, version: integer;
    ld: string;
begin
  version := 1;
  ClearUDPBuffer(NetOutBuf);
  NetPutByte(NetOutBuf, mtype);
  NetPutByte(NetOutBuf, version);
  NetPutWord(NetOutBuf, ScanSegsCount);
  for i := 0 to ScanSegsCount - 1 do begin
    NetPutWord(NetOutBuf, ScanSegs[i].Y);
    NetPutWord(NetOutBuf, ScanSegs[i].Xi);
    NetPutWord(NetOutBuf, ScanSegs[i].Xf);
  end;

  UDPRob.Send(NetOutBuf.data, NetOutBuf.MessSize, '127.0.0.1:9020');
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  UDPRob.Disconnect();
end;

procedure TFMain.BSetScanLinesClick(Sender: TObject);
var i: integer;
begin
  AccBandsCount := SGScanLines.RowCount - 1;
  SetLength(AccBands, AccBandsCount);
  for i := 0 to AccBandsCount - 1 do begin
    AccBands[i].Y := StrToInt(SGScanLines.Cells[0, i + 1]);
    AccBands[i].Xi := StrToInt(SGScanLines.Cells[1, i + 1]);
    AccBands[i].Xf := StrToInt(SGScanLines.Cells[2, i + 1]);
    AccBands[i].LineCount := StrToInt(SGScanLines.Cells[3, i + 1]);
    SetLength(AccBands[i].pix, Video.Width);
  end;

  SetLength(ScanSegs, 512);
  ScanSegsCount := 0;

  Memo.Lines.Add(format('AccBandsCount: %d',[AccBandsCount]));
  for i := 0 to AccBandsCount - 1 do begin
    Memo.Lines.Add(format('Y: %d, Xi:%d, Xf:%d, lines:%d',[accBands[i].Y, accBands[i].Xi, accBands[i].Xf, accBands[i].LineCount]));
  end;
end;


procedure TFMain.FormShow(Sender: TObject);
begin
  if FileExists('scanlines.xml') then begin
    SGScanLines.LoadFromFile('scanlines.xml');
  end;
  BSetScanLines.Click();
end;


procedure TFMain.CBVideoActiveChange(Sender: TObject);
var s: string;
begin
  if CBVideoActive.Checked then begin
    Video.Device:=EditDevice.Text;

    FShowImage.Width := Video.Width;
    FShowImage.Height := Video.Height;

    FShowImage.Image.SetSize(Video.Width, Video.Height);
    FShowImage.Show;

    Video.SetDebugList(Memo.Lines);
    Video.Open;

    Video.GetUserControls;

    FCamFeatures.Video := Video;
    FCamFeatures.show;
    //Video.SetFeatureValue(V4L2_CID_EXPOSURE_AUTO, V4L2_EXPOSURE_AUTO);

    Video.SetFeatureValue(V4L2_CID_EXPOSURE_AUTO, V4L2_EXPOSURE_MANUAL);
    //Video.SetFeatureValue(V4L2_CID_AUTOGAIN, 0);
    //Video.SetFeatureValue(V4L2_CID_AUTO_WHITE_BALANCE, 0);

    WriteStr(S, Video.PixelFormat);
    Memo.Lines.Add('format: ' + s);

  end else begin
    Video.Close;
    FShowImage.Close;
  end;
end;

procedure TFMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SGScanLines.SaveToFile('scanlines.xml');

  FCamFeatures.Close;
  Video.Close;
  FShowImage.Close;
end;

procedure TFMain.FormCreate(Sender: TObject);
var path: string;
begin
  DefaultFormatSettings.DecimalSeparator := '.';

  path := ExtractFilePath(Application.ExeName) + DirectorySeparator;
  if Paramcount > 0 then begin
    IniPropStorage.IniFileName := path + ParamStr(1);
  end else begin
    IniPropStorage.IniFileName := path + 'config.ini';
  end;

  UDPRob.Connect('127.0.0.1', 9021);
end;

procedure TFMain.ProcessLines(Image: TBGRABitmap);
var i, j, k, idx: integer;
    BGRAPixel: TBGRAPixel;
    w, xbi, xbf, black, old_black: integer;
    tresh: double;
begin
  ScanSegsCount := 0;

  if CBChartActive.Checked then begin
    LineSeriesRED.Clear;
    LineSeriesProc.Clear;
  end;
  idx := max(0, SGScanLines.Selection.Top - 1);

  for k := 0 to AccBandsCount - 1 do begin
    // Accumulate the RGB components over the selected lines
    AccBands[k].pix[AccBands[k].Xi].S := 0;
    for i := AccBands[k].Xi to AccBands[k].Xf do begin
      with AccBands[k].pix[i] do begin
        r := 0;
        g := 0;
        b := 0;

        // Sum all pixels int the column
        for j := 0 to AccBands[k].lineCount - 1 do begin
          BGRAPixel := Image.ScanAtInteger(i, AccBands[k].Y + j);
          r := r + BGRAPixel.Red;
          g := g + BGRAPixel.Green;
          b := b + BGRAPixel.Blue;
        end;

        if AccBands[k].lineCount > 0 then begin
          L := (R + 2* G + B) div ( 4 * AccBands[k].lineCount);
          R := R div AccBands[k].lineCount;
          G := G div AccBands[k].lineCount;
          B := B div AccBands[k].lineCount;
          if i > AccBands[k].Xi then S := AccBands[k].pix[i - 1].S + L;
        end;

        if (k = idx) and CBChartActive.Checked then begin
          // Show in the chart
          LineSeriesRED.AddXY(i, L);
        end;

      end;
    end;

    w := 50;
    black := 300;
    for i := AccBands[k].Xi to AccBands[k].Xf do begin
      with AccBands[k].pix[i] do begin
        xbi := max(i - w, AccBands[k].Xi);
        xbf := min(i + w, AccBands[k].Xf);
        tresh :=  (AccBands[k].pix[xbf].S  - AccBands[k].pix[xbi].S) / (xbf -xbi);

        old_black := black;

        if (L < tresh - 20) then begin
          black := 0;
        end else begin
          black := 300;
        end;

        // Start Black Block
        if (old_black > 0) and (black = 0) then begin
          ScanSegs[ScanSegsCount].Y := AccBands[k].Y;
          ScanSegs[ScanSegsCount].Xi := i;
        end;

        // End Black block
        if (old_black = 0) and (black > 0) then begin
          ScanSegs[ScanSegsCount].Xf := i;
          inc(ScanSegsCount);
        end;

        if (k = idx) and CBChartActive.Checked then begin
          // Show in the chart
          LineSeriesProc.AddXY(i, Black);
        end;

      end;

    end;

    // Show sampled lines
    for j := 0 to AccBands[k].lineCount do begin
      BGRAPixel.Blue := 255;
      BGRAPixel.Green := 255;
      BGRAPixel.Red := 0;
      image.SetPixel(1, AccBands[k].Y + j, BGRAPixel);
    end;
  end;

  MemoDebug.Clear;
  MemoDebug.Lines.Add(IntToStr(ScanSegsCount));
  for i := 0 to ScanSegsCount - 1 do begin
    MemoDebug.Lines.Add(format('%d, (%d, %d)', [ScanSegs[i].Y, ScanSegs[i].Xi, ScanSegs[i].Xf]));
  end;

end;


procedure TFMain.VideoFrame(Sender: TObject; FramePtr: PByte);
var i, j, k: integer;
begin
  FrameRate:=round(1/((GetTickCount-FrameTime)/1000));
  FrameTime:=GetTickCount;
  StatusBar.SimpleText := format('(%d, %d) %d fps', [video.Width, Video.Height, FrameRate]);

  case Video.PixelFormat of
    uvcpf_YUYV:
      YUYV_to_Gray(PLongWord(FramePtr), PLongWord(FShowImage.Image.Data), Video.Width * Video.Height);
    uvcpf_YUV420:
      YUV420_to_Gray(FramePtr, pointer(FShowImage.Image.Data), Video.Width * Video.Height);
    uvcpf_RGB24:
      BGR24_to_TrueColor(PRGB24Pixel(FramePtr), pointer(FShowImage.image.Data), Video.Width * Video.Height);
    uvcpf_BGR24:
      RGB24_to_TrueColor(PRGB24Pixel(FramePtr), pointer(FShowImage.image.Data), Video.Width * Video.Height);
    uvcpf_BGR32:
      move(PByte(FramePtr)^, PByte(FShowImage.image.Data)^, Video.Width * Video.Height * 4);
    uvcpf_RGB32:
      move(PByte(FramePtr)^, PByte(FShowImage.image.Data)^, Video.Width * Video.Height * 4);
  end;

  ProcessLines(FShowImage.image);
  SendCameraMessage(0);

  if CBShowImage.Checked then begin
    FShowImage.Refresh;
  end;
end;

initialization
  {$I main.lrs}

end.

//sudo modprobe bcm2835-v4l2
// or
//

