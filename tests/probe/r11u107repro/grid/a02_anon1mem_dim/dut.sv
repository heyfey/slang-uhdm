module dut(input logic [1:0] i, output logic [1:0] o);
  struct packed { logic a; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
