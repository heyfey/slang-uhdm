// § macroBodyTrailingComment125
`define W 4  // width
module top(output logic [`W-1:0] o, output logic [`W-1:0] q);
  logic [`W-1:0] x; logic [`W+`W-1:0] y;
  assign o = x;
  assign q = y[`W-1:0];
endmodule
