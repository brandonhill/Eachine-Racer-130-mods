
include <_setup.scad>;
include <component mount.scad>;
use <cam mount.scad>;
use <canopy.scad>;

module canopy_seal(hollow = true) {
	intersection() {
		union() {
			translate([0, 0, CANOPY_SEAL_DEPTH / 2])
			cube([SIZE_DIA, SIZE_DIA, CANOPY_SEAL_DEPTH], true);

			// extra lip around battery conn.
			translate([-FRAME_DIM[0] / 2 + CANOPY_THICKNESS, 0])
			translate([CANOPY_THICKNESS, 0, CANOPY_SEAL_DEPTH])
			linear_extrude(
				BATT_CONN_DIM[2] + TOLERANCE_CLEAR + FRAME_MOUNT_SKIN - CANOPY_SEAL_DEPTH / 2, scale = [1, 0.4])
			sq([
				CANOPY_THICKNESS * 2,
				FRAME_DIM[1] * 0.8]);

			// extra lip around battery strap surround
			*translate([(RX_ANT_MOUNT_DIM[0] + CANOPY_SEAL_DEPTH) / 2, 0, BATT_STRAP_SURROUND_DIM[2] - FRAME_MOUNT_SKIN])
			linear_extrude(CANOPY_SEAL_DEPTH, scale = [0.85, 1])
			sq([
				BATT_STRAP_SURROUND_DIM[1] + CANOPY_SEAL_DEPTH * 2 + RX_ANT_MOUNT_DIM[0] + RX_ANT_WIRE_RAD * 2,
				FRAME_DIM[1] * 1.2]);

			// extra lip around rx ant mount
			translate([RX_ANT_MOUNT_POS[0] + RX_ANT_WIRE_RAD * 2, 0, CANOPY_SEAL_DEPTH])
			linear_extrude(CANOPY_SEAL_DEPTH, scale = [0.85, 1])
			sq([
				CANOPY_SEAL_DEPTH * 2 + RX_ANT_MOUNT_DIM[0] * 1.3 + RX_ANT_WIRE_RAD * 2,
				FRAME_DIM[1] * 1.2]);
		}

		translate([0, 0, -FRAME_THICKNESS])
		difference() {
			difference() {
				canopy_solid(flares = false);
				canopy_lip();
				canopy_lip_back();
			}
			if (hollow)
			difference() {
				canopy_solid(flares = false, offset = -CANOPY_THICKNESS);
				canopy_lip(offset = CANOPY_THICKNESS);
				canopy_lip_back(offset = CANOPY_THICKNESS);
			}

			// cut off bottom
			translate([0, 0, -SIZE_DIA])
			cube(SIZE_DIA * 2, true);
		}
	}

	intersection() {
		canopy_solid(flares = false);

		// batt conn surround
		translate([-FRAME_DIM[0] / 2 + BATT_CONN_SURROUND_DIM[0] / 2 + CANOPY_THICKNESS, 0]) {
			hull() {
				translate([0, 0, CANOPY_SEAL_DEPTH / 2])
				cube([
					BATT_CONN_SURROUND_DIM[0],
					(FRAME_SCREW_BACK_POS[1] - FRAME_SCREW_DIM[0] / 2) * 2,
					CANOPY_SEAL_DEPTH], true);

				translate([0, 0, BATT_CONN_SURROUND_DIM[2] / 2 + TOLERANCE_FIT])
				cube(BATT_CONN_SURROUND_DIM, true);
			}

			translate([0, 0, CANOPY_SEAL_DEPTH / 2])
			cube([
				BATT_CONN_SURROUND_DIM[0],
				FRAME_DIM[1],
				CANOPY_SEAL_DEPTH], true);
		}
	}
}

module fc_standoff(
		h = FC_MOUNT_HEIGHT,
	) {
	difference() {
		stack_mount_post(bevel = "both", height = h, frame_mount = false, tolerance = TOLERANCE_FIT);
		stack_mount_post_holes(height = h + 0.2, tolerance = TOLERANCE_FIT);
	}
}

