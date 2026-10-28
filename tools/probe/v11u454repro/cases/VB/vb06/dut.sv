// § unpackedDimBasedLitKept454
module top;
  parameter int P [2'd1:0] = '{1, 2};
  localparam logic [3:0] Q [1'b1:1'b0] = '{4'h1, 4'h2};
  int x;
  initial x = P[0] + Q[1];
endmodule
