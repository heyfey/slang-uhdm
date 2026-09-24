module dut #(parameter type T = struct packed { logic [3:0] a; logic b; }) (input logic [4:0] i, output logic [4:0] o);
  assign o = i;
endmodule