module rx_mount() {
	component_mount(
		board_dim = RX_BOARD_DIM,
		h = RX_POS[2] - (FC_POS[2] + FC_BOARD_DIM[2]) + RX_BOARD_DIM[2] + STACK_MOUNT_LIP_THICKNESS,
		hole_spacing = FC_HOLE_SPACING,
		hole_offset = [
			0,
			RX_POS[0]],
		lip_thickness = STACK_MOUNT_LIP_THICKNESS,
		cutouts = [false, [-1]],
		screws = [true, [-1]],
		screw_r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR,
		screw_surround = FRAME_SCREW_SURROUND
	);
}

module rx_ant_mount(offset = 0) {
	module mount() {
		pos_rx_ant_mount()
		translate([0, -RX_ANT_MOUNT_DIM[1] / 2 + FRAME_MOUNT_WALLS, RX_ANT_MOUNT_DIM[2] / 2])
		cube([
			RX_ANT_MOUNT_DIM[0] + offset * 2,
			RX_ANT_MOUNT_DIM[1] + offset * 2,
			RX_ANT_MOUNT_DIM[2] + offset * 2], true);
	}

	hull() {
		*pos_stack_post()
		translate([0, 0, -offset])
		cylinder(
			h = RX_ANT_MOUNT_DIM[2] + offset * 2,
			r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR + FRAME_SCREW_SURROUND + offset);

		mount();

		translate([0, FRAME_DIM[1] / 2])
		rotate([-90, 0])
		linear_extrude(0.1)
		projection()
		rotate([90, 0])
		mount();
	}
}

module shape_canopy_seal(skin = false) {
	module shape_outer() {
		offset(r = -FRAME_MOUNT_WALLS / 2)
		hull()
		projection(cut = true)
		canopy_seal();
	}

	module shape_diff() {

		// front portion has full skin
		if (skin)
			#
			// translate([FRAME_DIM[1] / 2 + BATT_STRAP_SURROUND_DIM[1] / 2, 0])
			sq([FRAME_DIM[0], FRAME_DIM[1]]);

		// battery strap
		*translate([-FRAME_MOUNT_LIP_WIDTH, 0])
		rotate(BATT_STRAP_ROT)
		sq([BATT_STRAP_SURROUND_DIM[0], BATT_STRAP_SURROUND_DIM[1] - FRAME_MOUNT_LIP_WIDTH]);
	}

	difference() {
		shape_outer();

		smooth(FRAME_MOUNT_WALLS)
		difference() {
			offset(r = -FRAME_MOUNT_WALLS - FRAME_MOUNT_LIP_WIDTH)
			shape_outer();

			offset(r = FRAME_MOUNT_LIP_WIDTH)
			shape_diff();

			// front screws
			reflect(x = false)
			translate(FRAME_SCREW_FRONT_POS)
			circle(r = FRAME_SCREW_DIM[0] / 2 + FRAME_SCREW_SURROUND);

			// stack screws
			reflect(x = false)
			hull()
			reflect(y = false)
			pos_stack_post()
			circle(r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR + FRAME_SCREW_SURROUND);

			// back screws
			reflect(x = false)
			translate(FRAME_SCREW_BACK_POS)
			circle(r = FRAME_SCREW_DIM[0] / 2 + FRAME_SCREW_SURROUND);

			// batt conn surround
			translate([-10 + LED_POS[0] + FRAME_MOUNT_WALLS * 2 + TOLERANCE_CLEAR, 0])
			sq([20, FRAME_DIM[1]]);
		}
	}
}

module stack_mount_base() {
	r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR + FRAME_SCREW_SURROUND;
	r_terminal = FRAME_SCREW_DIM[0] / 2 + FRAME_SCREW_SURROUND;

	module led_support() {
		module back() {
			rotate([90, 0])
			linear_extrude(FRAME_MOUNT_WALLS, center = true)
			translate([0, LED_POS[2]])
			rotate([0, 0, 90 - LED_ROT[0]])
			sq([FRAME_MOUNT_WALLS / 2, LED_BOARD_DIM[1]]);
		}

