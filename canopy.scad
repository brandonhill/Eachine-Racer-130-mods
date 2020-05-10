
include <_setup.scad>;
use <board mount.scad>;
use <cam mount.scad>;

module canopy() {
	difference() {
		// canopy_solid(offset = TOLERANCE_CLEAR + CANOPY_THICKNESS, flares = false);
		// canopy_solid(offset = 0, flares = false);
		// *
		union() {
			difference() {
				canopy_solid(offset = TOLERANCE_CLEAR + CANOPY_THICKNESS);
				canopy_solid(offset = TOLERANCE_CLEAR);
			}
			intersection() {
				canopy_solid(offset = TOLERANCE_CLEAR);
				union() {
					canopy_lip();
					canopy_lip_back(smooth = 0.25);
				}
			}
		}

		// side boom cutouts
		pos_booms()
		translate([0, 10, -0.1])
		linear_extrude(FRAME_THICKNESS + 0.1, convexity = 2, scale = 0.85)
		offset(r = FRAME_THICKNESS * 3)
		sq([FRAME_ARM_WIDTH, 20]);

		// batt conn cutout
		hull()
		for (z = [0, FRAME_THICKNESS])
		translate([0, 0, z])
		batt_conn_cutout();

		// batt strap cutout
		*linear_extrude(FRAME_THICKNESS + BATT_STRAP_DIM[1], scale = [0.8, 1])
		offset(r = FRAME_THICKNESS)
		sq([
			BATT_STRAP_DIM[0] + TOLERANCE_CLOSE * 2,
			FRAME_DIM[1] + (TOLERANCE_CLEAR + CANOPY_THICKNESS) * 2]);

		// cam cutout (windshield)
		translate([CAM_POS[0], 0, FRAME_THICKNESS + CANOPY_SEAL_DEPTH + WINDSHIELD_CUTOUT_DIM[0] / 2])
		translate([CAM_DIM[2] / 2, 0])
		rotate([0, 90])
		linear_extrude(10, center = true)
		rounded_square(WINDSHIELD_CUTOUT_DIM, CANOPY_ROUNDING);

		// led cutouts
		translate([0, 0, FRAME_THICKNESS])
		pos_led()
		pos_led_holes()
		hull()
		reflect(x = false)
		translate([0, LED_DIM[0] / 3, LED_DIM[2] * 1.3])
		cylinder_true(h = CANOPY_THICKNESS + 0.2, r1 = LED_DIM[0] / 2, r2 = LED_DIM[0] / 6, $fn = 8);
		// cylinder_true(h = CANOPY_THICKNESS + 0.2, r = LED_DIM[0] / 6, $fn = 8);

		// motor wire cutouts
		pos_motor_wires()
		translate([0, 0, -FRAME_MOUNT_SKIN - MOTOR_WIRE_CUTOUT_DIM[1] / 2])
		rounded_cube([
			MOTOR_WIRE_CUTOUT_DIM[0],
			FRAME_DIM[1],
			MOTOR_WIRE_CUTOUT_DIM[1] * 2], MOTOR_WIRE_RAD);

		// rx ant mount cutouts
		translate([RX_ANT_MOUNT_POS[0] + TOLERANCE_CLEAR + RX_ANT_WIRE_RAD, 0])
		linear_extrude(RX_ANT_MOUNT_DIM[2] + FRAME_THICKNESS + TOLERANCE_FIT, scale = [0.6, 1])
		offset(r = RX_ANT_MOUNT_DIM[2] + FRAME_THICKNESS / 2)
		hull()
		reflect(x = false)
		translate([0, FRAME_DIM[1]])
		circle(RX_ANT_MOUNT_DIM[0] / 2);

		// venting
		if (CANOPY_VENT_R) {

			// top
			reflect(x = false)
			for (x = [-FRAME_DIM[0] * 0.15 : 6 + CANOPY_VENT_R : FRAME_DIM[0] * 0.4], y = [0, FC_DIM[1] * 0.15])
			translate([x, y, CANOPY_HEIGHT - CANOPY_THICKNESS / 2])
			linear_extrude(CANOPY_THICKNESS * 2)
			hull()
			for (i = [FC_DIM[0] * 0.125 : FC_DIM[0] * 0.25])
			translate([-i, i * 0.5])
			circle(r = CANOPY_VENT_R);

			// sides
			for (x = [-FRAME_DIM[0] * 0.3 : 6 + CANOPY_VENT_R : FRAME_DIM[0] * 0.1])
			translate([x, 0, 7 + CANOPY_VENT_R])
			rotate([90, 0])
			linear_extrude(FRAME_DIM[1] * 1.5, center = true)
			hull()
			for (i = [0, 4])
			translate([i / 2, i])
			circle(r = CANOPY_VENT_R);
		}


		// cut off bottom
		translate([0, 0, FRAME_THICKNESS]) // TODO: remove those other weird cutouts
		translate([0, 0, -SIZE_DIA])
		cube(SIZE_DIA * 2, true);
	}
}

