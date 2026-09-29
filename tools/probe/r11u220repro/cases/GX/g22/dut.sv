// § hpVarSelRangeIdxNamesByPath220
package pk; localparam int K = 1; endpackage
module top(input logic [41:0] din, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  assign tq = din;
  assign o = tq[0].pg[pk::K+0][1:0];
endmodule
