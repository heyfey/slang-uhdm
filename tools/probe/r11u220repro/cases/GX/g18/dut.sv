// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, input logic [1:0] jx, output logic [1:0] o);
  typedef struct packed { logic [1:0][1:0][3:0] pg; logic v; } s_t;
  s_t tq;
  assign tq = din;
  assign o = tq.pg[ix][jx+1][2:1];
endmodule