module canopy_lip_back(offset = 0, smooth = 0) {
	translate([-FRAME_DIM[0] / 2 + CANOPY_THICKNESS, 0, FRAME_THICKNESS])
	rotate([90, 0, 180])
	linear_extrude(FRAME_DIM[1], center = true)
	smooth_acute(smooth)
 	offset(r = offset)
	scale(0.5)
	shape_canopy_lip();
}

module canopy_lip(offset = 0) {
	translate([FRAME_DIM[0] / 2 - CANOPY_THICKNESS, 0, FRAME_THICKNESS])
	rotate([90, 0])
	linear_extrude(FRAME_DIM[1], center = true)
 	offset(r = offset)
	shape_canopy_lip();
}

module canopy_solid(flares = true, offset = 0) {
	a = asin((CANOPY_HEIGHT - CANOPY_ROUNDING) / (WINDSHIELD_RAD - CANOPY_ROUNDING));
	r = CANOPY_ROUNDING + offset;
	windshield_r = WINDSHIELD_RAD - CANOPY_ROUNDING;

	module points_cam() {
		#translate([0, 0, FRAME_THICKNESS])
		translate(CAM_POS)
		rotate(CAM_ROT)
		translate([(CAM_DIM[2] - CANOPY_ROUNDING) / 2, 0])
		rotate([0, 90])
		reflect()
		translate([CAM_DIM[0] / 2 * 3/4, CAM_DIM[0] / 2])
		sphere(r);
	}

	module points_esc() {
		translate(ESC_POS)
		reflect()
		rotate(ESC_ROT)
		translate([-CANOPY_ROUNDING + COMPONENT_CLEARANCE, -CANOPY_ROUNDING + COMPONENT_CLEARANCE])
		translate(ESC_DIM / 2)
		sphere(r);
	}

	module points_fc() {
		translate(FC_POS)
		reflect()
		rotate(FC_ROT)
		translate([-CANOPY_ROUNDING + COMPONENT_CLEARANCE, -CANOPY_ROUNDING + COMPONENT_CLEARANCE])
		translate(FC_DIM / 2)
		sphere(r);
	}

	module points_top() {
		translate([0, 0, CANOPY_HEIGHT - CANOPY_ROUNDING]) {
			// front
			*reflect(x = false)
			translate([CAM_POS[0] + CAM_DIM[2] / 2 - CANOPY_ROUNDING - 2, CAM_DIM[0] / 2 - CANOPY_ROUNDING])
			sphere(r, $fn = 8);

			// mid (vtx)
			reflect(x = false)
			translate([-FC_HOLE_SPACING[0] / 2, VTX_DIM[1] / 2])
			sphere_true(r, $fn = 8);

			// back
			translate([VTX_ANT_POS[0], 0])
			torus_true(8 - CANOPY_ROUNDING + COMPONENT_CLEARANCE, r, fn = 8);
		}
	}

	module points_led() {
		translate([0, 0, FRAME_THICKNESS])
		pos_led()
		reflect()
		translate([LED_BOARD_DIM[0] / 2, LED_BOARD_DIM[1] / 2, LED_BOARD_DIM[2] / 2 + LED_DIM[2] - CANOPY_ROUNDING + TOLERANCE_CLEAR])
		sphere(r);
	}

