// § portViewNdaNetCellParent293
// A modport expression port naming the net.
interface ifc ();
  wire [7:0] w = 8'd6;
  modport mp (input .a(w));
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.a;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
