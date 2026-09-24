package pk; typedef struct packed { logic [3:0] d; logic e; } s_t; endpackage
module dut #(parameter type B = pk::s_t, parameter type T = B, parameter int N = 2) (input T i [N-1:0], output T o [N-1:0]);
  assign o = i;
endmodule
