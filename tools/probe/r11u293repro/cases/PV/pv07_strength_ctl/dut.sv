// § portViewNdaNetCellParent293
// CONTROL: a drive strength (no net and no cell in golden).
interface ifc ();
  wire [7:0] w = 8'd5;
  wire (strong1, weak0) [7:0] s = 8'd6;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
