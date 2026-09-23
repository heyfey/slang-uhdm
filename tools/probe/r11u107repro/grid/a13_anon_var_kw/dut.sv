module dut(input logic [3:0] i, output logic [3:0] o);
  var struct packed { logic a; logic b; } [1:0] x;
  assign x = i;
  assign o = x;
endmodule
