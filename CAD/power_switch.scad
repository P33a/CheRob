module four_corners(dx, dy) {
  translate([dx, dy, 0])
  children(0);

  translate([dx, -dy, 0])
  children(0);
  
  translate([-dx, dy, 0])
  children(0);

  translate([-dx, -dy, 0])
  children(0);
}

module power_switch(ps_x = 16, ps_y = 14) {
  $fn = 32;
  four_corners(ps_x / 2, ps_y/2)
  difference() {
    cylinder(h = 8, d = 5);
    
    cylinder(h = 10, d = 1.7);
  }
}


module max471_support(max471_x = 24.6, max471_y = 22.3, max471_z = 1.6) {
  $fn= 32;
  bottom_wall = 2;
  outer_border = 2;
  inner_border = 0.8;
  
  hole_d = 2;
  hole_border = 3;
  go_inside = 1.1;
  
  difference() {
    union() {
      cube([max471_x + 2 * outer_border, max471_y + 2 * outer_border, max471_z + bottom_wall],center = true);  

      //translate([max471_x / 2 + outer_border, max471_y / 2 + outer_border, 0])
      four_corners(max471_x / 2 + outer_border - go_inside, max471_y / 2 + outer_border - go_inside)
      cylinder(d = hole_d + hole_border, h = max471_z + bottom_wall, center = true);
    }
    
    translate([0, 0, bottom_wall])
    cube([max471_x, max471_y, max471_z + bottom_wall],center = true);  

    translate([0, 0, -1e-3])
    cube([max471_x - 2 * inner_border, max471_y - 2 * inner_border, max471_z + bottom_wall],center = true);  
    
    four_corners(max471_x / 2 + outer_border - go_inside, max471_y / 2 + outer_border - go_inside)
    cylinder(d = hole_d, h = max471_z + bottom_wall + 1, center = true);
  }
}

module power_support(c_y = 50) {
  $fn = 32;
  translate([15, 0, 0])
  difference() {
    union() {
      cube([60, c_y, 2], center = true);
    
      translate([0, c_y/2 - 3/2, 10/2])
      cube([60, 3, 10], center = true);
      
      translate([-15, -8, 0])
      power_switch();
      
      translate([15, -4, 3])
      rotate([0, 0, 90])
      max471_support();
      
    }
    
    
    translate([-38/2 - 6, c_y/2, 5])
    rotate([90, 0, 0])
    cylinder(d = 2.5, h = 10);

    translate([38/2 - 6, c_y / 2, 5])
    rotate([90, 0, 0])
    cylinder(d = 2.5, h = 10);

    translate([-15, -8, 0])
    cylinder(d = 12, h = 10, center = true);

  }
  
}

//power_switch();
power_support();