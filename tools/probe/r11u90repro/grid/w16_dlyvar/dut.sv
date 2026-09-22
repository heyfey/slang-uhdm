// r11u90 w16 -- LAW B where the delay NAME is not a parameter at all.
interface ifc ();
  logic [31:0] dv;
  logic [31:0] c;
  assign #dv c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
