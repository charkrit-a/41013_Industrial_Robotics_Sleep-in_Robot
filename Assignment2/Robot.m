classdef Robot < handle

    methods (Static) 
        
        %Function to generate set of q to and create the trajectory using jtraj
        function qTrajec = CreateTraj(robot,brickPosition,jointGuess)

            steps = 100;

            qCurrent = robot.model.getpos();

            T = transl(brickPosition)*trotx(pi)*troty(0)*trotz(0);
                
            %Joint states that pick up the brick
            qMove = wrapToPi(robot.model.ikcon(T,jointGuess));

            qTrajec = jtraj(qCurrent,qMove,steps);

        end
        
        %Function to move the base of the gripper with the end-effector
        function MoveFinger(r,q,finger1,finger2,i)

            q_Finger1 = finger1.model.getpos();
            q_Finger2 = finger2.model.getpos();
            q_Finger1End = deg2rad([25 0]);
            q_Finger2End = deg2rad([25 0]);
            q_Finger1Trajectory = jtraj(q_Finger1,q_Finger1End,100);
            q_Finger2Trajectory = jtraj(q_Finger2,q_Finger2End,100);
            base = r.model.fkineUTS(q);
            
          %Update the base of the gripper and also move the finger simutaneously
            finger1.model.base=base*trotx(pi/2);
            finger1.model.animate(q_Finger1Trajectory(i,:));

            finger2.model.base=base*troty(pi)*trotx(-pi/2);
            finger2.model.animate(q_Finger2Trajectory(i,:));

        end
        
        %Function to move the arm from current position to pick up the brick
        function  MoveToBrick(r,qTrajec,finger1,finger2)

            for i = 1:size(qTrajec,1)
                q = qTrajec(i,:);
                r.model.animate(q);
                MoveFinger(r,q,finger1,finger2,i);
                pause(0.01)
            end

        end



        % This function has 5 input:
        % self = Robot Arm (LinearUR3e)
        % qArray = The set of q generated by the inverse kinematic from the start and end position
        % f1 = Finger 1
        % f2 = Finger 2
        % bricknum = The Pose of the generated bricks
        function PlotPose(self,qArray,freq,f1,f2,bricknum)

            num = 1;
            %Reads the Brick file in faces, vertices, and color of it
            [f,v,data] = plyread('HalfSizedRedGreenBrick.ply','tri');
            vertColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            BrickVertex = size(v,1);
            BrickMesh_h = trisurf(f,v(:,1)+bricknum(1,1),v(:,2)+bricknum(1,2), v(:,3)+bricknum(1,3) ...
                ,'FaceVertexCData',vertColours,'EdgeColor','none','EdgeLighting','none');


            for i=1:size(qArray,1)

                % Take the forward kinematic for the brick
                brick = self.model.fkineUTS(qArray(i,:));

                %BrickPose is the 4x4 matrix, transl(0,0,0.1) is move the brick down 0.1 in the Z direction
                %to make it look like it is grasped by the gripper
                BrickPose = brick*transl(0,0,0.1) ;

                %MOVE THE BRICK. Update the point then multiply it to the vertices
                UpdatedPoints = [BrickPose * [v,ones(BrickVertex,1)]']';

                %The vertices are all the rows and 1 to 3 columns of the UpdatedPoints
                BrickMesh_h.Vertices = UpdatedPoints(:,1:3);

                %Animate the robot arm
                self.model.animate(qArray(i,:));

                %Create a set of joint states to make the finger open from 0 degree to 20
                %Gets current angle position of finger 1 and 2
                q_Finger1 = f1.model.getpos();
                q_Finger2 = f2.model.getpos();
                %Outlines desired position of fingers 1 and 2
                q_Finger1End = deg2rad([20 0]);
                q_Finger2End = deg2rad([20 0]);
                %Develops trajectory of fingers 1 and 2 based on current vs desired angles
                q_Finger1Trajectory = jtraj(q_Finger1,q_Finger1End,100);
                q_Finger2Trajectory = jtraj(q_Finger2,q_Finger2End,100);


                %Transform the gripper by update the base and OPEN THE FINGER SIMUTANEOUSLY
                base = self.model.fkineUTS(qArray(i,:));
                %Updates Gripper 1 to tip of Arm
                f1.model.base = base*trotx(pi/2);
                f1.model.animate(q_Finger1Trajectory(i,:));
                %Updates Gripper 1 to tip of Arm
                f2.model.base = base*troty(pi)*trotx(-pi/2);
                f2.model.animate(q_Finger2Trajectory(i,:))

                pause(0.0005);

                num = num + 1;

            end
        end
        %% Function to plot and calculate the volume
        function [v] = PlotVolume(self, createNew, color)
            %Determines how big the angular steps are in radians for each joint
            stepRads = deg2rad(60);
            %Determines how big the steps are in meters for the rail
            stepmeter = 0.2;
            %Determines the limits for each joint in an 2x8 matrix
            qlim =[-0.8 -0.01 ; -2*pi 2*pi; -90*pi/180 90*pi/180; -170*pi/180 170*pi/180;-2*pi 2*pi;-2*pi 2*pi;-2*pi 2*pi];

            if createNew == 1 % only if pointCloud has not been create yet
                a = [4 13 4 6 13 13];
                pointCloudeSize = prod(a);
                pointCloud = zeros(pointCloudeSize,3);
                disp(num2str(size(pointCloud)));
                counter = 1;
                tic
                for q1 = qlim(1,1):stepmeter:qlim(1,2)
                    for q2 = qlim(2,1):stepRads:qlim(2,2)
                        for q3 = qlim(3,1):stepRads:qlim(3,2)
                            for q4 = qlim(4,1):stepRads:qlim(4,2)
                                for q5 = qlim(5,1):stepRads:qlim(5,2)
                                    for q6 = qlim(6,1):stepRads:qlim(6,2)
                                        q7 = 0;
                                        q = [q1,q2,q3,q4,q5,q6,q7];
                                        tr = self.model.fkineUTS(q);
                                        pointCloud(counter,:) = tr(1:3,4)';
                                        counter = counter + 1;

                                        if mod(counter/pointCloudeSize * 100,1) == 0
                                            display(['After ',num2str(toc),' seconds, completed ',num2str(counter/pointCloudeSize * 100),'% of poses']);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            hold on;
            if color == "red"
                color = [255 0 0]/255;
            else if color == "blue"
                    color = [0 0 255]/255;
            end
            end
            %Plot the volume of the robot arm by plotting the points, and create the point cloud
            figure(1);

            v = plot3(pointCloud(:,1),pointCloud(:,2),pointCloud(:,3),'o','Color',color);
            drawnow();

            hold on;
            %max x radius
            a = (max(pointCloud(:,1)) - min(pointCloud(:,1)))/2
            %max y radius
            b = (max(pointCloud(:,2)) - min(pointCloud(:,2)))/2
            %max z radius
            c = (max(pointCloud(:,3)) - min(pointCloud(:,3)))/2
            %Assume it is a sphere, calculate it volume as a elipsoid
            volume = (4/3)*pi*a*b*c;
            %display the volume value in m^3
            disp(strcat("Approximate volume (m^3) = ",num2str(volume)));
        end

        %Plot the environment
        function PlotSafetyEnvironment(X,Y,Z)
            f1 = PlaceObject('fenceFinal.ply',[X + 1, Y, Z]);
            hold on;
            f2 = PlaceObject('fenceFinal.ply',[X + 1, Y - 0.8, Z]);
            hold on;
            f3 =PlaceObject('fenceFinal.ply',[X + 1, Y + 0.8, Z]);
            hold on;
            f4 =PlaceObject('fenceFinal.ply',[X - 1.4, Y, Z]);
            hold on;
            f5 =PlaceObject('fenceFinal.ply',[X - 1.4,Y + 0.8, Z]);
            hold on;
            f6 =PlaceObject('fenceFinal.ply',[X - 1.4,Y - 0.8, Z]);
            hold on;

            %Plot the barrier and rotate it
            f7 =PlaceObject('fenceFinal.ply',[1.2 - Y, X - 1, Z]);
            verts = [get(f7,'Vertices'), ones(size(get(f7,'Vertices'),1),1)] * trotz(pi/2);
            set(f7,'Vertices',verts(:,1:3))
            hold on;

            f8 =PlaceObject('fenceFinal.ply',[1.2 - Y, X - 0.2, Z]);
            verts = [get(f8,'Vertices'), ones(size(get(f8,'Vertices'),1),1)] * trotz(pi/2);
            set(f8,'Vertices',verts(:,1:3))
            hold on;

            f9 =PlaceObject('fenceFinal.ply',[1.2 - Y, X + 0.6, Z]);
            verts = [get(f9,'Vertices'), ones(size(get(f9,'Vertices'),1),1)] * trotz(pi/2);
            set(f9,'Vertices',verts(:,1:3))
            hold on;

            f10 =PlaceObject('fenceFinal.ply',[-1.2 - Y, X - 1 , Z]);
            verts = [get(f10,'Vertices'), ones(size(get(f10,'Vertices'),1),1)] * trotz(pi/2);
            set(f10,'Vertices',verts(:,1:3))
            hold on;

            f11 =PlaceObject('fenceFinal.ply',[-1.2 - Y, X - 0.2, Z]);
            verts = [get(f11,'Vertices'), ones(size(get(f11,'Vertices'),1),1)] * trotz(pi/2);
            set(f11,'Vertices',verts(:,1:3))
            hold on;

            f12 =PlaceObject('fenceFinal.ply',[- 1.2 - Y, X + 0.6, Z]);
            verts = [get(f12,'Vertices'), ones(size(get(f12,'Vertices'),1),1)] * trotz(pi/2);
            set(f12,'Vertices',verts(:,1:3))
            hold on;

            %Plot the concrete ground
            set(0,'DefaultFigureWindowStyle','docked');
            surf([-2,-2;2,2] ...
                ,[-2,3;-2,3] ...
                ,[0.01,0.01;0.01,0.01] ...
                ,'CData',imread('concrete.jpg') ...
                ,'FaceColor','texturemap');
            person1 = PlaceObject('personMaleOld.ply',[-1.8 -Y, X, 0]);
            verts = [get(person1,'Vertices'), ones(size(get(person1,'Vertices'),1),1)] *trotz(pi/2);
            verts(:,1) = verts(:,1) * 0.5;
            verts(:,3) = verts(:,3) * 0.5;
            set(person1,'Vertices',verts(:,1:3))
            hold on;
        end

        %Plot all the brick
        function [b1, b2, b3, b4, b5, b6, b7, b8, b9] = PlotBrick(brick1, brick2, brick3, ...
                brick4, brick5, brick6, ...
                brick7, brick8, brick9)
            b1 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick1);
            b2 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick2);
            b3 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick3);
            b4 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick4);
            b5 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick5);
            b6 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick6);
            b7 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick7);
            b8 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick8);
            b9 = PlaceObject('HalfSizedRedGreenBrick.ply' ,brick9);
        end

 
    end
end