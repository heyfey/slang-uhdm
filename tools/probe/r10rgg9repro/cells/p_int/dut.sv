module m #(
  parameter int PI = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (PI) ? {2{sig}} : '0;

endmodule
module top;
  m #(.PI(0)) u_a();
endmodule
