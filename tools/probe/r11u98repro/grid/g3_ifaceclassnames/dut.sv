// r11u98 g3 -- the INTERFACE home, same two classes, no generate.
interface ifc ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
