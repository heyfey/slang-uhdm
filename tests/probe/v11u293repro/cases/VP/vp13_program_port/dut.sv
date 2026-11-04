// § portViewNdaNetCellParent293
// A program holding the modport port.
interface ifc ();
  wire [7:0] w = 8'd10;
  modport mp (input w);
endinterface
program prg (ifc.mp p);
  int n;
  initial n = p.w;
endprogram
module top;
  ifc u_if ();
  prg u_p (.p(u_if));
endmodule
