hole_x = 11;
hole_y = 12 / 2 + 2.5 + 3 / 2;

module laser_support_base() {
  $fn = 32;
  difference() {
    cube([30, 40, 4], center = true);

    translate([0, 0, 6 / 2 - 1])    
    cube([10 + 0.2, 40 + 2, 6], center = true);

    translate([0, 0, -14/2])    
    cube([30, 28, 14], center = true);
      
    translate([hole_x, hole_y, 0])    
    cylinder(d = 2.5, h = 100, center = true);
    
    translate([-hole_x, hole_y, 0])    
    cylinder(d = 2.5, h = 100, center = true);

    translate([-hole_x, -hole_y, 0])    
    cylinder(d = 2.5, h = 100, center = true);

    translate([hole_x, -hole_y, 0])    
    cylinder(d = 2.5, h = 100, center = true);
    
  }  
  
}


module laser_support_top() {
  $fn = 32;
  hole_d = 2.5;
  difference() {
    cube([30, 28, 14], center = true);

    //translate([10, 15, 0])   
    rotate([0, 90, 0])
    cylinder(d = 12 + 0.2, h = 100, center = true);

    translate([hole_x, hole_y, 0])    
    cylinder(d = hole_d, h = 100, center = true);
    
    translate([-hole_x, hole_y, 0])    
    cylinder(d = hole_d, h = 100, center = true);

    translate([-hole_x, -hole_y, 0])    
    cylinder(d = hole_d, h = 100, center = true);

    translate([hole_x, -hole_y, 0])    
    cylinder(d = hole_d, h = 100, center = true);
    
    rotate([90, 0, 0])
    cylinder(d = hole_d, h = 100, center = true);
    
  }  
  
}


module laser_support_simple() {
  $fn = 32;
  difference() {
    cube([20, 28, 14], center = true);

    // Nut Space
    //translate([0, -20, 11])   
    //cube([20 + 1, 28, 14], center = true);

    //translate([0, 20, 11])   
    //cube([20 + 1, 28, 14], center = true);
    
    // Nut Space 1
    translate([0, -hole_y, 3])    
    cylinder(d = 8.5, h = 100, center = false);
    
    translate([0, -hole_y - 8.5/2, 5 + 3])    
    cube([8.5, 8.5, 10], center = true);

    // Nut Space 2
    translate([0, hole_y, 3])    
    cylinder(d = 8.5, h = 100, center = false);
    
    translate([0, hole_y + 8.5/2, 5 + 3])    
    cube([8.5, 8.5, 10], center = true);


    // Laser Hole
    rotate([0, 90, 0])
    cylinder(d = 12 + 0.2, h = 100, center = true);

    // Screw hole 1
    translate([0, hole_y, 0])    
    cylinder(d = 3.2, h = 100, center = true);
    
    // Screw hole 2
    translate([0, -hole_y, 0])    
    cylinder(d = 3.2, h = 100, center = true);


    // LAser grip hole
    translate([6, 0, 0])    
    rotate([90, 0, 0])
    cylinder(d = 2.5, h = 100, center = true);
    
  }  
  //translate([0, -hole_y, 5])    
  //cylinder(d = 6.2, h = 2.5, center = true);
  
}

laser_support_top();
//translate([0, 0, 20])
//laser_support_base();

//laser_support_simple();