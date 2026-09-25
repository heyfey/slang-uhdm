// § pkgTdCastTargetOwnView151
package q;
  typedef struct packed { logic [3:0] A; } cfg_t;
  localparam cfg_t E = cfg_t'(0);
endpackage
package p;
  import q::*;
  typedef struct packed { logic [7:0] A; logic B; } pcfg_t;
  localparam pcfg_t E2 = pcfg_t'(1);
  function automatic pcfg_t mk();
    pcfg_t c;
    c.A = 8'd2;
    c.B = 1'b1;
    return c;
  endfunction
  localparam pcfg_t D = mk();
endpackage
module top(output logic [8:0] o);
  assign o = p::D ^ p::E2 ^ q::E;
endmodule
