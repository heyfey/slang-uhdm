// § portViewNdaNetCellParent293
// A delayed net declaration assignment.
interface ifc ();
  wire [7:0] #2 w = 8'd5;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
