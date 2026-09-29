// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign s.arr[0] = '0;
  assign s.arr[1][1:0] = d;
  assign o = s;
endmodule
