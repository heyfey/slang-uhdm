module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];

  assign arr[0] = (P) ? $left(vec) : 7;
endmodule
module top;
  m u_a();
endmodule
