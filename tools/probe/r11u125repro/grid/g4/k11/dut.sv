// § macroBodyTrailingComment125
`define A 2 // x
`define B (`A+1)   // y
module top(output logic [`B:0] o);
  logic [`B:0] x; logic z;
  assign o = x;
endmodule
