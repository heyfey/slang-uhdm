// r11u81 arm a3 — THE HOP STORE'S BOUNDARIES.
// Where does the untyped-parameter switch (CompileHelper.cpp:3904-3995) STOP
// answering, and what does a DECLARED type hand on?  One hop per face:
// width casts, based widths other than 16, a SIGNED based literal (whose own
// `int_typespec` the literal path already writes), arithmetic over a based
// name, an UNSIZED decimal, a string, a real, a `logic [7:0]`, a `bit`, an
// implicit `signed`, an implicit parameter WITH a packed dimension, and a
// depth-3 chain.  Operand 0 is a guaranteed bail; members are 24 bits.
package a3;
  localparam int          K    = 6;
  localparam              WC1  = 16'(5);         // a WIDTH cast
  localparam              WC2  = 16'(8'sd200);   // a width cast over signed
  localparam              WC3  = 8'(-3);         // a width cast over negative
  localparam              WC4  = byte'(5);       // a TYPE cast
  localparam              WC5  = int'(3);        // a TYPE cast
  localparam              H8   = 8'h5;           // an 8-bit hex
  localparam              H64  = 64'hF;          // a 64-bit hex
  localparam              SH   = 16'sh5;         // a SIGNED hex literal
  localparam              PH   = 16'h5;
  localparam              AH   = PH + 1;         // arithmetic over a hex name
  localparam              UDU  = 'd5;            // an UNSIZED decimal
  localparam string       STR  = "ab";           // a string
  localparam logic [7:0]  LG   = 8'd5;           // a DECLARED logic vector
  localparam bit          BT   = 1'b1;           // a DECLARED bit
  localparam signed       SG   = 5;              // an implicit SIGNED
  localparam       [7:0]  PDIM = 8'd5;           // implicit WITH a dimension
  localparam              D1   = 16'h5;
  localparam              D2   = D1;
  localparam              D3   = D2;             // depth 3
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] h01; logic [23:0] h02; logic [23:0] h03; logic [23:0] h04;
    logic [23:0] h05; logic [23:0] h06; logic [23:0] h07; logic [23:0] h08;
    logic [23:0] h09; logic [23:0] h10; logic [23:0] h11; logic [23:0] h12;
    logic [23:0] h13; logic [23:0] h14; logic [23:0] h15;
    logic [23:0] e01;
  } a3_t;
  localparam a3_t A = '{bail: 8'hxA,
                        h01: WC1, h02: WC2, h03: WC3, h04: WC4,
                        h05: WC5, h06: H8,  h07: H64, h08: SH,
                        h09: AH,  h10: UDU, h11: LG,  h12: BT,
                        h13: SG,  h14: PDIM, h15: D3,
                        e01: K+1};
endpackage
module a3_hopbnd81 #(parameter a3::a3_t CA = a3::A)
                    (output logic [23:0] z00, output logic [23:0] z01,
                     output logic [23:0] z02, output logic [23:0] z03,
                     output logic [23:0] z04, output logic [23:0] z05,
                     output logic [23:0] z06, output logic [23:0] z07,
                     output logic [23:0] z08, output logic [23:0] z09,
                     output logic [23:0] z10, output logic [23:0] z11,
                     output logic [23:0] z12, output logic [23:0] z13,
                     output logic [23:0] z14, output logic [23:0] z15);
  assign z00 = CA.bail;
  assign z01 = CA.h01; assign z02 = CA.h02; assign z03 = CA.h03;
  assign z04 = CA.h04; assign z05 = CA.h05; assign z06 = CA.h06;
  assign z07 = CA.h07; assign z08 = CA.h08; assign z09 = CA.h09;
  assign z10 = CA.h10; assign z11 = CA.h11; assign z12 = CA.h12;
  assign z13 = CA.h13; assign z14 = CA.h14; assign z15 = CA.h15;
endmodule
