// § ppMacroBodyLines160
`define STR(x) `"x`"
`define MSG(tag, v) \
  initial $display({`STR(tag), ": %0d"}, \
                   v);
module top (input logic [3:0] a);
  `MSG(hello_tag, a)
  `MSG(  spaced_tag  , a + 1)
endmodule
