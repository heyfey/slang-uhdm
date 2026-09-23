module dut(input logic [1:0] i, output logic [1:0] o);
  struct packed { logic a; logic b; } x;
  always_comb x = i;
  assign o = x;
endmodule
