// § ppOutputCol166
`define MSG(s) s
module top;
  initial $display(`MSG("a,(b)"), 1);
endmodule
