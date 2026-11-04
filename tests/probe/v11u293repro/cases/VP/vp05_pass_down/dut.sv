// § portViewNdaNetCellParent293
// The modport port passed down to a child.
interface ifc ();
  wire [7:0] w = 8'd4;
  modport mp (input w);
endinterface
module leaf (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module sub (ifc.mp p, output logic [7:0] o);
  leaf u_l (.p(p), .o(o));
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
