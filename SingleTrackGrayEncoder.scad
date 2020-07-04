/*
 * Single Track Gray Code encoder
 *
 * This utilises 6 sensors so gives a resolution of +/- 3 degrees
 * (discrete states = 2^n-2n)
 * this gives 52 possible states
 * so 6.92 degree resolution
 */

// Rotor parameters
rotor_d = 40;
wall_t = 2;
height = 12.5+wall_t;
shaft_d = 8;
shaft_h = 50+height;
pcb_side = 48;
screw_d = 3;

hub_id = shaft_d+wall_t/2;
hub_od = hub_id+2*wall_t;
hub_h = 2*wall_t;

// led/sensor device parameters
opto_l = 25;
opto_h = 12.5;
opto_w = 6.5;
dev_d = 3;  //rotor_d
dev_h = 3;  //height excluding flange & leads
mount_d = 5;    //mounting hole rotor_d
aperture = dev_d/2;     //beam slot width
ring_w = 3*mount_d;   // width of ring

$fn=128;

// possible views:
// all - everything
// rotor - the rotating encoder
// sensor_mount - mount for opto interrupters
// sensor_plate - mounting plate for the leds/photo transistors
view = "all";

module rotor() {
    difference() {
        union() {
            // disc
            cylinder(d=rotor_d-6*wall_t, h=wall_t);
            // shaft
            translate([0,0,-height])
                cylinder(d=shaft_d,h=shaft_h);
            difference() {
                cylinder(d=rotor_d,h=wall_t);
                rotate([0,0,-10])
                    isoprism(rotor_d,wall_t,20);
                rotate([0,0,-130])
                    isoprism(rotor_d,wall_t,50);
                rotate([0,0,150])
                    isoprism(rotor_d,wall_t,80);
            };
        };
    };
};

module sensor_mount() {
    // hub
    translate([0,0,wall_t])
        difference() {
            cylinder(d=hub_od,h=hub_h);
            cylinder(d=hub_id,h=hub_h);
        };
    difference() {
        // plate
        translate([-pcb_side/2,-pcb_side/2,0])
            cube([pcb_side,pcb_side,wall_t]);
        // hub
        cylinder(d=hub_id,h=wall_t);
        // mounting holes
        translate([-pcb_side/2+screw_d,-pcb_side/2+screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([pcb_side/2-screw_d,-pcb_side/2+screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([-pcb_side/2+screw_d,pcb_side/2-screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([pcb_side/2-screw_d,pcb_side/2-screw_d,0])
            cylinder(d=screw_d,h=wall_t);
    };
    translate([0,0,wall_t])
        difference() {
            cylinder(d=rotor_d+4*wall_t,h=opto_l/2+2*wall_t);
            cylinder(d=rotor_d+2*wall_t,h=opto_l/2+2*wall_t);
            for(a = [0:60:300]) {
                x = sin(a)*(rotor_d/2+hub_od);
                y = cos(a)*(rotor_d/2+hub_od);
                translate([x,y,wall_t])
                    rotate([90,0,360-a]) {
                        cylinder(d=screw_d,h=rotor_d/2);
                        translate([-opto_w/2,screw_d,(opto_l-opto_h)/2])
                        cube([opto_w, opto_h, opto_h]);
                    };
            };
        };
};

module sensor_plate() {
    // hub
    translate([0,0,-wall_t])
        difference() {
            cylinder(d=hub_od,h=hub_h);
            cylinder(d=hub_id,h=hub_h);
        };
    // sensor ring
    difference() {
        // plate
        translate([-pcb_side/2,-pcb_side/2,0])
            cube([pcb_side,pcb_side,wall_t]);
        // hub
        cylinder(d=hub_id,h=wall_t);
        // mounting holes
        translate([-pcb_side/2+screw_d,-pcb_side/2+screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([pcb_side/2-screw_d,-pcb_side/2+screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([-pcb_side/2+screw_d,pcb_side/2-screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        translate([pcb_side/2-screw_d,pcb_side/2-screw_d,0])
            cylinder(d=screw_d,h=wall_t);
        // apertures
        for(a = [0:60:300]) {
            x = sin(a)*(rotor_d/2-ring_w/4);
            y = cos(a)*(rotor_d/2-ring_w/4);
            translate([x,y,0])
                cylinder(d=aperture,h=wall_t);
        }; // end of aperture for loop
    };
    // device holders
    for(a = [0:60:300]) {
        x = sin(a)*(rotor_d/2-ring_w/4);
        y = cos(a)*(rotor_d/2-ring_w/4);
        translate([x,y,0])
            device_holder();
    }; // end of device_holder for loop
    // mounting pillars
    m_pillar(-pcb_side/2+screw_d,-pcb_side/2+screw_d);
    m_pillar(pcb_side/2-screw_d,-pcb_side/2+screw_d);
    m_pillar(-pcb_side/2+screw_d,pcb_side/2-screw_d);
    m_pillar(pcb_side/2-screw_d,pcb_side/2-screw_d);
};

module m_pillar(x,y) {
    translate([x,y,(-hub_h-wall_t)/2])
        difference() {
            cylinder(d=2*screw_d,h=(hub_h+wall_t)/2);
            cylinder(d=screw_d,h=(hub_h+wall_t)/2);
        };
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
    translate([0,0,-height])
        sensor_mount();
    translate([0,0,height])
        rotate([180,0,0])
            sensor_mount();
    }
else
    echo("UNKNOWN VIEW SELECTED. Set the view variable to define the view"); 


module isoprism(l, h, a){
    // produces an isoceles prism
    // l = length on Y axis
    // h = height on Z axis
    // a = apex angle
    // this is a nice exercise in basic trigonmetry
    x = sin(a/2)*l;
    y = cos(a/2)*l;
    polyhedron(
        points=[[0,0,0],[-x,y,0],[x,y,0], [0,0,h],[-x,y,h],[x,y,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
};