
include <_conf.scad>;
use <board mount.scad>;
use <cam mount.scad>;

module canopy(
		cam_arm_width = CAM_MOUNT_ARM_WIDTH,
		cam_hole_rad = CANOPY_CAM_HOLE_RAD,
		dim = CANOPY_DIM,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_width = FRAME_DIM[1],
		lip_depth = CANOPY_LIP_DEPTH,
		lip_thickness = CANOPY_LIP_THICKNESS,
		lip_width = CANOPY_LIP_WIDTH,
		rounding = CANOPY_ROUNDING,
		strap_dim = BATT_STRAP_DIM,
		thickness = CANOPY_THICKNESS,
		cam_z_offset = CAM_Z_OFFSET,
	) {

	difference() {

		canopy_solid();
		canopy_solid(offset = -thickness);

		// battery strap holes
		hull()
		reflect(y = false)
		translate([-strap_dim[0] / 2, 0])
		rotate([90, 0])
		cylinder(h = frame_width + 0.2, r = strap_dim[1] + TOLERANCE_CLEAR, center = true);

		// camera hole
		translate([
			CAM_MOUNT_POS[0],
			0,
			CAM_MOUNT_BASE_THICKNESS + CAM_Z_OFFSET + CAM_DIM[1] / 2 + 3])
		rotate([0, -CAM_ANGLE])
		translate([-CAM_PIVOT_OFFSET - 3, 0])
		reflect(x = false, y = false, z = [-1, 1])
		capsule(20, cam_hole_rad, center = true);

		// clip holes
		canopy_clips(back = true, front = true, offset = TOLERANCE_FIT, diff = true);

		// vtx ant. hole
		hull()
		for (z = [0, VTX_POS[2]])
		translate([-(frame_hole_spacing[0] / 2 + 4), 0, z])
		rotate([0, 90])
		cylinder(h = 20, r = 1.25, center = true);

		// wire hole (back)
		hull()
		reflect(x = false)
		translate([-(frame_hole_spacing[0] / 2 + 3), 2])
		capsule(18, 4, center = true);

		// wire holes (front)
		reflect(x = false)
		translate([frame_hole_spacing[0] / 2 + 9, frame_hole_spacing[1] / 2 + 2])
		capsule(18, 4, center = true);
	}

	// retention lip
	intersection() {
		canopy_solid();

		translate([TOLERANCE_FIT, 0])
		union() {
			translate([CAM_MOUNT_POS[0] + cam_arm_width / 2, 0, lip_thickness / 2])
			translate([50, 0])
			cube([100, frame_width, lip_thickness], true);

			canopy_lip();
		}
	}
}

module canopy_clips(
		canopy_thickness = CANOPY_THICKNESS,
		clip_thickness = CANOPY_CLIP_THICKNESS,
		diff = false,
		fc_dim = FC_DIM,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_surround = FRAME_SCREW_SURROUND,
		frame_width = FRAME_DIM[1],
		offset = 0,
		width = CANOPY_CLIP_WIDTH,
	) {

	reflect(x = false)
	translate([
		-(frame_hole_spacing[0] / 2 + frame_screw_dim[0] / 2 + frame_screw_surround - clip_thickness / 2),
		frame_hole_spacing[1] / 2 - width / 2])
	rotate([90, 0, 180])
	linear_extrude(width + offset * 2, center = true)
	offset(delta = offset)
	shape_canopy_clip(diff = diff);
}

module canopy_lip(
		cam_mount_pos = CAM_MOUNT_POS,
		cam_mount_width = CAM_MOUNT_ARM_WIDTH,
		depth = CANOPY_LIP_DEPTH,
		offset = 0,
		width = CANOPY_LIP_WIDTH,
	) {

	pos_x = cam_mount_pos[0] + cam_mount_width / 2;

	translate([pos_x, 0])
	rotate([90, 0, 180])
	linear_extrude(width + offset * 2, center = true)
// 	offset(r = offset)
	shape_canopy_lip();
}

module canopy_solid(
		canopy_thickness = CANOPY_THICKNESS,
		clip_width = CANOPY_CLIP_WIDTH,
		dim = CANOPY_DIM,
		frame_hole_spacing = FRAME_HOLE_SPACING,
		frame_screw_dim = FRAME_SCREW_DIM,
		frame_screw_surround = FRAME_SCREW_SURROUND,
		frame_width = FRAME_DIM[1],
		offset = 0,
		rounding = CANOPY_ROUNDING,
	) {

	front = CAM_MOUNT_POS[0] + 9;
	r = rounding + offset;

	module corner(base = false) {
		sphere(r, $fn = base ? 8 : $fn);
	}

	intersection() {

		translate([0, 0, 50 + offset])
		cube([100, 100, 100], true);

		hull()
		reflect(x = false)
		translate([0, frame_width / 2 - rounding]) {

				translate([
					-(frame_hole_spacing[0] / 2 + frame_screw_dim[0] / 2 + frame_screw_surround - rounding + TOLERANCE_FIT + canopy_thickness),
					0]) {

					// back bottom
					corner();

					// back mid
					translate([0, 0, FC_POS[2] + FC_DIM[2] / 2])
					corner();
				}

				// back top
				translate([-FC_DIM[0] / 4, -dim[1] * 0.25, dim[2] - rounding])
				corner(base = true);

				// fc
				translate([FC_DIM[0] / 2, 0, FC_POS[2] + FC_DIM[2] / 2])
				corner();

				// mount
				translate([frame_hole_spacing[0] / 2, 0])
				corner();

				// mid top
				translate([frame_hole_spacing[0] / 2, 0, dim[2] - rounding])
				corner(base = true);

				translate([CAM_MOUNT_POS[0], 0]) {
					// cam mount mid
					translate([0, 0, dim[2] / 2])
					corner();

					// cam mount top
					translate([0, -rounding / 2, dim[2] - rounding])
					corner(base = true);
				}

				// front bottom
				translate([CAM_MOUNT_POS[0] + CAM_MOUNT_ARM_WIDTH / 2 - rounding / 2, -rounding / 2])
				corner();

				// front mid
				translate([front, -dim[1] / 4, dim[2] / 2])
				corner();

				// front top
				translate([front - 4, -dim[1] / 4, dim[2] - rounding])
				corner(base = true);
		}
	}
}

// clip for rear of canopy
module shape_canopy_clip(
		canopy_thickness = CANOPY_THICKNESS,
		clip_thickness = CANOPY_CLIP_THICKNESS,
		diff = false,
		height = CANOPY_CLIP_HEIGHT,
	) {

	if (!diff)
	translate([0, (height - clip_thickness / 2) / 2])
	square([clip_thickness, height - clip_thickness / 2], true);

	translate([-clip_thickness / 2, height - clip_thickness])
	rotate([0, 0, 20])
	segment(70, canopy_thickness * 1.25 + clip_thickness);
}

// retention lip for front of canopy
module shape_canopy_lip(
		depth = CANOPY_LIP_DEPTH,
		thickness = CANOPY_LIP_THICKNESS,
	) {
	
	polygon([
		[0, 0],
		[0, thickness - PRINT_LAYER],
		[depth, thickness / 2],
		[depth, 0],
	]);
}
