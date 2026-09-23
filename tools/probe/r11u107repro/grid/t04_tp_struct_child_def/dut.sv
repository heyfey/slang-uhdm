module child #(parameter type T = struct packed { logic [3:0] a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
module dut(input logic [4:0] i, output logic [4:0] o);
  child u(.i(i), .o(o));
endmodule
