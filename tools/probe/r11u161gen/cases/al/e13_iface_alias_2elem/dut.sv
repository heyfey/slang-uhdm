// r11u161 alias face: interface alias of a package enum, two-element packed array read through the instance
package lp;
   typedef enum logic [1:0] { X = 2'd1, Y = 2'd2 } tx_e;
endpackage
interface bus_if;
  typedef lp::tx_e my_t;
  my_t [1:0] w;
endinterface
module top(output logic [3:0] o);
  bus_if b();
  assign b.w = {lp::X, lp::Y};
  assign o = b.w;
endmodule
