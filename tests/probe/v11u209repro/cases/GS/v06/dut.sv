// § genConnTrailSelChain205: a hierarchical path to a child signal with a genvar bit select in a for-generate instance
module leaf(input logic [3:0] i);
  logic [3:0] s;
  assign s = i;
endmodule
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input logic [3:0] x, output logic [3:0] o);
  leaf l (.i(x));
  for (genvar k = 0; k < 4; k++) begin : g
    sub u(.i(l.s[k]), .o(o[k]));
  end
endmodule
