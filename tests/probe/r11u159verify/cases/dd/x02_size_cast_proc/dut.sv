// § hierSizeCastBaseStructTs151
package pk;
  typedef struct packed { int unsigned W; } cfg_t;
  localparam cfg_t Base = '{W: 3};
endpackage
module top #(parameter pk::cfg_t Cfg = pk::Base) (input logic [7:0] a, output logic [7:0] o);
  always_comb o = 8'(Cfg.W'(a + 1));
endmodule
