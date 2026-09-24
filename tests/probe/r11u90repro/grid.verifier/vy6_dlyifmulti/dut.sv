// v11u90 vy6 -- one interface, several cont_assigns, only ONE delayed by a
// parameter name: the clone must not disturb the others.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c, d, e;
  assign      c = 32'd10;
  assign #D   d = 32'd11;
  assign #3   e = 32'd12;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c ^ u_if.d ^ u_if.e;
endmodule
