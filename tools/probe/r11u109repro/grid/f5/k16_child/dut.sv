module ch(input logic [3:0] i, output logic [3:0] o);
  struct packed { logic a; logic b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
module dut(input logic [3:0] i, input logic c, output logic [3:0] o);
  ch u(.i(i), .o(o));
endmodule
