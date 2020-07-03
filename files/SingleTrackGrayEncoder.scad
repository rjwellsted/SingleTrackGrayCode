/*
 * Single Track Gray Code encoder
 *
 * This utilises 6 sensors so gives a resolution of +/- 3.5 degrees
 * (discrete states = 2^n-2n)
 * this gives 60 possible states
 * so 6 degree resolution
 */

// Rotor parameters
diameter = 40;
height = 10;
wall_t = 2;
shaft_d = 8;
shaft_h = 50;

// led/sensor device parameters
dev_d = 3;  //diameter
dev_h = 3;  //height excluding flange & leads
mount_d = 5;    //mounting hole diameter
aperture = dev_d/2;     //beam slot width
ring_w = 3*mount_d;   // width of ring

$fn=128;

// possible views:
// all - everything
// rotor - the rotating encoder
// sensor_mount - mounting ring for the leds/photo transistors
view = "sensor_mount";

module rotor() {
    difference() {
        union() {
            // disc
            cylinder(d=diameter-6*wall_t, h=wall_t);
            // shaft
            translate([0,0,-2*wall_t])
                cylinder(d=shaft_d,h=shaft_h+2*wall_t);
            difference() {
                cylinder(d=diameter, h=wall_t);
                rotate([0,0,200])
                    cube([diameter,diameter,wall_t]);
                rotate([0,0,80])
                    isoprism(diameter,wall_t,20);
                rotate([0,0,20])
                        isoprism(diameter,wall_t,40);
            };
        };
    };
};

module sensor_mount() {
    difference() {
        cylinder(d=diameter,h=wall_t);
        cylinder(d=diameter-ring_w,h=wall_t);
        
        for(a = [0:60:300]) {
            x = sin(a)*(diameter/2-ring_w/4);
            y = cos(a)*(diameter/2-ring_w/4);
            translate([x,y,0])
                cylinder(d=aperture,h=wall_t);
        }; // end of for loop
    };
    for(a = [0:60:300]) {
        x = sin(a)*(diameter/2-ring_w/4);
        y = cos(a)*(diameter/2-ring_w/4);
        translate([x,y,0])
            device_holder();
        }; // end of for loop
};

module device_holder() {
    // produce a holder
    // with a small aperture to
    // prevent false triggering
    difference() {
        // outside of the cover
        translate([0,0,wall_t])
            cylinder(d=mount_d+wall_t,h=dev_h+wall_t);
        // mounting flange
        translate([0,0,dev_h+wall_t])
            cylinder(d=mount_d,h=wall_t);
        // the inside
        translate([0,0,wall_t])
            cylinder(d=dev_d,h=dev_h);
        // the apeture
        cylinder(d=aperture,h=wall_t);
    };
};

if (view == "rotor")
    rotor();
else if (view == "sensor_mount")
    sensor_mount();
else if (view == "all") {
    rotor();
    translate([0,0,wall_t*2])
        sensor_mount();
    translate([0,0,-wall_t])
        rotate([180,0,0])
            sensor_mount();
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