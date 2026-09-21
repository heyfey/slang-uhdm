// r11u82 s3 -- a PACKAGE-level base, by the package-scoped name and through a
// module-level alias, module level and inside a generate scope.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
  localparam cfg_t P_LOC = build(800);
endpackage

module dut (output logic [31:0] o);
  import p::*;
  localparam p::cfg_t A_LOC = p::build(816);
  logic [31:0] q_pkg;  assign q_pkg  = p::P_LOC.n;        // package-scoped base
  logic [31:0] q_imp;  assign q_imp  = P_LOC.n;           // the same, wildcard-imported
  logic [31:0] q_loc;  assign q_loc  = A_LOC.n;           // module-own control
  if (1) begin : G1
    logic [31:0] g_pkg; assign g_pkg = p::P_LOC.n;        // package base from a gen scope
    logic [31:0] g_loc; assign g_loc = A_LOC.n;           // module base, simple, gen scope
  end
  assign o = q_pkg ^ q_imp ^ q_loc ^ G1.g_pkg ^ G1.g_loc;
endmodule
