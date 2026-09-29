// § hpVarSelRangeIdxNamesByPath220 — a path's trailing var_select whose indices are a parameter and a function call, ending in a range
module top #(parameter int P = 1)(input logic [15:0] din, input logic k, output logic [1:0] o1, output logic [1:0] o2);
  typedef struct packed { logic [1:0][1:0][1:0] a; logic [7:0] b; } s_t;
  s_t s;
  assign s = din;
  function automatic int idx(input logic v); return v ? 1 : 0; endfunction
  assign o1 = s.a[P][0][1:0];
  assign o2 = s.a[idx(k)][P][1:0];
endmodule
