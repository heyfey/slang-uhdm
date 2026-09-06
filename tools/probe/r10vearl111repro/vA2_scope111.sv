// v111 adversarial arm A2 -- SCOPES THE IMPLEMENTER'S g3 LEFT OUT, and the
// INSTANCE-COUNT axis.  $unit-scope, interface-scope (read through a modport
// and inside the interface itself), program-scope, a module localparam whose
// value DEPENDS on an overridable parameter (so the three instances carry
// three different folded values), and a plain non-dotted select for contrast.
localparam int unsigned UNITW = 2;      // $unit / compilation-unit scope

package pk2v111;
  typedef struct packed { logic [63:0] src; logic v; } h_t;
endpackage

interface if2v111 (input logic clk);
  localparam int unsigned IFW = 2;
  pk2v111::h_t d;
  logic [63:0] q;
  // read INSIDE the interface
  assign q[1:0] = d.src[0 +: IFW];
  modport mp (input d, import f);
  function automatic int f(); return 0; endfunction
endinterface

module s2v111 #(parameter int M = 2)
               (input pk2v111::h_t h_i, if2v111 ifp, output logic [63:0] o);
  localparam int unsigned DEP = M;        // per-instance value
  localparam int unsigned CST = 2;
  logic [63:0] r;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[ 1: 0] = h_i.src[0 +: DEP];    // three different widths
    assign r[ 3: 2] = h_i.src[0 +: CST];
    assign r[ 5: 4] = h_i.src[0 +: UNITW];  // $unit-scope localparam
    assign r[ 7: 6] = ifp.d.src[0 +: CST];  // dotted through an interface port
    assign r[ 9: 8] = ifp.d.src[0 +: ifp.IFW]; // interface-scope parameter
  end
  assign o = r;
endmodule

module vA2_scope111;
  logic clk;
  pk2v111::h_t s;
  logic [63:0] o1, o2, o3;
  if2v111 ifi (.clk(clk));
  s2v111 #(.M(2)) u1 (.h_i(s), .ifp(ifi), .o(o1));
  s2v111 #(.M(3)) u2 (.h_i(s), .ifp(ifi), .o(o2));
  s2v111 #(.M(4)) u3 (.h_i(s), .ifp(ifi), .o(o3));
endmodule
