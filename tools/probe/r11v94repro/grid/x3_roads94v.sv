// r11v94 BREAK arm x3 — the READ ROADS for both laws.  The same kind-2
// package hop and the same negative package parameter read from a MODULE
// localparam, a GENERATE block, an INTERFACE, a CLASS in a package, a
// FUNCTION body, a port connection and a net-decl-assign, plus the IMPORTED
// (bare) read that r11v91's verified gate must keep on the reader's vote.
package x3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed       DSI = 16'd5;
  localparam unsigned     DUI = 16'd5;
  localparam logic [7:0]  DNU = -3;
  localparam int          DSB = 8 - 1;
endpackage
import x3p::DSI;
import x3p::DNU;
module x3_roads94v (output logic [63:0] o);
  localparam logic [7:0]         E1 = x3p::DSI;
  localparam logic signed [31:0] E2 = x3p::DUI;
  localparam logic [7:0]         E3 = DSI;
  wire signed [31:0] wDNU = x3p::DNU;
  wire signed [31:0] wDNB = DNU;
  wire signed [31:0] wDSB = x3p::DSB;
  function automatic int f3();
    int l = x3p::DSB;
    return l + x3p::DNU;
  endfunction
  localparam int E4 = f3();
  localparam x3p::t A = '{bail: 8'hxA, a: E1, b: E2, c: E3, d: E4,
                          e: E1, f: E2, g: E3};
  x3_sink #(.R(A)) s1();
  if (1) begin : gb
    localparam logic [7:0]         F1 = x3p::DSI;
    localparam logic signed [31:0] F2 = x3p::DUI;
    wire signed [31:0] wF3 = x3p::DNU;
    localparam x3p::t B = '{bail: 8'hxA, a: F1, b: F2, c: F1, d: F2,
                            e: F1, f: F2, g: F1};
    x3_sink #(.R(B)) s2();
  end
  x3_ifc u_if();
  assign o = {wDNU, wDNB} ^ {wDSB, wDSB};
endmodule
interface x3_ifc ();
  localparam logic [7:0]         H1 = x3p::DSI;
  localparam logic signed [31:0] H2 = x3p::DUI;
  wire signed [31:0] wH3 = x3p::DNU;
  localparam x3p::t C = '{bail: 8'hxA, a: H1, b: H2, c: H1, d: H2,
                          e: H1, f: H2, g: H1};
endinterface
module x3_sink #(parameter x3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
