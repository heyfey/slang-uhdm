// r11u91 arm p3 — WHICH WIDTH the `vpiDecConst` package hop keeps: the
// PACKAGE parameter's declared `Bits`, or the literal's written width, and
// what a package-INTERNAL chain answers when the two hops disagree.
package p3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam logic [7:0]  QD   = 16'd5;   // Bits 8 vs the literal's 16
  localparam int          QDL  = 8'd5;    // Bits 32 vs the literal's 8
  localparam              QIM  = 8'd5;    // implicit: the literal's 8
  localparam int          QI   = 16'd5;
  localparam logic [7:0]  QC8  = QI;      // a chain whose hops DISAGREE
  localparam logic [63:0] QC64 = QI;
  localparam              QCIM = QI;      // an implicit chain hop
  localparam bit [11:0]   QB12 = 16'd5;
endpackage
module p3_pkgsize91;
  localparam logic [15:0] T1 = p3p::QD;
  localparam logic [15:0] T2 = p3p::QDL;
  localparam logic [15:0] T3 = p3p::QIM;
  localparam logic [15:0] T4 = p3p::QC8;
  localparam logic [15:0] T5 = p3p::QC64;
  localparam logic [15:0] T6 = p3p::QCIM;
  localparam logic [15:0] T7 = p3p::QB12;
  localparam p3p::t A = '{bail: 8'hxA, a: T1, b: T2, c: T3, d: T4,
                          e: T5, f: T6, g: T7};
  p3_sink #(.R(A)) s1();
endmodule
module p3_sink #(parameter p3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
