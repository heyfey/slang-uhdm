typedef struct packed { logic a; logic b; } ab_t;
module dut(input logic [3:0] i, output logic [3:0] o);
  ab_t [1:0] x;
  assign x = i;
  assign o = x;
endmodule
