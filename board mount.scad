
include <_conf.scad>;
use <cam mount.scad>;
use <canopy.scad>;

module board_mount_post(
		height = 5,
		board_hole_spacing = FC_HOLE_SPACING,
		board_screw_dim = SCREW_M2_DIM,
		frame_mount = true,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_depth = 3,
		frame_screw_surround = FRAME_SCREW_SURROUND,
	) {

	// board mount post
	translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2])
	cylinder(h = height, r = board_screw_dim[0] / 2 + frame_screw_surround);

	// frame mount screw surround
	if (frame_mount)
	hull() {
		translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2])
		cylinder(h = min(height, frame_screw_depth), r = frame_screw_dim[0] / 2 + frame_screw_surround);

		translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2])
		cylinder(h = min(height, frame_screw_depth), r = frame_screw_dim[0] / 2 + frame_screw_surround);
	}
}

module board_mount_post_holes(
		height = 5,
		board_hole_spacing = FC_HOLE_SPACING,
		board_screw_dim = SCREW_M2_DIM,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = SCREW_M2_DIM,
		frame_screw_depth = FRAME_SCREW_DEPTH,
	) {

	// board mount screw hole
	translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2, -0.1])
	cylinder(h = height + 0.2, r = board_screw_dim[0] / 2);

	// frame mount screw hole
	translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2, -0.1])
	cylinder(h = max(height, frame_screw_depth) + 0.2, r = frame_screw_dim[0] / 2);
}

module board_mount_back(
		base_thickness = BOARD_MOUNT_BASE_THICKNESS,
		depth = 10,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_depth = FRAME_SCREW_DEPTH,
		frame_screw_dim = SCREW_M2_DIM,
		frame_screw_surround = 1.5,
		height = 5,
	) {

	r = frame_screw_dim[0] / 2 + frame_screw_surround;

	difference() {
		union() {

			// connector
			hull()
			reflect(x = [-1])
			board_mount_post(frame_mount = false, height = base_thickness);

			// posts
			reflect(x = [-1])
			board_mount_post(height = height);

			// clip attachments
			linear_extrude(frame_screw_depth, convexity = 2)
			reflect(x = false)
			hull()
			show_half(2d = true)
			projection(cut = true) {
				reflect(x = [-1])
				board_mount_post();
				canopy_clips(back = true);
			}

			canopy_clips(back = true);
		}

		// holes
		reflect(x = [-1])
		board_mount_post_holes(height = height);
	}

	translate([-(frame_hole_spacing[0] / 2 + depth), 0])
	children();
}

module board_mount_front(
		base_thickness = BOARD_MOUNT_BASE_THICKNESS,
		cam_pos = CAM_MOUNT_POS,
		cam_mount_width = CAM_MOUNT_ARM_WIDTH,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = SCREW_M2_DIM,
		frame_screw_surround = 1.5,
		height = 5,
	) {

	cam_mount_offset = cam_pos[0] - cam_mount_width / 2 - FC_HOLE_SPACING[0] / 2;
	r = frame_screw_dim[0] / 2 + frame_screw_surround;

	difference() {
		union() {
			reflect(x = [1])
			board_mount_post(height = height);

			// connector
			hull()
			reflect(x = [1])
			board_mount_post(frame_mount = false, height = base_thickness);

			// cam mount guides
			reflect(x = false)
			translate([FC_HOLE_SPACING[0] / 2 + cam_mount_offset / 2 - TOLERANCE_CLOSE, CANOPY_LIP_WIDTH / 3, base_thickness / 2])
			cube([cam_mount_offset, 4, base_thickness], true);
		}

		// screw holes
		reflect(x = [1])
		translate([0, 0, -0.1])
		board_mount_post_holes(height = height + 0.2);
	}
}

module board_mount(
		cutout_dim = [FC_DIM[0], FC_DIM[1]],
		frame_outset = [0, 1],
		height = 5,
		board_hole_spacing = FC_HOLE_SPACING,
		board_screw_dim = SCREW_M2_DIM,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = SCREW_M2_DIM,
		frame_screw_depth = 4,
		frame_screw_surround = 1.5,
		inset_xy = [2, 0],
		lip_thickness = 0.6,
	) {

	difference() {
		union() {
			// board mount posts
			four_up()
			translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2])
			cylinder(h = height, r = board_screw_dim[0] / 2 + frame_screw_surround);

			// frame mount screw surrounds
			four_up()
			hull() {
				translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2])
				cylinder(h = frame_screw_depth, r = frame_screw_dim[0] / 2 + frame_screw_surround);

				translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2])
				cylinder(h = frame_screw_depth, r = frame_screw_dim[0] / 2 + frame_screw_surround);
			}
		}

		// board mount screw holes
		four_up()
		translate([board_hole_spacing[0] / 2, board_hole_spacing[1] / 2, -0.1])
		cylinder(h = height + 0.2, r = board_screw_dim[0] / 2);

		// frame mount screw holes
		four_up()
		translate([frame_hole_spacing[0] / 2, frame_hole_spacing[1] / 2, -0.1])
		cylinder(h = frame_screw_depth + 0.2, r = frame_screw_dim[0] / 2);
	}
}

// rotate([180, 0]) // for printing
// board_mount();

module all_in_one_mount() {

	module mounts() {
		translate(CAM_MOUNT_POS)
		cam_mount()
		children();

		board_mount();
	}

	mounts()
	children();

	difference() {
		union() {

			// post arms
			linear_extrude(1)
			difference() {
				offset(r = 1)
				square(FC_HOLE_SPACING, true);

				offset(r = -1)
				square(FC_HOLE_SPACING, true);
			}

			// cam mount arms
			linear_extrude(2, convexity = 2)
			for (y = [-1, 1])
			scale([1, y])
			difference() {
				hull() {
					translate([FRAME_HOLE_SPACING[0] / 2, FRAME_HOLE_SPACING[1] / 2])
					circle(2);
					translate([CAM_MOUNT_POS[0], CAM_DIM[0] / 2 - 1])
					circle(2);
				}

				translate(CAM_MOUNT_POS)
				hull() projection() cam_mount();
			}
		}

		// screw holes
		linear_extrude(5, center = true)
		for (x = [-1, 1], y = [-1, 1])
		scale([x, y]) {
			translate([FC_HOLE_SPACING[0] / 2, FC_HOLE_SPACING[1] / 2])
			circle(SCREW_M2_DIM[0] / 2);
			translate([FRAME_HOLE_SPACING[0] / 2, FRAME_HOLE_SPACING[1] / 2])
			circle(SCREW_M2_DIM[0] / 2);
		}
	}
}
