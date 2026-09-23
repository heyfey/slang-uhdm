module dut(input logic [7:0] i, output logic [7:0] o);
  struct packed { logic a; logic b; } [1:0][1:0] x;
  assign x = i;
  assign o = x;
endmodule
