// v11u82 v1 -- LAW A BREAK: "a package-scoped name is NOT a written path" is
// what keeps the landed conversions' fold alive, so it is tested in the shapes
// the grid did not reach: inside a CHILD instance, inside an INTERFACE, and
// through a nested package qualification.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
  localparam cfg_t P_LOC = build(800);
endpackage

interface ifc (output logic [31:0] q);
  logic [31:0] i_pkg; assign i_pkg = p::P_LOC.n;      // package base in an interface
  assign q = i_pkg;
endinterface

module kid (output logic [31:0] q);
  import p::*;
  logic [31:0] k_pkg; assign k_pkg = p::P_LOC.n;      // package base in a child
  logic [31:0] k_imp; assign k_imp = P_LOC.n;         // wildcard-imported spelling
  assign q = k_pkg ^ k_imp;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] a, b;
  kid u1 (.q(a));
  ifc u_if (.q(b));
  assign o = a ^ b;
endmodule
