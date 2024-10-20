clear all;
clf
clc;

%Base Position of the Robot 
X = 0;
Y = 0;
Z = 0;

%Brick Positions
b1X = 0.4;
b1Y = 0;
b1Z = 0;

b2X = 0.3;
b2Y = 0.1765;
b2Z = 0;

b3X = 0.3;
b3Y = 0.353;
b3Z = 0;

b4X = 0.417;
b4Y = 0;
b4Z = 0;

b5X = 0.417;
b5Y = 0.1765;
b5Z = 0;

b6X = 0.417;
b6Y = 0.353;
b6Z = 0;

b7X = 0.534;
b7Y = 0;
b7Z = 0;

b8X = 0.534;
b8Y = 0.1765;
b8Z = 0;

b9X = 0.534;
b9Y = 0.353;
b9Z = 0;
%% Plot the LinearUR3e and the gripper

% Call the LinearResearch3
r = LinearResearch3 (transl(X,Y,Z));
hold on 

% Take the base of end-effector 
qCurrent = r.model.getpos();
base = r.model.fkineUTS(qCurrent);


%Call the gripper with 2 fingers and plot the calculated base 
finger1 = LinearFinger(base*trotx(pi/2)); 
finger2 = LinearFinger(base*troty(pi)*trotx(-pi/2));

%% Plot the environment
%Robot.PlotSafetyEnvironment(X, Y, Z)

%Plot the Kitchen table 
t1 = PlaceObject('kitchenTable.ply',[-1, Y, X]);
verts = [get(t1,'Vertices'), ones(size(get(t1,'Vertices'),1),1)]* trotx(-pi/2);
verts(:,1) = verts(:,1) *0.0008;
verts(:,2) = verts(:,2) *0.0008;
verts(:,3) = verts(:,3) *0.0008;
set(t1,'Vertices',verts(:,1:3))
hold on;

%s1 = PlaceObject('Shelf.ply',[X+1, Y, 0]);
%verts = [get(s1,'Vertices'), ones(size(get(s1,'Vertices'),1),1)]* trotx(-pi/2)* trotz(pi/2);
%verts(:,1) = verts(:,1)*0.0008;
%verts(:,2) = verts(:,2)*0.0008;
%verts(:,3) = verts(:,3)*0.0008;
%set(s1,'Vertices',verts(:,1:3))
%hold on;

%Plot the Computer table 
%t2 = PlaceObject('computerTable.ply',[1, 0, 0.5]);
%verts = [get(t2,'Vertices'), ones(size(get(t2,'Vertices'),1),1)]* trotz(pi/2);
%verts(:,1) = verts(:,1) * 0.01;
%verts(:,2) = verts(:,1) * 0.01;
%verts(:,3) = verts(:,3) * 0.01;
%set(t2,'Vertices',verts(:,1:3))
%hold on;

%Plot the Fire Extinguisher 
%e1 = PlaceObject('fireExtinguisher.ply',[-1, 0, 0.5]);
%verts = [get(e1,'Vertices'), ones(size(get(e1,'Vertices'),1),1)]* trotz(pi/2);
%verts(:,1) = verts(:,1) * 0.1;
%verts(:,2) = verts(:,1) * 0.1;
%verts(:,3) = verts(:,3) * 0.1;
%set(e1,'Vertices',verts(:,1:3))
%hold on;

axis([-2+X 2+X -2+Y 2+Y -1 1+Z]);
hold on
%% Place the bricks 
%brick{i} = [x y 0] %brick{i}arm = [x y z+0.15]
brick1 = [b1X + X, b1Y + Y, b1Z + Z];
brick1ArmPos = [b1X + X, b1Y + Y, 0.15 + Z]; %z+0.15
brick1WallPos = [-1 + X, -0.1465 + Y, 0.15 + Z]; %-x and z+0.15

brick2 = [b2X + X, b2Y + Y, b1Z + Z];
brick2ArmPos = [b2X + X, b2Y + Y, b2Z + 0.15 + Z];
brick2WallPos = [-1 + X, 0 + Y, 0.15 + Z];

brick3 = [b3X + X, b3Y + Y, 0 + Z];
brick3ArmPos = [b3X + X, b3Y + Y, b3Z+ 0.15 + Z];
brick3WallPos = [-1 + X, 0.1465 + Y, 0.15 + Z];

brick4 = [b4X + X, b4Y + Y, b1Z + Z];
brick4ArmPos = [b4X + X, b4Y + Y, b4Z + 0.15 + Z];
brick4WallPos = [-1 + X, -0.1465+ Y, 0.1815 + Z];

brick5 = [b5X + X, b5Y + Y, 0 + Z];
brick5ArmPos = [b5X + X, b5Y + Y, b5Z + 0.15 + Z];
brick5WallPos = [-1 + X, 0 + Y, 0.1815 + Z];

