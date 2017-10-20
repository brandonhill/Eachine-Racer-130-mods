
include <_conf.scad>;
use <canopy.scad>;

module cam_mount(
		angle = CAM_ANGLE,
		arm_thickness = CAM_MOUNT_ARM_THICKNESS,
		arm_width = CAM_MOUNT_ARM_WIDTH,
		base_thickness = CAM_MOUNT_BASE_THICKNESS,
		cam_dim = CAM_DIM,
		screw_dim = SCREW_M2_DIM,
		z_offset = CAM_Z_OFFSET,
	) {

	pos_z = base_thickness + z_offset;
	height = pos_z + cam_dim[1] / 2 + arm_width / 2;
	width = cam_dim[0] + (TOLERANCE_CLEAR + arm_thickness) * 2;

	module shape_mount() {
		translate([0, height / 2])
		difference() {
			square([width, height], true);

			// cam/main cutout
			translate([0, base_thickness])
			square([width - arm_thickness * 2, height], true);
		}
	}

	difference() {

		translate(CAM_MOUNT_POS)
		rotate([90, 0, 90])
		intersection() {

			// mount
			linear_extrude(arm_width, center = true, convexity = 3)
			shape_mount();

			// round top of posts
			translate([0, (height - arm_width) / 2])
			hull()
			reflect()
			translate([width, height / 2])
			sphere_true(arm_width / 2, $fn = 8);
		}

		translate(CAM_MOUNT_POS) {

			// cam pivot holes
			rotate([90, 0, 90])
			translate([0, height - arm_width / 2])
			rotate([0, 90, 0])
			cylinder(h = width + 0.2, r = screw_dim[0] / 2, center = true);

			// mount holes
			reflect(x = false)
			translate([0, CAM_MOUNT_SCREW_SPACING / 2, base_thickness / 2])
			cylinder(
				h = base_thickness + 0.2,
// 				r = screw_dim[0] / 2,
				r = screw_dim[0] / 2 - TOLERANCE_CLOSE, // prints horiz., so tighten up (?)
				center = true);
		}

		// retention lip hole
		translate([0.01, 0])
		canopy_lip(offset = TOLERANCE_CLOSE);
	}

	translate([CAM_MOUNT_POS[0], 0, pos_z + cam_dim[1] / 2])
	rotate([0, -angle])
	children();
}
