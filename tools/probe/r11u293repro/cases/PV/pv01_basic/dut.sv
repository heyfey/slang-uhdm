// § portViewNdaNetCellParent293
// A modport port view of a net declaration assignment.
interface ifc ();
  wire [31:0] w = 32'd11;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [31:0] o);
  assign o = p.w;
endmodule
module top (output logic [31:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
