// r11u90 u6 -- LAW A: a comma list under ONE strength.
interface ifc ();
  wire (strong1, weak0) [31:0] a = 32'd1, b = 32'd2;
  wire [31:0] c = 32'd3;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
