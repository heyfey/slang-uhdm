// § portViewNdaNetCellParent293
// A scalar net with an initializer.
interface ifc ();
  wire w = 1'b1;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic o);
  assign o = p.w;
endmodule
module top (output logic o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
