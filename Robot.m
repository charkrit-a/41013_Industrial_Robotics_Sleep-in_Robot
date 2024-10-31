classdef Robot < handle
    %ROBOT Wrapper for convenient use of robotics toolbox
    %   Helper and convenience functions for robotics toolbox
    
    properties (Access=private)
        r
        qCurrent
        qTarget
        qTraj
        trTarget
        endEffectorOffset
        collideables
    end
    
    methods
        function obj = Robot(r,endEffectorOffset,q,collideables)
            %ROBOT Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 4
                collideables = "none";
            end
            if nargin < 3
                q = GenerateInitialQ(r);
            end
            if nargin < 2
                endEffectorOffset = transl(0,0,0);
            end

            obj.r = r;
            obj.qCurrent = q;
            obj.qTarget = q;
            obj.endEffectorOffset = endEffectorOffset;
            obj.trTarget = r.model.fkine(obj.qCurrent);
            r.model.animate(q);
            obj.collideables = collideables;
        end

        function tr = Fkine(obj, q)
            %FKINE gets the transform of every joint 
            if nargin < 2
                q = obj.qCurrent;
            end
            
            baseTr = obj.r.model.base;
            L = obj.r.model.links;
            n = length(L);

            % initialise the 
            tr = zeros(4,4,n+1);

            % calculate all links using DH parameters
            tr(:,:,1) = baseTr;
            for i = 1 : n
                if L(i).isrevolute
                    tr(:,:,i+1) = tr(:,:,i) * trotz(q(i)+L(i).offset) * transl(0,0,L(i).d) * transl(L(i).a,0,0) * trotx(L(i).alpha);
                else
                    tr(:,:,i+1) = tr(:,:,i) * trotz(L(i).offset) * trotz(pi) * transl(0, 0, q(i)) * transl(L(i).a, 0, 0) * trotx(L(i).alpha);
                end
            end

            for i = 1 : n+1
                % plot3(tr(1,4,i),tr(2,4,i),tr(3,4,i),'x','MarkerSize',10,'Color','r');
            end
        end 

        function Teach(obj, q)
            %TEACH animate specific q
            obj.qCurrent = q;
            obj.r.model.animate(obj.qCurrent);
        end

        function Jog(obj, input)
            %JOG Manually jog the robot
            % input [vx;vy;vz;wx;wy;wz]
            
            % simulation time step
            dt = 0.15;

            % turn joystick input into an end-effector velocity command
            Kv = 0.3; % linear velocity gain
            Kw = 0.8; % angular velocity gain
            
            vx = Kv*input(1);
            vy = Kv*input(2);
            vz = Kv*input(3);
            
            wx = Kw*input(4);
            wy = Kw*input(5);
            wz = Kw*input(6);
            
            dx = [vx;vy;vz;wx;wy;wz]; % combined velocity vector
            
            % use DLS J inverse to calculate joint velocity
            lambda = 0.5;
            J = obj.r.model.jacob0(obj.qCurrent);
            [~,n] = size(J);
            Jinv_dls = inv((J'*J)+lambda^2*eye(n))*J';
            dq = Jinv_dls*dx;
            
            % apply joint velocity to step robot joint angles 
            q = obj.qCurrent + dq'*dt;

            % animate the robot
            obj.Teach(q);
        end

        function result = DetectCollision(obj, mesh_h, q)
            %DETECTCOLLISION detects a collision with any mesh object
            if nargin < 3
                q = obj.qCurrent;
            end

            result = false;
            linkTransforms = obj.Fkine(q); % Get link start and end points
            numLinks = size(linkTransforms,3);
            numFaces = size(mesh_h.Faces, 1);
            verts = zeros(3,1,3);

            % iterate through each of the links
            for i = 1 : numLinks-1
                % Define the line segment for this link
                lineStart = linkTransforms(1:3,4,i);
                lineEnd = linkTransforms(1:3,4,i+1);

                % Iterate through each triangle of the mesh
                for j = 1:numFaces
                    % Get vertices of the j-th triangle face
                    verts(:,1) = mesh_h.Vertices(mesh_h.Faces(j, 1), :)';
                    verts(:,2) = mesh_h.Vertices(mesh_h.Faces(j, 2), :)';
                    verts(:,3) = mesh_h.Vertices(mesh_h.Faces(j, 3), :)';
                    
                    % Plot each vertex of the triangle face
                    % plot3(verts(1,:), verts(2,:), verts(3,:), 'o', 'MarkerSize', 10, 'Color', 'b');

                    % Calculate plane normal and point
                    planeNormal = cross(verts(:,:,2) - verts(:,:,1), verts(:,:,3) - verts(:,:,1));
                    planePoint = verts(:,:,1);
                    
                    [intersectP,check] = LinePlaneIntersection(planeNormal',planePoint',lineStart',lineEnd'); 
                    
                    if check && IsIntersectionPointInsideTriangle(intersectP, verts) && IsPointOnSegment(intersectP', lineStart, lineEnd)
                        % plot3(intersectP(:,1),intersectP(:,2),intersectP(:,3), '*', 'MarkerSize', 10, 'Color', 'k');
                        result = true;
                        % return
                    end
                end    
            end
        end

        function result = SetTargetTr(obj,tr,qGuess,steps)
            %SETTARGET Set a end effector position target
            %   Accepts a global pose and generates a trajectory to reach
            %   that pose.
            if nargin < 3
                qGuess = obj.qCurrent;
            end
            if nargin < 4
                steps = 100;
            end

            result = false;

            if all(obj.trTarget == tr) && ~isempty(obj.qTraj)
                result = true;
                return
            end
            
            obj.trTarget = tr;
            trWithOffset = tr/obj.endEffectorOffset;
            % obj.qTarget = obj.r.model.ikine(tr, qGuess, 'mask', [1 1 1 0 0 0]);
            obj.qTarget = obj.r.model.ikcon(trWithOffset, qGuess);
            traj = jtraj(obj.qCurrent, obj.qTarget, steps);

            obj.qTraj = [];
            
            % check for collisions along this path
            if obj.collideables ~= "none"
                for i = 1:size(obj.collideables,1)
                    for j = 1:size(traj,1)
                        if obj.DetectCollision(obj.collideables(i), traj(j,:))
                            return
                        end
                    end
                end
            end

            result = true;
            obj.qTraj = traj;
        end

        function result = SetTargetQ(obj,q,steps)
            %SETTARGET Set a joint position target
            if nargin < 3
                steps = 100;
            end

            result = false;
            
            if all(obj.qTarget == q) && ~isempty(obj.qTraj)
                result = true;
                return
            end

            obj.qTarget = q;
            obj.trTarget = obj.r.model.fkine(q);
            traj = jtraj(obj.qCurrent, obj.qTarget, steps);
            obj.qTraj = [];
            
            % check for collisions along this path
            if obj.collideables ~= "none"
                for i = 1:size(obj.collideables,1)
                    for j = 1:size(traj,1)
                        if obj.DetectCollision(obj.collideables(i), traj(j,:))
                            return
                        end
                    end
                end
            end

            result = true;
            obj.qTraj = traj;
        end

        function StepArm(obj)
            obj.Teach(obj.qTraj(1,:));
            obj.qTraj(1,:) = [];
            drawnow;
        end
        
        function status = Animate(obj,entity,rotation)
            %ANIMATE Move the robot arm end effector to a pose
            %   Detailed explanation goes here
            if nargin < 3
                rotation = 1;
            end
            if nargin < 2
                entity = "none";
                rotation = 1;
            end 

            status = false;

            if isempty(obj.qTraj)
                status = true;
                return
            end

            obj.StepArm();
            if entity ~= "none"
                trEntity = obj.r.model.fkine(obj.qCurrent).T * obj.endEffectorOffset * rotation;
                entity.Move(trEntity);
            end 
        end

    end
end

function q = GenerateInitialQ(robot)
    %GENERATEINITIALQ Generate joint states for 
    % Initialize the joint configuration vector
    numJoints = numel(robot.model.links);  % Number of joints in the robot
    q = zeros(1, numJoints);  % Preallocate the joint angle vector

    % Loop over each joint to set its initial configuration
    for i = 1:numJoints
        % Get the joint limits for this link
        qlim = robot.model.links(i).qlim;

        % If joint limits are defined, set the joint value in the middle of the range
        if ~isempty(qlim)
            q(i) = mean(qlim);  % Set the joint angle to the middle of the joint limits
        else
            q(i) = 0;  % Default value if no limits are set
        end
    end
end

function [intersectionPoint,check] = LinePlaneIntersection(planeNormal,pointOnPlane,point1OnLine,point2OnLine)
    %LINEPLANEINTERSECTION checks for intersections with a plane

    intersectionPoint = [0 0 0];
    u = point2OnLine - point1OnLine;
    w = point1OnLine - pointOnPlane;
    D = dot(planeNormal,u);
    N = -dot(planeNormal,w);
    check = 0; %#ok<NASGU>
    if abs(D) < 10^-7        % The segment is parallel to plane
        if N == 0           % The segment lies in plane
            check = 2;
            return
        else
            check = 0;       %no intersection
            return
        end
    end
    
    %compute the intersection parameter
    sI = N / D;
    intersectionPoint = point1OnLine + sI.*u;
    
    if (sI < 0 || sI > 1)
        check= 3;          %The intersection point  lies outside the segment, so there is no intersection
    else
        check=1;
    end
end

function result = IsIntersectionPointInsideTriangle(intersectP,triangleVerts)
    %ISINTERSECTIONPOINTINSIDETRIANGLE checks if a point lies within a triangle

    u = triangleVerts(2,:) - triangleVerts(1,:);
    v = triangleVerts(3,:) - triangleVerts(1,:);
    
    uu = dot(u,u);
    uv = dot(u,v);
    vv = dot(v,v);
    
    w = intersectP - triangleVerts(1,:);
    wu = dot(w,u);
    wv = dot(w,v);
    
    D = uv * uv - uu * vv;
    
    % Get and test parametric coords (s and t)
    s = (uv * wv - vv * wu) / D;
    if (s < 0.0 || s > 1.0)        % intersectP is outside Triangle
        result = 0;
        return;
    end
    
    t = (uv * wu - uu * wv) / D;
    if (t < 0.0 || (s + t) > 1.0)  % intersectP is outside Triangle
        result = 0;
        return;
    end
    
    result = 1;                      % intersectP is in Triangle
end

function result = IsPointOnSegment(point, lineStart, lineEnd, tolerance)
    %ISPOINTONSEGMENT Check if a point lies on a line segment in 3D.
    if nargin < 4
        tolerance = 1e-6;
    end
    
    result = all(point >= min(lineStart, lineEnd) - tolerance) && ...
                  all(point <= max(lineStart, lineEnd) + tolerance);
end