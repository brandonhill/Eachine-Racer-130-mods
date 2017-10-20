// **************
// MOCK

include <_conf.scad>;
use <ant mount.scad>;
use <board mount.scad>;
use <cam mount.scad>;
use <canopy.scad>;

*
mock_battery();

// *
//%
color(COLOUR_CF)
mock_frame();
translate([0, 0, FRAME_THICKNESS]) {

// 	*
	mock_buzzer();

// 	*
	cam_mount()
	mock_camera();

// 	*
	%
//	show_half()
	translate(CANOPY_POS)
	canopy();

// 	*
	reflect()
	translate(MOTOR_SPACING / 2) {
		mock_motor();
		translate([0, 0, MOTOR_HEIGHT + 5])
		mock_prop();
	}

	mock_rx();

// 	*
	board_mount_back();

// 	*
	board_mount_front();

// 	*
	translate([-33, 0, 6])
	rotate([0, -90])
	rotate([90, 0, 45])
	mock_rx_ant();

// 	*
	translate([-30, 0, 0])
	ant_mount()
	translate([0, 0, -10])
	5g_cp_antenna(40);

	mock_fc();

	mock_vtx();
}

module mock_battery(pos = BATT_POS, rot = []) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(BATT_DIM, true);
}

module mock_buzzer(pos = BUZZER_POS, rot = BUZZER_ROT) {
	translate(pos)
	rotate(rot)
	translate([0, 0, -BUZZER_DIM[2] / 2])
	buzzer_piezo(h = BUZZER_DIM[2], r = BUZZER_DIM[0] / 2, wires = false);
}

module mock_camera(pos = [], rot = [], fov = 120) {
	translate(pos)
// 	rotate([0, oscillate(-5, 5)])
	rotate(rot) {
		translate([CAM_PIVOT_OFFSET, 0])
		cam_runcam_swift_micro();

		// FOV
		*
		%
// 		translate([CAM_DIM[2] / 2, 0])
		rotate([0, 90])
		cylinder(h = 10, r1 = 0, r2 = tan(fov / 2) * (10));
	}
}

module mock_fc(pos = FC_POS, rot = FC_ROT) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(FC_DIM, true);
}

module mock_frame(
		arm_angle = FRAME_ARM_ANGLE,
		arm_width = FRAME_ARM_WIDTH,
		center_offset = FRAME_CENTER_OFFSET,
		dim = FRAME_DIM,
		motor_spacing = MOTOR_SPACING,
		thickness = FRAME_THICKNESS,
	) {

	module shape_arm() {
		translate([-arm_width / 2, 0])
		square([arm_width, (motor_spacing[1] + arm_width) / 2]);
	}

	module shape_center() {
		square(dim, true);
	}

	linear_extrude(thickness)
	smooth(2)
	{

		// center
		*
		translate([center_offset, 0])
		shape_center();
// 		*
		square([78, 32], true);

		// arms
		for (x = [-1, 1], y = [-1, 1])
		scale([x, y])
		translate([motor_spacing[0] / 2, 0])
		translate([0, motor_spacing[1] / 2])
		rotate([0, 0, -arm_angle])
		translate([0, -motor_spacing[1] / 2])
		shape_arm();
	}
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

module mock_rx(pos = RX_POS, rot = []) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK)
	cube(RX_DIM, true);
}

module mock_rx_ant(pos = [], rot = []) {
	l = 40;
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY) {
		cylinder(h = l, r = 0.5);
		rotate([0, 90])
		cylinder(h = l, r = 0.5);
	}
}

module mock_vtx(pos = VTX_POS, rot = VTX_ROT) {
	translate(pos)
	rotate(rot) {
		vtx_vtx03();

		*translate([0, VTX_DIM[1] / 2 - 1, 1])
		rotate([90, 0])
		5g_cp_antenna(63);
	}
}
