// § macroBodyTrailingComment125
`define S "a//b"  // str
module top(input logic [3:0] a, output logic [3:0] o);
  initial $display(`S); assign o = a;
endmodule
