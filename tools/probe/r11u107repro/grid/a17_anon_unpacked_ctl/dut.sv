module dut(input logic [3:0] i, output logic [3:0] o);
  struct packed { logic a; logic b; } [1:0] x [2];
  assign x[0] = i;
  assign x[1] = i;
  assign o = x[0];
endmodule
