// § hpVarSelRangeIdxNamesByPath220
module top(input logic clk, input logic [32:0] din, input logic [1:0] i, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s = din;
  always_ff @(posedge clk) o <= s.arr[i][5:4];
endmodule
