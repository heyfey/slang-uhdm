module dut #(
    parameter type A = struct packed { logic [31:0] a; logic [15:0] b; logic c; },
    parameter type B = A
) (input logic clk_i, input B i, output B o);
  assign o = i;
endmodule
