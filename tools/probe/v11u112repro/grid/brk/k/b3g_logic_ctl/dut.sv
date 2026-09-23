module m(output logic [7:0] o);
  localparam type T = logic [7:0];
  localparam type E = enum logic [1:0] {A, B};
  T x;
  T [1:0] p;
  E e;
  assign x = '0; assign p = '0; assign e = A;
  assign o = x ^ p[1] ^ e;
endmodule
