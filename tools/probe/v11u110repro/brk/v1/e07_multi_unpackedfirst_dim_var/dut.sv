package pk;
  typedef logic [3:0] T;
  typedef T row_t;
  typedef struct packed { row_t [1:0][0:1] U; logic v; } S;
endpackage
module dut(input logic [40:0] a, output logic o);
  pk::S s;
  assign s = a;
  assign o = ^s.U[1][0];
endmodule
