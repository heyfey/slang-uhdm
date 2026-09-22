// r11u90 w15 -- LAW B with TWO instances of the same interface.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_a ();
  ifc u_b ();
  assign o = u_a.c ^ u_b.c;
endmodule
