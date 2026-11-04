// § strLitContLineSpan220
module top(output string o, input logic [1:0] k);
  always_comb case (k)
    0: o = "abc \
def";
    default: o = "g";
  endcase
endmodule
