module dut(input logic [5:0] i, output logic [5:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  struct packed { e_t e; logic b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
