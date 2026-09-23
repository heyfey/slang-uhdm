module dut(input logic [3:0] i, output logic [3:0] o);
  struct packed { bit a; bit b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
