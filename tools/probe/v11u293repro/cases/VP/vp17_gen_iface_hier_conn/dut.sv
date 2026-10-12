// § portViewNdaNetCellParent293
// The interface sits in a generate block and the module outside connects it by a hierarchical name.
interface ifc ();
  wire [7:0] w = 8'd6;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top (output logic [7:0] o);
  if (1) begin : g
    ifc u_if ();
  end
  sub u_s (.p(g.u_if), .o(o));
endmodule
