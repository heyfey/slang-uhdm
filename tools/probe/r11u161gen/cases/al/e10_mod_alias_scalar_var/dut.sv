// r11u161 alias face: module alias of a package enum typing a scalar variable
package lp;
   typedef enum logic [3:0] { On = 4'b1010, Off = 4'b0101 } tx_e;
endpackage
module top(output logic [3:0] o);
  typedef lp::tx_e my_t;
  my_t v;
  assign v = lp::Off;
  assign o = v;
endmodule
