// v11u82 v2 -- LAW A BREAK: the base is reached through a PARAMETER CHAIN and
// the WRITTEN form is a path to an ALIAS whose own initializer is a simple
// name.  asmRefFamilyBase walks the hops; simpleBase82 reads only the first.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  localparam p::cfg_t M_LOC = p::build(600);
  localparam p::cfg_t B_ALIAS = M_LOC;                 // alias by SIMPLE name
  logic [31:0] a_simp; assign a_simp = B_ALIAS.n;      // simple name, aliased base
  logic [31:0] a_path; assign a_path = dut.B_ALIAS.n;  // PATH to the same alias
  assign o = a_simp ^ a_path;
endmodule
