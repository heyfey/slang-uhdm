// r11u94 arm q1 — THE IMPLICIT PACKAGE DECLARATION'S SYNTHESIZED TYPESPEC,
// the signing keyword x the written dimension x the literal's own width.
// r11u91's R1/R0: `red91PkgDeclKind91` returns -1 for every shape here and
// BOTH faces of `§ modPkgFedHopStore91` refuse it.  The producer
// (`CompileType.cpp:1395-1437`, `compileTypespec`'s `paSigning_Signed` /
// `paSigning_Unsigned` / `paPacked_dimension` arms with `isVariable=false`)
// SYNTHESIZES an `int_typespec` for a parameter's implicit type — signed iff
// the `signed` keyword is written, carrying the written packed dimension as
// its ranges and NOTHING when none is written, so `Bits(ts)` is the
// dimension's width or the int default 32.  The literal's own width never
// reaches the store on a `'d` leaf (`adjustSize` keeps a `vpiDecConst`).
package q1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int             QI   = 16'd5;   // dk=1 CONTROL (landed law)
  localparam signed          QSI  = 16'd5;   // implicit + `signed`
  localparam unsigned        QUI  = 16'd5;   // implicit + `unsigned`
  localparam signed [7:0]    QSD  = 16'd5;   // `signed` + a dimension
  localparam        [7:0]    QPD  = 16'd5;   // a dimension alone
  localparam unsigned [15:0] QUD  = 8'd5;    // `unsigned` + a dimension
  localparam signed          QS8  = 8'd5;    // `signed`, a NARROW literal
  localparam signed [15:0]   QSW  = 8'd5;    // `signed` + a WIDER dimension
endpackage
module q1_pkgsyn94;
  localparam logic [7:0] U1 = q1p::QI;
  localparam logic [7:0] U2 = q1p::QSI;
  localparam logic [7:0] U3 = q1p::QUI;
  localparam logic [7:0] U4 = q1p::QSD;
  localparam logic [7:0] U5 = q1p::QPD;
  localparam logic [7:0] U6 = q1p::QUD;
  localparam logic [7:0] U7 = q1p::QS8;
  localparam logic [7:0] U8 = q1p::QSW;
  localparam q1p::t A = '{bail: 8'hxA, a: U1, b: U2, c: U3, d: U4,
                          e: U5, f: U6, g: U7};
  localparam q1p::t B = '{bail: 8'hxA, a: U8, b: U2, c: U4, d: U5,
                          e: U6, f: U7, g: U3};
  q1_sink #(.R(A)) s1();
  q1_sink #(.R(B)) s2();
endmodule
module q1_sink #(parameter q1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