	module points_vtx() {
		for (z = [0, FRAME_THICKNESS + VTX_POS[2] + VTX_DIM[2] / 2])
		translate([VTX_POS[0], VTX_POS[1], z])
		reflect(x = false)
		rotate(VTX_ROT) {
			translate([(VTX_DIM[0] + CANOPY_ROUNDING) / 2, (VTX_DIM[1] + CANOPY_ROUNDING) / 2 - VTX_ANT_MOUNT_DIM[1]])
			sphere(r);
			translate([VTX_ANT_MOUNT_DIM[0] + CANOPY_ROUNDING, VTX_DIM[1] + CANOPY_ROUNDING] / 2)
			sphere(r);
		}
	}

	difference() {
		hull()
		// union()
		{

			points_top();

			// cam pivot
			translate(CAM_POS)
			reflect(x = false)
			rotate(CAM_ROT)
			translate([-CANOPY_ROUNDING + COMPONENT_CLEARANCE, -CANOPY_ROUNDING + COMPONENT_CLEARANCE])
			translate([CAM_MOUNT_ARM_WIDTH / 2, CAM_DIM[0] / 2 + CAM_MOUNT_ARM_THICKNESS + CAM_MOUNT_SCREW_DIM[2] + TOLERANCE_CLEAR, FRAME_THICKNESS])
			sphere(r);

			// windshield
			reflect(x = false) {
				translate([0, CAM_DIM[0] / 2 - CANOPY_ROUNDING])
				translate([-(windshield_r) + FRAME_DIM[0] / 2 - CANOPY_ROUNDING - CANOPY_THICKNESS, 0])
				// translate([windshield_r, 0])
				// rotate([0, 0, 20])
				// translate([-windshield_r, 0])
				{
					rotate([90, 0])
					rotate_extrude(angle = a, $fa = 5)
					translate([windshield_r, 0])
					circle(r);

					rotate([0, -a])
					translate([windshield_r, 0])
					rotate([0, a])
					sphere_true(r, $fn = 8);
				}
			}

			points_esc();

			points_fc();

			// led
			points_led();
			linear_extrude(1)
			projection()
			points_led();

			// frame centre
			linear_extrude(FRAME_THICKNESS)
			offset(r = offset)
			rounded_square([
				FRAME_DIM[0] * 0.75,
				FRAME_DIM[1]], CANOPY_ROUNDING);
		}

		// windshield recess
		translate([-(windshield_r) + FRAME_DIM[0] / 2 - CANOPY_ROUNDING - CANOPY_THICKNESS, 0])
		rotate([90, 0])
		rotate_extrude(angle = 90, $fa = 5)
		translate([WINDSHIELD_RAD + 5 - TOLERANCE_CLEAR - WINDSHIELD_THICKNESS + offset, 0])
		sq([10, WINDSHIELD_CUTOUT_DIM[1] + (TOLERANCE_CLEAR + CANOPY_THICKNESS) * 2 + 3 - offset * 2]);
	}

	if (flares) {

		// batt strap cutout flares
		*hull()
		reflect(z = true)
		translate([
			BATT_STRAP_DIM[0] / 2 - CANOPY_ROUNDING / 2,
			FRAME_DIM[1] / 2 + BATT_STRAP_DIM[1] - CANOPY_ROUNDING / 2,
			BATT_STRAP_SURROUND_DIM[2] + CANOPY_THICKNESS - CANOPY_ROUNDING / 2])
		sphere(r);

		// motor wire cutout flares
		translate([0, 0, -FRAME_THICKNESS])
		for (x = [-1, 1])
		scale([x, 1])
		pos_motor_wires(reflect = [false, true])
		translate([0, x > 0 ? -1 : 0]) // front and back are inset differently
		hull()
		for (x = [-1, 1], y = [0, 1], z = [0, 1])
		translate([
			(MOTOR_WIRE_CUTOUT_DIM[0] / 2 - CANOPY_ROUNDING / 2) * x,
			-CANOPY_ROUNDING - CAM_POS[2] * 0.6 * z - 10 * y - 1,
			CAM_POS[2] * z])
		sphere(r);
	}
}

module shape_canopy_lip() {
	mirror([1, 0])
	polygon([
		[-10, 0],
		[-10, CANOPY_LIP_DIM[1]],
		[0, CANOPY_LIP_DIM[1]],
		[CANOPY_LIP_DIM[0], 0],
	]);
}
