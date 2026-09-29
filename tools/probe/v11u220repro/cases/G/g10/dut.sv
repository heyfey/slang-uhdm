// § hpVarSelRangeIdxNamesByPath220
package p; localparam int K = 2; endpackage
module top(input logic [32:0] din, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s = din;
  assign o = s.arr[p::K][1:0];
endmodule
