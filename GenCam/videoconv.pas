unit videoconv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  PRGB24Pixel = ^TRGB24Pixel;
  TRGB24Pixel = packed record
    Red:   Byte;
    Green: Byte;
    Blue:  Byte;
  end;

  PBGR24Pixel = ^TBGR24Pixel;
  TBGR24Pixel = packed record
    Blue:  Byte;
    Green: Byte;
    Red:   Byte;
  end;

procedure YUYV_to_Gray(src: PLongWord; dest: PLongWord; size: integer);
procedure YUV420_to_Gray(src: PByte; dest: PLongWord; size: integer);
procedure RGB24_to_TrueColor(src: PRGB24Pixel; dest: PLongWord; size: Integer);
procedure BGR24_to_TrueColor(src: PRGB24Pixel; dest: PLongWord; size: Integer);


implementation


// this format (like many others) is not guaranteed
// to be supported by all devices.
procedure YUYV_to_Gray(src: PLongWord; dest: PLongWord; size: integer);
var i, r,g,b: integer;
begin
  for i := 0 to (size div 2) - 1 do begin
    g := src^ and $FF;
    r := g;
    b := g;
    dest^ := (r shl 16) or (g shl 8) or (b);
    Inc(dest);
    g := (src^ shr 16) and $FF;
    r := g;
    b := g;
    dest^ := (r shl 16) or (g shl 8) or (b);
    Inc(src);
    Inc(dest);
  end;
end;

// when using the libv4l wrapper then YUV420 is always
// amongst the supported formats, even if the camera
// would not support it natively.
procedure YUV420_to_Gray(src: PByte; dest: PLongWord; size: integer);
var i, r,g,b: integer;
begin
  // Y, U and V are not interleaved, they are in continuous
  // blocks. We read the first block containing Y (8 bit per pixel)
  // and simply ignore the rest.
  for i := 0 to size -1 do begin
    g := src[i];
    r := g;
    b := g;
    dest[i] := (r shl 16) or (g shl 8) or (b);
  end;
end;

// when using the libv4l wrapper then RGB24 is always
// amongst the supported formats, even if the camera
// would not support it natively.
procedure RGB24_to_TrueColor(src: PRGB24Pixel; dest: PLongWord; size: Integer);
var i: integer;
begin
  for i := 0 to size -1 do begin
    dest[i] :=  (src[i].Red shl 16) or (src[i].Green shl 8) or src[i].Blue;
  end;
end;

// when using the libv4l wrapper then BGR24 is always
// amongst the supported formats, even if the camera
// would not support it natively.
procedure BGR24_to_TrueColor(src: PRGB24Pixel; dest: PLongWord; size: Integer);
var i: integer;
begin
  //move(src^, dest^, size*4);
  for i := 0 to size -1 do begin
    // this is the reason why often BGR instead of RGB
    // is used, we don't need shifting like above, we can
    // simply dump entire longwords into their new locations.
    dest[i] := PLongWord(@src[i])^;
  end;
end;


end.

