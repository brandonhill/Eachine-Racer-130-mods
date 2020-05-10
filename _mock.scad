// **************
// MOCK

include <_setup.scad>;

PRINT_COL_ALL = "lime";
PRINT_COL_CANOPY = COLOUR_GREY_DARK;

MOCK_HARDWARE = false;

use <board mount.scad>;
use <cam mount.scad>;
use <canopy.scad>;

*mock_batt();

color(COLOUR_CF)
translate([0, 0, -0.01])
% mock_frame();
// # cube([FRAME_DIM[0], FRAME_DIM[1], FRAME_THICKNESS], true) // dim check

// *
// color(PRINT_COL_CANOPY)
// % color([0.5, 0.5, 0.5, 0.25])
//translate([0, 0, 0.01])
%
show_half()
// show_half([0, 0, 90])
canopy();

// mock windshield
*%
show_half([90, 0], [0, 0, FRAME_THICKNESS])
translate([-(WINDSHIELD_RAD - CANOPY_ROUNDING) + FRAME_DIM[0] / 2 - CANOPY_ROUNDING - CANOPY_THICKNESS + WINDSHIELD_THICKNESS, 0])
rotate([90, 0])
rotate_extrude(angle = asin(CANOPY_HEIGHT / (WINDSHIELD_RAD - WINDSHIELD_THICKNESS)), $fa = 5)
translate([WINDSHIELD_RAD + TOLERANCE_CLOSE + WINDSHIELD_THICKNESS / 2, 0])
sq([WINDSHIELD_THICKNESS, WINDSHIELD_CUTOUT_DIM[1] + 2 - TOLERANCE_CLEAR * 2]);

*% pos_motor_wires()
for (x = [-1 : 1])
translate([MOTOR_WIRE_RAD * 2 * x, 0, -FRAME_MOUNT_SKIN])
rotate([90, 0])
cylinder(h = 10, r = MOTOR_WIRE_RAD, center = true);

translate([0, 0, FRAME_THICKNESS]) {

	*
	union() {
		$fs = 1;
		color("gold")
		batt_conn_cutout(offset = 0, l = BATT_CONN_DIM[0] - 3);
	}

	// *
	//color(PRINT_COL_ALL)
	pos_cam_mount()
	cam_mount();

	*
	mock_camera();

	// *
	pos_led()
	% mock_led();

	*
	reflect()
	translate(MOTOR_SPACING / 2) {
		*mock_motor();
		translate([0, 0, MOTOR_HEIGHT + 5])
		mock_prop();
	}

	// *
	// color(PRINT_COL_ALL)
	// *color(PRINT_COL_CANOPY)
	// show_half()
	stack_mount_base();

	*
	reflect(x = false)
	pos_rx_ant_mount()
	% mock_rx_ant();

	*
	mock_esc();

	// *
	//color(PRINT_COL_ALL)
	mock_fc_mount_posts();

	*
	mock_fc();

	// *
	// show_half()//[0, 0, 90])
	// color(PRINT_COL_ALL)
	translate(RX_POS)
	rotate(RX_ROT)
	translate([0, 0, RX_BOARD_DIM[2] + STACK_MOUNT_LIP_THICKNESS])
	mirror([0, 0, 1])
	rx_mount();

	*
	mock_rx();

	// *
	// show_half()//[0, 0, 90])
	//color(PRINT_COL_ALL)
	translate([FC_POS[0] - VTX_POS[0], 0])
	translate(VTX_POS)
	translate([0, 0, VTX_BOARD_DIM[2] + STACK_MOUNT_LIP_THICKNESS])
	mirror([0, 0, 1])
	vtx_mount();

	*
	mock_vtx();

	*
	mock_vtx_ant();

	*
	translate([0, 0, VTX_POS[2] + VTX_BOARD_DIM[2] + TOLERANCE_FIT])
	transpose(FC_HOLE_SPACING / 2)
	% screw(dim = SCREW_M2_SOCKET_DIM, h = VTX_POS[2]);
}

echo(str("Screw lengths, frame base = ", FRAME_BASE_SCREW_LENGTH, ", stack back = ", STACK_SCREW_BACK_LENGTH, ", front = ", STACK_SCREW_FRONT_LENGTH));

