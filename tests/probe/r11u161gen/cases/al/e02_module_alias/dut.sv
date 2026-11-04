// § r11u161 alias face (from r11u159verify/cases/ea/e02_module_alias)
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
module top(output logic [3:0] o);
  typedef lp::tx_e my_t;
  my_t [0:0] w;
  assign w[0] = lp::On;
  assign o = w[0];
endmodule
