// r11u161 alias face CONTROL: module alias of a package enum WITH an added packed dimension
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
module top(output logic [7:0] o);
  typedef lp::tx_e [1:0] arr_t;
  arr_t w;
  assign w = {lp::On, lp::On};
  assign o = w;
endmodule
