// § portViewNdaNetCellParent293
// A plain net beside the assigned one.
interface ifc ();
  wire [7:0] w = 8'd5;
  wire [7:0] x;
  assign x = 8'd6;
  modport mp (input w, input x);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w ^ p.x;
endmodule
module top (output logic [7:0] o);
  ifc u_if ();
  sub u_s (.p(u_if), .o(o));
endmodule
