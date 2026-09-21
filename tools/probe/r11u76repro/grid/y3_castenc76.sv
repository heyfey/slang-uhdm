// r11u76 arm y3 — THE SIGNEDNESS CAST'S ENCODING: cast shapes x operand kinds.
// r11v73's RV-6 read `signed'(16'd5)` as golden `const/16@1=` with an "EMPTY"
// value.  That empty string is the committed shape lister's own blind spot
// (its value regex lists UINT|INT|BIN|HEX|OCT|STRING|REAL|SCALAR and NOT
// `DEC:`); this arm is read with the DEC-aware lister.
// Operand 0 is a guaranteed bail (`8'hxA`), so every operand after it prints
// `reduceExpr`'s own answer against 24-bit members that collide with nothing.
// `X*` rows are the cast at ONE HOP (an untyped name onto it); `D*` rows are
// the SAME cast written DIRECTLY as the member.
package y3;
  localparam int  K   = 6;
  localparam      UD  = 16'd5;            // a NAME operand, verbatim decimal
  localparam      UH  = 16'h5;            // a NAME operand, verbatim hex
  localparam      MN  = -16'd5;           // a NAME operand, MINTED
  localparam      CS  = signed'(16'd5);   // signed cast over a based decimal
  localparam      HCS = CS;
  localparam      CU  = unsigned'(16'sd5);
  localparam      HCU = CU;
  localparam      CH  = signed'(16'h5);   // signed cast over a based HEX
  localparam      HCH = CH;
  localparam      CB  = signed'(16'b101); // signed cast over a based BINARY
  localparam      HCB = CB;
  localparam      CO  = unsigned'(16'o5); // unsigned cast over a based OCTAL
  localparam      HCO = CO;
  localparam      CN  = signed'(UD);      // cast over a NAME
  localparam      HCN = CN;
  localparam      CA2 = signed'(16'd9 + 16'd1);  // cast over an ARM
  localparam      HCA = CA2;
  localparam      CM  = signed'(MN);      // cast over a MINTED name
  localparam      HCM = CM;
  localparam      CUS = signed'(5);       // cast over an UNSIZED decimal
  localparam      HCS2= CUS;
  localparam      SF  = $signed(16'd5);   // the SYSTEM-FUNCTION spelling
  localparam      HSF = SF;
  localparam      UF  = $unsigned(16'sd5);
  localparam      HUF = UF;
  localparam      C16 = 16'(5);           // a WIDTH cast — the landed control
  localparam      HC1 = C16;
  localparam      AD  = 16'd9 + 16'd1;    // an arm — the landed control
  localparam      HAD = AD;
  typedef struct packed {
    logic [23:0] bail; // 8'hxA GUARANTEED BAIL
    logic [23:0] x01;  // HCS
    logic [23:0] x02;  // HCU
    logic [23:0] x03;  // HCH
    logic [23:0] x04;  // HCB
    logic [23:0] x05;  // HCO
    logic [23:0] x06;  // HCN
    logic [23:0] x07;  // HCA
    logic [23:0] x08;  // HCM
    logic [23:0] x09;  // HCS2
    logic [23:0] x10;  // HSF
    logic [23:0] x11;  // HUF
    logic [23:0] x12;  // HC1  control
    logic [23:0] x13;  // HAD  control
    logic [23:0] d01;  // signed'(16'd5)          DIRECT
    logic [23:0] d02;  // unsigned'(16'sd5)       DIRECT
    logic [23:0] d03;  // $signed(16'd5)          DIRECT
    logic [23:0] d04;  // 16'd5                   DIRECT verbatim control
    logic [23:0] d05;  // 16'h5                   DIRECT verbatim control
    logic [23:0] d06;  // 16'(5)                  DIRECT width cast
    logic [23:0] d07;  // signed'(16'd5) + 0      the cast INSIDE an arm
    logic [23:0] e01;  // K+1  plain control
  } y3_t;
  localparam y3_t A = '{bail: 8'hxA,
                        x01: HCS, x02: HCU, x03: HCH, x04: HCB, x05: HCO,
                        x06: HCN, x07: HCA, x08: HCM, x09: HCS2, x10: HSF,
                        x11: HUF, x12: HC1, x13: HAD,
                        d01: signed'(16'd5), d02: unsigned'(16'sd5),
                        d03: $signed(16'd5), d04: 16'd5, d05: 16'h5,
                        d06: 16'(5), d07: signed'(16'd5) + 0,
                        e01: K+1};
endpackage
module y3_castenc76 #(parameter y3::y3_t CA = y3::A)
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
                      output logic [23:0] z20, output logic [23:0] z21);
  assign z00 = CA.bail; assign z01 = CA.x01; assign z02 = CA.x02;
  assign z03 = CA.x03;  assign z04 = CA.x04; assign z05 = CA.x05;
  assign z06 = CA.x06;  assign z07 = CA.x07; assign z08 = CA.x08;
  assign z09 = CA.x09;  assign z10 = CA.x10; assign z11 = CA.x11;
  assign z12 = CA.x12;  assign z13 = CA.x13; assign z14 = CA.d01;
  assign z15 = CA.d02;  assign z16 = CA.d03; assign z17 = CA.d04;
  assign z18 = CA.d05;  assign z19 = CA.d06; assign z20 = CA.d07;
  assign z21 = CA.e01;
endmodule
