module child #(parameter type T = struct packed { logic [3:0] a; logic b; }) (input T i, output T o);
  assign o = i;
endmodule
module dut(input logic [5:0] i, output logic [5:0] o);
  child #(.T(logic [5:0])) u(.i(i), .o(o));
endmodule
