package pk;
  typedef logic T;
  typedef T row_t;
  typedef struct packed { row_t [1:0][0:1] U; logic v; } S;
endpackage
module dut(input pk::S s, output logic o);
  assign o = ^s;
endmodule
