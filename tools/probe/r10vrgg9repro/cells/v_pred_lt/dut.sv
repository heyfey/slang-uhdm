module m #(
  parameter int Q = 1
)();
  logic        sig;
  logic [7:0]  vec;
  logic [7:0]  arr[2];

  assign arr[0] = (Q < 3) ? 42 : 7;

endmodule
module top;
  m #(.Q(5)) u_a();
endmodule
