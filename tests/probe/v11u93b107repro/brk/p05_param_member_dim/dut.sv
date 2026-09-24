module dut #(parameter int W = 3, parameter int N = 2) (input logic [W*N+N-1:0] i, output logic [W*N+N-1:0] o);
  struct packed { logic [W-1:0] a; logic b; } [N-1:0] x;
  assign x = i;
  assign o = x;
endmodule
