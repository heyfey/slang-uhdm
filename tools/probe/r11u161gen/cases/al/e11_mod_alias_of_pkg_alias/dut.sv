// r11u161 alias face: module alias of a package alias of an enum (chain)
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
   typedef tx_e tx_t;
endpackage
module top(output logic [3:0] o);
  typedef lp::tx_t my_t;
  my_t [0:0] w;
  assign w[0] = lp::On;
  assign o = w[0];
endmodule
