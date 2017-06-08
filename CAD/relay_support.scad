$fn = 32;

holes = [
  [0, 0],
  [0, 32],
  [44, 0],
  [44, 32]
];

module place_things(pos_list) {
   for (t = pos_list) {  
     translate(t)
     //children(0);
     children([0:1:$children-1]);
   }
 }


module relay_support(db = 6, cx1 = 44/2 - 4, cx2 = 44/2 + 4, cy = 32/2) {

  difference() {
    union() {
      place_things(holes)
      cylinder(d = 4.5, h = 5);
      
      linear_extrude(height = 1.2, center = true, convexity = 10, twist = 0) {
        hull() {
          translate(holes[0])
          circle(d = db); 
          
          translate([cx1, cy, 0])
          circle(d = db); 
        }

        hull() {
          translate(holes[1])
          circle(d = db); 
          
          translate([cx1, cy, 0])
          circle(d = db); 
        }

        hull() {
          translate(holes[3])
          circle(d = db); 
          
          translate([cx2, cy, 0])
          circle(d = db); 
        }
        
        hull() {
          translate(holes[2])
          circle(d = db); 
          
          translate([cx2, cy, 0])
          circle(d = db); 
        }

        hull() {
          translate([cx1, cy, 0])
          circle(d = db + 3); 
          
          translate([cx2, cy, 0])
          circle(d = db + 3); 
        }
      }
    }
    place_things(holes)
    cylinder(d = 3, h = 20, center = true);    
    
    translate([cx1, cy, 0])
    cylinder(d = 2.5, h = 20, center = true);    

    translate([cx2, cy, 0])
    cylinder(d = 2.5, h = 20, center = true);    

  }
}


relay_support();