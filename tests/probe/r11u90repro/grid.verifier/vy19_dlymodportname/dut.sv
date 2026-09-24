// v11u90 vy19 -- a MODPORT and the delay parameter share a name-space in the
// interface body; the delay names the parameter.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  modport mp (input c);
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
