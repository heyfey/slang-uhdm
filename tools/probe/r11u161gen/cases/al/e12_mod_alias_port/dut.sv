// r11u161 alias face: $unit alias of a package enum typing a port
package lp;
   typedef enum logic [2:0] { A = 3'd1, B = 3'd6 } tx_e;
endpackage
typedef lp::tx_e my_t;
module top(input my_t i, output logic [2:0] o);
  assign o = i;
endmodule
