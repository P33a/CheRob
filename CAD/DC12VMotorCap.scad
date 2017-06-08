slack = 0.5;
holes_radius = 15.5;
screw_M4 = 3.5 / 2;

module motor_cap_slanted(m_d = 35, thickness = 1.2){
  difference() {
    union() {
      // Main Body
      translate([0, 0, 0])
      cylinder(d1 = 30, d2 = m_d, h = 14, $fn = 50, center = false);
      translate([0, 0, 14])
      cylinder(d = m_d, h = 6, $fn = 50, center = false);
    }
    translate([0, 0, thickness])
    cylinder(d1 = 30 - thickness, d2 = m_d - thickness, h = 14, $fn = 50, center = false);
    translate([0, 0, 14 + thickness])
    cylinder(d = m_d - thickness, h = 6, $fn = 50, center = false);


    //translate([0, 0, thickness])
    translate([25, 0, 14 + 2])
    cube([50, 12, 10], center = true);


  }
}

module motor_cap(m_d = 35, m_h = 12.5 + 4, m_sup = 4 , thickness = 1.5){
  $fn = 128;
  difference() {
    union() {
      // Main Body
      translate([0, 0, 0])
      cylinder(d = m_d + 2 * thickness, h = m_h + thickness,  center = false);
    }
    translate([0, 0, thickness])
    cylinder(d = m_d - 0.6, h = m_h, center = false);

    translate([0, 0, thickness + m_h - m_sup])
    cylinder(d = m_d, h = m_h, center = false);

    translate([25, 0, m_h  + thickness - 9])
    cube([50, 16, 4], center = true);


  }
}



motor_cap();