// **************
// For STL generation

use <ant mount.scad>;
use <board mount.scad>;
use <cam mount.scad>;
use <canopy.scad>;

$fs = 0.5;

*
rotate([0, -90])
ant_mount();

*
rotate([0, -90])
cam_mount();

*
board_mount_back();

*
board_mount_front();

*
rotate([180, 0])
canopy();

// ************
// TESTS

// canopy lip
*
rotate([180, 0])
intersection() {
	canopy();

	translate([33, 0])
	cube([10, 50, 6], true);
}