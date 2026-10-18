// § unknownModBitSelConnScope404
module child (input x, output y);
  wire [3:0] q;
  wire [3:0][1:0] m;
  integer i;
  nosuch s (.a(q[i]), .b(m[1][0]), .c(q[3:0]), .d(q[x]), .y(y));
endmodule
module top; endmodule
