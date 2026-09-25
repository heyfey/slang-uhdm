// r11u161 alias face: two module aliases of the same package enum
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
module top(output logic [7:0] o);
  typedef lp::tx_e a_t;
  typedef lp::tx_e b_t;
  a_t [0:0] u;
  b_t [0:0] v;
  assign u[0] = lp::On;
  assign v[0] = lp::On;
  assign o = {u, v};
endmodule
