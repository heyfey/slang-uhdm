// § macroBodyTrailingComment125
`define S "a//b" // c
module top(output logic [7:0] o);
  string s = `S; logic [7:0] x;
  assign o = x;
endmodule
