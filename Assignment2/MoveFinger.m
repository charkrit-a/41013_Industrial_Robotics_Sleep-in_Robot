function MoveFinger(robot,q,finger1,finger2,i)
    
    q_Finger1 = finger1.model.getpos();
    q_Finger2 = finger2.model.getpos();
    q_Finger1End = deg2rad([25 0]);
    q_Finger2End = deg2rad([25 0]);
    q_Finger1Trajectory = jtraj(q_Finger1,q_Finger1End,100);
    q_Finger2Trajectory = jtraj(q_Finger2,q_Finger2End,100);
    base = robot.model.fkineUTS(q);

    finger1.model.base=base*trotx(pi/2);
     
    finger1.model.animate(q_Finger1Trajectory(i,:)); 
   
    finger2.model.base=base*troty(pi)*trotx(-pi/2);

    finger2.model.animate(q_Finger2Trajectory(i,:));
 
end