clear all;
clf
clc;

Init();

%Base Position of the Robot 
X = -0.3;
Y = 0;
Z = 0;

%Axis Size       
XUpperAxis = 3;
YLowerAxis = -3;
ZUpperAxis = 2;
ZLowerAxis = -0.57;

%obj Positions
b1X = 0.4;
b1Y = 0;
b1Z = 0;

b2X = 0.3;
b2Y = 0.1765;
b2Z = 0;
%% Plot the Research 3 and the gripper

% Call the LinearResearch3
r = LinearUR10e (transl(X,Y,Z));
r2 = UR3(transl(0.5,0.2,0)*trotz(pi/2));
hold on 

% Take the base of end-effector 
qCurrent = r.model.getpos();
base = r.model.fkineUTS(qCurrent);


%Call the gripper with 2 fingers and plot the calculated base 
finger1 = LinearFinger(base*trotx(pi/2)); 
finger2 = LinearFinger(base*troty(pi)*trotx(-pi/2));

%% Plot the environment
EthanHelpers.PlotSafetyEnvironment(X, Y, Z, XUpperAxis, YLowerAxis, ZUpperAxis, ZLowerAxis)

%% Place the objs 
XMilk = -1.8+X;
XMilkOffset = -0.14;
YMilk = 0.7;

%obj{i} = [x y 0] %obj{i}arm = [x y z+0.15]
obj1 = [XMilk, YMilk, 0.15];
obj1ArmPos = [XMilk, YMilk, 0.15+0.15 ]; %z+0.15
obj1WallPos = [b2X + X, b2Y + Y, b2Z + 0.15 + Z]; %-x and z+0.15

obj2 = [b2X + X, b2Y + Y, b1Z + Z];
obj2ArmPos = [b2X + X, b2Y + Y, b2Z + 0.15 + Z];
obj2WallPos = [-1 + X, 0 + Y, 0.15 + Z];


%% Plot 9 objs
[b1, b2] = EthanHelpers.Plotobj(obj1, obj2);

%% A set of joints guess for ikcon to reach the objs

%A set of joints guess for picking the obj
jointguess = deg2rad([0 180 -90 0 0 90 0]);

%A set of joints guess for dropping the obj
jointGuessEnd= deg2rad([0 180 60 30 0 -90 0]);

%A set of joints guess for picking the obj
jointguess2 = deg2rad([0 180 -90 0 0 90 0]);

%A set of joints guess for dropping the obj
jointGuessEnd2 = deg2rad([0 180 60 30 0 -90 0]);

%% Move Ur10e to first obj
qTraj = EthanHelpers.CreateTraj(r, obj1ArmPos, jointguess);

EthanHelpers.MoveToobj(r,qTraj,finger1,finger2);

%% Picking the 1st obj and move it 

qTraj = EthanHelpers.CreateTraj(r, obj1WallPos,jointGuessEnd);

%Delete the initial obj
try delete(b1); 
catch ME
end

EthanHelpers.PlotPose(r,qTraj,5,finger1,finger2,obj1);
%% Move Ur3 to first obj
qTraj2 = EthanHelpers.CreateTraj2(r, obj1ArmPos, jointguess2);

EthanHelpers.MoveToobj(r,qTraj,finger1,finger2);

%% Picking the 1st obj and move it 

qTraj = EthanHelpers.CreateTraj(r, obj1WallPos,jointGuessEnd2);

%Delete the initial obj
try delete(b1); 
catch ME
end

EthanHelpers.PlotPose(r,qTraj,5,finger1,finger2,obj1);

%% Move to 2nd obj position after dropping 1st obj

qTraj = EthanHelpers.CreateTraj(r, obj2ArmPos, jointguess);

EthanHelpers.MoveToobj(r,qTraj,finger1,finger2);

%% Grasp 2nd obj
qTraj = EthanHelpers.CreateTraj(r, obj2WallPos, jointGuessEnd);

%Delete the initial obj
try delete(b2); 
catch ME
end
EthanHelpers.PlotPose(r,qTraj,5,finger1,finger2,obj2);

%% Move back to starting position

qTraj = EthanHelpers.CreateTraj(r, obj2WallPos, jointguess);

EthanHelpers.MoveToobj(r,qTraj,finger1,finger2);
