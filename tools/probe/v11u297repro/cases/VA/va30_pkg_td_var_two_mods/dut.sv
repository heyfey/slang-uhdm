// § varDeclInitMovesSharedTsEnd297
package p; typedef enum logic [1:0] { A, B, C } e_t; endpackage
module m1(output logic [1:0] o); import p::*; var e_t x = B; assign o = x; endmodule
module m2(output logic [1:0] o); var p::e_t y = p::C; assign o = y; endmodule
module dut(output logic [1:0] o, q);
  m1 u1(.o(o));
  m2 u2(.o(q));
endmodule
