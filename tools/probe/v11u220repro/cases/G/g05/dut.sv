// § hpVarSelRangeIdxNamesByPath220
module top(input logic [40:0] din, input logic [1:0] i, output logic [1:0] o);
  typedef struct packed { logic [3:0][7:0] b; logic v; } in_t;
  typedef struct packed { in_t a; logic [7:0] x; } out_t;
  out_t s;
  assign s = din;
  assign o = s.a.b[i][1:0];
endmodule
