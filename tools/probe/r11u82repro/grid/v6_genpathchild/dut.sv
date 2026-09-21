// v11u82 v6 -- LAW A BREAK: from INSIDE a generate scope, a written path into
// a CHILD instance and into an INTERFACE, beside the simple-name control that
// the landed conversions ride.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module kid (output logic [31:0] q);
  localparam p::cfg_t K_LOC = p::build(700);
  assign q = 32'd0;
endmodule

interface ifc;
  localparam p::cfg_t I_LOC = p::build(900);
endinterface

module dut (output logic [31:0] o);
  localparam p::cfg_t M_LOC = p::build(600);
  logic [31:0] w;
  kid u1 (.q(w));
  ifc u_if ();
  if (1) begin : G1
    logic [31:0] g_kid;  assign g_kid  = u1.K_LOC.n;    // gen scope -> child path
    logic [31:0] g_if;   assign g_if   = u_if.I_LOC.n;  // gen scope -> interface path
    logic [31:0] g_own;  assign g_own  = M_LOC.n;       // simple-name control
  end
  assign o = w ^ G1.g_kid ^ G1.g_if ^ G1.g_own;
endmodule