		reflect(x = false)
		translate([
			LED_POS[0] + FRAME_MOUNT_WALLS / 2,
			BATT_CONN_DIM[1] / 2 + TOLERANCE_CLOSE + FRAME_MOUNT_WALLS / 2])
		difference() {
			hull() {
				back();
				linear_extrude(FRAME_MOUNT_SKIN)
				projection()
				back();
			}

			// cut off top
			translate([0, 0, 20])
			cube(20, true);
		}
	}

	module pos_stack_holes_back() {
		reflect(x = [-1])
		pos_stack_post()
		children();
	}

	module pos_stack_holes_front() {
		reflect(x = false)
		pos_stack_post()
		children();
	}

	difference() {
		union() {
			// stack posts
			pos_stack_holes_back() {
				cylinder_true(h = ESC_POS[2] - FRAME_SCREW_SURROUND, r = r_terminal, center = false);
				translate([0, 0, ESC_POS[2]])
				mirror([0, 0, 1])
				cylinder_true(h = FRAME_SCREW_SURROUND, r2 = r_terminal, r1 = r_terminal - FRAME_SCREW_SURROUND + PRINT_NOZZLE_DIA, center = false);

				// braces
				hull() {
					translate([0, 0, ESC_POS[2] / 2])
					cube([r_terminal, FRAME_MOUNT_WALLS, ESC_POS[2]], true);
					cube([(ESC_POS[2] + r_terminal) * 2, FRAME_MOUNT_WALLS, 0.1], true);
				}
			}

			pos_stack_holes_front() {
				cylinder_true(h = ESC_POS[2] - FRAME_SCREW_SURROUND, r = r_terminal, center = false);
				translate([0, 0, ESC_POS[2]])
				mirror([0, 0, 1])
				cylinder_true(h = FRAME_SCREW_SURROUND, r2 = r_terminal, r1 = r_terminal - FRAME_SCREW_SURROUND + PRINT_NOZZLE_DIA, center = false);

				// braces
				hull() {
					translate([0, 0, ESC_POS[2] / 2])
					cube([r_terminal, FRAME_MOUNT_WALLS, ESC_POS[2]], true);
					cube([(ESC_POS[2] + r_terminal) * 2, FRAME_MOUNT_WALLS, 0.1], true);
				}
			}

			// screw surround attachments
			*reflect(x = false)
			hull() {
				pos_stack_post()
				cylinder_true(h = STACK_MOUNT_BASE_THICKNESS, r = r, center = false);
				reflect(x = [-1], y = false)
				pos_stack_post()
				cylinder_true(h = STACK_MOUNT_BASE_THICKNESS, r = r_terminal, center = false);
			}

			// batt strap surround
			*rotate(BATT_STRAP_ROT)
			translate([0, 0, BATT_STRAP_SURROUND_DIM[2] / 2])
			cube(BATT_STRAP_SURROUND_DIM, true);

			// canopy seal
			union() {
				// edge
				canopy_seal();

				// lip (back)
				*show_half([0, 0, 90])
				linear_extrude(FRAME_MOUNT_SKIN, convexity = 2)
				shape_canopy_seal();

				// skin (front)
				//show_half([0, 0, -90])
				linear_extrude(SKIN_MIN_THICKNESS, convexity = 2)
				shape_canopy_seal(skin = true);
			}

			// back screw surrounds
			reflect(x = false)
			translate(FRAME_SCREW_BACK_POS)
			cylinder_true(h = CANOPY_SEAL_DEPTH, r = FRAME_SCREW_DIM[0] / 2 + FRAME_SCREW_SURROUND, center = false);

			// front screw surrounds
			reflect(x = false)
			translate(FRAME_SCREW_FRONT_POS)
			cylinder_true(h = CANOPY_SEAL_DEPTH, r = FRAME_SCREW_DIM[0] / 2 + FRAME_SCREW_SURROUND, center = false);

			intersection() {
				canopy_seal(hollow = false);

				union() {
					// back screw braces
					reflect(x = false)
					translate(FRAME_SCREW_BACK_POS)
					linear_extrude(CANOPY_SEAL_DEPTH)
					translate([FRAME_MOUNT_WALLS / 2, 0])
					mirror([1, 0])
					square([
						FRAME_MOUNT_WALLS,
						FRAME_DIM[0] / 2 + FRAME_SCREW_BACK_POS[0]]);

					// front screw braces
					reflect(x = false)
					translate(FRAME_SCREW_FRONT_POS)
					linear_extrude(CANOPY_SEAL_DEPTH)
					translate([-FRAME_SCREW_SURROUND, -FRAME_MOUNT_WALLS / 2])
					square([FRAME_DIM[0] / 2 - FRAME_SCREW_FRONT_POS[0], FRAME_MOUNT_WALLS]);
				}
			}

			// led mount
			led_support();

			// brace for extra clamp strength around battery conn.
			hull() {
				intersection() {
					hull()
					led_support();

					translate([LED_POS[0] + LED_BOARD_DIM[2] + TOLERANCE_CLEAR, 0, BATT_CONN_DIM[2] + FRAME_MOUNT_SKIN + LED_BOARD_DIM[1] * 0.8 / 2])
					cube([FRAME_MOUNT_WALLS, (FRAME_SCREW_BACK_POS[1] - FRAME_SCREW_DIM[0] / 2) * 2, LED_BOARD_DIM[1] * 0.8], true);
				}

				translate([LED_POS[0] + LED_BOARD_DIM[2] + TOLERANCE_CLEAR, 0, 1])
				cube([FRAME_MOUNT_WALLS, (FRAME_SCREW_BACK_POS[1] - FRAME_SCREW_DIM[0] / 2) * 2, 2], true);
			}


			// rx ant mount
			reflect(x = false) {
				rx_ant_mount();

				// brace
				translate([
					RX_ANT_MOUNT_POS[0],
					FRAME_DIM[1] / 2 - CANOPY_THICKNESS / 2])
				hull() {
					translate([0, 0, RX_ANT_MOUNT_DIM[2] / 2])
					cube([FRAME_MOUNT_WALLS, CANOPY_THICKNESS / 2, RX_ANT_MOUNT_DIM[2]], true);
					translate([0,  -(CANOPY_THICKNESS + RX_ANT_MOUNT_DIM[2]) / 2])
					cube([FRAME_MOUNT_WALLS, RX_ANT_MOUNT_DIM[2], 0.1], true);
				}
			}
		}

		// batt conn cutout
		translate([0, 0, TOLERANCE_CLEAR]) // accommodate some bridge sag
		batt_conn_cutout(delta = true);

		// led wire cutout
		translate([-FRAME_DIM[0] / 2, 0, BATT_CONN_DIM[2] + TOLERANCE_CLOSE + FRAME_MOUNT_WALLS + 7])
		cube([BATT_CONN_DIM[0] * 2, BATT_CONN_DIM[1] + TOLERANCE_CLOSE * 2, 10], true);

		// batt strap cutout
		*rotate(BATT_STRAP_ROT)
		translate([0, 0, (BATT_STRAP_SURROUND_DIM[2] - FRAME_MOUNT_SKIN) / 2 - 0.1])
		cube([
			BATT_STRAP_SURROUND_DIM[0] * 2,
			BATT_STRAP_SURROUND_DIM[1] - FRAME_MOUNT_WALLS * 2,
			BATT_STRAP_SURROUND_DIM[2] - FRAME_MOUNT_SKIN + 0.1], true);

		// front canopy clip
		translate([0, 0, -FRAME_THICKNESS])
		canopy_lip(offset = TOLERANCE_CLOSE);

		// back canopy clip
		translate([0, 0, -FRAME_THICKNESS])
		canopy_lip_back(offset = TOLERANCE_FIT);

		// motor wire cutouts
		reflect(x = false)
		for (x = [-1, 1])
		scale([x, 1])
		hull()
		for (z = [0, CANOPY_SEAL_DEPTH])
		translate([0, 0, z])
		pos_motor_wires(reflect = [false, false])
		translate([0, x > 0 ? -5 : -3, -FRAME_THICKNESS + TOLERANCE_CLOSE])
		rotate([90, 0])
		linear_extrude(5, center = true)
		rounded_square([
			MOTOR_WIRE_CUTOUT_DIM[0],
			MOTOR_WIRE_CUTOUT_DIM[1]], MOTOR_WIRE_RAD);

		// back screw holes
		reflect(x = false)
		translate([
			FRAME_SCREW_BACK_POS[0],
			FRAME_SCREW_BACK_POS[1],
			-0.1])
		cylinder_true(h = CANOPY_SEAL_DEPTH + 0.2, r = FRAME_SCREW_DIM[0] / 2 - TOLERANCE_CLOSE, center = false);

		// front screw holes
		reflect(x = false)
		translate([
			FRAME_SCREW_FRONT_POS[0],
			FRAME_SCREW_FRONT_POS[1],
			-0.1])
		cylinder_true(h = CANOPY_SEAL_DEPTH + 0.2, r = FRAME_SCREW_DIM[0] / 2 - TOLERANCE_CLOSE, center = false);

		// rx ant wire holes
		reflect(x = false)
		translate([
			RX_ANT_MOUNT_POS[0] + RX_ANT_MOUNT_DIM[0] * 2/3 + RX_ANT_WIRE_RAD,
			FRAME_DIM[1] / 2,
			FRAME_MOUNT_SKIN + RX_ANT_WIRE_RAD + TOLERANCE_CLOSE])
		rotate([90, 0])
		cylinder_true(h = FRAME_MOUNT_WALLS * 2, r = RX_ANT_WIRE_RAD + TOLERANCE_CLOSE, $fn = 8);

		// rx ant mount zip tie holes
		reflect(x = false)
		pos_rx_ant_mount()
		translate([0, -ZIP_TIE_DIM[1] / 2, RX_ANT_MOUNT_DIM[2] / 2])
		cube([ZIP_TIE_DIM[0], ZIP_TIE_DIM[1], RX_ANT_MOUNT_DIM[2] + 0.2], true);

		// stack screw holes
		translate([0, 0, -0.1]) {
			pos_stack_holes_back()
			cylinder(h = ESC_POS[2] + 0.2, r = FRAME_SCREW_DIM[0] / 2); // terminal

			pos_stack_holes_front()
			// cylinder_true(h = ESC_POS[2] + 0.2, r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR, center = false);
			cylinder(h = ESC_POS[2] + 0.2, r = FRAME_SCREW_DIM[0] / 2); // terminal
		}
	}
}

