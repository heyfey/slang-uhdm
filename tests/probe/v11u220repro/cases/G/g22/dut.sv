// § hpVarSelRangeIdxNamesByPath220
module top(input logic [32:0] din, input logic [1:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  wire [1:0] w = s.arr[i][1:0];
  assign s = din;
  assign o = {w, s.arr[i][7:6]};
endmodule
