// § hpSelRoute157
typedef struct packed { int W; int D; } cfg_t;
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}) (input logic [7:0] v, input logic [3:0] x, output logic [7:0] q [2]);
  for (genvar g = 0; g < 2; g++) begin : G
    localparam int L = Cfg.D * 2 + g;
    logic [Cfg.W-1:0] r;
    assign r = v[Cfg.W-1:0] ^ L;
    assign q[g] = Cfg.W'(x);
  end
endmodule
