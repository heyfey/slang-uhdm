package pk;
  typedef logic [3:0] T;
  typedef T row_t;
  typedef struct packed { row_t [1:0][0:1] U; row_t [2:0][1:0] V; row_t W; } S;
endpackage
module dut(input pk::S s, output logic o);
  assign o = ^s;
endmodule
