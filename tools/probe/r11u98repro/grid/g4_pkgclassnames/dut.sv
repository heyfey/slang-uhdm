// r11u98 g4 -- the PACKAGE home, same two classes.
package pk;
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endpackage
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
