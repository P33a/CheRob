unit robot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const NUM_MOTORS = 2;
const NUM_SONARS = 2;

type

TRobotConf = record
  wheel_radius: double;
  wheel_dist: double;
  ticks_per_rad: double;
  dt: double;
  speed_of_sound: double;
end;

TRobotState = record
  odo: array [0..NUM_MOTORS - 1] of Smallint;
  vwheel: array [0..NUM_MOTORS - 1] of double;
  sonar_raw: array [0..NUM_SONARS - 1] of Smallint;
  sonar: array [0..NUM_SONARS - 1] of double;
  min_sonar, delta_sonar: double;

  V, W: double;

  x, y, theta: double;

  S: double
end;

TStateMachine = record
  tin, Sin, Anglein: double;
  state: string;
end;

procedure DifferentialOdo(var RS, RS_ant: TRobotState; var RC: TRobotConf);

procedure SetNewState(var SM: TStateMachine; new_state: string);

implementation

procedure DifferentialOdo(var RS, RS_ant: TRobotState; var RC: TRobotConf);
var i: integer;
    theta: double;
begin
  for i := 0 to NUM_MOTORS - 1 do begin
    RS.vwheel[i] := RS.odo[i] * RC.wheel_radius / (RC.ticks_per_rad * RC.dt);
  end;

  RS.V := (RS.vwheel[0] + RS.vwheel[1]) / 2;
  RS.W := (RS.vwheel[0] - RS.vwheel[1]) / RC.wheel_dist;

  RS.theta := RS_ant.theta + RC.dt * RS.W;
  theta := (RS_ant.theta + RS.theta) / 2;

  RS.x := RS_ant.x + RC.dt * RS.v * cos(theta);
  RS.y := RS_ant.y + RC.dt * RS.v * sin(theta);
  RS.S += RC.dt * RS.v;

  // Normalize theta
end;


procedure SetNewState(var SM: TStateMachine; new_state: string);
begin
  SM.tin := GetTickCount64();
  SM.state := new_state;
end;

end.

