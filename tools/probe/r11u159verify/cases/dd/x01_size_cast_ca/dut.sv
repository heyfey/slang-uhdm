// § hierSizeCastBaseStructTs151
package pk;
  typedef struct packed { int unsigned W; } cfg_t;
  function automatic cfg_t build(int unsigned w);
    cfg_t r;
    r.W = w;
    return r;
  endfunction
endpackage
module top #(parameter pk::cfg_t Cfg = pk::build(6)) (input logic [7:0] a, output logic [7:0] o);
  assign o = 8'(Cfg.W'(a));
endmodule
