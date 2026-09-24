module dut(input logic [63:0] i, output logic [63:0] o);
  struct packed { int a; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