if (MOCK_HARDWARE) {

	// front frame base screws
	reflect(x = false)
	translate(FRAME_SCREW_FRONT_POS)
	mirror([0, 0, 1])
	% screw(
		FRAME_SCREW_DIM,
		FRAME_BASE_SCREW_LENGTH
	);

	// front stack screws
	reflect(x = false)
	translate([0, 0, FRAME_THICKNESS + FC_POS[2] + FC_BOARD_DIM[2] + CAM_MOUNT_ARM_WIDTH])
	pos_stack_post()
	// mirror([0, 0, 1])
	% screw(
		FRAME_SCREW_DIM,
		STACK_SCREW_FRONT_LENGTH
	);

	// back stack screws
	reflect(x = [-1])
	translate([0, 0, FRAME_THICKNESS + VTX_POS[2] + VTX_BOARD_DIM[2]])
	pos_stack_post()
	% screw(
		FRAME_SCREW_DIM,
		STACK_SCREW_BACK_LENGTH
	);

	// back frame base screws
	reflect(x = false)
	translate(FRAME_SCREW_BACK_POS)
	mirror([0, 0, 1])
	% screw(
		FRAME_SCREW_DIM,
		FRAME_BASE_SCREW_LENGTH
	);
}

module mock_batt(pos = BATT_POS, rot = []) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(BATT_DIM, true);
}

module mock_batt_strap(pos = BATT_STRAP_POS, rot = BATT_STRAP_ROT) {
	translate(pos)
	rotate(rot)
	translate([0, 0, BATT_STRAP_DIM[1] / 2]) {
		cube([FRAME_DIM[1] + (TOLERANCE_CLEAR + BATT_STRAP_DIM[1]) * 2, BATT_STRAP_DIM[0], BATT_STRAP_DIM[1]], true);
		reflect(y = false)
		translate([(FRAME_DIM[1] + BATT_STRAP_DIM[1]) / 2, 0])
		rotate([0, 20])
		cube([50, BATT_STRAP_DIM[0], BATT_STRAP_DIM[1]], true);
	}
}

module mock_buzzer(pos = BUZZER_POS, rot = BUZZER_ROT) {
	translate(pos)
	rotate(rot)
	translate([0, 0, -BUZZER_DIM[2] / 2])
	buzzer_piezo(h = BUZZER_DIM[2], r = BUZZER_DIM[0] / 2, wires = false);
}

module mock_camera(pos = CAM_POS, rot = CAM_ROT, fov = 120) {
	translate(pos)
	// rotate([0, oscillate(-5, 5)])
	rotate(rot) {
		translate([CAM_PIVOT_OFFSET, 0])
		cam_runcam_swift_micro(col = "lime", outset = CAM_DIM[2] + CAM_PIVOT_OFFSET);

		// FOV
		*
		%
		// translate([CAM_DIM[2] / 2, 0])
		rotate([0, 90])
		cylinder(h = 10, r1 = 0, r2 = tan(fov / 2) * (10));
	}
}

module mock_esc(pos = ESC_POS, rot = ESC_ROT) {
	translate(pos)
	rotate(rot)
	esc_hakrc_20_15ax4(center = "board");
}

module mock_fc_mount_posts(
		h = FC_MOUNT_HEIGHT,
		pos = FC_POS,
	) {
	translate(pos)
	reflect()
	translate([0, 0, -h])
	fc_standoff();
}

module mock_fc(pos = FC_POS, rot = FC_ROT) {
	translate(pos)
	rotate(rot)
	fc_omnibus_f4_mini();
}

module mock_led() {
	// board
	translate([0, 0, LED_BOARD_DIM[2] / 2])
	cube(LED_BOARD_DIM, true);

	// leds
	pos_led_holes()
	translate([0, 0, LED_DIM[2] / 2])
	cube(LED_DIM, true);
}

module mock_motor(pos = [], rot = []) {
	translate(pos)
	rotate(rot)
	motor_generic(
		height = MOTOR_HEIGHT,
		rad = MOTOR_RAD,
		mount_arm_width = 0,
		mount_height = 0,
		mount_rad = 0,
		mount_holes = 4,
		mount_hole_rad = 1.5 / 2,
		mount_hole_thickness = 0, // ?
		shaft_height = 4,
		shaft_rad = 0.5,
		col_bell = COLOUR_RED,
		col_mount = COLOUR_GREY_DARK
	);
}

module mock_prop(r = PROP_RAD) {
	color(COLOUR_GREY_DARK)
	rotate_extrude()
	translate([r, 0])
	circle(0.1);
}

module mock_rx(pos = RX_POS, rot = RX_ROT) {
	translate(pos)
	rotate(rot)
	rx_frsky_xm_plus();
}

module mock_rx_ant(pos = [], rot = []) {
	l = 35;
	rotate([0, 90, 90])
	cylinder(h = l, r = 0.5);
}

module mock_vtx() {
	pos_vtx()
	vtx();
}

module mock_vtx_ant() {
	translate(VTX_ANT_POS)
	rotate(VTX_ANT_ROT)
	5g_uxii_antenna(20);
}
