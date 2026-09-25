// r11u161 alias face: module alias of a package enum whose base width is a package parameter
package lp;
   localparam int W = 3;
   typedef enum logic [W-1:0] { On = 3'd5 } tx_e;
endpackage
module top(output logic [2:0] o);
  typedef lp::tx_e my_t;
  my_t [0:0] w;
  assign w[0] = lp::On;
  assign o = w[0];
endmodule
