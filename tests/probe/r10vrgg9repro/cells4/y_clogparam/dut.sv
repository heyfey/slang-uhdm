module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  localparam int W = 9;

  assign arr[0] = (P) ? $clog2(W) : 7;
endmodule
module top;
  m u_a();
endmodule
