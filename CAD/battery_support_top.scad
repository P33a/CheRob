module battery_support_top(slot = 31, wall = 5, bs_h = 6, slot_in = 20) {
  $fn = 32;
  difference() {
    cube([wall + slot_in, 2 * wall + slot, bs_h], center = true);  
    
    translate([wall / 2, 0, 0])
    cube([slot_in + 1e-3, slot, 2 * bs_h], center = true);    
    
    translate([-wall/2 - (slot_in - wall)/2, 10, 0])
    cylinder(d = 2.5, h = 2 * bs_h, center = true);

    translate([-wall/2 - (slot_in - wall)/2, -10, 0])
    cylinder(d = 2.5, h = 2 * bs_h, center = true);
  }
}


module battery_support_vert(w = 2, h = 34.5){
  $fn = 32;
  difference() {
    linear_extrude(height = 30, center = true, convexity = 10)
    polygon(points=[[0, 0],
                    [20, 0],
                    [20, w],
                    [w, w],
                    [w, h + 5],
                    [0, h + 5],
                    [0, h + 2],
                    [-3, h + 2],
                    [-3, h],
                    [0, h],
                  ]);
    
    translate([10, 0, 10])
    rotate([90, 0, 0])
    cylinder(d = 2.5, h = 10, center = true);

    translate([10, 0, -10])
    rotate([90, 0, 0])
    cylinder(d = 2.5, h = 10, center = true);
  }
  
}

battery_support_top();
//battery_support_vert();