// r11v91 BREAK arm v4 — DEPTH, the OVERRIDE gate, the NON-instance homes and
// the shapes the width face recurses through.  `red91PkgStoreSize91` recurses
// with depth<=8 and `red91PkgStoreSigned91` likewise; a chain LONGER than the
// cap must DECLINE, not answer wrong.  A package hop initialised from a
// module parameter is impossible, but a package hop initialised from ANOTHER
// PACKAGE's parameter is not.
package v4a;
  localparam int AI = 16'd5;
endpackage
package v4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int          X0 = 16'd5;
  localparam logic [7:0]  X1 = X0;
  localparam logic [9:0]  X2 = X1;
  localparam logic [11:0] X3 = X2;
  localparam logic [13:0] X4 = X3;
  localparam logic [15:0] X5 = X4;
  localparam logic [17:0] X6 = X5;
  localparam logic [19:0] X7 = X6;
  localparam logic [21:0] X8 = X7;
  localparam logic [23:0] X9 = X8;   // depth 9 from the leaf
  localparam int          XX = v4a::AI;   // a CROSS-PACKAGE hop
  localparam logic [7:0]  XP = 8'h1A;     // an 'h leaf: the width face declines
endpackage
module v4_pkgdepth91;
  localparam logic [7:0] Y1 = v4p::X1;
  localparam logic [7:0] Y2 = v4p::X5;
  localparam logic [7:0] Y3 = v4p::X9;   // past the cap at the reader
  localparam logic [7:0] Y4 = v4p::XX;   // cross-package
  localparam logic [7:0] Y5 = v4p::XP;   // 'h: the width face must decline
  localparam logic [7:0] Y6 = v4p::X0;
  localparam logic [7:0] Y7 = v4p::X2;
  localparam v4p::t A = '{bail: 8'hxA, a: Y1, b: Y2, c: Y3, d: Y4,
                          e: Y5, f: Y6, g: Y7};
  v4_sink #(.R(A)) s1();
  if (1) begin : g
    localparam logic [7:0] Z1 = v4p::X0;   // a GEN-BLOCK home
    localparam logic [7:0] Z2 = v4p::X1;
    localparam v4p::t B = '{bail: 8'hxA, a: Z1, b: Z2, c: Z1, d: Z2,
                            e: Z1, f: Z2, g: Z1};
    v4_sink #(.R(B)) s2();
  end
endmodule
module v4_sink #(parameter v4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
