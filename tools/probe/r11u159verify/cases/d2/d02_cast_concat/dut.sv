// § pkgTdCastTargetOwnView151
package p;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  localparam cfg_t E = cfg_t'({8'd3, 1'b0});
  function automatic cfg_t mk();
    cfg_t c;
    c.A = 8'd7;
    c.B = 1'b1;
    return c;
  endfunction
  localparam cfg_t D = mk();
endpackage
module top(output logic [8:0] o);
  assign o = p::D | p::E;
endmodule
