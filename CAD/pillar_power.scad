

module hexagon(size, height) {
  boxWidth = size / sqrt(3);
  for (r = [-60, 0, 60]) rotate([0,0,r]) cube([boxWidth, size, height], true);
}

module pilar(ph = 21.5, disp = 2.5) {
  difference() {
    hexagon(11, ph);
    //translate([0, disp, 0])
    cylinder(d = 3.4, h = ph + 1, center = true, $fn = 64);
  }
}


//rotate([90, 0, 90])
pilar();