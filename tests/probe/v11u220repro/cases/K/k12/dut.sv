// § strLitContLineSpan220
module top(input string s, output int o);
  always_comb case (s)
    "ab\
cd": o = 1;
    default: o = 0;
  endcase
endmodule
