// r11u94 arm q3 — THE READER SHAPES over a synthesized-typespec package hop,
// and the two controls that must not move.  The clone CARRIES the synthesized
// typespec, so `DesignElaboration.cpp:2568`'s fill-in cannot run and the
// READER'S DECLARATION GETS NO VOTE on either field — including a SIGNED
// reader over an `unsigned`/dimension-only package hop, which is the mirror
// of r11u91's `R8` and the cell that decides whether the law REPLACES the
// declaration read or ORs into it.  `V7` is the IMPORTED read (r11v91's
// scoped-name gate: not the clone road, the reader keeps its vote) and the
// generate/interface homes repeat the two sharpest cells.
package q3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed        TSI = 16'd5;
  localparam unsigned      TUI = 16'd5;
  localparam        [11:0] TPD = 16'd6;
  localparam signed [11:0] TSD = 16'd6;
endpackage
import q3p::TSI;
module q3_pkgread94;
  localparam logic [7:0]         V1 = q3p::TSI;
  localparam logic signed [31:0] V2 = q3p::TUI;  // SIGNED reader, UNSIGNED pkg
  localparam logic signed [31:0] V3 = q3p::TPD;  // SIGNED reader, dim-only pkg
  localparam logic [3:0]         V4 = q3p::TSD;  // NARROW reader
  localparam logic [7:0]         V5 = q3p::TUI;
  localparam logic signed [7:0]  V6 = q3p::TSI;
  localparam logic [7:0]         V7 = TSI;       // the IMPORTED read
  localparam q3p::t A = '{bail: 8'hxA, a: V1, b: V2, c: V3, d: V4,
                          e: V5, f: V6, g: V7};
  q3_sink #(.R(A)) s1();
  if (1) begin : gb
    localparam logic [7:0]         G1 = q3p::TSI;
    localparam logic signed [31:0] G2 = q3p::TUI;
    localparam q3p::t B = '{bail: 8'hxA, a: G1, b: G2, c: G1, d: G2,
                            e: G1, f: G2, g: G1};
    q3_sink #(.R(B)) s2();
  end
  q3_ifc u_if();
endmodule
interface q3_ifc ();
  localparam logic [7:0]         I1 = q3p::TSD;
  localparam logic signed [31:0] I2 = q3p::TPD;
  localparam q3p::t C = '{bail: 8'hxA, a: I1, b: I2, c: I1, d: I2,
                          e: I1, f: I2, g: I1};
endinterface
module q3_sink #(parameter q3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