module stack_mount_post(
		bevel = true,
		height = STACK_MOUNT_HEIGHT,
		frame_mount = true,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_depth = 3,
		frame_screw_surround = FRAME_SCREW_SURROUND,
		stack_hole_spacing = FC_HOLE_SPACING,
		stack_screw_dim = SCREW_M2_SOCKET_DIM,
		tolerance = 0,
	) {

	// board mount post
	translate([stack_hole_spacing[0] / 2, stack_hole_spacing[1] / 2]) {
		r = stack_screw_dim[0] / 2 + tolerance + frame_screw_surround;
		r_bevel = bevel ? stack_screw_dim[0] / 2 + PRINT_NOZZLE_DIA : r;
		h_bevel = r - r_bevel;

		translate([0, 0, bevel == "both" ? h_bevel : 0])
		cylinder(h = height - h_bevel * (bevel == "both" ? 2 : 1), r = r);

		translate([0, 0, height / 2])
		reflect(x = false, y = false, z = bevel == "both")
		translate([0, 0, height / 2 - h_bevel])
		cylinder(h = h_bevel, r1 = r, r2 = r_bevel);
	}

	// frame mount screw surround
	if (frame_mount)
	hull() {
		translate([stack_hole_spacing[0] / 2, stack_hole_spacing[1] / 2])
		cylinder(h = min(height, frame_screw_depth), r = frame_screw_dim[0] / 2 + tolerance + frame_screw_surround);

		translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2])
		cylinder(h = min(height, frame_screw_depth), r = frame_screw_dim[0] / 2 + tolerance + frame_screw_surround);
	}
}

