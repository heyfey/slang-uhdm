// r11u85 a5 -- THE LIVE CORPUS SHAPE (`InterfaceAssign`): an interface body
// writing a literal with NO delay and NO strength.  LAW A must leave it
// byte-identical.
interface ifc ();
  logic [31:0] a;
  logic [31:0] b;
  assign a = 32'd77;
  assign b = 32'd78;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.a ^ u_if.b;
endmodule
