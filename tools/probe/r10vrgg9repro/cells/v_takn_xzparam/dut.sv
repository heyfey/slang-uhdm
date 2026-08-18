module m #(
  parameter bit P = 0
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];
  localparam logic [3:0] XZ = 4'b10xz;

  assign arr[0] = (P) ? XZ : 42;

endmodule
module top;
  m #(.P(1)) u_a();
endmodule