module stack_mount_post_holes(
		height = STACK_MOUNT_HEIGHT,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = SCREW_M2_SOCKET_DIM,
		frame_screw_depth = FRAME_SCREW_DEPTH,
		stack_hole_spacing = FC_HOLE_SPACING,
		stack_screw_dim = SCREW_M2_SOCKET_DIM,
		tolerance = 0,
	) {

	// board mount screw hole
	translate([stack_hole_spacing[0] / 2, stack_hole_spacing[1] / 2, -0.1])
	cylinder(h = height + 0.2, r = stack_screw_dim[0] / 2 + tolerance);
	//thread_iso_metric(stack_screw_dim[0], height + 0.2, THREAD_PITCH_M2_COARSE, center = false, internal = true, tolerance = tolerance);

	// frame mount screw hole
	translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2, -0.1])
	cylinder(h = max(height, frame_screw_depth) + 0.2, r = frame_screw_dim[0] / 2 + tolerance);
	//thread_iso_metric(frame_screw_dim[0], max(height, frame_screw_depth) + 0.2, THREAD_PITCH_M2_COARSE, center = false, internal = true, tolerance = tolerance);
}

module vtx_mount() {
	board_dim = VTX_BOARD_DIM;
	board_offset = [0, 0];
	h = VTX_POS[2]
		- (RX_POS[2] + RX_BOARD_DIM[2] + STACK_MOUNT_LIP_THICKNESS)
		+ VTX_BOARD_DIM[2] + STACK_MOUNT_LIP_THICKNESS;
	h_ant_surround = 4;
	hole_offset = [FC_POS[0], 0];
	screw_r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR;

