function EnvironmentA2()    
    % ENVIRONMENTA2 renders the environment for assessment2
    
    X = -0.3;
    Y = 0;
    Z = 0;
    XUpperAxis = 3;
    YLowerAxis = -3;
    ZUpperAxis = 2;
    ZLowerAxis = -0.57;

    %Shelf Coordinates
    XShelf = -1.5+X;
    XShelfOffset = -0.14;
    YShelf = 0;
    YWallOffset = 1.2;
    YSignOffset = YWallOffset-0.01;
    
    %Remaining Axis length created
    XLowerAxis = XShelf+XShelfOffset;
    YUpperAxis = Y + YWallOffset;
    
    %Fence Dimensions
    heightofFence = 0.4;
    lengthofFence = 0.8;
    fenceOffset = 0.4;
   
    lengthOfBorderX = 3.2; %Fence border along x-axis
    lengthOfBorderY = 3.2; %Fence border along y-axis
    
    %Number of Fences Calculated to fit each axis completely
    fenceNumZ = 4;
    fenceNumX = round(lengthOfBorderX/lengthofFence);
    fenceNumY = round(lengthOfBorderY/lengthofFence);
    
    %Fence Wall at y-axis at x = 1.2
    for j = 1:fenceNumY
        for i = 1:fenceNumZ
            fenceY(i+fenceNumZ*(j-1)) = PlaceObject('fenceFinal.ply',[lengthOfBorderX + XLowerAxis, YUpperAxis - fenceOffset - lengthofFence * (j-1), ZLowerAxis + (i-1)*heightofFence]);
        end
    end
    
    %Fence Wall along x-axis at y = -1.2m
    for j = 1:fenceNumX
        for i = 1:fenceNumZ
            fenceX(i+fenceNumZ*(j-1)) = PlaceObject('fenceFinal.ply',[ -(YUpperAxis - lengthOfBorderY), XLowerAxis + fenceOffset + lengthofFence * (j-1), ZLowerAxis + (i-1)*heightofFence]);
            verts = [get(fenceX(i+fenceNumZ*(j-1)),'Vertices'), ones(size(get(fenceX(i+fenceNumZ*(j-1)),'Vertices'),1),1)] * trotz(pi/2);
            set(fenceX(i+fenceNumZ*(j-1)),'Vertices',verts(:,1:3))
        end
    end
    
    %Plot Kitchen
    PlaceObject('Kitchen.PLY', ...
    [ XLowerAxis YUpperAxis ZLowerAxis]);

    %Plot the Kitchen Table
    t1 = PlaceObject('kitchenTable.ply',[0, 0, 0]);
    verts = [get(t1,'Vertices'), ones(size(get(t1,'Vertices'),1),1)]* trotx(-pi/2);
    verts(:,1) = verts(:,1) *0.001;
    verts(:,2) = verts(:,2) *0.0008;
    verts(:,3) = verts(:,3) *0.0008;
    set(t1,'Vertices',verts(:,1:3))
    
    %Plot the Laptop table 
    t2 = PlaceObject('computerTable.ply',[10*(1.7)/0.008, 10*0.25/0.008, 10*0/0.008]);
    verts = [get(t2,'Vertices'), ones(size(get(t2,'Vertices'),1),1)]* trotx(-pi/2);
    verts(:,1) = verts(:,1)*0.0008;
    verts(:,2) = verts(:,2)*0.0008;
    verts(:,3) = verts(:,3)*0.0015;
    set(t2,'Vertices',verts(:,1:3))
    
    %Plot the Emergency Stop table 
    t3 = PlaceObject('computerTable.ply',[10*(1.7)/0.008, 10*0.25/0.008, 10*(1)/0.008]);
    verts = [get(t3,'Vertices'), ones(size(get(t3,'Vertices'),1),1)]* trotx(-pi/2);
    verts(:,1) = verts(:,1)*0.0008;
    verts(:,2) = verts(:,2)*0.0008;
    verts(:,3) = verts(:,3)*0.0015;
    set(t3,'Vertices',verts(:,1:3))
    
    %Plot Laptop
    l1 = PlaceObject('Laptop.ply',[10*(1.6)/0.008, 10*0/0.008, 10*0.5/0.008]);
    verts = [get(l1,'Vertices'), ones(size(get(l1,'Vertices'),1),1)];
    verts(:,1) = verts(:,1)*0.0008;
    verts(:,2) = verts(:,2)*0.0008;
    verts(:,3) = verts(:,3)*0.0008;
    set(l1,'Vertices',verts(:,1:3))

    %E-Stop Button
    PlaceObject('Emergency_Stop_Button.PLY', ...
    [ 1.7 -1 0.5]);
    
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
end
