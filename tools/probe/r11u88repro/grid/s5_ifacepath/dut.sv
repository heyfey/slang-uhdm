// r11u82 s5 -- the base in an INTERFACE instance, by a written path, and the
// same member by a simple name inside the interface.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

interface ifc;
  localparam p::cfg_t I_LOC = p::build(900);
  logic [31:0] i_simple; assign i_simple = I_LOC.n;       // simple, in the interface
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  logic [31:0] i_path; assign i_path = u_if.I_LOC.n;      // written path, into an interface
  assign o = u_if.i_simple ^ i_path;
endmodule
