// v11u82 v5 -- LAW A BREAK: the base reached through an INTERFACE PORT from
// inside the child, and through the interface instance from the parent.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

interface ifc;
  localparam p::cfg_t I_LOC = p::build(900);
endinterface

module kid (ifc ip, output logic [31:0] q);
  logic [31:0] p_path; assign p_path = ip.I_LOC.n;    // through an interface PORT
  assign q = p_path;
endmodule

module dut (output logic [31:0] o);
  ifc u_if ();
  logic [31:0] w;
  kid u1 (.ip(u_if), .q(w));
  assign o = w;
endmodule
