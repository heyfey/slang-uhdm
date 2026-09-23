package pk;
  typedef struct packed {
    struct packed { logic a; logic b; } [1:0] m;
  } t_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::t_t x;
  assign x = i;
  assign o = x;
endmodule
