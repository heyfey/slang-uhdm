// § r11u161 alias face (from r11u159verify/cases/ea/e08_iface_alias)
package lp;
   typedef enum logic [3:0] { On = 4'b1010 } tx_e;
endpackage
interface bus_if;
  typedef lp::tx_e my_t;
  my_t [0:0] w;
endinterface
module top(output logic [3:0] o);
  bus_if b();
  assign b.w[0] = lp::On;
  assign o = b.w[0];
endmodule
