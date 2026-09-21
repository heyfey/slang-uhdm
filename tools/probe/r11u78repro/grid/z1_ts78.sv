// r11u78 arm z1 — WHOSE TYPESPEC IS IT?  `expr::Compare` READS `Typespec`, and
// golden hangs one on the cast operands where ours hangs none (r11v76 §4).
// The producer's `$signed` arm (ExprEval.cpp:4700-4711) mints a signed
// `logic_typespec` ONLY when the returned constant has none; every other
// `return c` face hands back whatever the LITERAL carried.  This arm reads the
// literal's own typespec off the DEF-view `sys_func_call` arguments AND the
// folded pattern operand side by side, per base and per signedness spelling.
// Operand 0 is a guaranteed bail (`8'hxA`), members are 24 bits.
package z1;
  localparam int K = 6;
  // the literals, one per base x spelling, each behind a cast and a hop
  localparam      SD  = signed'(16'd5);      // unsigned DEC under $signed
  localparam      HSD = SD;
  localparam      SSD = signed'(16'sd5);     // signed DEC under $signed
  localparam      HSSD= SSD;
  localparam      UD  = unsigned'(16'd5);    // unsigned DEC under $unsigned
  localparam      HUD = UD;
  localparam      USD = unsigned'(16'sd5);   // signed DEC under $unsigned
  localparam      HUSD= USD;
  localparam      UH  = unsigned'(16'h5);    // unsigned HEX under $unsigned
  localparam      HUH = UH;
  localparam      USH = unsigned'(16'sh5);   // signed HEX under $unsigned
  localparam      HUSH= USH;
  localparam      UO  = unsigned'(16'o5);    // unsigned OCT under $unsigned
  localparam      HUO = UO;
  localparam      USO = unsigned'(16'so5);   // signed OCT under $unsigned
  localparam      HUSO= USO;
  localparam      UB  = unsigned'(16'b101);  // unsigned BIN under $unsigned
  localparam      HUB = UB;
  localparam      USB = unsigned'(16'sb101); // signed BIN under $unsigned
  localparam      HUSB= USB;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] h09; logic [23:0] h10;
    logic [23:0] d01; logic [23:0] d02; logic [23:0] d03; logic [23:0] d04;
    logic [23:0] d05; logic [23:0] d06;
    logic [23:0] v01; logic [23:0] v02; logic [23:0] v03; logic [23:0] v04;
    logic [23:0] e01;
  } z1_t;
  localparam z1_t A = '{bail: 8'hxA,
                        // one HOP above the cast
                        h01: HSD,  h02: HSSD, h03: HUD,  h04: HUSD,
                        h05: HUH,  h06: HUSH, h07: HUO,  h08: HUSO,
                        h09: HUB,  h10: HUSB,
                        // the cast written DIRECTLY as the member
                        d01: signed'(16'd5),   d02: signed'(16'sd5),
                        d03: unsigned'(16'sd5), d04: unsigned'(16'h5),
                        d05: unsigned'(16'o5),  d06: unsigned'(16'b101),
                        // the BARE literal written directly (the controls:
                        // the literal path, already byte-equal)
                        v01: 16'd5, v02: 16'sd5, v03: 16'h5, v04: 16'o5,
                        e01: K+1};
endpackage
module z1_ts78 #(parameter z1::z1_t CA = z1::A)
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
                 output logic [23:0] z20);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08; assign z09 = CA.h09;
  assign z10 = CA.h10;
  assign z11 = CA.d01; assign z12 = CA.d02; assign z13 = CA.d03;
  assign z14 = CA.d04; assign z15 = CA.d05; assign z16 = CA.d06;
  assign z17 = CA.v01; assign z18 = CA.v02; assign z19 = CA.v03;
  assign z20 = CA.v04;
endmodule
