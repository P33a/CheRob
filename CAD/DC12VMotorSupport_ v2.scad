slack = 0.5;
holes_radius = 15.5;
screw_M4 = 3.5 / 2;
thickness = 10;

module motor_support(){
  difference() {
    union() {
      // Main Body
      //translate([0, 0, 0])
      //  cylinder(h = thickness, r = 23, $fn = 50, center = true);
      translate([-30 + 36/2 + 1, 0, 0])
        cube(size = [60, 46, thickness], center = true);

     //translate([33, 46/2, 5 - 1e-2])
     //rotate([90, 0, 0])
     //linear_extrude(height = 46, center = false, convexity = 10, twist = 0)
     //  polygon( points = [[0, 0],[0, 10],[-10, 0]] );
    }
    // Motor hole
    translate([0, 0, thickness/2 - 1])
      cylinder(h = thickness, r = 36/2 + slack, $fn = 50, center = true);

    // Motor "bearing" hole
    translate([-7, 0, -1])
      cylinder(h = thickness, r = 12/2 + slack, $fn = 50, center = true);

    // Motor screw holes
    for (i = [0 : 5]) {
      rotate([0, 0, i * 60]) {
        // screw hole
        translate([0, holes_radius, -1])
          cylinder(h = thickness, r = 3/2 + slack, $fn = 50, center = true);

        // screw head hole
        //translate([0, holes_radius, -thickness/2])
        //  cylinder(h = 3, r = 6/2 + slack, $fn = 50, center = true);
      }

    }

    // support holes
    translate([25, 36/2, 0])
    rotate([0, 90, 0])
      cylinder(h = 36, r = screw_M4, $fs = 0.5, center = true);

    translate([25, -36/2, 0])
    rotate([0, 90, 0])
      cylinder(h = 36, r = screw_M4, $fs = 0.5, center = true);
    
    translate([25 - 60, 35/2, 0])
    rotate([0, 90, 0])
      cylinder(h = 36, r = screw_M4, $fs = 0.5, center = true);    
    
    translate([25 - 60, -35/2, 0])
    rotate([0, 90, 0])
      cylinder(h = 36, r = screw_M4, $fs = 0.5, center = true);
  }
}




//translate([0, 0, 5])
//  motor_support();
motor_support();

