module dut(input logic [5:0] i, output logic [5:0] o);
  struct packed { logic signed [1:0] a; logic b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
