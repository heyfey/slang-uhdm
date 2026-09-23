module dut(input logic [3:0] i, input logic c, output logic [3:0] o);
  wire struct packed { logic a; logic b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
