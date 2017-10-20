
include <_conf.scad>;

module ant_mount(
		height = 14,
		screw_dim = SCREW_M2_DIM,
		screw_surround = 1.5,
		screw_depth = 4,
		thickness = 3,
		vtx_ant_wire_rad = VTX_ANT_WIRE_RAD,
		vtx_ant_clip_length = 10,
		vtx_ant_clip_thickness = 1.5,
		zip_tie_hole_dim = ZIP_TIE_DIM,
	) {

	vtx_ant_angle = 78;
	vtx_ant_wire_clip_rad = vtx_ant_wire_rad + TOLERANCE_CLOSE + vtx_ant_clip_thickness;
	rx_mount_width = zip_tie_hole_dim[0] + screw_surround * 3.5;
	width = max(vtx_ant_wire_clip_rad * 2, screw_dim[0] + screw_surround * 2);

	difference() {
		union() {

			// staff
			cylinder(h = height, r = width / 2);
			translate([-(width - thickness) / 2, 0, height / 2])
			cube([thickness, width, height], true);

			// rx antenna wire mount
			reflect(x = false)
			translate([-(width - thickness) / 2, width / 2, height - rx_mount_width * 0.667])
			rotate([45, 0])
			cube([thickness, rx_mount_width, rx_mount_width], true);

			// VTx antenna wire clip outer
			translate([0, 0, height])
			rotate([0, vtx_ant_angle])
			translate([0, 0, -vtx_ant_wire_clip_rad])
			linear_extrude(vtx_ant_clip_length, convexity = 2)
			difference() {
				circle(width / 2);

				circle(vtx_ant_wire_rad + TOLERANCE_FIT);

				rotate([0, 0, 135])
				segment(90, width);
			}
		}

		// flatten base
		translate([-(width - thickness) / 2 - thickness, 0])
		cube([thickness, width * 4, height * 4], true);

		// rx zip tie holes
		reflect(x = false)
		translate([-(width - thickness) / 2, width / 2, height - rx_mount_width * 0.667])
		rotate([-45, 0])
		translate([
			0,
			(rx_mount_width - (zip_tie_hole_dim[0] + TOLERANCE_CLOSE * 2)) / 2 - screw_surround,
			(rx_mount_width - (zip_tie_hole_dim[1] + TOLERANCE_CLOSE * 2)) / 2 - screw_surround])
		cube([
			thickness + 0.2,
			zip_tie_hole_dim[0] + TOLERANCE_CLOSE * 2,
			zip_tie_hole_dim[1] + TOLERANCE_CLOSE * 2], true);

		// VTx antenna wire clip hole
		translate([0, 0, height])
		rotate([0, vtx_ant_angle])
		cylinder(h = height * 2, r = vtx_ant_wire_rad + TOLERANCE_FIT, center = true);

		// mount screw hole
		translate([0, 0, -0.1])
		cylinder(h = screw_depth + 0.2, r = screw_dim[0] / 2);
	}

	translate([0, 0, height])
	rotate([0, vtx_ant_angle])
	translate([0, 0, vtx_ant_clip_length - thickness])
	rotate([180, 0])
	children();
}
