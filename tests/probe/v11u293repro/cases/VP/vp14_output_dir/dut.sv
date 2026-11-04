// § portViewNdaNetCellParent293
// An output modport direction on the net.
interface ifc ();
  wire [7:0] w = 8'd11;
  modport mp (output w);
endinterface
module sub (ifc.mp p);
endmodule
module top;
  ifc u_if ();
  sub u_s (.p(u_if));
endmodule
