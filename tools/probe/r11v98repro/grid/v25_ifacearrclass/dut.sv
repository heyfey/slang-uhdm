// v25 -- an interface ARRAY instance whose interface holds a class.
interface ifc ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endinterface
module dut (output logic [31:0] o);
  ifc u_i [0:1] ();
  assign o = 32'd0;
endmodule
