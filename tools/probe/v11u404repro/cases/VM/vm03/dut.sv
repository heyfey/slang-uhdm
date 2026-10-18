// § macroArgParamOrder404
`define PRM(n) parameter n = 4
`define PORT(n) input n
module m #(`PRM(c), parameter b = 2, `PRM(a)) (`PORT(z), input y, `PORT(x));
  initial $display(a, b, c, x, y, z);
endmodule
module top; m u(.x(1'b0), .y(1'b0), .z(1'b0)); endmodule
