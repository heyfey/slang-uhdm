// r11u81 arm a1 — LAW A's GRID: WHOSE TYPESPEC DOES A NAME HOP HAND ON?
// Surelog's untyped-parameter switch (CompileHelper.cpp:3904-3995) gives an
// implicitly typed parameter a typespec keyed on its REDUCED value's
// `VpiConstType` — an `int_typespec` for Int/UInt/Hex/Oct/Bin (the based ones
// carrying a `[size-1:0]` RANGE, and only when the size is not -1), NOTHING
// for a DecConst, `real_typespec`/`string_typespec` otherwise — and
// `substituteAssignedValue`'s caller (CompileExpression.cpp:2973-2995) then
// hangs THAT typespec on the constant it hands back for a reference, gated on
// the constant having none.  This arm reads one hop per const-type face, at
// depth 1 and depth 2, beside the same spelling written DIRECTLY as the member
// (where no hop exists and golden hangs nothing).
// Operand 0 is a guaranteed bail (`8'hxA`); members are 24 bits.
package a1;
  localparam int K   = 6;
  localparam     PD  = 16'd5;          // vpiDecConst
  localparam     PSD = 16'sd5;         // vpiDecConst, `s` marker
  localparam     PH  = 16'h5;          // vpiHexConst
  localparam     PO  = 16'o5;          // vpiOctConst
  localparam     PB  = 16'b101;        // vpiBinaryConst
  localparam     PU  = 5;              // a plain integer literal
  localparam     PA  = 16'd9 + 16'd1;  // arithmetic
  localparam     PN  = -5;             // a NEGATIVE value
  localparam     PC  = 16'(5);         // a WIDTH cast
  localparam     PUN = 'h5;            // UNSIZED hex (VpiSize -1)
  localparam     PH2 = PH;             // depth 2 over hex
  localparam     PD2 = PD;             // depth 2 over dec
  localparam     PA2 = PA;             // depth 2 over arithmetic
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] h09; logic [23:0] h10; logic [23:0] h11; logic [23:0] h12;
    logic [23:0] h13;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03; logic [23:0] d04;
    logic [23:0] e01;
  } a1_t;
  localparam a1_t A = '{bail: 8'hxA,
                        h01: PD,  h02: PSD, h03: PH,  h04: PO,
                        h05: PB,  h06: PU,  h07: PA,  h08: PN,
                        h09: PC,  h10: PUN, h11: PH2, h12: PD2,
                        h13: PA2,
                        d01: 16'd5, d02: 16'h5, d03: 16'(5),
                        d04: 16'd9 + 16'd1,
                        e01: K+1};
endpackage
module a1_hopts81 #(parameter a1::a1_t CA = a1::A)
                   (output logic [23:0] z00, output logic [23:0] z01,
                    output logic [23:0] z02, output logic [23:0] z03,
                    output logic [23:0] z04, output logic [23:0] z05,
                    output logic [23:0] z06, output logic [23:0] z07,
                    output logic [23:0] z08, output logic [23:0] z09,
                    output logic [23:0] z10, output logic [23:0] z11,
                    output logic [23:0] z12, output logic [23:0] z13,
                    output logic [23:0] z14, output logic [23:0] z15,
                    output logic [23:0] z16, output logic [23:0] z17);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08; assign z09 = CA.h09;
  assign z10 = CA.h10; assign z11 = CA.h11; assign z12 = CA.h12;
  assign z13 = CA.h13;
  assign z14 = CA.d01; assign z15 = CA.d02; assign z16 = CA.d03;
  assign z17 = CA.d04;
endmodule
