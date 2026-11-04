// § portExprElabDefNets146
module c(.a({b, e}));
  input b;
  input e;
endmodule
module top(input logic x, y, z);
  c c1(.a({x, y}));
  c c2(.a({y, z}));
endmodule
