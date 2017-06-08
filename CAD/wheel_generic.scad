
$fa=12;
$fs=0.5;
screw_M2 = 1.7;
screw_M25 = 2.1;
screw_M3 = 2.5;

slack = 0.3;
wheel_width = 5;
wheel_small_width = 3;

oring_radius = 76/2;
oring_width = 3.5;
hole_radius = 6.0/2 + slack/2;
max_r = oring_radius + oring_width/2;
cut_r = 0;
hub_width = 10;
hub_radius = 12;
hub_top_chanfer = 1;
hub_bottom_chanfer = 1.5;

screw_radius = screw_M3 / 2;

rim_holes_num = 8;
rim_holes_d = 13;

module axis_slot(chop = 0.55) {
  translate([hole_radius - chop, -hole_radius, 0]) 
  cube([2 * chop, 2 * hole_radius, hub_width], center = false);
}



module wheel() {
  difference() {
    union() {
      difference() {
        rotate_extrude(convexity = 10, $fn = 100)
        difference() {
          polygon( points=[[0, 0], 
                           [max_r - cut_r, 0], 
                           [max_r - cut_r, wheel_width], 
                           [max_r - wheel_width, wheel_width],
                           [max_r - 8, wheel_small_width],
                           [hub_radius + hub_bottom_chanfer, wheel_small_width],
                           [hub_radius, wheel_small_width + hub_bottom_chanfer], 
                           [hub_radius, hub_width - hub_top_chanfer],
                           [hub_radius - hub_top_chanfer, hub_width], 
                           [0, hub_width]] );
          // O-Ring carving
          translate([max_r, wheel_width/2, 0]) circle(r = oring_width/2);
        }
        // wheel axis hole
        cylinder(h = 3 * hub_width, r = hole_radius, center = true);
      }
      axis_slot();
      //mirror() axis_slot();
    }
    
    // pin holes (120º) 
    for(i = [0:2]){
      rotate([0, 0, 120 * i])
      translate([0, 0, wheel_small_width + (hub_width - wheel_small_width)/2]) 
      rotate([0, 90, 0])
      cylinder(h = 2 * hub_radius, r = screw_radius, center = false);
    }
    
    for(i = [0:rim_holes_num - 1]){
      rotate([0, 0, i * 360 / rim_holes_num])
      translate([hub_radius + (oring_radius - hub_radius)/2, 0 , 0]) 
      cylinder(h = 2 * hub_radius, d = rim_holes_d, center = true);
    }  

  }
}


wheel();