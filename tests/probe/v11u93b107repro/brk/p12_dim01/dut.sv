module dut(input logic [5:0] i, output logic [5:0] o);
  struct packed { logic a; logic b; } [0:2] x;
  assign x = i;
  assign o = x;
endmodule
