

// WIRING SECTION TYPES
BEND = 0;
STRAIGHT = 1;

WIRE_BEND_ANGLE_DEFAULT = 90;
WIRE_BEND_RADIUS_DEFAULT = 10;

test = [
	[STRAIGHT,	50],
	[BEND,		45,	10,	[0, 90]], // angle, radius, rotation
	[STRAIGHT,	20],
];

module track_bend(angle = 90, r = WIRE_BEND_RADIUS_DEFAULT) {

	scale([1, -sign(angle)])
	translate([0, r])
	rotate([0, 0, -90])
	rotate_extrude(angle = abs(angle))
	translate([r, 0])
	track_profile_normal();

	children();
}


module draw_track(pieces, step = 0) {

	piece = pieces[step];
	type = piece[0];

	module draw_next_at(pos = [], rot = [])
		translate(pos)
		rotate(rot) {
			if (step < len(pieces) - 1) draw_track(pieces, step + 1) children();
			else children();
		}

	// BEND
	if (type == BEND) {
		a = piece[2];
		r = piece[1];
		draw_bend(piece[1], piece[2]) children();

	// STRAIGHT
	} else if (type == STRAIGHT) {
		draw_straight(piece[1]) children();
	}
}

draw_track(test);
