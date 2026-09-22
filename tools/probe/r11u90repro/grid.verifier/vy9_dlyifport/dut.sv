// v11u90 vy9 -- the interface carrying the delay-ref cell is passed as a
// PORT: extra elaborated views of the same cell.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  modport mp (input c);
endinterface
module sub (ifc.mp p, output logic [31:0] o);
  assign o = p.c;
endmodule
module dut (output logic [31:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
