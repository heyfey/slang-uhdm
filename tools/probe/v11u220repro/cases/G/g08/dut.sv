// § hpVarSelRangeIdxNamesByPath220
module top(input logic [32:0] din, input logic [1:0] i, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  function automatic logic [1:0] f(input logic [1:0] a); return ~a; endfunction
  assign s = din;
  assign o = f(s.arr[i][1:0]);
endmodule
