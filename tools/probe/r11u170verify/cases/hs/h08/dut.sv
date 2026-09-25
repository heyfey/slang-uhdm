// § hpSelRoute157
package pk;
  typedef struct packed { int W; int D; } cfg_t;
  parameter cfg_t Cfg = '{W: 8, D: 2};
  localparam int P = Cfg.W + Cfg.D;
  typedef logic [Cfg.W-1:0] word_t;
endpackage
module top (input pk::word_t a, output logic [pk::P-1:0] o);
  assign o = pk::P'(a[pk::Cfg.D-1:0]);
endmodule
