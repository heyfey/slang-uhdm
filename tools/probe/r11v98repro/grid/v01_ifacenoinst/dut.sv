// v01 -- an interface with a class that is NEVER instantiated.
interface ifc ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endinterface
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
