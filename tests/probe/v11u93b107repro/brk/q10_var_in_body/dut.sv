module dut #(parameter type T = struct packed { logic [1:0] a; logic b; }) (input logic [2:0] i, output logic [2:0] o);
  T r;
  assign r = i;
  assign o = r;
endmodule
