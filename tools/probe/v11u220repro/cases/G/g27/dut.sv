// § hpVarSelRangeIdxNamesByPath220
module top(input logic [32:0] din, input logic [1:0] i, input logic [3:0] q, output logic o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s = din;
  assign o = q[s.arr[s.arr[i][1:0]][1:0]];
endmodule
