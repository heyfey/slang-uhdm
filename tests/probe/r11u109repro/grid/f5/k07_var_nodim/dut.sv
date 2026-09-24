module dut(input logic [1:0] i, output logic [1:0] o);
  var struct packed { logic a; logic b; } x;
  assign x = i;
  assign o = x;
endmodule
