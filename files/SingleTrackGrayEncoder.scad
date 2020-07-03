/*
 * Single Track Gray Code encoder
 *
 * This utilises 6 sensors so gives a resolution of +/- 3 degrees
 * (discrete states = 2^n-2n)
 * this gives 60 possible states
 * so 6 degree resolution
 */

// Rotor parameters
diameter = 50;
height = 10;
wall_thickness = 2;
shaft_diameter = 6;
recess_diameter = 11;
recess_depth = 0.5;

// led/sensor device parameters
dev_d = 3;  //diameter
dev_h = 3;  //height excluding flange & leads
mount_d = 5;    //mounting hole diameter
slot_w = 1;     //beam slot width
ring_w = 3*mount_d;   // width of ring

$fn=128;

// possible views:
// all - everything
// rotor - the rotating encoder
// sensor_ring - mounting ring for the leds/photo transistors
view = "sensor_ring";

module rotor() {
    difference() {
        union() {
            // disc
            cylinder(d=diameter-6*wall_thickness, h=wall_thickness);
             difference() {
                cylinder(d=diameter, h=wall_thickness);
                rotate([0,0,200])
                    cube([diameter,diameter,wall_thickness]);
                rotate([0,0,80])
                    isoprism(diameter,wall_thickness,20);
                rotate([0,0,20])
                        isoprism(diameter,wall_thickness,40);
            };
        };
        // centre hole
        cylinder(d=shaft_diameter,h=height);
        // recess
        cylinder(d=recess_diameter, h=recess_depth);
    };
};

module sensor_ring() {
    difference() {
        cylinder(d=diameter,h=wall_thickness);
        cylinder(d=diameter-ring_w,h=wall_thickness);
        
        for(a = [0:60:300]) {
            x = sin(a)*(diameter/2-ring_w/4);
            y = cos(a)*(diameter/2-ring_w/4);
            translate([x,y,0])
                cylinder(d=mount_d,h=wall_thickness);
        }; // end of for loop
    };
    for(a = [0:60:300]) {
        x = sin(a)*(diameter/2-ring_w/4);
        y = cos(a)*(diameter/2-ring_w/4);
        translate([x,y,0])
            sensor_cover();       }; // end of for loop
};

module sensor_cover() {
    // produce a sensor/led cover
    // with a small appeture to
    // prevent false triggering
    difference() {
        // outside of the cover
        cylinder(d=mount_d+wall_thickness,h=dev_h+wall_thickness);
        // mounting flange
        cylinder(d=mount_d,h=wall_thickness/2);
        // the inside
        cylinder(d=dev_d,h=dev_h);
        // the appeture
        cylinder(d=slot_w,h=height+wall_thickness);
    };
};

if (view == "rotor")
    rotor();
else if (view == "led_ring")
    sensor_ring();
else if (view == "sensor_ring")
    sensor_ring();
else if (view == "all") {
    rotor();
    translate([0,0,-height])
        sensor_ring();
    translate([0,0,height+wall_thickness])
        rotate([180,0,0])
            sensor_ring();
    }
else
    echo("UNKNOWN VIEW SELECTED. Set the view variable to define the view"); 


module isoprism(l, h, a){
    // produces an isoceles prism
    // l = length on y axis
    // h = height
    // a = apex angle
    // a nice exercise in basic trigonmetry
    x = sin(a/2)*l;
    y = cos(a/2)*l;
    polyhedron(
        points=[[0,0,0],[-x,y,0],[x,y,0], [0,0,h],[-x,y,h],[x,y,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
};