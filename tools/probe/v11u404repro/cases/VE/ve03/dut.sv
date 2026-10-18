// § unknownModWildcardConnPort404
module child (input clk, input [3:0] d, output [3:0] q);
  nosuch #(.W(4)) a (.*, .q());
  nosuch b (.clk(clk), .*);
endmodule
module top; endmodule
