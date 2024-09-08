DISPLAY_WIDTH = 160;
DISPLAY_DEPTH = 80;
DISPLAY_HEIGHT = 15; // excluding the little nubbin thing

DISPLAY_STANDOFFS = [
	[16.7, 7.65],
	[66.7, 7.65],
	[143.3, 7.65],
	[16.7, 72.65],
	[93.3, 72.65],
	[143.3, 72.65]
];

BOARD_DEPTH = 44.45;
BOARD_X_INSET = 0.2;
BOARD_Z_OFFSET = 11;

HEIGHT = 36; // of the case, excludes the backplate

SURFACE = 1.5;

DIFFUSER_HEIGHT = 0.2;

RADIUS = 4;

DISPLAY_SPACING = RADIUS / 2;

USB_C_Y_OFFSET = 14;
USB_C_Z_OFFSET = -3.15;

RTC_STANDOFF_X_SPACING = 0.5 * 25.4;
RTC_STANDOFF_Y_SPACING = 0.8 * 25.4;
RTC_X_OFFSET = 90;
RTC_STANDOFF_HEIGHT = 5;

SCREW_HEIGHT = 6.3;
SCREW_HEAD_DIAMETER = 4.1;
SCREW_HEAD_HEIGHT = 1.7;
SCREW_SHAFT_DIAMETER = 1.8;
	
BUTTON_DEPTH = 7.8;
BUTTON_HEIGHT = 4.2;
BUTTON_SPACING = 1.9;
BUTTON_Z_OFFSET = 1.3;
BUTTON_START_Y = 2.5;
	
function total_width() = DISPLAY_WIDTH + DISPLAY_SPACING * 2 + SURFACE * 2;
function total_depth() = DISPLAY_DEPTH + DISPLAY_SPACING * 2 + SURFACE * 2;
function board_total_height() = DISPLAY_HEIGHT + BOARD_Z_OFFSET;

module display() {
	delta = DISPLAY_SPACING + SURFACE;
	
	translate([delta, delta, DIFFUSER_HEIGHT])
	import("5036 RGB Matrix.stl");
}

module board() {
	translate([SURFACE + BOARD_X_INSET, BOARD_DEPTH + total_depth() / 2 - BOARD_DEPTH / 2, board_total_height()])
	rotate([180, 0, 0])
	import("5778 Matrix Portal S3.stl");
}

module usb_c() {
	width = 9.4;
	depth = 4;

	translate([0, total_depth() / 2 + USB_C_Y_OFFSET, board_total_height() + USB_C_Z_OFFSET])
	rotate([90, 0, 90])
	union() {		
		for (x = [-1, 1]) {
			translate([(width / 2 - depth / 2) * x, 0, 0])
			cylinder(d = depth, h = SURFACE, $fn = 20);
		}
		
		translate([0, 0, SURFACE / 2])
		cube([width - depth, depth, SURFACE], center = true);
	}
}

module case() {
	render()
	difference() {
		hull() {
			for (x = [RADIUS, SURFACE * 2 + DISPLAY_SPACING * 2 + DISPLAY_WIDTH - RADIUS]) {
				for (y = [RADIUS, SURFACE * 2 + DISPLAY_SPACING * 2 + DISPLAY_DEPTH - RADIUS]) {
					translate([x, y, 0])
					cylinder(r = RADIUS, h = HEIGHT, $fn = 36);
				}
			}
		}
		
		hull() {
			for (x = [RADIUS + SURFACE, SURFACE + DISPLAY_SPACING * 2 + DISPLAY_WIDTH - RADIUS]) {
				for (y = [RADIUS + SURFACE, SURFACE + DISPLAY_SPACING * 2 + DISPLAY_DEPTH - RADIUS]) {
					translate([x, y, SURFACE])
					cylinder(r = RADIUS, h = HEIGHT - SURFACE, $fn = 36);
				}
			}
		}
		
		translate([SURFACE + DISPLAY_SPACING - 1, SURFACE + DISPLAY_SPACING - 1, DIFFUSER_HEIGHT])
		cube([DISPLAY_WIDTH + 2, DISPLAY_DEPTH + 2, SURFACE - DIFFUSER_HEIGHT]);
		
		usb_c();
		
		screws();
		
		for (i = [0 : 2]) {
			y = total_depth() / 2 - BOARD_DEPTH / 2 + BUTTON_START_Y + i * (BUTTON_DEPTH + BUTTON_SPACING);
		
			translate([0, y, HEIGHT - BOARD_Z_OFFSET - SURFACE - BUTTON_HEIGHT + BUTTON_Z_OFFSET])
			cube([SURFACE, BUTTON_DEPTH, BUTTON_HEIGHT]);
		}
	}
}

module screw() {
	cylinder(d = SCREW_SHAFT_DIAMETER, h = SCREW_HEIGHT, $fn = 20);
	
