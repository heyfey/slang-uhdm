// r11u90 w10 -- LAW B: a PACKAGE-qualified parameter delay.
package pk;
  parameter int PD = 7;
endpackage
interface ifc ();
  logic [31:0] c;
  assign #pk::PD c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
