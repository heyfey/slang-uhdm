module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign {vec[1],vec[0]} = (P) ? 2'b11 : 2'b00;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
