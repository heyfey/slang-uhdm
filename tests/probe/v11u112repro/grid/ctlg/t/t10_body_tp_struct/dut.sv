module dut(input logic [4:0] i, output logic [4:0] o);
  parameter type T = struct packed { logic [3:0] a; logic b; };
  T v;
  assign v = i;
  assign o = v;
endmodule
