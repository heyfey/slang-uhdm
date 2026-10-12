// § portViewNdaNetCellParent293
// The module using the modport sits in a generate block.
interface ifc ();
  wire [7:0] w = 8'd3;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  if (1) begin : g
    sub u_s (.p(u_if), .o(o));
  end
endmodule
