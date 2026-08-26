// r10earl97 g3 -- HOME GRID.  The SAME cast-width shape (a COMPUTED-default
// typed localparam used as a bare `P'(x)` width) reached from a package, a
// module, a submodule, a GENERATE scope, an interface and THREE instances of
// one definition -- the cast-site copy is per-home, so the law must move every
// home or none.
package p3h97;
  parameter int PBASE = 8;
  parameter int PW    = $clog2(PBASE + 1);
endpackage
interface if3h97;
  localparam int IBASE = 8;
  localparam int IW    = $clog2(IBASE + 1);
  logic [3:0]  mm;
  logic [31:0] oo;
  assign oo = 32'(IW'(mm));
endinterface
module top3h97;
  import p3h97::*;
  logic [31:0] a, b, c, d, e;
  logic [3:0]  m;
  if3h97 u_if();
  sub3h97 #(.InW(8)) u_s1(.o(a));
  sub3h97 #(.InW(8)) u_s2(.o(b));
  sub3h97 #(.InW(8)) u_s3(.o(c));
  gen3h97 #(.InW(8)) u_g(.o(d));
  assign e = 32'(PW'(m));
endmodule
module sub3h97 #(parameter int InW = 32) (output logic [31:0] o);
  localparam int SW = $clog2(InW + 1);
  logic [3:0] m;
  assign o = 32'(SW'(m));
endmodule
module gen3h97 #(parameter int InW = 32) (output logic [31:0] o);
  logic [3:0] m;
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    localparam int GW = $clog2(InW + 1);
    logic [31:0] w;
    assign w = 32'(GW'(m));
  end
  assign o = gb[0].w ^ gb[1].w;
endmodule
