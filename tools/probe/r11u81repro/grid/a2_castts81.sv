// r11u81 arm a2 — THE CAST FACES: THE MINT (LAW B), THE DANGLING REF (LAW D)
// AND THE DECLARED-TYPE ARGUMENT (LAW C).
// `ExprEval.cpp:4735-4770`: `$signed` over a UInt/Bin/Hex/Oct constant MINTS a
// fresh `INT:` constant and ALWAYS hangs a signed `logic_typespec` behind a
// `ref_typespec` on it (unconditionally — the constant is new).  `$unsigned`
// over a NEGATIVE Int/Dec mints a `UINT:` constant and hangs NOTHING.  The
// `return c` faces hand back the argument's own constant (r11u78's law).
// A NAME between the cast and the literal makes golden answer the hopped
// symbol's typespec instead (declared type -> that type's typespec; untyped
// DecConst -> the empty shape R1 recorded).
// Operand 0 is a guaranteed bail (`8'hxA`); members are 24 bits.
package a2;
  localparam int      K   = 6;
  localparam byte     TB  = 8'd5;            // a DECLARED-TYPE parameter
  localparam int      TI  = 5;
  localparam shortint TS  = 5;
  localparam          UD  = 16'd5;           // untyped, DecConst
  localparam          UH  = 16'h5;           // untyped, HexConst
  localparam M1  = signed'(16'h5);           // MINT: hex under $signed
  localparam HM1 = M1;
  localparam M2  = signed'(16'b101);         // MINT: bin under $signed
  localparam HM2 = M2;
  localparam M3  = signed'(5);               // MINT: uint under $signed
  localparam HM3 = M3;
  localparam M4  = signed'(16'd9 + 16'd1);   // MINT: arithmetic under $signed
  localparam HM4 = M4;
  localparam M5  = unsigned'(-8'sd100);      // MINT: $unsigned over NEGATIVE
  localparam HM5 = M5;
  localparam M6  = $signed(16'h5);           // the system-call spelling
  localparam HM6 = M6;
  localparam R1  = unsigned'(16'd5);         // R1: $unsigned + DecConst
  localparam HR1 = R1;
  localparam R2  = signed'(UD);              // a NAME between cast and literal
  localparam HR2 = R2;
  localparam R3  = unsigned'(UH);            // a NAME, hex
  localparam HR3 = R3;
  localparam C1  = signed'(TB);              // LAW C: byte argument
  localparam HC1 = C1;
  localparam C2  = signed'(TI);              // LAW C: int argument
  localparam HC2 = C2;
  localparam C3  = unsigned'(TS);            // LAW C: shortint argument
  localparam HC3 = C3;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] h09; logic [23:0] h10; logic [23:0] h11; logic [23:0] h12;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03; logic [23:0] d04;
    logic [23:0] d05; logic [23:0] d06; logic [23:0] d07; logic [23:0] d08;
    logic [23:0] v01; logic [23:0] v02; logic [23:0] v03;
    logic [23:0] e01;
  } a2_t;
  localparam a2_t A = '{bail: 8'hxA,
                        // one HOP above the cast
                        h01: HM1, h02: HM2, h03: HM3, h04: HM4,
                        h05: HM5, h06: HM6, h07: HR1, h08: HR2,
                        h09: HR3, h10: HC1, h11: HC2, h12: HC3,
                        // the cast written DIRECTLY as the member
                        d01: signed'(16'h5),   d02: signed'(16'b101),
                        d03: signed'(5),       d04: unsigned'(-8'sd100),
                        d05: unsigned'(16'd5), d06: signed'(UD),
                        d07: signed'(TB),      d08: unsigned'(TS),
                        // the bare names and literal (controls)
                        v01: TB, v02: TI, v03: 16'h5,
                        e01: K+1};
endpackage
module a2_castts81 #(parameter a2::a2_t CA = a2::A)
                    (output logic [23:0] z00, output logic [23:0] z01,
                     output logic [23:0] z02, output logic [23:0] z03,
                     output logic [23:0] z04, output logic [23:0] z05,
                     output logic [23:0] z06, output logic [23:0] z07,
                     output logic [23:0] z08, output logic [23:0] z09,
                     output logic [23:0] z10, output logic [23:0] z11,
                     output logic [23:0] z12, output logic [23:0] z13,
                     output logic [23:0] z14, output logic [23:0] z15,
                     output logic [23:0] z16, output logic [23:0] z17,
                     output logic [23:0] z18, output logic [23:0] z19,
                     output logic [23:0] z20, output logic [23:0] z21,
                     output logic [23:0] z22, output logic [23:0] z23);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08; assign z09 = CA.h09;
  assign z10 = CA.h10; assign z11 = CA.h11; assign z12 = CA.h12;
  assign z13 = CA.d01; assign z14 = CA.d02; assign z15 = CA.d03;
  assign z16 = CA.d04; assign z17 = CA.d05; assign z18 = CA.d06;
  assign z19 = CA.d07; assign z20 = CA.d08;
  assign z21 = CA.v01; assign z22 = CA.v02; assign z23 = CA.v03;
endmodule
