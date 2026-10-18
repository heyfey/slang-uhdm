// § unknownModWildcardConnPort404
module child (input clk_i, input [3:0] d_i, output [3:0] q_o);
  nosuch_synth synth
    (.*);
  nosuch2 s2 (.clk_i, .*);
endmodule
module top; endmodule
