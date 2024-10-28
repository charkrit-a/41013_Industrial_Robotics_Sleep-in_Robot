function A2(app)
    clf
    clc
    Init();
    hold on
    
    % define environment
    EnvironmentA2();
    
    % plot robots
    r1 = Robot(LinearUR10e(transl(-0.3,0,0)), transl(0,0,0.1)*troty(-pi/2));
    r2 = Robot(UR3e(transl(0.5,0.2,0)*trotz(pi/2), true, 'gripper_2fg7_base'), transl(0,0,0.08), [0 -pi/2 pi/2 -pi/2 -pi/2 0]);

    % place objects
    milk = Entity("Milk.ply", transl(-1.8,0.7,0.15));
    juice = Entity("OrangeJuice.ply", transl(-1.8,0.8,0.15));
    cerealGreen = Entity("CerealBox_Green.ply", transl(-0.78,0.85,1.1)*trotz(pi/2));
    cerealPurple = Entity("CerealBox_Blue.ply", transl(-1.25,0.85,1.1)*trotz(pi/2));
    cerealRed = Entity("CerealBox_Red.ply", transl(-1.35,0.85,1.1)*trotz(pi/2));

    disp("Setup complete, press any key to continue...")
    pause

    % example of how to make the robots move
    r1Animate = @() r1.Animate(cerealGreen.GetPose());
    r2Animate = @() r2.Animate(transl(0,0,1));
    Animate(r1Animate,r2Animate);
    
    disp("End, press any key to exit program.")
    pause
end

function Animate(r1animate, r2animate)
    while(1)
        r1Done = r1animate();
        r2Done = r2animate();

        if r1Done && r2Done
            break
        end
        pause(0.02); % pause for smoother animations
    end
end

function Cereal(box, r1, r2)
end

function drink(drink, r1, r2)
end