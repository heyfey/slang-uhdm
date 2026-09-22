// r11u90 u1 -- LAW A: a strength-decorated net declaration with NO initializer.
interface ifc ();
  wire [31:0] w_plain;
  wire (strong1, weak0) [31:0] w_ni;
  assign w_plain = 32'd11;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_plain;
endmodule
