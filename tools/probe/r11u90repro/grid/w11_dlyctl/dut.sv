// r11u90 w11 -- the CONTROLS: a literal delay and a real delay, both already
// golden's constants.
interface ifc ();
  logic [31:0] c1;
  logic [31:0] c2;
  assign #3 c1 = 32'd10;
  assign #1.5 c2 = 32'd11;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c1 ^ u_if.c2;
endmodule
