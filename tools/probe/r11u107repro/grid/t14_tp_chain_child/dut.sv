module child #(
    parameter type A = struct packed { logic [3:0] a; logic b; },
    parameter type B = A
) (input B i, output B o);
  assign o = i;
endmodule
module dut(input logic [4:0] i, output logic [4:0] o);
  child u(.i(i), .o(o));
endmodule
