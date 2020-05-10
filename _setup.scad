
include <_conf.scad>;

module batt_conn_cutout(offset = TOLERANCE_CLEAR, delta, l = BATT_CONN_DIM[0]) {
	module shape() {
		translate([0, BATT_CONN_DIM[1] / 4])
		sq([BATT_CONN_DIM[2], BATT_CONN_DIM[1] / 2]);
		rounded_square([BATT_CONN_DIM[2], BATT_CONN_DIM[1]], BATT_CONN_DIM[2] / 4);
	}
	translate([-FRAME_DIM[0] / 2 + BATT_CONN_DIM[0] / 2, 0, BATT_CONN_DIM[2] / 2])
	rotate([0, -90])
	linear_extrude(l)//, center = true)
	// rotate([0, 0, -90])
	if (delta)
		offset(delta = offset) shape();
	else
		offset(r = offset) shape();
}

module mock_frame(
		thickness = FRAME_THICKNESS,
	) {
	linear_extrude(thickness)
	shape_frame();
}

module pos_booms(reflect = [true, true]) {
	reflect(x = reflect[0], y = reflect[1])
	translate([MOTOR_SPACING[0] / 2, MOTOR_SPACING[1] / 2])
	rotate([0, 0, -FRAME_ARM_ANGLE])
	translate([0, -MOTOR_SPACING[1] / 2])
	children();
}

module pos_canopy_clip() {
	translate(CANOPY_CLIP_POS)
	children();
}

module pos_led(pos = LED_POS, rot = LED_ROT) {
	translate(pos)
	rotate(rot)
	children();
}

module pos_led_holes() {
	reflect(y = false)
	for (x = [1, 3])
	translate([(LED_SPACING + LED_DIM[0]) / 2 * x, 0, LED_DIM[2] / 2])
	children();
}

module pos_motor_wires(reflect = [true, true]) {
	pos_booms(reflect = reflect)
	translate([
		-(FRAME_ARM_WIDTH / 6), // inset a bit
		FRAME_DIM[1] / 2,
		FRAME_THICKNESS + SKIN_MIN_THICKNESS + MOTOR_WIRE_RAD])
	children();
}

module pos_rx(pos = RX_POS, rot = RX_ROT, z = true) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
	children();
}

module pos_rx_ant_mount() {
	translate(RX_ANT_MOUNT_POS)
	rotate([0, 0, 45])
	children();
}

module pos_stack_post(
		stack_hole_spacing = FC_HOLE_SPACING,
	) {
	translate(stack_hole_spacing / 2)
	children();
}

module pos_vtx(pos = VTX_POS, rot = VTX_ROT, z = true) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
	children();
}

module shape_frame() {

	module shape_center() {
		sq(FRAME_DIM);
	}

	module shape() {
		translate([FRAME_CENTER_OFFSET, 0])
		shape_center();

		shape_frame_booms();
	}

	difference() {
		smooth(5)
		intersection() {
			sq([SIZE_DIA, SIZE_DIA] * 1.5);
			difference() {
				sq([SIZE_DIA, SIZE_DIA] * 2);

				// need to smooth the diff
				smooth(14)
				difference() {
					sq([SIZE_DIA, SIZE_DIA] * 2);
					shape();
				}
			}
		}

		reflect()
		pos_stack_post()
		circle(FRAME_SCREW_DIM[0] / 2 + TOLERANCE_FIT);
	}
}

module shape_frame_booms() {
	pos_booms()
	translate([-FRAME_ARM_WIDTH / 2, 0])
	square([FRAME_ARM_WIDTH, (MOTOR_SPACING[1] + FRAME_ARM_WIDTH) / 2]);
}

module vtx() {
	// vtx_vtx03();
	// vtx_ewrf_e7092tm();
	vtx_ewrf_e7082cpro();
}
