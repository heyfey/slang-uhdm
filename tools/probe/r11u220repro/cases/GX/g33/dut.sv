// § hpVarSelRangeIdxNamesByPath220
module sub(output logic q); assign q = 1; endmodule
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  sub u(.q(imp));
  assign tq = din;
  assign o = tq[0].pg[ix+imp][1:0];
endmodule
