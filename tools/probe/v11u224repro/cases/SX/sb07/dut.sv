// § strLitPpEscIdShift224
`define L localparam string S = "a\nb` c";
module top(output string o, output int k);
  `L localparam int K = 2;
  assign o = S;
  assign k = K;
endmodule
