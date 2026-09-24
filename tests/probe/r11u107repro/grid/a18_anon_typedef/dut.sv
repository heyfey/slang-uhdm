typedef struct packed { logic a; logic b; } [1:0] t_t;
module dut(input logic [3:0] i, output logic [3:0] o);
  t_t x;
  assign x = i;
  assign o = x;
endmodule
