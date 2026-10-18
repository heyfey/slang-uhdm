// § unknownModBitSelConnScope404
module child (input x, output y);
  wire [3:0] q;
  wire [7:0] r;
  nosuch s (.a(x), .b(), .c(y), .d(q[1]), .e(r[3:0]), .f({x,y}), .g(q[2+:2]), .h(~x));
  nosuch2 s2 (x, , q[0]);
endmodule
module top; endmodule
