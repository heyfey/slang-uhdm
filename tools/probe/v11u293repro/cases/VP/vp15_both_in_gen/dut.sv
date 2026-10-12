// § portViewNdaNetCellParent293
// The interface and the module using its modport both sit in a generate block.
interface ifc ();
  wire [7:0] w = 8'd3;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  if (1) begin : g
    ifc u_if ();
    sub u_s (.p(u_if), .o(o));
  end
endmodule
