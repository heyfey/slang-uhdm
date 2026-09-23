module dut(input logic [3:0] i, input logic c, output logic [3:0] o);
  struct packed { logic a; logic b; } [1:0] x, y;
  assign x = i;
  always_comb y = x;
  assign o = y;
endmodule
