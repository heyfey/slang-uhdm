// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  localparam int K = 1;
  s_t [1:0] tq;
  assign tq = din;
  assign o = tq[0].pg[ix][K:K-1];
endmodule