brick6 = [b6X + X, b6Y + Y, b1Z + Z];
brick6ArmPos = [b6X + X, b6Y + Y, b6Z + 0.15 + Z];
brick6WallPos = [-1 + X, 0.1465 + Y, 0.1815 + Z];

brick7 = [b7X + X, b7Y + Y, b1Z + Z];
brick7ArmPos = [b7X + X, b7Y + Y, b7Z + 0.15 + Z];
brick7WallPos = [-1 + X, -0.1465 + Y, 0.211 + Z];

brick8 = [b8X + X, b8Y + Y, b1Z + Z];
brick8ArmPos = [b8X + X, b8Y + Y, b8Z + 0.15 + Z];
brick8WallPos = [-1 + X, 0 + Y, 0.213 + Z];

brick9 = [b9X + X, b9Y + Y, b1Z + Z];
brick9ArmPos = [b9X + X, b9Y + Y, b9Z + 0.15 + Z];
brick9WallPos = [-1 + X, 0.1465 + Y, 0.213 + Z];

%% Plot 9 bricks
[b1, b2, b3, b4, b5, b6, b7, b8, b9] = Robot.PlotBrick(brick1, brick2, brick3, brick4, brick5, brick6, brick7, brick8, brick9);

%% A set of joints guess for ikcon to reach the bricks

%A set of joints guess for picking the brick
jointguess = deg2rad([0 180 -90 0 0 90 0]);

%A set of joints guess for dropping the brick
jointGuessEnd= deg2rad([0 180 60 30 0 -90 0]);

%A set of joints guess for dropping the brick 9
jointGuess9 = deg2rad([0 0 -90 0 0 90 0]);

%% Move to first brick
qTraj = Robot.CreateTraj(r, brick1ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);

%% Picking the 1st brick and move it 

qTraj = Robot.CreateTraj(r, brick1WallPos,jointGuessEnd);

%Delete the initial brick
try delete(b1); 
catch ME
end

Robot.PlotPose(r,qTraj,5,finger1,finger2,brick1);

%% Move to 2nd brick position after dropping 1st brick

qTraj = Robot.CreateTraj(r, brick2ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);

%% Grasp 2nd brick
qTraj = Robot.CreateTraj(r, brick2WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b2); 
catch ME
end
Robot.PlotPose(r,qTraj,5,finger1,finger2,brick2);

%% Move to 3rd brick position after dropping 2nd brick

qTraj = Robot.CreateTraj(r, brick3ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);


%% Grasp 3rd brick and Move it
qTraj = Robot.CreateTraj(r, brick3WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b3);
catch ME
end
Robot.PlotPose(r,qTraj,5,finger1,finger2,brick3);

%% Move to 4th brick position after dropping 3rd brick

qTraj = Robot.CreateTraj(r, brick4ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);

%% Grasp 4th brick and move it

qTraj = Robot.CreateTraj(r, brick4WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b4); 
catch ME
end

Robot.PlotPose(r,qTraj,5,finger1,finger2,brick4);
%% Move to 5th brick position after dropping 4th brick

qTraj = Robot.CreateTraj(r, brick5ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);
%% Grasp 5th brick and move it 

qTraj = Robot.CreateTraj(r, brick5WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b5); 
catch ME
end

Robot.PlotPose(r,qTraj,5,finger1,finger2,brick5);


%% Move to 6th brick position after dropping 5th brick

qTraj = Robot.CreateTraj(r, brick6ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);
%% Grasp 6th brick and move it

qTraj = Robot.CreateTraj(r, brick6WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b6);
catch ME
end
Robot.PlotPose(r,qTraj,5,finger1,finger2,brick6);
%% Move to 7th brick position after dropping 6th brick

qTraj = Robot.CreateTraj(r, brick7ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);

%% Grasp 7th brick

qTraj = Robot.CreateTraj(r, brick7WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b7); 
catch ME
end
Robot.PlotPose(r,qTraj,5,finger1,finger2,brick7);

%% Move to 8th brick position after dropping 7th brick

qTraj = Robot.CreateTraj(r, brick8ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);
%% Grasp 8th brick
qTraj = Robot.CreateTraj(r, brick8WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b8); 
catch ME
end
Robot.PlotPose(r,qTraj,5,finger1,finger2,brick8);

%% Move to 9th brick position after dropping 8th brick

qTraj = Robot.CreateTraj(r, brick9ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);

%% Grasp 9th brick

qTraj = Robot.CreateTraj(r, brick9WallPos, jointGuessEnd);

%Delete the initial brick
try delete(b9);
catch ME
end

Robot.PlotPose(r,qTraj,5,finger1,finger2,brick9);

%% Move back to starting position

qTraj = Robot.CreateTraj(r, brick9ArmPos, jointguess);

Robot.MoveToBrick(r,qTraj,finger1,finger2);
