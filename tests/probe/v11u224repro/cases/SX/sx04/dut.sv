// § strLitPpEscIdShift224
module top(output string o, output int k);
  localparam string S = "a\nb` c"; localparam int K = 3;
  assign o = S;
  assign k = K;
endmodule
