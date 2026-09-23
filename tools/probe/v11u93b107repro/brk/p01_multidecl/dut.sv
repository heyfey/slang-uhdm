module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] o2);
  struct packed { logic a; logic b; } [1:0] x, y;
  assign x = i;
  assign y = ~i;
  assign o = x;
  assign o2 = y;
endmodule
