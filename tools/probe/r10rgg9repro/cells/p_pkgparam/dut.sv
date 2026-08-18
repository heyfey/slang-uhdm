package pk;
  parameter bit PP = 0;
endpackage
module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (pk::PP) ? {2{sig}} : '0;

endmodule
module top;
  m u_a();
endmodule
