module dut(input logic [3:0] i, output logic [3:0] o);
  var struct packed { logic a; logic b; } [1:0] x, y;
  assign x = i;
  assign y = x;
  assign o = y;
endmodule
