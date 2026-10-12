// § portViewNdaNetCellParent293
// A wand net with an initializer.
interface ifc ();
  wand [7:0] w = 8'hf0;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
