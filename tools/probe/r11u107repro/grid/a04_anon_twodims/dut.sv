module dut(input logic [11:0] i, output logic [11:0] o);
  struct packed { logic a; logic b; } [1:0][2:0] x;
  assign x = i;
  assign o = x;
endmodule
