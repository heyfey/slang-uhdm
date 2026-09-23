package pk; typedef struct packed { logic [3:0] d; logic e; } s_t; endpackage
module dut #(parameter type T = pk::s_t) (input T i [1:0], output T o [1:0]);
  assign o = i;
endmodule
