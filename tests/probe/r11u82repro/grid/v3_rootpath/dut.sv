// v11u82 v3 -- LAW A BREAK: the $root-rooted written path and a path written
// through the module's OWN instance name from the parent.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  localparam p::cfg_t M_LOC = p::build(600);
  logic [31:0] r_path; assign r_path = $root.dut.M_LOC.n;  // $root-rooted
  logic [31:0] r_own;  assign r_own  = M_LOC.n;            // control
  assign o = r_path ^ r_own;
endmodule
