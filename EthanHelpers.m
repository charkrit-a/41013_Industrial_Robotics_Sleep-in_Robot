classdef EthanHelpers < handle

    methods (Static) 
        %Function to generate set of q to and create the trajectory using jtraj
        function qTrajec = CreateTraj(robot,objPosition,jointGuess)

            steps = 100;

            qCurrent = robot.model.getpos();

            T = transl(objPosition)*trotx(pi)*troty(0)*trotz(0);
                
            %Joint states that pick up the obj
            qMove = wrapToPi(robot.model.ikcon(T,jointGuess));

            qTrajec = jtraj(qCurrent,qMove,steps);

        end
        
        %Function to generate set of q to and create the trajectory using jtraj
        function qTrajec2 = CreateTraj2(robot,objPosition,jointGuess)

            steps2 = 100;

            qCurrent2 = robot.model.getpos();

            T2 = transl(objPosition)*trotx(pi)*troty(0)*trotz(0);
                
            %Joint states that pick up the obj
            qMove2 = wrapToPi(robot.model.ikcon(T2,jointGuess));

            qTrajec = jtraj(qCurrent2,qMove2,steps2);

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
        
        %Function to move the arm from current position to pick up the obj
        function  MoveToobj(r,qTrajec,finger1,finger2)

            for i = 1:size(qTrajec,1)
                q = qTrajec(i,:);
                r.model.animate(q);
                MoveFinger(r,q,finger1,finger2,i);
                pause(0.01)
            end

        end



        % This function has 5 input:
        % self = Robot Arm (Linearur10e)
        % qArray = The set of q generated by the inverse kinematic from the start and end position
        % f1 = Finger 1
        % f2 = Finger 2
        % objnum = The Pose of the generated objs
        function PlotPose(self,qArray,freq,f1,f2,objnum)

            num = 1;
            %Reads the obj file in faces, vertices, and color of it
            [f,v,data] = plyread('Milk.ply','tri');
            objVertex = size(v,1);
            objMesh_h = trisurf(f,v(:,1)+objnum(1,1),v(:,2)+objnum(1,2), v(:,3)+objnum(1,3) ...
                ,'EdgeColor','none','EdgeLighting','none');


            for i=1:size(qArray,1)

                % Take the forward kinematic for the obj
                obj = self.model.fkineUTS(qArray(i,:));

                %objPose is the 4x4 matrix, transl(0,0,0.1) is move the obj down 0.1 in the Z direction
                %to make it look like it is grasped by the gripper
                objPose = obj*transl(0,0,0.1)*troty(pi);

                %MOVE THE obj. Update the point then multiply it to the vertices
                UpdatedPoints = [objPose * [v,ones(objVertex,1)]']';

                %The vertices are all the rows and 1 to 3 columns of the UpdatedPoints
                objMesh_h.Vertices = UpdatedPoints(:,1:3);

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
        function PlotSafetyEnvironment(X, Y, Z, XUpperAxis, YLowerAxis, ZUpperAxis, ZLowerAxis)
            %Shelf Coordinates
            XShelf = -1.5+X;
            XShelfOffset = -0.14;
            YWallOffset = 1.2;
            YSignOffset = YWallOffset-0.01;
            
            %Remaining Axis length created
            XLowerAxis = XShelf+XShelfOffset;
            YUpperAxis = Y + YWallOffset;
            
            %Fence Dimensions
            heightofFence = 0.5;
            lengthofFence = 0.8;
            fenceOffset = 0.4;
           
            lengthOfBorderX = 3.2; %Fence border along x-axis
            lengthOfBorderY = 3.2; %Fence border along y-axis
            
            %Number of Fences Calculated to fit each axis completely
            fenceNumZ = round((ZUpperAxis+abs(ZLowerAxis))/heightofFence);
            fenceNumX = round(lengthOfBorderX/lengthofFence);
            fenceNumY = round(lengthOfBorderY/lengthofFence);
            
            %Fence Wall at y-axis at x = 1.2
            for j = 1:fenceNumY
                for i = 1:fenceNumZ
                    fenceY(i+fenceNumZ*(j-1)) = PlaceObject('fenceFinal.ply',[lengthOfBorderX + XLowerAxis, YUpperAxis - fenceOffset - lengthofFence * (j-1), ZLowerAxis + (i-1)*heightofFence]);
                    hold on;
                end
            end
            
            %Fence Wall along x-axis at y = -1.2m
            for j = 1:fenceNumX
                for i = 1:fenceNumZ
                    fenceX(i+fenceNumZ*(j-1)) = PlaceObject('fenceFinal.ply',[ -(YUpperAxis - lengthOfBorderY), XLowerAxis + fenceOffset + lengthofFence * (j-1), ZLowerAxis + (i-1)*heightofFence]);
                    verts = [get(fenceX(i+fenceNumZ*(j-1)),'Vertices'), ones(size(get(fenceX(i+fenceNumZ*(j-1)),'Vertices'),1),1)] * trotz(pi/2);
                    set(fenceX(i+fenceNumZ*(j-1)),'Vertices',verts(:,1:3))
                    hold on;
                end
            end
            
            %Plot the Kitchen Table
            t1 = PlaceObject('kitchenTable.ply',[0, 0, 0]);
            verts = [get(t1,'Vertices'), ones(size(get(t1,'Vertices'),1),1)]* trotx(-pi/2);
            verts(:,1) = verts(:,1) *0.001;
            verts(:,2) = verts(:,2) *0.0008;
            verts(:,3) = verts(:,3) *0.0008;
            set(t1,'Vertices',verts(:,1:3))
            hold on;

            %Plot the Laptop table 
            t2 = PlaceObject('computerTable.ply',[10*(1.7)/0.008, 10*0.25/0.008, 10*0/0.008]);
            verts = [get(t2,'Vertices'), ones(size(get(t2,'Vertices'),1),1)]* trotx(-pi/2);
            verts(:,1) = verts(:,1)*0.0008;
            verts(:,2) = verts(:,2)*0.0008;
            verts(:,3) = verts(:,3)*0.0015;
            set(t2,'Vertices',verts(:,1:3))
            hold on;

            %Plot the Emergency Stop table 
            t3 = PlaceObject('computerTable.ply',[10*(1.7)/0.008, 10*0.25/0.008, 10*(1)/0.008]);
            verts = [get(t3,'Vertices'), ones(size(get(t3,'Vertices'),1),1)]* trotx(-pi/2);
            verts(:,1) = verts(:,1)*0.0008;
            verts(:,2) = verts(:,2)*0.0008;
            verts(:,3) = verts(:,3)*0.0015;
            set(t3,'Vertices',verts(:,1:3))
            hold on;

            %Plot Laptop
            l1 = PlaceObject('Laptop.ply',[10*(1.7)/0.008, 10*0/0.008, 10*0.6/0.008]);
            verts = [get(l1,'Vertices'), ones(size(get(l1,'Vertices'),1),1)];
            verts(:,1) = verts(:,1)*0.0008;
            verts(:,2) = verts(:,2)*0.0008;
            verts(:,3) = verts(:,3)*0.0008;
            set(l1,'Vertices',verts(:,1:3))
            hold on;
            
            %Milk Carton Coordinates
            m1 = PlaceObject('Milk.ply',[10*0/0.008, 10*0.83/0.008, 10*(-XShelf)/0.008]);
            verts = [get(m1,'Vertices'), ones(size(get(m1,'Vertices'),1),1)] * trotx(-pi/2) * trotz(pi/2);
            verts(:,1) = verts(:,1) *0.0008;
            verts(:,2) = verts(:,2) *0.0008;
            verts(:,3) = verts(:,3) *0.0008;
            set(m1,'Vertices',verts(:,1:3))
            hold on;
            
            %Plot the Shelf
            %s1 = PlaceObject('Shelf.ply',[10*YShelf/0.008, 10*ZLowerAxis/0.008, 10*(-XShelf)/0.008]);
            %verts = [get(s1,'Vertices'), ones(size(get(s1,'Vertices'),1),1)]* trotx(-pi/2) * trotz(pi/2);
            %verts(:,1) = verts(:,1)*0.0008;
            %verts(:,2) = verts(:,2)*0.0008;
            %verts(:,3) = verts(:,3)*0.0008;
            %set(s1,'Vertices',verts(:,1:3))
            %hold on;

            %Plot Kitchen
            PlaceObject('Kitchen.PLY', ...
            [ XLowerAxis YUpperAxis ZLowerAxis]);

            %Plot Cereal Box
            PlaceObject('Bowl.ply', ...
            [0.7 0 0]);

            %Plot the concrete ground
            set(0,'DefaultFigureWindowStyle','docked');
            surf([XLowerAxis,XLowerAxis;XUpperAxis,XUpperAxis] ...
                ,[YLowerAxis,YUpperAxis;YLowerAxis,YUpperAxis] ...
                ,[ZLowerAxis,ZLowerAxis;ZLowerAxis,ZLowerAxis] ...
                ,'CData',imread('concrete.jpg') ...
                ,'FaceColor','texturemap');
            
            % wall 1
            surf([XLowerAxis,XLowerAxis;XLowerAxis,XLowerAxis] ...
            ,[YLowerAxis,YLowerAxis;YUpperAxis,YUpperAxis] ...
            ,[ZUpperAxis,ZLowerAxis;ZUpperAxis,ZLowerAxis] ...
            ,'CData',permute(imread('wall.jpg'),[2 1 3]) ...
            ,'FaceColor','texturemap');
            
            % wall 2
            surf([XLowerAxis,XLowerAxis;XUpperAxis,XUpperAxis] ...
            ,[YUpperAxis,YUpperAxis;YUpperAxis,YUpperAxis] ...
            ,[ZUpperAxis,ZLowerAxis;ZUpperAxis,ZLowerAxis] ...
            ,'CData',permute(imread('wall.jpg'),[2 1 3]) ...
            ,'FaceColor','texturemap');

            % operator
            PlaceObject('Worker.ply', ...
            [ 2.5+X 0+Y ZLowerAxis]);
            PlaceObject('Worker.ply', ...
            [ 2.5+X -1+Y ZLowerAxis]);
            % fire extinguisher
            PlaceObject('FireExtinguisherCO2.ply', ...
            [ 1.9+X 0.9+Y ZLowerAxis]);
        
            % signs
            % safety boots
            surf([1.6,1.6;1.9,1.9] ...
            ,[Y+YSignOffset,Y+YSignOffset;Y+YSignOffset,Y+YSignOffset] ...
            ,[1.8,1.5;1.8,1.5] ...
            ,'CData',permute(imread('Safety_Boots.jpg'),[2 1 3]) ...
            ,'FaceColor','texturemap');
            % safety glasses
            surf([1.2,1.2;1.5,1.5] ...
            ,[Y+YSignOffset,Y+YSignOffset;Y+YSignOffset,Y+YSignOffset] ...
            ,[1.8,1.5;1.8,1.5] ...
            ,'CData',permute(imread('Eye_Protection.jpg'),[2 1 3]) ...
            ,'FaceColor','texturemap');
            % no tresspass
            surf([0.8,0.8;1.1,1.1] ...
            ,[Y+YSignOffset,Y+YSignOffset;Y+YSignOffset,Y+YSignOffset] ...
            ,[1.8,1.35;1.8,1.35] ...
            ,'CData',permute(imread('No_Tresspassing.jpg'),[2 1 3]) ...
            ,'FaceColor','texturemap');
            
            axis([XLowerAxis XUpperAxis+X YLowerAxis+Y YUpperAxis+Y ZLowerAxis ZUpperAxis+Z]);
            hold on
        end

        %Plot all the obj
        function [b1, b2] = Plotobj(obj1, obj2)
            b1 = PlaceObject('Milk.ply' ,obj1);
            b2 = PlaceObject('Milk.ply' ,obj2);
        end

 
    end
end