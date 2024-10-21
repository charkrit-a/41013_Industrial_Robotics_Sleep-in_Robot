clear all;
clf
clc;

Init();

%Base Position of the Robot 
X = 0;
Y = 0;
Z = 0;

%Axis Size
Xaxis = 2;
Yaxis = 2;
ZUpperAxis = 2;
ZLowerAxis = -0.57;

%Brick Positions
b1X = 0.4;
b1Y = 0;
b1Z = 0;

b2X = 0.3;
b2Y = 0.1765;
b2Z = 0;
%% Plot the Research 3 and the gripper

% Call the LinearResearch3
r = LinearUR3e (transl(X,Y,Z));
hold on 

% Take the base of end-effector 
qCurrent = r.model.getpos();
base = r.model.fkineUTS(qCurrent);


%Call the gripper with 2 fingers and plot the calculated base 
finger1 = LinearFinger(base*trotx(pi/2)); 
finger2 = LinearFinger(base*troty(pi)*trotx(-pi/2));

%% Plot the environment
EthanHelpers.PlotSafetyEnvironment(X, Y, Z, ZUpperAxis, ZLowerAxis)

%Plot the Kitchen table 

%Plot the Computer table 
%t2 = PlaceObject('computerTable.ply',[1, 0, 0.5]);
%verts = [get(t2,'Vertices'), ones(size(get(t2,'Vertices'),1),1)]* trotz(pi/2);
%verts(:,1) = verts(:,1)*0.0008;
%verts(:,2) = verts(:,2)*0.0008;
%verts(:,3) = verts(:,3)*0.0008;
%set(t2,'Vertices',verts(:,1:3))
%hold on;

axis([-Xaxis+X Xaxis+X -Yaxis+Y Yaxis+Y ZLowerAxis ZUpperAxis+Z]);
hold on
%% Place the bricks 
%brick{i} = [x y 0] %brick{i}arm = [x y z+0.15]
brick1 = [10*(b1X + X)/0.008, 10*(b1Y + Y)/0.008, 10*(b1Z + Z)/0.008];
brick1ArmPos = [10*(b1X + X)/0.008, 10*(b1Y + Y)/0.008, 10*(0.15 + Z)/0.008]; %z+0.15
brick1WallPos = [10*(-1 + X)/0.008, 10*(-0.1465 + Y)/0.008, 10*(0.15 + Z)/0.008]; %-x and z+0.15

brick2 = [10*(b2X + X)/0.008, 10*(b2Y + Y)/0.008, 10*(b2Z + Z)/0.008];
brick2ArmPos = [10*(b2X + X)/0.008, 10*(b2Y + Y)/0.008, 10*(b2Z+ 0.15 + Z)/0.008]; %z+0.15
brick2WallPos = [10*(-1 + X)/0.008, 10*(0 + Y)/0.008, 10*(0.15 + Z)/0.008]; %-x and z+0.15


%% Plot 9 bricks
[b1, b2] = EthanHelpers.PlotBrick(brick1, brick2);

%% A set of joints guess for ikcon to reach the bricks

%A set of joints guess for picking the brick
jointguess = deg2rad([0 180 -90 0 0 90 0]);

%A set of joints guess for dropping the brick
jointGuessEnd= deg2rad([0 180 60 30 0 -90 0]);

%% Move to first brick
qTraj = EthanHelpers.CreateTraj(r, brick1ArmPos, jointguess);

EthanHelpers.MoveToBrick(r,qTraj,finger1,finger2);

%% Picking the 1st brick and move it 

qTraj = EthanHelpers.CreateTraj(r, brick1WallPos,jointGuessEnd);

%Delete the initial brick
try delete(b1); 
catch ME
end

EthanHelpers.PlotPose(r,qTraj,5,finger1,finger2,brick1);

%% Move to 2nd brick position after dropping 1st brick

qTraj = EthanHelpers.CreateTraj(r, brick2ArmPos, jointguess);

EthanHelpers.MoveToBrick(r,qTraj,finger1,finger2);

%% Grasp 2nd brick
qTraj = EthanHelpers.CreateTraj(r, brick2WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b2); 
catch ME
end
EthanHelpers.PlotPose(r,qTraj,5,finger1,finger2,brick2);

%% Move back to starting position

qTraj = EthanHelpers.CreateTraj(r, brick2WallPos, jointguess);

EthanHelpers.MoveToBrick(r,qTraj,finger1,finger2);
