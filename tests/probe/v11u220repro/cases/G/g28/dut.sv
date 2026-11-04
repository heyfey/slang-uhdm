// § hpVarSelRangeIdxNamesByPath220
module sub(output logic [1:0] q); assign q = 2'd1; endmodule
module top(input logic [32:0] din, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  sub u(.q(imp));
  assign s = din;
  assign o = s.arr[imp][1:0];
endmodule
