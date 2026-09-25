// § r11u161 alias face (from r11u159verify/cases/ea/e05_local_alias_import)
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
module top(output logic [3:0] o);
  import lp::*;
  typedef tx_e my_t;
  my_t [0:0] w;
  assign w[0] = On;
  assign o = w[0];
endmodule
