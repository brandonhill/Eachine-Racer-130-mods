
include <../BH-Lib/all.scad>;

// **************
// Printing

PRINT_LAYER = 0.2;
PRINT_NOZZLE = 0.5;

TOLERANCE_CLOSE = 0.2;
TOLERANCE_FIT   = 0.3;
TOLERANCE_CLEAR = 0.4;

// **************
// CONSTANTS

BATT_DIM = [50, 32, 13];
BATT_STRAP_DIM = [10, 3]; // cross section

BUZZER_DIM = [9.5, 9.5, 5.25];

// CAM_DIM = CAM_CCD_MICRO_DIM;
// CAM_DIM = CAM_CMOS_MICRO_DIM;
CAM_DIM = CAM_RUNCAM_SWIFT_MICRO_DIM;
CAM_MOUNT_SCREW_SPACING = 16;
CAM_PIVOT_OFFSET = -11.5;

FRAME_ARM_ANGLE = 17;
FRAME_ARM_WIDTH = 14;
FRAME_CENTER_OFFSET = 4;
FRAME_DIM = [102, 32]; // center portion
FRAME_HOLE_SPACING = [28, 24]; // existing FC mount holes in CF bottom plate
FRAME_SCREW_DEPTH = 3;
FRAME_SCREW_DIM = SCREW_M2_DIM;
FRAME_SCREW_SURROUND = 1.5;
FRAME_THICKNESS = 2;

MOTOR_HEIGHT = 12;
MOTOR_RAD = 7;
MOTOR_SPACING = [90, 111]; // ~ ?

OMNIBUS_F3_MICRO_DIM = [27.3, 27.3, 5];
OMNIBUS_HOLE_SPACING = 20;

PROP_RAD = 3 * MMPI / 2;

RX_FRSKY_MINI_DIM = [25, 12.5, 2.75];
RX_FRSKY_MICRO_XM_DIM = [22, 12, 3.2];

SIZE_DIA = 135;

VTX_ANT_WIRE_RAD = 1.8 / 2;
VTX_DIM = [19, 22, 6];

ZIP_TIE_DIM = [3, 1.5];

// **************
// CONFIG

COMPONENT_CLEARANCE = 0.5;

BATT_POS = [-5, 0, -BATT_DIM[2] / 2 - 1];

BOARD_MOUNT_BASE_THICKNESS = PRINT_LAYER * 2;

CAM_ANGLE = 25;
CAM_MOUNT_ARM_THICKNESS = 2;
CAM_MOUNT_ARM_WIDTH = 5;
CAM_MOUNT_BASE_THICKNESS = 3;
CAM_Z_OFFSET = 3; // allow tilt clearance

CANOPY_DIM = [55, FRAME_DIM[1], 27];
CANOPY_POS = [0, 0, 0.01];

CANOPY_CAM_HOLE_RAD = CAM_RUNCAM_SWIFT_MICRO_RAD[2] + TOLERANCE_CLEAR;
CANOPY_CLIP_HEIGHT = 4;
CANOPY_CLIP_THICKNESS = 1.2;
CANOPY_CLIP_WIDTH = 4;
CANOPY_LIP_DEPTH = 2;
CANOPY_LIP_THICKNESS = 2;
CANOPY_LIP_WIDTH = 12;
CANOPY_ROUNDING = 4;
CANOPY_THICKNESS = 0.8;

// ***
// Components

BUZZER_POS = [19, 0, BUZZER_DIM[2] / 2];
BUZZER_ROT = [0, 180];

FC_DIM = OMNIBUS_F3_MICRO_DIM;
FC_HOLE_SPACING = FC_OMNIBUS_F3_MINI_HOLE_SPACING;
FC_POS = [0, 0, 5 + FC_DIM[2] / 2];
FC_ROT = [];

RX_DIM = RX_FRSKY_MICRO_XM_DIM;
RX_POS = [0, 0, FC_POS[2] + FC_DIM[2] / 2 + COMPONENT_CLEARANCE + RX_DIM[2] / 2];

VTX_POS = [0, 0, RX_POS[2] + RX_DIM[2] / 2 + COMPONENT_CLEARANCE + VTX_DIM[2] / 2];
VTX_ROT = [0, 0, -90];

CAM_MOUNT_POS = [FC_POS[0] + FC_DIM[0] / 2 + 14, 0];