// § macroBodyTrailingComment125
`define INC(x) x + 1   // add one
module top(input logic [3:0] a, output logic [3:0] o, p);
  assign o = `INC(a); assign p = a;
endmodule
