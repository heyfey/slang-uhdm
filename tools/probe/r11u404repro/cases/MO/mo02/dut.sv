// § macroArgParamOrder404
`define P(x) x = 1
module m #(parameter `P(a), parameter b = 2, parameter `P(c)) (output [a+b+c:0] o);
  assign o = '0;
endmodule
module top; m u(); endmodule
