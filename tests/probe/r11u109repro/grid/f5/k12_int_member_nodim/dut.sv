module dut(input logic [31:0] i, output logic [31:0] o);
  struct packed { int a; } x;
  assign x = i;
  assign o = x;
endmodule
