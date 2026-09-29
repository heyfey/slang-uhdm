// § hpVarSelRangeIdxNamesByPath220
module top(input logic [32:0] din, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  int i;
  assign s = din;
  initial begin
    i = 0;
    o = s.arr[i++][1:0];
  end
endmodule
