unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, IniPropStorage, SdpoSerial, LCLIntf, LCLType, ComCtrls, channels,
  robot, math;

type

  { TFMain }

  TFMain = class(TForm)
    BOpenSerial: TButton;
    BCloseSerial: TButton;
    BRobotStop: TButton;
    BSendRaw: TButton;
    BConfigSet: TButton;
    BSetRobotPose: TButton;
    BRobotSetVW: TButton;
    CBRawDebug: TCheckBox;
    EditRobotV: TEdit;
    EditRobotW: TEdit;
    EditRobotX: TEdit;
    EditRobotSetX: TEdit;
    EditRobotSetV: TEdit;
    EditRobotY: TEdit;
    EditRobotTheta: TEdit;
    EditRobotSetTheta: TEdit;
    EditRobotSetY: TEdit;
    EditRobotSetW: TEdit;
    EditWheelRadius: TEdit;
    EditSerialName: TEdit;
    EditSendRaw: TEdit;
    EditWheelDistance: TEdit;
    IniPropStorage: TIniPropStorage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    MemoDebug: TMemo;
    PageControl: TPageControl;
    Serial: TSdpoSerial;
    ShapeSerialState: TShape;
    StatusBar: TStatusBar;
    TabDebug: TTabSheet;
    TabConfig: TTabSheet;
    TabControl: TTabSheet;
    procedure BCloseSerialClick(Sender: TObject);
    procedure BConfigSetClick(Sender: TObject);
    procedure BOpenSerialClick(Sender: TObject);
    procedure BRobotSetVWClick(Sender: TObject);
    procedure BRobotStopClick(Sender: TObject);
    procedure BSendRawClick(Sender: TObject);
    procedure BSetRobotPoseClick(Sender: TObject);
    procedure EditSendRawKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SerialRxData(Sender: TObject);
  private
    procedure processFrame(channel: char; value: integer; source: integer);
    procedure ShowSerialState;
    { private declarations }
  public

    SerialChannels: TChannels;
    procedure SendMessage(c: char; val: integer);
  end;

var
  FMain: TFMain;

  RS, RS_ant: TRobotState;
  RC: TRobotConf;

implementation

{$R *.lfm}





{ TFMain }


procedure TFMain.ShowSerialState;
begin
  if Serial.Active then begin
    ShapeSerialState.Brush.Color := clGreen;
  end else begin
    ShapeSerialState.Brush.Color := clRed;
  end;
end;

procedure TFMain.SendMessage(c: char; val: integer);
begin
  Serial.WriteData(c + IntToHex(word(Val) and $FFFF, 4));
end;


procedure TFMain.BOpenSerialClick(Sender: TObject);
begin
  Serial.Device := EditSerialName.Text;
  Serial.Open;
  ShowSerialState();
end;

procedure TFMain.BRobotSetVWClick(Sender: TObject);
var Vref, Wref: double;
    V1, V2: double;
    Odo1ref, Odo2ref: integer;
begin
//  RS.vwheel[i] := RS.odo[i] * RC.wheel_radius / (RC.ticks_per_rad * RC.dt);
  Vref := StrToFloat(EditRobotSetV.Text);
  Wref := StrToFloat(EditRobotSetW.Text);

  V1 := Vref + Wref * RC.wheel_dist / 2;
  V2 := Vref - Wref * RC.wheel_dist / 2;

  Odo1ref := round(V1 * RC.ticks_per_rad * RC.dt / RC.wheel_radius);
  Odo2ref := round(V2 * RC.ticks_per_rad * RC.dt / RC.wheel_radius);

  SendMessage('R', Odo1ref);
  SendMessage('S', Odo2ref);

  MemoDebug.Lines.Add(format('OdoRef: %d, %d (%g)',[Odo1ref, Odo2ref, RC.dt]));

end;

procedure TFMain.BRobotStopClick(Sender: TObject);
begin
  SendMessage('R', 0);
  SendMessage('S', 0);
end;

procedure TFMain.BSendRawClick(Sender: TObject);
begin
  Serial.WriteData(EditSendRaw.Text);
end;

procedure TFMain.BSetRobotPoseClick(Sender: TObject);
begin
  RS.x := StrToFloat(EditRobotSetX.Text);
  RS.y := StrToFloat(EditRobotSetY.Text);
  RS.theta := StrToFloat(EditRobotSetTheta.Text);
end;

procedure TFMain.EditSendRawKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    BSendRaw.Click();
  end;
end;

procedure TFMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  BRobotStop.Click();
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  SerialChannels := TChannels.Create(@processFrame);
  RC.dt := 0.04;
  RC.wheel_dist := 0.188;   //
  RC.wheel_radius := 0.04105;   //in meters (SI)
  RC.ticks_per_rad := 305.5775;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  ShowSerialState();
  BConfigSet.Click();
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  SerialChannels.Free;
end;



procedure TFMain.SerialRxData(Sender: TObject);
var s: string;
begin
  s := Serial.ReadData;
  if s = '' then exit;

  SerialChannels.ReceiveData(s);

  //MemoDebug.VertScrollBar.Position := MemoDebug.VertScrollBar.Range;
  if CBRawDebug.Checked then begin
    MemoDebug.Text := MemoDebug.Text + s;
    MemoDebug.SelStart:=Length(MemoDebug.Text);
    while MemoDebug.Lines.Count > 1000 do begin
      MemoDebug.Lines.Delete(0);
    end;
  end;
end;

procedure TFMain.BCloseSerialClick(Sender: TObject);
begin
  Serial.Close;
  ShowSerialState();
end;

procedure TFMain.BConfigSetClick(Sender: TObject);
begin
  RC.wheel_radius := StrToFloat(EditWheelRadius.Text);
  RC.wheel_dist := StrToFloat(EditWheelDistance.Text);
end;



procedure TFMain.processFrame(channel: char; value: integer; source: integer);
var i, iIBat, iVbat: integer;
    Vbat: double;
    s: string;
    Vodo: Smallint;
begin
  //MemoDebug.Text := MemoDebug.Text + channel;
  if channel = 'i' then begin
  //end else if channel = 'r' then begin
    // if the arduino was reset ...
  end else if channel = 'v' then begin
    RS.odo[0] := Smallint(value);
    //EditVOdo.Text:=IntToStr(RS.odo[0]);
  end else if channel = 'w' then begin
    RS.odo[1] := Smallint(value);
    //EditVOdo.Text:=IntToStr(RS.o[0]);

    RS_ant := RS;
    DifferentialOdo(RS, RS_ant, RC);
    EditRobotV.Text :=  format('%.4g', [RS.v]);
    EditRobotW.Text :=  format('%.4g', [RS.w]);

    EditRobotX.Text :=  format('%.4g', [RS.x]);
    EditRobotY.Text :=  format('%.4g', [RS.y]);
    EditRobotTheta.Text :=  format('%.4g', [radtodeg(RS.theta)]);

  end else if channel = 'u' then begin
    iVbat := value shr 16;
    iIBat := value and $FFFF;
    //EditBatteryCurrent.Text := IntToStr(iIBat);
    //EditBatteryCurrent.Text := format('%.2f', [iIBat / 103 * 0.53]);
    //EditBatteryVoltage.Text := IntToStr(iVBat);
    //EditBatteryVoltage.Text := format('%.2f', [iVbat / 390 * 10.0]);
  end else if channel in ['s', 't'] then begin
    i := 1 + ord(channel) - ord('r');

  end;
end;
end.

