typedef struct packed { logic [1:0] p; logic q; } e_t;
module dut(input logic [5:0] i, output logic [5:0] o);
  struct packed { e_t e; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
