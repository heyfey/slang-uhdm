// § hpSelRoute157
typedef struct packed { int W; int D; } cfg_t;
interface ifc #(parameter cfg_t Cfg = '{W: 6, D: 3}) ();
  logic [Cfg.W-1:0] v;
  logic [Cfg.D-1:0] w;
  localparam int K = Cfg.W - Cfg.D;
  assign w = v[Cfg.D-1:0] | Cfg.D'(K);
endinterface
module top; ifc #(.Cfg('{W: 10, D: 5})) u(); endmodule
