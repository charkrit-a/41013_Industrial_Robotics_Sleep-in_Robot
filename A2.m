function A2(app)
    clf
    clc
    Init();
    hold on
    
    % define environment
    EnvironmentA2();
    
    % plot robots
    r1 = Robot(LinearUR10e(transl(-0.3,0,0)));
    r2 = Robot(UR3e(transl(0.5,0.2,0)*trotz(pi/2), true, 'gripper_2fg7_base'), transl(0,0,0.08), [0 -pi/2 pi/2 -pi/2 -pi/2 0]);

    % place objects
    milk = Entity("Milk.ply", transl(-1.8,0.7,0.1));
    juice = Entity("OrangeJuice.ply", transl(-1.8,0.8,0.1));
    cerealGreen = Entity("CerealBox_Green.ply", transl(-0.7,1,1)*trotz(pi/2));
    cerealPurple = Entity("CerealBox_Purple.ply", transl(-1.25,1,1)*trotz(pi/2));
    cerealRed = Entity("CerealBox_Red.ply", transl(-1,1,1)*trotz(pi/2));

    disp("Setup complete, press any key to continue...")
    pause

    % Example step 1
    while(1)
        r1Done = r1.Animate(juice.GetPose()); % movement to go get the juice && r2Done
        r2Done = r2.Animate(transl(0.2,0.2,0.2)); % just to show simultaneous movement
        
        if r1Done && r2Done
            break
        end 

        pause(0.02); % pause for smoother animations
    end

    % Example step 2
    while(1)
        r1Done = r1.Animate(transl(0,0,0), juice); % movement to move the juice 
        r2Done = r2.Animate(transl(0.5,-0.2,0.2), milk); % just to show simultaneous movement
        
        if r1Done && r2Done
            break
        end 

        pause(0.03); % pause for smoother animations
    end
    
    disp("End, press any key to exit program.")
    pause
end