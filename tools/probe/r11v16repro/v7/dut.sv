// v7 — the reading SITES around the explicit cont_assign loop: a generate-for
// body, a generate-if body, an interface body, a net-declaration assign, and a
// child instance, all reading the same member of the same assembled parameter.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 4;
    c.base = 64'h2000;
    return c;
  endfunction
endpackage

interface ifc ();
  localparam p::cfg_t IC = p::build();
  wire [31:0] o_if;
  assign o_if = IC.n;
endinterface

module dut (output wire [31:0] o_nda, o_gi);
  localparam p::cfg_t CFG = p::build();
  wire [31:0] w_nda = CFG.n;
  assign o_nda = w_nda;
  if (1) begin : gi
    wire [31:0] gw;
    assign gw = CFG.n;
  end
  assign o_gi = gi.gw;
  for (genvar k = 0; k < 2; k++) begin : gf
    wire [31:0] gfw;
    assign gfw = CFG.n;
  end
  ifc u_if ();
endmodule
