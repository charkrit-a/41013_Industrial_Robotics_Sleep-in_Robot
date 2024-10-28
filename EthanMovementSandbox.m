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

%Brick Positions
b1X = 0.4;
b1Y = 0;
b1Z = 0;

b2X = 0.3;
b2Y = 0.1765;
b2Z = 0;
%% Plot the Research 3 and the gripper

% Call the LinearResearch3
link(1) = Link([pi     0       0       pi/2    1]); % PRISMATIC Link
link(2) = Link('d',	0.1807,'a',       -0.01,'alpha', pi/2,'qlim', deg2rad([-360 360]), 'offset', 0);
link(3) = Link('d', 0     ,'a',-0.6127,'alpha',     0,'qlim', deg2rad([-360 360]), 'offset', 0);
link(4) = Link('d', 0     ,'a',-0.57155,'alpha',    0,'qlim', deg2rad([-360 360]), 'offset', 0);
link(5) = Link('d',0.17,'a',       0,'alpha', pi/2,'qlim', deg2rad([-360 360]), 'offset', 0);
link(6) = Link('d',0.117,'a',       0,'alpha',-pi/2,'qlim', deg2rad([-360,360]), 'offset', 0);
link(7) = Link('d',0.1125,'a',     0,'alpha',    0,'qlim', deg2rad([-360,360]), 'offset', 0);
link(1).qlim = [-0.8 -0.01];
link(2).qlim = [-360 360];
link(3).qlim = [-360 360];
link(4).qlim = [-360 360];
link(5).qlim = [-360 360];
link(6).qlim = [-360 360];
link(7).qlim = [-360 360];
link(3).offset = -pi/2;
link(5).offset = -pi/2;
link(7).offset = -pi/2;

robot = SerialLink([link(1) link(2) link(3) link(4) link(5) link(6) link(7)],'name','UR10e') * trotx(pi/2) * troty(pi/2);
hold on 

q = zeros(1,7);       
robot.plot(q);       
robot.teach();

%% Plot the environment
EthanHelpers.PlotSafetyEnvironment(X, Y, Z, XUpperAxis, YLowerAxis, ZUpperAxis, ZLowerAxis)