classdef Entity < handle
    %ENTITY Class to represent moveable objects
    %   Plots ply model, track and move its position
    
    properties (Access = private)
        pose;
        sizeWHD;
        mesh_h;
        vertCount;
        verts;
    end
    
    methods
        function obj = Entity(modelFile, WHD, tr)
            %ENTITY Construct an instance of this class
            %   Construct class and draw entity in plot
            if nargin < 3
                tr = eye(4);
            end
            obj.pose = tr;
            obj.sizeWHD = WHD;

            [f,v,data] = plyread(modelFile, 'tri');
            obj.vertCount = size(v,1);
            midPoint = sum(v)/obj.vertCount;
            obj.verts = v - repmat(midPoint, obj.vertCount, 1);

            obj.mesh_h = PlaceObject(modelFile, tr(1:3,4)');
        end
        
        function tr = GetPose(obj)
            %GETPOS Getter function for the position of the brick
            tr = obj.pose;
        end

        function obj = Move(obj, newPosition)
            %MOVE move the brick to a new pose
            %   By multiplying all vertices by the global transform
            % TODO: FINISH THIS
            vertsHomogenous = [obj.verts,ones(obj.vertCount,1)];
            updatedPoints = (vertsHomogenous * newPosition')';
            obj.mesh_h.Vertices = updatedPoints(:,1:3)';
        end
    end
end