	module pos_ant() {
		// rotate(VTX_ROT)
		// translate([VTX_POS[0] + VTX_ANT_POS[0], 0])
		translate([VTX_ANT_POS[0], 0])
		children();
	}

	module shape_ant() {
		pos_ant()
		circle(VTX_ANT_DIM[0] / 2);
	}

	module shape_ant_arms() {
		hull() {
			reflect(x = false)
			translate(hole_offset)
			translate(-FC_HOLE_SPACING / 2)
			circle(r = FRAME_MOUNT_WALLS / 2);

			pos_ant()
			circle(r = FRAME_MOUNT_WALLS / 2);
		}
	}

	component_mount(
		board_dim = [VTX_BOARD_DIM[1], VTX_BOARD_DIM[0], VTX_BOARD_DIM[2]],
		board_offset = [FC_POS[0] + VTX_POS[0], 0],
		h = h,
		hole_spacing = FC_HOLE_SPACING,
		hole_offset = hole_offset,
		lip_thickness = STACK_MOUNT_LIP_THICKNESS,
		cutouts = [[-1], false],
		screws = [[-1], true],
		screw_r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR,
		screw_surround = FRAME_SCREW_SURROUND
	);

	difference() {
		union() {
			// ant surround
			linear_extrude(h_ant_surround, convexity = 3)
			difference() {
				offset(r = FRAME_MOUNT_WALLS) {
					shape_ant();
					shape_ant_arms();
				}
				shape_ant();
				shape_ant_arms();

				translate([-FC_HOLE_SPACING[0] / 2, 0])
				translate([25 - FRAME_SCREW_SURROUND, 0])
				sq(50);
			}

			// posts
			reflect(x = [-1])
			component_post(
				bevel = false,
				h = h,
				hole_offset = hole_offset,
				hole_spacing = FC_HOLE_SPACING,
				screw_surround = FRAME_SCREW_SURROUND,
				screw_r = screw_r);
		}

		// ant wire cutout
		*translate([VTX_POS[0] - VTX_DIM[1] / 2, -VTX_DIM[0] / 2, h])
		hull()
		for (z = [0, -VTX_ANT_WIRE_RAD])
		translate([0, 0, z])
		rotate([90, 0, -20])
		cylinder(h = 5, r = VTX_ANT_WIRE_RAD + TOLERANCE_FIT, center = true);

		// post holes
		reflect(x = [-1])
		component_post_hole(
			h = h,
			hole_offset = hole_offset,
			hole_spacing = FC_HOLE_SPACING,
			screw_r = screw_r,
			terminal = true);
	}
}