	translate([0, 0, SCREW_HEIGHT - SCREW_HEAD_HEIGHT])
	cylinder(d2 = SCREW_HEAD_DIAMETER, d1 = SCREW_SHAFT_DIAMETER, h = SCREW_HEAD_HEIGHT, $fn = 20);
}

module screws() {
	locations = [
		[10, SCREW_HEIGHT, 90, 0],
		[total_width() / 2, SCREW_HEIGHT, 90, 0],
		[total_width() - 10, SCREW_HEIGHT, 90, 0],
		[10, total_depth() - SCREW_HEIGHT, 270, 0],
		[total_width() / 2, total_depth() - SCREW_HEIGHT, 270, 0],
		[total_width() - 10, total_depth() - SCREW_HEIGHT, 270, 0],
		[SCREW_HEIGHT, total_depth() / 2, 0, 270, 0],
		[total_width() - SCREW_HEIGHT, total_depth() / 2, 0, 90, 0]
	];

	for (location = locations) {
		x = location[0];
		y = location[1];
		x_rotation = location[2];
		y_rotation = location[3];
		
		translate([x, y, HEIGHT - 3])
		rotate([x_rotation, y_rotation, 0])
		screw();
	}
}

module backplate() {
	translate([0, 0, HEIGHT])
	render()
	difference() {
		hull() {
			for (x = [RADIUS, SURFACE * 2 + DISPLAY_SPACING * 2 + DISPLAY_WIDTH - RADIUS]) {
				for (y = [RADIUS, SURFACE * 2 + DISPLAY_SPACING * 2 + DISPLAY_DEPTH - RADIUS]) {
					translate([x, y, 0])
					cylinder(r = RADIUS, h = SURFACE, $fn = 36);
				}
			}
		}
		
		// display standoffs
		for (standoff = DISPLAY_STANDOFFS) {
			x = standoff[0] + SURFACE + DISPLAY_SPACING;
			y = standoff[1] + SURFACE + DISPLAY_SPACING;
			
			/*translate([x, y, SURFACE / 2])
			cylinder(d = 6, h = SURFACE / 2, $fn = 36);*/
			
			translate([x, y, 0])
			cylinder(d = 3.2, h = SURFACE, $fn = 36);
		}
	}
	
	render()
	difference() {
		translate([0, 0, HEIGHT - 6])
		hull() {
			for (x = [RADIUS + SURFACE, SURFACE + DISPLAY_SPACING * 2 + DISPLAY_WIDTH - RADIUS]) {
				for (y = [RADIUS + SURFACE, SURFACE + DISPLAY_SPACING * 2 + DISPLAY_DEPTH - RADIUS]) {
					translate([x, y, 0])
					cylinder(r = RADIUS, h = 6, $fn = 36);
				}
			}
		}
		
		translate([0, 0, HEIGHT - 6])
		hull() {
			for (x = [RADIUS + SURFACE * 2, DISPLAY_SPACING * 2 + DISPLAY_WIDTH - RADIUS]) {
				for (y = [RADIUS + SURFACE * 2, DISPLAY_SPACING * 2 + DISPLAY_DEPTH - RADIUS]) {
					translate([x, y, 0])
					cylinder(r = RADIUS, h = 6, $fn = 36);
				}
			}
		}
		
		screws();
	}
	
	// board standoffs
	for (x = [9.32, 49.95]) {
		for (y = [30.15, 49.85]) {
			translate([x, y, board_total_height()])
			render()
			difference() {
				cylinder(d = 4, h = HEIGHT - board_total_height(), $fn = 36);
				cylinder(d = 2.4, h = HEIGHT - board_total_height(), $fn = 36);
			}
		}
	}
	
	// RTC standoffs
	for (x = [RTC_X_OFFSET, RTC_X_OFFSET + RTC_STANDOFF_X_SPACING]) {
		for (y = [total_depth() / 2 - RTC_STANDOFF_Y_SPACING / 2, total_depth() / 2 + RTC_STANDOFF_Y_SPACING / 2]) {
			translate([x, y, HEIGHT - RTC_STANDOFF_HEIGHT])
			render()
			difference() {
				cylinder(d = 4.5, h = RTC_STANDOFF_HEIGHT, $fn = 36);
				cylinder(d = 2.9, h = RTC_STANDOFF_HEIGHT, $fn = 36);
			}
		}
	}
	
	// display standoffs
	for (standoff = DISPLAY_STANDOFFS) {
		x = standoff[0] + SURFACE + DISPLAY_SPACING;
		y = standoff[1] + SURFACE + DISPLAY_SPACING;
		
		translate([x, y, DISPLAY_HEIGHT])
		render()
		difference() {
			cylinder(d = 6, h = HEIGHT - DISPLAY_HEIGHT, $fn = 36);
			cylinder(d = 3.3, h = HEIGHT - DISPLAY_HEIGHT, $fn = 36);
		}
	}
}

//color("red") screws();
//case();
backplate();
//display();
//board();