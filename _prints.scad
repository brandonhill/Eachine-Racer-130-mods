// **************
// For STL generation

include <_setup.scad>;
use <board mount.scad>;
use <cam mount.scad>;
use <canopy.scad>;

$fs = 0.5;

*cam_mount();

rotate([180, 0])
canopy();

// x 4
*fc_standoff();

*rx_mount();

*union() {
	stack_mount_base();

	// manual supports
	*linear_extrude(BATT_STRAP_DIM[1] + TOLERANCE_CLOSE)
	grid(
		dim = [BATT_STRAP_DIM[0] * 2/3, FRAME_DIM[1] + 4],
		divisions = [2, 1],
		walls = 0.5125);

	*linear_extrude(BATT_CONN_DIM[2] + TOLERANCE_CLOSE)
	translate([-(FRAME_DIM[0] - BATT_CONN_DIM[0] / 2) / 2, 0])
	grid(
		dim = [BATT_CONN_DIM[0], BATT_CONN_DIM[1]] * 2/3,
		divisions = [1, 1],
		walls = 0.5125);
}

*vtx_mount();
