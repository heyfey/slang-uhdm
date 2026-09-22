// r11u91 arm p2 — THE EDGES OF THE PACKAGE-FED READ, and the shapes the law
// must DECLINE: a package-internal chain, a plain unsized decimal, the
// non-`'d` bases, an operation, a cast, a DIRECT package operand (y3_home87's
// control) and a reader whose own declaration is wider or narrower.
package p2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int          QI  = 16'd5;
  localparam int          QC  = QI;        // a PACKAGE-INTERNAL chain
  localparam int          QZ  = 5;         // a plain unsized decimal
  localparam logic [7:0]  QB  = 8'b1010;   // BIN
  localparam logic [7:0]  QO  = 8'o17;     // OCT
  localparam int          QE  = 2 + 3;     // an operation
  localparam logic [31:0] QW  = 32'd21;    // a wide DEC
  localparam int unsigned QUN = 16'd6;     // int unsigned
endpackage
module p2_pkgedge91;
  localparam logic [7:0]  S1 = p2p::QC;            // the package chain
  localparam logic [7:0]  S2 = p2p::QZ;            // plain decimal
  localparam logic [7:0]  S3 = p2p::QB;            // BIN
  localparam logic [7:0]  S4 = p2p::QO;            // OCT
  localparam logic [7:0]  S5 = p2p::QE;            // operation-fed
  localparam logic [63:0] S6 = p2p::QW;            // a WIDER reader
  localparam bit [3:0]    S7 = p2p::QI;            // a NARROWER bit reader
  localparam int unsigned S8 = p2p::QUN;           // int unsigned both ends
  localparam logic [7:0]  S9 = signed'(p2p::QI);   // THROUGH A CAST — declined
  localparam logic [7:0]  S10 = p2p::QI + 0;       // an OPERATION — declined
  localparam logic [7:0]  S11 = 16'd5;             // a LITERAL — the control
  localparam p2p::t A = '{bail: 8'hxA, a: S1, b: S2, c: S3, d: S4,
                          e: S5, f: S6, g: S7};
  localparam p2p::t B = '{bail: 8'hxA, a: S8, b: S9, c: S10, d: S11,
                          e: p2p::QI, f: p2p::QW, g: p2p::QB};
  p2_sink #(.R(A)) s1();
  p2_sink #(.R(B)) s2();
endmodule
module p2_sink #(parameter p2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
