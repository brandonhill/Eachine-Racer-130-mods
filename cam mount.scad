
include <_conf.scad>;
use <canopy.scad>;

module pos_cam_mount() {
	translate(CAM_MOUNT_POS)
	children();
}

module cam_mount() {
	pivot_offset = CAM_POS[2] - CAM_MOUNT_POS[2];
	h = min(pivot_offset + CAM_MOUNT_ARM_WIDTH / 2, CAM_MOUNT_ARM_WIDTH);
	arm_dim = [
		CAM_POS[0] - CAM_MOUNT_POS[0],
		CAM_MOUNT_ARM_THICKNESS,
		CAM_MOUNT_ARM_WIDTH
	];
	post_screw_r = FRAME_SCREW_DIM[0] / 2 + TOLERANCE_CLEAR;

	module posts() {
		reflect(x = false)
		translate([0, FC_HOLE_SPACING[1] / 2]) {
			// bevel
			cylinder_true(
				h = FRAME_SCREW_SURROUND,
				r2 = post_screw_r + FRAME_SCREW_SURROUND,
				r1 = post_screw_r + PRINT_NOZZLE_DIA, center = false);

			translate([0, 0, FRAME_SCREW_SURROUND])
			cylinder_true(h = h - FRAME_SCREW_SURROUND, r = post_screw_r + FRAME_SCREW_SURROUND, center = false);
		}
	}

	difference() {
		union() {
			// arms
			reflect(x = false)
			translate([0, (CAM_DIM[0] + TOLERANCE_FIT + arm_dim[1]) / 2]) {
				translate([arm_dim[0] / 2, 0, h / 2])
				cube([
					arm_dim[0],
					arm_dim[1],
					h], true);


				translate([arm_dim[0], 0, CAM_POS[2] - CAM_MOUNT_POS[2]])
				hull() {
					rotate([90, 0])
					cylinder_true(
						h = arm_dim[1],
						r = CAM_MOUNT_SCREW_DIM[0] / 2 + TOLERANCE_FIT + 1.5,
						$fn = 8);
					translate([0, 0, h / 2 - pivot_offset])
					cube([
						1,
						arm_dim[1],
						h], true);
				}
			}

			// connector
			*translate([0, 0, h - FRAME_MOUNT_SKIN])
			linear_extrude(FRAME_MOUNT_SKIN)
			hull()
			projection()
			posts();

			posts();
		}

		// cam screw holes
		// translate([arm_dim[0], 0, h - arm_dim[2] / 2])
		translate([arm_dim[0], 0, CAM_POS[2] - CAM_MOUNT_POS[2]])
		rotate([90, 0])
		rotate([0, 0, 30])
		cylinder_true(h = CAM_DIM[0] * 2, r = CAM_MOUNT_SCREW_DIM[0] / 2 + TOLERANCE_FIT, $fn = 6);

		// stack screw holes
		reflect(x = false)
		translate([0, FC_HOLE_SPACING[1] / 2, -0.1])
		cylinder_true(h = h + 0.2, r = post_screw_r, center = false);

		// cut off bottom
		translate([0, 0, -20])
		cube(40, true);
	}
}
